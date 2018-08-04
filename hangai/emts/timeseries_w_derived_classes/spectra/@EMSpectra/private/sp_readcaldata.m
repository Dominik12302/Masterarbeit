% function [cal_file, cal_data] = read_caldata(channelname,sensorname,sensorsn,sfreq,cal_path)
function obj = sp_readcaldata(obj,ts)

    % adds fields caldata and caldir to spectra objects. caldata has 3
    % rows: frequency (descending), amplitude and phase (in degree).
    %
    % caldata is the transferfunction of the sensor or device, i.e.,
    % spectra must be divided by caldata.

    cal_file = {''};
    cal_data = [1e+6 1e-6; 1 1 ; 0 0];
    cal_path = obj.caldir{1};
    if ts.resmpfreq, sfreq = ts.srate; else sfreq = ts.resmpfreq; end
    if ~isdir(obj.caldir{1})
        if obj.debuglevel == 2, disp([' - calibration directory ' obj.caldir{1} ' does not exist!']); end
        cal_file = {''};
        cal_data = [1e+6 1e-5; 1 1 ; 0 0];
        % use theoretical transfer function
        for ich = 1:numel(ts.usech)
            cal_file = {''};
            channelname = ts.chnames(ts.usech(ich));            
            cal_data = [1e+6 1e-5; 1 1 ; 0 0];
            sensorname = ts.sens_name(ts.usech(ich));
            if ~isempty(strfind(sensorname{1},'MFS05'))  || ~isempty(strfind(sensorname{1},'mfs05')) || ~isempty(strfind(sensorname{1},'MFS10')) || ~isempty(strfind(sensorname{1},'mfs10'))
                f = logspace(-4,5,9*7);
                P1 = 1i*f/4;
                P2 = 1i*f/8192;
                F = P1./(1+P1).*1./(1+P2);
                data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
                if obj.debuglevel == 1,  disp([' - ' sensorname{1} ': using theoretical transfer function for MFS05 / MFS10']); end
                cal_file = {''};
                cal_data = data;
            elseif ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'mfs06'))
                f = logspace(-4,5,9*7);
                P1 = 1i*f/4;
                P2 = 1i*f/8192;
                F = P1./(1+P1).*1./(1+P2);
                data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
                if obj.debuglevel == 1,  disp([' - ' sensorname{1} ': using theoretical transfer function for MFS06']); end
                cal_file = {''};
                cal_data = data;
            elseif ~isempty(strfind(sensorname{1},'MFS07'))  || ~isempty(strfind(sensorname{1},'mfs07'))
                f = logspace(-4,5,9*7);
                P1 = 1i*f/32;
                P2 = 1i*f/40000;
                F = P1./(1+P1).*1./(1+P2);
                data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
                if obj.debuglevel == 1,  disp([' - ' sensorname{1} ': using theoretical transfer function for MFS07']); end
                cal_file = {''};
                cal_data = data;
            elseif ~isempty(strfind(sensorname{1},'MFS11'))  || ~isempty(strfind(sensorname{1},'mfs11'))
                f = logspace(-5,5,10*7);
                P1 = 1i*f/0.7227;
                P2 = 1i*f/32.45;
                P3 = 1i*f/45106;
                P4 = 1i*f/48000;
                P5 = 1i*f/37589;
                F = P1./(1+P1).*P2./(1+P2).*1./(1+P3).*1./(1+P4).*1./(1+P5);
                data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
                if debuglevel == 1, disp([' - ' channelname{1} ': using theoretical transfer function for MFS11']); end
                cal_file = {''};
                cal_data = data;
            elseif ~isempty(strfind(sensorname{1},'SHFT02'))  || ~isempty(strfind(sensorname{1},'shft02'))
                f = logspace(0,6,6*7);
                P1 = 1i*f/300000;
                F = 1./(1+P1);
                data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
                if obj.debuglevel == 1,  disp([' - ' sensorname{1} ': using theoretical transfer function for SHFT02']); end
                cal_file = {''};
                cal_data = data;
            else
                if obj.debuglevel == 2,  disp([' - ' sensorname{1} ' assuming unit responses!']); end
            end
            obj.calfile(ich) = cal_file;
            obj.caldata{ich} = cal_data;
        end
    else
        for ich = 1:numel(ts.usech)
            sensorname = ts.sens_name(ts.usech(ich));
            channelname = ts.chnames(ts.usech(ich));
            sensorsn = ts.sens_sn(ts.usech(ich));
            if ~isempty(strfind(channelname{1},'B'))
                % magnetic channel
                [cal_file,cal_data] = findmags(channelname, sensorname, sensorsn,cal_file,cal_data,cal_path,obj.debuglevel,sfreq);
            elseif ~isempty(strfind(channelname{1},'E'))
                % electric channel
                system = ts.system;
                systemSN = ts.systemSN;
                [cal_file, cal_data] = findedes(channelname,system,systemSN,cal_path,obj.debuglevel);
            else
                cal_file = {''};
                cal_data = [1e+6 1e-6; 1 1 ; 0 0];
                if obj.debuglevel == 1, disp('- unknown channel type! -> unit response assumed'); end
            end
            obj.calfile(ich) = cal_file;
            obj.caldata{ich}  = cal_data;
        end
    end
end

function [cal_file, cal_data] = findedes(channelname,system,systemSN,cal_path,debuglevel)
    cal_file = {''};
    cal_data = [1e+6 1e-6; 1 1 ; 0 0];    
    
    if strcmpi(system,'EDE')
        
        found_ede_calfile = false;
        
        rspname = [system,systemSN,'.edi'];
        cal_file = {fullfile(cal_path,rspname)};
        if exist(cal_file{1})==2
            edi = EDI(cal_file{1});
            if debuglevel == 1, disp([channelname{1},' found calibration file ',rspname]); end
            data(1,:) = edi.f(:).';
            ZZ = squeeze(edi.Z(1,1,:)+edi.Z(2,2,:))./2;
            data(2,:) = abs(ZZ).';
            data(3,:) = 180/pi*angle(ZZ).';
            data = [cal_data(:,1) data cal_data(:,end)];
            cal_data = data;
            
            found_ede_calfile = true;            
        end
        
        rspname = [system,systemSN,'.dat']; % ascii format assumed
        cal_file = {fullfile(cal_path,rspname)};
        if exist(cal_file{1})==2
            
            if debuglevel == 1, disp([channelname{1},' found calibration file ',rspname]); end
            cal_data = load(rspname,'-ascii').';
            
            found_ede_calfile = true;            
        end
        
        if ~found_ede_calfile
            
            data(1,:) = logspace(6,-6,13*200);
            fac = 1/1.018;
            
            % as in sp_writeafc2.m
            data(2,:) = fac*ones(size(data(1,:)));
            data(3,:) = 180/pi*angle(exp(+1i*2*pi*data(1,:)*0.00079));            
            str =  'Thereotical response e^(2*pi*i*f*0.00079s))/1.018 assumed for EDE electric channel';

%             % unit response
%             data(2,:) = ones(size(data(1,:)));
%             data(3,:) = zeros(size(data(1,:)));
%             str =  'Unit response assumed';
            
            cal_data = data;
            
            
            
            if debuglevel == 1, disp([' - No calibration file found for electric channel EDE -> ',str]); end
        end
    else
        if debuglevel == 2, disp(' - electric channel! -> unit response assumed'); end
    end
end

function [cal_file,cal_data] = findmags(channelname, sensorname, sensorsn,cal_file,cal_data,cal_path,debuglevel,sfreq)


    %% Metronix calibration format
    % assumes the following file naming convention
    % mfs50004.cal for mfs05 coil with SN 4
    % mfs70113.cal for mfs07 coil with SN 113

    p2 = sensorsn{1};
    p1 = sensorname{1};
    p2s = num2str(p2);
    ch = channelname{1};
    %%sensorname{1} = 'mfs06 ';
    % MFS coils
    if ~isempty(strfind(sensorname{1},'MFS05'))  || ~isempty(strfind(sensorname{1},'mfs05'))
        rspname = ['mfs50' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'mfs06'))
        rspname = ['mfs60' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'MFS07'))  || ~isempty(strfind(sensorname{1},'mfs07'))
        rspname = ['mfs70' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'MFS10'))  || ~isempty(strfind(sensorname{1},'mfs10'))
        rspname = ['mfs10' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'MFS11'))  || ~isempty(strfind(sensorname{1},'mfs11'))
        rspname = ['mfs11' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'SHFT02'))  || ~isempty(strfind(sensorname{1},'shft02'))
        rspname = ['shft02' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'Geomag'))  || ~isempty(strfind(sensorname{1},'GEOMAG'))
        rspname = ['Geomag' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'FGS'))  || ~isempty(strfind(sensorname{1},'Fgs'))
        rspname = ['FGS' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'COIL'))  || ~isempty(strfind(sensorname{1},'coil'))
        rspname = ['COIL' p2s '.cal'];
    else
        cal_file = {''};
        cal_data = [1e+6 1e-5; 1 1 ; 0 0];
        if debuglevel == 2,  disp('CALIBRATION: unknown magnetic sensor! -> unit response assumed'); end
        return;
    end

    % try to locate this file
    if exist(fullfile(cal_path,rspname))==2 % file exists
        if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,rspname)]); end
        fid = fopen(fullfile(cal_path,rspname));
        tmp = fgetl(fid);
        while isempty(strfind(tmp,'Chopper On')) && ~feof(fid)
            tmp = fgetl(fid);
        end
        tmp = fgetl(fid);
        dataon = [];
        while ~isempty(tmp) && ~feof(fid) &&  isempty(strfind(tmp,'Chopper Off'))
            dataon = [dataon sscanf(tmp,'%f %f %f',[3 1])];
            tmp = fgetl(fid);
        end

        while isempty(strfind(tmp,'Chopper Off')) && ~feof(fid)
            tmp = fgetl(fid);
        end
        tmp = fgetl(fid);
        dataoff = [];
        while ~isempty(tmp) && ~feof(fid)
            dataoff = [dataoff sscanf(tmp,'%f %f %f',[3 1])];
            tmp = fgetl(fid);
        end
        fclose(fid);
        if sfreq > 512, data = dataoff; else data = dataon; end
        if numel(data)>=5
            data = [data(:,1) data];
            data(1,1) = 1e-5;
            data(2,:) = data(2,:).*data(1,:);
            cal_data = data;
            cal_file = {fullfile(cal_path,rspname)};
        end
        return;
    end

    % assumes gfz naming convention of coil
    % 4 chars, first identifies type of mfs coil (5,6,7), the remaining three
    % identify the serial number of that coil

    % MFS coils
    if ~isempty(strfind(sensorname{1},'MFS05')) || ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'MFS07')) || ~isempty(strfind(sensorname{1},'MFS10')) || ~isempty(strfind(sensorname{1},'MFS11'))
        rspname = ['mfs' p2s(1) '0' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'COIL'))  || ~isempty(strfind(sensorname{1},'coil'))
        rspname = ['COIL' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'Geomag'))  || ~isempty(strfind(sensorname{1},'Geomag'))
        rspname = ['Geomag' p2s '.cal'];
    elseif ~isempty(strfind(sensorname{1},'FGS03'))  || ~isempty(strfind(sensorname{1},'FGS03'))
        rspname = ['FGS03' p2s '.cal'];

    else
        cal_file = {''};
        cal_data = [1e+6 1e-5; 1 1 ; 0 0];
        if debuglevel == 1, disp('** Warning: unknown magnetic sensor! -> unit response assumed'); end
        return
    end

    % try to locate this file
    if exist(fullfile(cal_path,rspname))==2 % file exists
        if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,rspname)]); end
        fid = fopen(fullfile(cal_path,rspname));
        tmp = fgetl(fid);
        while isempty(strfind(tmp,'Chopper On')) && ~feof(fid)
            tmp = fgetl(fid);
        end
        tmp = fgetl(fid);
        dataon = [];
        while ~isempty(tmp) && ~feof(fid) &&  isempty(strfind(tmp,'Chopper Off'))
            dataon = [dataon sscanf(tmp,'%f %f %f',[3 1])];
            tmp = fgetl(fid);
        end

        while isempty(strfind(tmp,'Chopper Off')) && ~feof(fid)
            tmp = fgetl(fid);
        end
        tmp = fgetl(fid);
        dataoff = [];
        while ~isempty(tmp) && ~feof(fid)
            dataoff = [dataoff sscanf(tmp,'%f %f %f',[3 1])];
            tmp = fgetl(fid);
        end
        fclose(fid);
        if sfreq > 512, data = dataoff; else data = dataon; end
        if numel(data)>=5
            data(2,:) = data(2,:).*data(1,:);
            cal_data = data;
            cal_file = {fullfile(cal_path,rspname)};
        end
        %                 return;
    end

    %% Potsdam Calibration format
    str = {'BB','LF','HF'};
    for ind = 1 : numel(str);

        % magnetic channel
        if ~isempty(strfind(sensorname{1},'MFS05')) || ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'MFS07')) || ~isempty(strfind(sensorname{1},'MFS10')) || ~isempty(strfind(sensorname{1},'MFS11'))
            rspname = ['Metronix_Coil-----TYPE-00' p2s(1) '_',str{ind},'-ID-000' p2s(2:end) '.RSP'];
        elseif ~isempty(strfind(sensorname{1},'GEOMAG'))  || ~isempty(strfind(sensorname{1},'Geomag'))
            switch ch
                case 'Bx'
                    rspname = ['Geomag_Fluxgate---TYPE-0001' '_X-ID-0000' p2s(1:end) '.RSP'];%Geomag_Fluxgate---TYPE-0001_Z-ID-000046
                case 'By'
                    rspname = ['Geomag_Fluxgate---TYPE-0001' '_Y-ID-0000' p2s(1:end) '.RSP'];%Geomag_Fluxgate---TYPE-0001_Z-ID-000046
                case 'Bz'
                    rspname = ['Geomag_Fluxgate---TYPE-0001' '_Z-ID-0000' p2s(1:end) '.RSP'];%Geomag_Fluxgate---TYPE-0001_Z-ID-000046
            end
        elseif ~isempty(strfind(sensorname{1},'COIL'))  || ~isempty(strfind(sensorname{1},'coil'))
            rspname = ['COIL' p2s '.cal'];
        else
            cal_file = {''};
            cal_data = [1e+6 1e-6; 1 1 ; 0 0];
            if debuglevel == 1, disp('** Warning: unknown magnetic channel! -> unit response assumed'); end
            return;
        end

        % try to locate this file
        if exist(fullfile(cal_path,rspname))==2 % file exists
            if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,rspname)]); end
            fid = fopen(fullfile(cal_path,rspname));
            tmp = fgetl(fid);
            staticgain = 0;
            while isempty(strfind(tmp,'---------------')) && ~feof(fid)
                tmp = fgetl(fid);
                if strfind(tmp,'StaticGain')
                    staticgain = 1;
                end
            end
            if ~staticgain
                tmp = fscanf(fid,'%f %f',[2 1]);
            end
            tmp = fgetl(fid);tmp = fgetl(fid);
            data = [];
            while isempty(strfind(tmp,'---------------')) && ~feof(fid)
                data = [data sscanf(tmp,'%f %f %f',[3 1])];
                tmp = fgetl(fid);
            end
            if isempty(strfind(tmp,'---------------'))
                data = [data sscanf(tmp,'%f %f %f',[3 1])];
            end
            data(2,:) = data(2,:);%./data(1,:);
            fclose(fid);
            if numel(data)>=5
                cal_data = data;
                cal_file = {fullfile(cal_path,rspname)};
            end
            return;
        end

        % magnetic channel
        if ~isempty(strfind(sensorname{1},'MFS05')) || ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'MFS07')) || ~isempty(strfind(sensorname{1},'MFS10')) || ~isempty(strfind(sensorname{1},'MFS11'))
            if ~isempty(strfind(sensorname{1},'MFS05')), bla = '05'; end
            if ~isempty(strfind(sensorname{1},'MFS06')), bla = '06'; end
            if ~isempty(strfind(sensorname{1},'MFS07')), bla = '07'; end
            if ~isempty(strfind(sensorname{1},'MFS10')), bla = '10'; end
            if ~isempty(strfind(sensorname{1},'MFS11')), bla = '11'; end
            while numel(p2s)<3, p2s = ['0' p2s]; end
            rspname = ['Metronix_Coil-----TYPE-0' bla '_',str{ind},'-ID-000' p2s(1:end) '.RSP'];
        elseif ~isempty(strfind(sensorname{1},'COIL'))  || ~isempty(strfind(sensorname{1},'coil'))
            rspname = ['COIL' p2s '.cal'];
        else
            cal_file = {''};
            cal_data = [1e+6 1e-6; 1 1 ; 0 0];
            if debuglevel == 1, disp('**Warning: unknown magnetic channel! -> unit response assumed'); end
            return;
        end

        % try to locate this file
        if exist(fullfile(cal_path,rspname))==2 % file exists
            if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,rspname)]); end
            fid = fopen(fullfile(cal_path,rspname));
            tmp = fgetl(fid);
            staticgain = 0;
            while isempty(strfind(tmp,'---------------')) && ~feof(fid)
                tmp = fgetl(fid);
                if strfind(tmp,'StaticGain')
                    staticgain = 1;
                end
            end
            if ~staticgain
                tmp = fscanf(fid,'%f %f',[2 1]);
            end
            tmp = fgetl(fid);tmp = fgetl(fid);
            data = [];
            while isempty(strfind(tmp,'---------------')) && ~feof(fid)
                data = [data sscanf(tmp,'%f %f %f',[3 1])];
                tmp = fgetl(fid);
            end
            data(2,:) = data(2,:);%./data(1,:);
            fclose(fid);
            if numel(data)>=5
                cal_data = data;
                cal_file = {fullfile(cal_path,rspname)};
            end
            return;
        elseif exist(fullfile(cal_path,[rspname,'X']))==2 % file exists
            if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,[rspname,'X'])]); end        
            cal_file = {fullfile(cal_path,[rspname,'X'])};        
            xmlfile = xml2struct(cal_file{1});
            staticgain_id = find(strcmp({xmlfile.Children.Name},'StaticGain'));
            staticgain = str2double(xmlfile.Children(staticgain_id).Children.Data);
            data_id = find(strcmp({xmlfile.Children.Name},'ResponseData'));
            Attr = {xmlfile.Children(data_id).Attributes};
            AttrNames = cellfun(@(x){x(:).Name},Attr,'UniformOutput',false);
            freq_id = cellfun(@(x)find(strcmp(x,'Frequency')),AttrNames);
            mag_id = cellfun(@(x)find(strcmp(x,'Magnitude')),AttrNames);
            phase_id = cellfun(@(x)find(strcmp(x,'Phase')),AttrNames);
            data = zeros(numel(freq_id),3);
            for ind2 = 1 : numel(freq_id)
                values = str2double({Attr{ind2}.Value});
                data(ind2,:) = values([freq_id(ind2) mag_id(ind2) phase_id(ind2)]);
            end            
            data = sortrows(data);
            % z = data(:,2).*exp(1i.*data(:,3).*pi./180);
            % data(:,2:3) = [real(z) imag(z)];
            cal_data = data.';
            return;
        end

    end

    %% Phoenix Calibration format

    % magnetic channel
    if ~isempty(strfind(sensorname{1},'MFS05')) || ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'MFS07')) || ~isempty(strfind(sensorname{1},'MFS10')) || ~isempty(strfind(sensorname{1},'MFS11'))
        rspname = ['Metronix_Coil-----TYPE-00' p2s(1) '_BB-ID-000' p2s(2:end) '.RSP'];
    elseif ~isempty(strfind(sensorname{1},'COIL'))  || ~isempty(strfind(sensorname{1},'coil'))
        rspname = ['COIL' p2s '_CLC .asc'];
    else
        cal_file = {''};
        cal_data = [1e+6 1e-6; 1 1 ; 0 0];
        if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,rspname)]); end
        return;
    end

    % try to locate this file
    if exist(fullfile(cal_path,rspname))==2 % file exists
        if debuglevel == 1,  disp([' - ' channelname{1} ': found calibration file ' fullfile(cal_path,rspname)]); end
        fid = fopen(fullfile(cal_path,rspname));
        tmp = fgetl(fid);
        tmp = fgetl(fid);
        tmp = fgetl(fid);
        tmp = fgetl(fid);
        data = fscanf(fid,'%d %f %f %f',[4 inf]);
        %data(2,:) = data(2,:);%./data(1,:);
        fclose(fid);
        if numel(data)>=5
            cal_data = data(2:end,:);
            cal_file = {fullfile(cal_path,rspname)};
        end
        return;
    end

    %% use theoretical transfer function
    if ~isempty(strfind(sensorname{1},'MFS05'))  || ~isempty(strfind(sensorname{1},'mfs05')) || ~isempty(strfind(sensorname{1},'MFS10')) || ~isempty(strfind(sensorname{1},'mfs10'))
        f = logspace(-4,5,9*7);
        P1 = 1i*f/4;
        P2 = 1i*f/8192;
        F = P1./(1+P1).*1./(1+P2);
        data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
        if debuglevel == 1, disp([' - ' channelname{1} ': using theoretical transfer function for MFS05 / MFS10']); end
        cal_file = {''};
        cal_data = data;
    elseif ~isempty(strfind(sensorname{1},'MFS06')) || ~isempty(strfind(sensorname{1},'mfs06'))
        f = logspace(-5,5,10*7);
        P1 = 1i*f/4;
        P2 = 1i*f/8192;
        F = P1./(1+P1).*1./(1+P2);
        data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
        if debuglevel == 1, disp([' - ' channelname{1} ': using theoretical transfer function for MFS06']); end
        cal_file = {''};
        cal_data = data;
    elseif ~isempty(strfind(sensorname{1},'MFS07'))  || ~isempty(strfind(sensorname{1},'mfs07'))
        f = logspace(-5,5,10*7);
        P1 = 1i*f/32;
        P2 = 1i*f/40000;
        F = P1./(1+P1).*1./(1+P2);
        data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
        if debuglevel == 1, disp([' - ' channelname{1} ': using theoretical transfer function for MFS07']); end
        cal_file = {''};
        cal_data = data;
    elseif ~isempty(strfind(sensorname{1},'MFS11'))  || ~isempty(strfind(sensorname{1},'mfs11'))
        f = logspace(-5,5,10*7);
        P1 = 1i*f/0.7227;
        P2 = 1i*f/32.45;
        P3 = 1i*f/45106;
        P4 = 1i*f/48000;
        P5 = 1i*f/37589;
        F = P1./(1+P1).*P2./(1+P2).*1./(1+P3).*1./(1+P4).*1./(1+P5);
        data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
        if debuglevel == 1, disp([' - ' channelname{1} ': using theoretical transfer function for MFS11']); end
        cal_file = {''};
        cal_data = data;    
    elseif ~isempty(strfind(sensorname{1},'SHFT02'))  || ~isempty(strfind(sensorname{1},'shft02'))
        f = logspace(0,6,6*7);
        P1 = 1i*f/300000;
        F = 1./(1+P1);
        data(1,:)=f; data(2,:) = abs(F); data(3,:) = angle(F)*180/pi;
        if debuglevel == 1, disp([' - ' channelname{1} ': using theoretical transfer function for SHFT02']); end
        cal_file = {''};
        cal_data = data;
    end

end