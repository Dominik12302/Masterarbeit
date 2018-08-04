% Function designed to work with the ADU class in order to read a .ats
% file to an ADU object from the datafile 'datafile'
%
% CAUTION: The data has to be in integer values (i.e. the measured values
% before they are multiplied by the lsb factor)
function obj = ats_read(obj,datapath)
obj.source = {datapath};
atsfiles = dir(fullfile(datapath,'*.ats'));
if isempty(atsfiles)
    if obj.debuglevel, disp('** Warning. No *.ats data files found'); end
    return;
else
    if obj.debuglevel, disp(['   found ' num2str(numel(atsfiles),'%03d') ' *.ats files: sorting ...']); end
    for ifile = 1:numel(atsfiles);
        if length(atsfiles(ifile).name) <13 % old naming convention
        header = ats_read_header(fullfile(obj.source{1},atsfiles(ifile).name),obj.debuglevel);
        systemSN(ifile)     = {header.SN_string};
        system(ifile)       = {atsfiles(ifile).name(5:7)};
        channel(ifile)      = [header.ch_no];
        filenumber(ifile)   = [str2num(header.run)];
        channelname(ifile)  = {header.chnames};
        srate(ifile)        = [header.srate];
        atsfilename(ifile)  = {atsfiles(ifile).name};
        else
        systemSN(ifile)     = {atsfiles(ifile).name(1:3)};
        system(ifile)       = {atsfiles(ifile).name(5:7)};
        channel(ifile)      = [str2num(atsfiles(ifile).name(10:11))];
        filenumber(ifile)   = [str2num(atsfiles(ifile).name(14:16))];
        channelname(ifile)  = {atsfiles(ifile).name(19:20)};
        % 3 digit sampling rate assumed, if fails, 3 2-digit, then 1 digit
        % (JK)
        sr = [str2num(atsfiles(ifile).name(25:27))];
        if isempty(sr); sr = [str2num(atsfiles(ifile).name(25:26))]; end
        if isempty(sr); sr = [str2num(atsfiles(ifile).name(25))]; end
        if isempty(sr);     error('could not find sampling rate of ats-file'); end
        srate(ifile)        = sr;
        atsfilename(ifile)  = {atsfiles(ifile).name};
        end
    end
    fn  = sort(unique(filenumber));
    if obj.debuglevel, fprintf(1,'\b'); disp([' ' num2str(numel(fn),'%03d') ' runs;']); end
    cn  = sort(unique(channel));
    if obj.debuglevel, fprintf(1,'\b'); disp([' ' num2str(numel(cn),'%02d') ' channels;']); end
    sn  = unique(systemSN);
    sys = unique(system);
    srn = unique(srate);
    if numel(sn) > 1
        if obj.debuglevel, fprintf(1,'\b'); disp([' ' num2str(numel(sn),'%02d') ' systems;']); end
        disp('** Error: only one system accepted for one continous recording: please sort into differen directories.');
        return
    else
        switch sys{1}
            case 'EDE'
                obj.system = 'EDE';
            case 'SP4'
                obj.system = 'SP4';
            case 'MTU'
                obj.system = 'MTU';
            otherwise
                obj.system = 'ADU07e';
        end
        obj.systemSN = sn{1};
    end
    if numel(srn) > 1
        if obj.debuglevel, fprintf(1,'\b'); disp([' ' num2str(numel(srn),'%03d') ' smp.rates;']); end
        disp('** Error: All files must be recorded with the same sampling rate.');
        return
    end
    filematrix = zeros(numel(fn),numel(cn));
    for ifn = 1:numel(fn)
        indfn = find(filenumber==fn(ifn));
        if ifn == 1,
            chnames = channelname(indfn);
            for ich = 1:numel(chnames)
                if strfind(chnames{ich},'H')
                    ii = strfind(chnames{ich},'H');
                    chnames{ich}(ii) = 'B';
                end
            end
        end
        if numel(indfn) == numel(cn)
            for ich = 1:numel(cn)
                indch = channel(indfn)==cn(ich);
                filematrix(ifn,ich) = indfn(indch);
            end
        else
            disp(['**Error: Missing at least one channel for run ' num2str(fn(ifn),'%03d') ]); 
            return;
        end
    end
    obj.Nfiles   = [numel(fn) numel(cn)];
    obj.atsfiles = atsfilename(filematrix);
    obj.Nch      = numel(cn);
    obj.chnames  = chnames;
    
    %% Open file:
    Nsmp = 0;
    ifn = 1;
    if obj.debuglevel==2, disp([' - reading header from files *R' num2str(ifn,'%03d') '*.ats']); end
    for ich = 1:numel(cn)
        header = ats_read_header(fullfile(obj.source{1},obj.atsfiles{ifn,ich}),obj.debuglevel);
        obj.headerlength= header.length;
        obj.srate       = header.srate; srate = obj.srate;
        obj.starttime   = datevec(header.startstr);
        obj.lsb(ich)    = header.lsb;
        if header.dipole == 0,
            obj.dipole(ich) = 1;
        else
            obj.dipole(ich)= header.dipole;
        end
        obj.orient(ich)     = header.orient;
        obj.tilt(ich)       = 0;
        if strcmp(obj.chnames,'Bz'), obj.tilt(ich) = 90; end
        obj.sens_sn(ich)    = {header.sens_sn};
        obj.sens_name(ich)  = {header.sens_name};
        % lat lon
        obj.lat             = header.lat/1000/60/60;
        obj.lon             = header.lon/1000/60/60;
        Nsmp_f(ich)         = header.Nsmp_f;
    end
    Nsmp_f = unique(Nsmp_f);
    if numel(Nsmp_f) ~= 1,
        disp('**Error: Number of samples not the same for all channes!');
        %return;
        Nsmp = Nsmp+min(Nsmp_f);
        Nsmpfile(ifn) = min(Nsmp_f);
    else
        Nsmp = Nsmp+Nsmp_f;
        Nsmpfile(ifn) = Nsmp_f;
    end
    [stop,stopms,start2,start2ms]     = get_stoptime(obj.starttime,obj.starttimems,Nsmpfile,obj.srate);
    startstopfile = [obj.starttime obj.starttimems stop stopms];
    
    for ifn = 2:obj.Nfiles(1,1)
        if obj.debuglevel==2, disp([' - reading header from files *R' num2str(ifn,'%03d') '*.ats']); end
        for ich = 1:obj.Nfiles(1,2)
            % testing if the number of samples is the same for each channel
            header              = ats_read_header_short(fullfile(obj.source{1},obj.atsfiles{ifn,ich}),obj.debuglevel);
            Nsmp_f(ich) = header.Nsmp_f;
        end
        Nsmp_f = unique(Nsmp_f);
        if numel(Nsmp_f) ~= 1,
            % JK 2015/10/23
            % disp('**Error: Number of samples not the same for all channes!');
            % return;
            disp('**Warning: Number of samples not the same for all channes, omitting incomplete parts!');
            Nsmp = Nsmp+min(Nsmp_f);
            Nsmpfile(ifn) = min(Nsmp_f);
        else
            Nsmp = Nsmp+Nsmp_f;
            Nsmpfile(ifn) = Nsmp_f;
        end
        % testing the starttimes for all runs, but only for the first
        % channel
        header              = ats_read_header_short(fullfile(obj.source{1},obj.atsfiles{ifn,1}),obj.debuglevel);
        start               = datevec(header.startstr);
        startms             = 0;
        if start == start2 & startms == start2ms % continous recording
            [stop,stopms,start2,start2ms]     = get_stoptime(start,startms,header.Nsmp_f,header.srate);
            startstopfile = [startstopfile; [start startms stop stopms]];
        else % discontinous recording or some bug in the header file
            if obj.debuglevel
                disp(['** Error: Detected time gap in file ' obj.atsfiles{ifn,1}]);
                fprintf(1,'            >>> Starttime should be a %d %d %d %d %d %d + %.2f us\n',start2, start2ms);
                fprintf(1,'                but was found to be   %d %d %d %d %d %d + %.2f us\n',start, startms);
            end
            return;
        end
    end
    obj.startstopfile = startstopfile;
    obj.Nsmpfile      = [cumsum([1 Nsmpfile(1:end-1)])' cumsum(Nsmpfile)'];
    obj.Nsmp          = sum(Nsmpfile);
    obj.stoptime      = stop;
    obj.stoptimems    = stopms;
end
end
function     [stop,stopms,start2,start2ms]     = get_stoptime(start,startms,Nsmp,srate)
% stop is the time of the last recording of the current file
% start 2 is the time of the first sample in the next file
start(6) = start(6)+startms/1000+floor((Nsmp-1)/srate);
stop     = datevec(datenum(start));
stopms   =  1000*(Nsmp-1-floor((Nsmp-1)/srate)*srate)/srate;

start(6) = start(6)+1/srate+stopms/1000;
start2 = datevec(datenum(start));
start2ms = start2(6)-floor(start2(6));
start2(6) = floor(start2(6));
start2ms  = round((start2ms*1000)*100)/100;

end



