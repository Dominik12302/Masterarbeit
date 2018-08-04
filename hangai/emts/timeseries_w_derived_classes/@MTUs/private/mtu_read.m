function obj = mtu_read(obj, pathname)
    obj.source = {pathname};
    % data files
    mseedfiles = dir(fullfile(pathname, '*.mseed*'));
    % header file
    hdrfiles = dir(fullfile(pathname,'configuration.inf'));
    hdrfiles = hdrfiles(1);
    % recorder.ini file
    inifiles = dir(fullfile(pathname,'recorder.ini'));
    inifiles = inifiles(1);
    % gps files
    gpsfiles = dir(fullfile(pathname, '*.gps'));
    gpsfiles = gpsfiles(min([max([1,round(mean(numel(gpsfiles)))]),numel(gpsfiles)]));

    obj.inffiles = {hdrfiles(1).name};
    obj.gpsfiles = {gpsfiles(1).name};
    obj.inifiles = {inifiles(1).name};   
    
    if isempty(mseedfiles)
        if obj.debuglevel == 2, disp('** Warning, no mseed-files found'); end
    else
        if obj.debuglevel, disp(['   found ' num2str(numel(mseedfiles)) ' data files']); end
        Nfiles = numel(mseedfiles);

        obj.system = 'MTU';
        
        % identify time (number) and channel from filenames
        number = [];
        channel = cell(Nfiles,1);
        for ind = 1 : Nfiles            
            number = [number; str2double(mseedfiles(ind).name(4:15))];
            dots = strfind(mseedfiles(ind).name,'.');
            channel{ind} = mseedfiles(ind).name(dots(1)+1:dots(2)-1);
        end
        % sort files after time
        [dummy, neworder] = sortrows(number);
        mseedfiles = mseedfiles(neworder);
        channel = channel(neworder);                

        % find channels present
        uch = unique(channel);
        nch = numel(uch);
        
        % reshape into N x ch matrix
        mseedfiles = reshape(mseedfiles,nch,Nfiles/nch)';
        channel = reshape(channel, nch,Nfiles/nch)';
        
        % make sure that channel order is the same for all times
        for ind = 1 : size(mseedfiles,1)
            [channel(ind,:), order] = sort(channel(ind,:));
            mseedfiles(ind,:) = mseedfiles(ind,order);
        end

        % store mseed filenames in N x ch - cell-array 
        for ind = 1 : size(mseedfiles,1)
            for ind2 = 1 : size(mseedfiles,2)
                obj.mseedfiles{ind,ind2} = mseedfiles(ind,ind2).name;
            end
        end
        obj.Nch = nch;
        obj.Nfiles = [size(obj.mseedfiles)];

        % read gps file
        [obj.lat, obj.lon] = read_gps_file(fullfile(pathname,gpsfiles(1).name));

        % read configuration.inf
        header = read_inf(fullfile(pathname,hdrfiles(1).name));

        % read recorder.ini
        ini = read_rec_ini(fullfile(pathname,inifiles(1).name));
        
        % least significant bit
        obj.lsb =  ones(1,nch)*1e-6; % hard coded, 1 microVolt/bit

        % allocate some memory
        Nsmp_mat = zeros(size(mseedfiles));            
        
        % loop over channels
        obj.srate = [];
        for ind = 1 : nch
            
            fprintf(['Reading channel ',num2str(ind),':']);
            
            % find out what component we are dealing with
            chtype = unique(channel(:,ind));
            if numel(chtype) > 1
                error('ill-defined channel found');
            end
            chtype = chtype{1};                    
            switch chtype
                case 'hx'
                    obj.chnames{ind} = 'Bx';
                case 'hy'
                    obj.chnames{ind} = 'By';
                case 'hz'
                    obj.chnames{ind} = 'Bz';
                case 'ex'
                    obj.chnames{ind} = 'Ex';
                case 'ey'
                    obj.chnames{ind} = 'Ey';
            end
            fprintf([' ',num2str(obj.chnames{ind})]);
            
            % find out which channels we are looking for
            % is it mseed or mseed2?
            tmp = cell(Nfiles/nch,1);
            for ind2 = 1:Nfiles/nch
                tmp{ind2} = obj.mseedfiles{ind2,ind}(end);
            end           
            utmp = unique(tmp);
            if numel(utmp) == 1
                switch utmp{1}
                    case '2' %mseed2
                        ftype = 'mseed2';
                    case 'd' %mseed
                        ftype = 'mseed';
                    otherwise
                        error('file type not mseed, mseed2!');
                end
            else
                error('different file types mseed/mseed2 mixed in station!')
            end            
            fprintf([' (',ftype,')']);
            
            % look through ini-structure (recorder.ini) and detect sampling rate
            ii = -1;
            for ind2 = 1 : 20;
                if ~isfield(ini,['channel_',num2str(ind2-1),'_long_id']); continue; end
                str = ini.(['channel_',num2str(ind2-1),'_long_id']);
                if strcmp(str(1:2),chtype); % found right component
                    if strcmp(str(4:end),ftype) % found right channel type, mseed/2
                        ii = ind2-1;
                        break;
                    end
                end
            end
            if ii == -1; error('could not determine sampling rate'); end
            obj.srate = [obj.srate, ini.(['channel_',num2str(ii),'_samplerate'])];
            
            % and find which channel in recorder.ini terminology describes the current channel
            channel_index = 0;
            for ind2 = 1 : 5;
                if strcmpi(chtype,header.CHAN_ORDER(ind2*3-2 + (0:1)));
                    channel_index = ind2;
                    break;
                end
            end
            if channel_index == 0;
                error('could not identify channel in recorder.ini (using CHAN_ORDER)');
            end

            % read fields from configuration.inf
            obj.sens_name{ind} = header.(['SENSOR_',num2str(channel_index),'_TYPE']);            
            if isempty(obj.sens_name{ind}) && strcmp(chtype(1),'h')
                % ASSUMING MFS05 coils
                obj.sens_name{ind} = 'MFS05';
                disp(['Channel ',obj.chnames{ind},': assuming MFS05 sensor (currently hardcoded ...)'])
            end       
            
            % lsb determined by sensor:
            if strfind(obj.sens_name{ind},'MFS05'), obj.lsb(ind) = obj.lsb(ind) / 800;  end
            if strfind(obj.sens_name{ind},'MFS06'), obj.lsb(ind) = obj.lsb(ind) / 800;  end
            if strfind(obj.sens_name{ind},'MFS07'), obj.lsb(ind) = obj.lsb(ind) / 640;  end
            if strfind(obj.sens_name{ind},'SHFT02'), obj.lsb(ind) = obj.lsb(ind) / 50;  end
            if strfind(obj.sens_name{ind},'COIL'), obj.lsb(ind) = obj.lsb(ind) / 1000;  end
            if strfind(obj.sens_name{ind},'FGS03'), obj.lsb(ind) = obj.lsb(ind) / 0.1;  end            
            
            % obj.sens_type{ind} = header.(['SENSOR_',num2str(channel_index),'_TYPE']);
            obj.sens_sn{ind} =   header.(['SENSOR_',num2str(channel_index),'_NAME']);
            if ~isempty(header.(['LENGTH_',num2str(channel_index)]))
                obj.dipole(ind)  =   header.(['LENGTH_',num2str(channel_index)]);
            elseif strcmp(chtype(1),'e')
                disp('**Warning, dipole length not specified');
            end
            obj.orient(ind)  =   header.(['AZIM_',num2str(channel_index)]);
            if strcmp(obj.chnames(ind),'Bz'); obj.tilt(ind) = 90; else obj.tilt(ind) = 0; end
                        
            % detect file start and stop times and number of samples etc.,
            % unfortunately by reading all files in
            npat = repmat(' ',1,16);
            fprintf([',  ',npat,' samples ...']); 
            if ind == 1 ; startstopfile = []; end                 
            Nsmp_ch = 0;
            for ind2 = 1 : Nfiles/nch                
                X = rdmseed(fullfile(pathname,obj.mseedfiles{ind2,ind}));
                Nsmp_mat(ind2,ind) = 0;
                for ind3 = 1:numel(X)
                    Nsmp_mat(ind2,ind) = Nsmp_mat(ind2,ind) + X(ind3).NumberSamples;                    
                end
                Nsmp_ch = Nsmp_ch + Nsmp_mat(ind2,ind);
                n = num2str(Nsmp_ch,'%d');
                np = npat; np(end-numel(n)+1:end) = n;
                                
                if ind == 1
                    ds = datestr(datenum(jl2normaldate(X(1).RecordStartTime(1)*1000 + X(1).RecordStartTime(2))),31);
                    hdr_start = [X(1).RecordStartTime(1) str2double(ds(6:7)) str2double(ds(9:10)) X(1).RecordStartTime(3:5)];
                    if ind2 == 1;                                            
                        start = hdr_start;
                        startms = 0;
                        obj.starttime = start;
                        obj.starttimems = startms;
                    else                        
                        start = start2;
                        startms = start2ms;                        
                    end
                    [stop, stopms, start2, start2ms]     = get_stoptime(start,startms,Nsmp_mat(ind2,ind),obj.srate);
                    
                    startstopfile = [startstopfile; [start startms stop stopms]];
                end
                % pause(.1);
                fprintf(['\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b',np,' samples ...']);
            end
            fprintf('\n')
            
        end
        
        obj.startstopfile = startstopfile;
        obj.stoptime = stop;
        obj.stoptimems = stopms;
        obj.srate = unique(obj.srate);
        if numel(obj.srate) > 1; error('data consists of different sampling rates'); end
        
        if ~all(sum(Nsmp_mat,2) ~= Nsmp_mat(:,1)./nch);                             
            disp('**Error: Number of samples not the same for all channes!');            
            return;
        else
            Nsmpfile = Nsmp_mat(:,1)';            
        end
        obj.Nsmp          = sum(Nsmpfile);
        
        [stop,stopms,start2,start2ms]     = get_stoptime(obj.starttime,obj.starttimems,obj.Nsmp,obj.srate);
        startstopfile = [obj.starttime obj.starttimems stop stopms];

        tmp = header.START_TIME;
        hdr_starttime = [str2double(tmp( 1: 4)),str2double(tmp( 6: 7)),str2double(tmp( 9:10)),...
            str2double(tmp(12:13)),str2double(tmp(15:16)),str2double(tmp(18:19))];
        hdr_startms = 0;
        
        % deviation is allowed because header may be rewritten upon, e.g.,
        % restart of files. Therefore, the following check is moot:
        % if any(hdr_starttime~=obj.starttime); disp('** header starttime deviates from mseed starttime'); end
        
        % WHAT IS THIS FOR????
        obj.startstopfile = startstopfile;        
        
        obj.stoptime      = stop;
        obj.stoptimems    = stopms;
        
        obj.Nsmpfile      = [cumsum([1 Nsmpfile(1:end-1)])' cumsum(Nsmpfile)'];
        
    end
    
    
end

function     [stop,stopms,start2,start2ms]     = get_stoptime(start,startms,Nsmp,srate)
    % stop is the time of the last recording of the current file
    % start 2 is the time of the first sample in the next file
    if isempty(Nsmp); Nsmp = 0; end
    start(6) = start(6)+startms/1000+(Nsmp-1)/srate;
    stop = datevec(datenum(start));
    stopms = stop(6)-floor(stop(6));
    stop(6) = floor(stop(6));
    stopms  = round((stopms*1000)*100)/100;

    start(6) = start(6)+1/srate;
    start2 = datevec(datenum(start));
    start2ms = start2(6)-floor(start2(6));
    start2(6) = floor(start2(6));
    start2ms  = round((start2ms*1000)*100)/100;

end