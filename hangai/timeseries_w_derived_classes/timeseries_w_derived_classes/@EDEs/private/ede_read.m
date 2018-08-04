function obj = ede_read(obj,pathname)
obj.source = {pathname};

dipolefile = dir(fullfile(pathname,'*dipol.txt'));
magfile    = dir(fullfile(pathname,'*serialnr_magnetometer.txt'));
if ~isempty(dipolefile)
    dataext = '*.mtd';
    fid = fopen(fullfile(pathname,dipolefile.name));
    obj.dipole(1) = fscanf(fid,'%*s %*s %*s %f %*s',[1 1]);
    tmp = fscanf(fid,'%s',1); % dont understand why this is necessary, but it is.
    obj.dipole(2) = fscanf(fid,'%*s %*s %*s %f %*s',[1 1]);
    if obj.debuglevel==2, disp(['   Dipole lengths:       Ex ' num2str(obj.dipole(1)) ' - Ey ' num2str(obj.dipole(1)) ' (m)']); end
else
    if obj.debuglevel==2, disp('** Warning. could not find dipole file; using default values (unit lengths)'); end
end
if ~isempty(magfile)
    dataext = '*.mts';
    fid = fopen(fullfile(pathname,magfile.name));
    obj.dipole    = [1 1 1];
    obj.Nch       = 3;
    obj.chnames   = {'Bx' 'By' 'Bz'};
    obj.sens_name = {'FGS03e' 'FGS03e' 'FGS03e'};
    obj.lsb       = [1 1 1]*obj.lsb(1)*9.8*4/0.1; % for the fluxgates
    obj.orient    = [0 90 0];
    obj.tilt      = [0 0 90];
    for ich = 1:3
    obj.sens_sn{ich}   = str2num(fscanf(fid,'%*s %*s %*s %*s %s',[1 1]));
    end
%     fscanf(fid,'%*s %*s %*s %*s %*d',[1 1]);
%     tmp = fscanf(fid,'%s',1); % dont understand why this is necessary, but it is.
%     obj.dipole(2) = fscanf(fid,'%*s %*s %*s %f %*s',[1 1]);
    if obj.debuglevel==2, disp(['   Dipole lengths:       Ex ' num2str(obj.dipole(1)) ' - Ey ' num2str(obj.dipole(1)) ' (m)']); end
else
    if obj.debuglevel==2, disp('** Warning. could not find magserialnumberfile; using default values (unit lengths)'); end
end
% data files
mtdfiles = dir(fullfile(pathname,dataext));
% header files
hdfiles  = dir(fullfile(pathname,'edesoh*.txt'));

if isempty(mtdfiles) || isempty(hdfiles) || numel(mtdfiles) ~= numel(hdfiles)
    if obj.debuglevel==1, disp('** Warning. No data files or number of *.mtd files does not mactch number of *.txt files'); end
    return;
else
    if obj.debuglevel, disp(['   found ' num2str(numel(mtdfiles)) ' data files']); end
    Nfiles = numel(mtdfiles);
    %% sort files
    number = [];
    for ifile = 1:Nfiles
        [p, name, ext]= fileparts(mtdfiles(ifile).name);
        name = [name(1:3) 'soh' name(4:end)];
        cont = 1;
        number(ifile)   = str2num(name(23:25));
    end
    [b,ind] = sort(number,'ascend');
    mtdfiles = mtdfiles(ind);
    hdfiles  = hdfiles(ind);
    %% 
    mtd = []; hd = []; cont = 1;
    % test for missing data files
    for ifile = 1:Nfiles
        if cont
            [p, name, ext]= fileparts(mtdfiles(ifile).name);
            name = [name(1:3) 'soh' name(4:end)];
            cont = 1;
            if ~exist(fullfile(pathname,[name '.txt']),'file')
                if obj.debuglevel==2, disp(['** Warning. Can not find file ' fullfile(pathname,[name '.txt'])]); end
                day   = fliplr([str2num(name(14:15)) str2num(name(16:17)) str2num(name(18:19))]);
                day   = datevec(datenum(day)+1);
                day   = [num2str(day(3),'%02d') num2str(day(2),'%02d') num2str(day(1),'%02d')];
                nname = name; nname(14:19) = day;
                if exist(fullfile(pathname,[nname '.txt']),'file')
                    if obj.debuglevel==2, disp(['            >>> Assuming that ' fullfile(pathname,[nname '.txt']) ' is the correct name']); end
                    name = nname;
                else
                    cont = 0;
                    if obj.debuglevel==2, disp(['   - stop here reading data. Please check the data directory ' datapath]); end
                end
            end
        end
        mtd = [mtd {mtdfiles(ifile).name}];
        hd  = [hd {[name '.txt']}];
    end
    obj.mtdfiles = mtd;
    obj.hdfiles  = hd;
    obj.Nfiles   = numel(mtd);
    if strcmp(mtd{1}(1:3),'ede'), 
        obj.system = 'EDE'; 
        obj.systemSN = mtd{1}(6:8);
    end
    % read the header information from the first header file
    ede          = readsoh(fullfile(obj.source{1}, obj.hdfiles{1}));
    obj.starttime= ede.start;
    obj.starttimems = ede.startms;
    obj.srate    = ede.srate;
    Nsmpfile     = ede.Nsmp;
    rlon = num2str(floor(str2num(ede.lon)));
    inddeglon = numel(rlon)-2;
    rlat = num2str(floor(str2num(ede.lat)));
    inddeglat = numel(rlat)-2;
    obj.lat      = str2num(ede.lat(1:inddeglat))+str2num(ede.lat(inddeglat+1:end))/60; % Conversion of coordinates to decimal degrees
    obj.lon      = str2num(ede.lon(1:inddeglon))+str2num(ede.lon(inddeglon+1:end))/60;
    obj.ppsdelay = ede.timeshift;
    [stop,stopms,start2,start2ms]     = get_stoptime(obj.starttime,obj.starttimems,Nsmpfile,obj.srate);
    startstopfile = [obj.starttime obj.starttimems stop stopms];
    for ifile = 2:obj.Nfiles
        ede          = readsoh(fullfile(obj.source{1}, obj.hdfiles{ifile}));        
        if ede.start == start2 & ede.startms == start2ms % continous recording    
            [stop,stopms,start2,start2ms]     = get_stoptime(ede.start,ede.startms,ede.Nsmp,ede.srate);
                startstopfile = [startstopfile; ...
                    [ede.start ede.startms stop stopms]];
        else % discontinous recording or some bug in the header file
            if obj.debuglevel == 2
                disp(['** Warning: Detected time gap in file ' obj.hdfiles{ifile}]);
                fprintf(1,'            >>> Starttime should be a %d %d %d %d %d %d + %.2f us\n',start2, start2ms);
                fprintf(1,'                but was found to be   %d %d %d %d %d %d + %.2f us\n',ede.start, ede.startms);
                fprintf(1,'                This is probably an EDE bug, and we try to ignore it :-)\n');     
            end
            % pretending that the data are correct, but the entries in the text file are wrong
            ede.start = start2;
            ede.startms = start2ms;
            [stop,stopms,start2,start2ms]     = get_stoptime(ede.start,ede.startms,ede.Nsmp,ede.srate);
            startstopfile = [startstopfile; ...
                    [ede.start ede.startms stop stopms]];
        end
        Nsmpfile = [Nsmpfile ede.Nsmp];
    end
    obj.startstopfile = startstopfile;
    obj.Nsmpfile      = [cumsum([1 Nsmpfile(1:end-1)])' cumsum(Nsmpfile)'];
    obj.Nsmp          = sum(Nsmpfile);
    obj.stoptime      = stop;
    obj.stoptimems    = stopms;
end
if obj.debuglevel == 2
    disp([' + Station details for site ' obj.name ' - run ' obj.run ':']);
    fprintf(1,'   System:\t\t\t\t %s %s\n',obj.system, obj.systemSN);
    fprintf(1,'   Latitude:\t\t\t %.6f ?\n',obj.lat);
    fprintf(1,'   Longitude:\t\t\t %.6f ?\n',obj.lon);
    fprintf(1,'   Sampling rate \t\t %d Hz\n',obj.srate);
    fprintf(1,'   Start or recording: \t %s',obj.starttimestr);
    fprintf(1,' + %08.4f ms (1st sample)\n',obj.starttimems);
    fprintf(1,'   Stop or recording: \t %s',obj.stoptimestr);
    fprintf(1,' + %08.4f ms (last sample)\n',obj.stoptimems);
    fprintf(1,'   PPS Delay: \t\t\t %.2f us\n',obj.ppsdelay*1000000);
end
% test if dipole_file exist

end
function     [stop,stopms,start2,start2ms]     = get_stoptime(start,startms,Nsmp,srate)
% stop is the time of the last recording of the current file
% start 2 is the time of the first sample in the next file
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

function ede = readsoh(fname)

version = 1; % To store file version, 1=old version (november measurements),  2 = new (as of 24.01.2014)
%ede.tshift  = 0.0002; % Time shift of ede (only for 500Hz? I don't know..)

fid = fopen(fname,'r','b');
tmp = fgetl(fid); % tmp then contains something like:  "SYSTEMSTARTZEIT : 111834.018" -> row 1 of soh-file
if ~isempty(strfind(tmp,'SYSTEMSTARTZEIT'))
    version = 1;
elseif ~isempty(strfind(tmp,'EDE NR'))
    version = 3;
else
    version = 2;    
end

if(version==1) %% Routines for old File Version:
    %disp('Reading: EDE File Version Nov. 2013');
    tmp = fgetl(fid); % tmp contains something like: "START DATUM     : 311013" -> row 2 of soh-file
    date = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]); % e.g.: "311013" for 31. Oktober 2013
    tmp = fgetl(fid); % Latitude
    ede.lat = (sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]));
    tmp = fgetl(fid); % Longitude
    ede.lon = (sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]));
    tmp = fgetl(fid);
    tmp = fgetl(fid); % e.g.:  "SAMPLERATE      : 500 HZ"
    ede.srate = sscanf(tmp,'%*s %*s %d Hz',[1]);
    tmp = fgetl(fid); % e.g.  DELAY FROM 1PPS : 80.290000 us
    ede.timeshift = str2num(sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]))*10^(-6);
    tmp = fgetl(fid); % line after that...
    starttime = sscanf(tmp,'%*s %*s %d %d %d',[3])'; %  array size 1x3, e.g. [11,18,37]
    ede.start = [2000+str2num(date(5:6)) str2num(date(3:4)) str2num(date(1:2)) starttime]; % array size 1x6, e.g. [2013,10,31,11,18,37]
    tmp = fgetl(fid); tmp = fgetl(fid); % e.g.  "SAMPLE COUNTER  : 3546112"
    ede.Nsmp = sscanf(tmp,'%*s %*s %*s %d',[1])'; % Number of samples as it is defined in soh-file
end
if(version==2)
    %disp('Reading: EDE File Version 2014');
    tmp = fgetl(fid); % tmp contains something like: "START DATUM     : 311013" -> row 2 of soh-file
    date = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]); % e.g.: "311013" for 31. Oktober 2013
    tmp = fgetl(fid); % Latitude
    ede.lat = (sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]));
    tmp = fgetl(fid); % Longitude
    ede.lon = (sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]));
    tmp = fgetl(fid); % e.g.  DELAY FROM 1PPS : 80.290000 us
    ede.timeshift = str2num(sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]))*10^(-6);
    tmp = fgetl(fid); % Read empty line
    tmp = fgetl(fid); % e.g.:  "SAMPLERATE      : 500 HZ"
    ede.srate = sscanf(tmp,'%*s %*s %d Hz',[1]);
    tmp = fgetl(fid); % line after that...
    
    % Now: Distinguish between file version of Jan. 2014 and Febr. 2014
    if(strcmp(tmp(2:10),'STARTTIME'))
        %disp('File Version: Jan. 2014');
        starttime = sscanf(tmp,'%*s %*s %d %d %d %d',[4])'; %  array size 1x4, e.g. [11,18,37,324]
        %             ede.start = [2000+str2num(date(5:6)) str2num(date(3:4)) str2num(date(1:2)) starttime(1:3)]; % array size 1x6
        ede.start = [2000+str2num(date(4:5)) str2num(date(2:3)) str2num(date(1)) starttime(1:3)]; % array size 1x6, e.g. [2013,10,31,11,18,37]
        ede.start = ede.start + [0 0 0 0 0 starttime(4)/1000];
        tmp = fgetl(fid); % Line with stop date
        tmp = fgetl(fid); % Empty line
        tmp = fgetl(fid); tmp = fgetl(fid); % e.g.  "SAMPLE COUNTER  : 3546112"
        ede.Nsmp = sscanf(tmp,'%*s %*s %*s %d',[1])'; % Number of samples as it is defined in soh-file
    else
        %disp('File Version: Feb. 2014');
        starttime = sscanf(tmp,'%*s %*s %d %d %d %d',[4])'; %  array size 1x4, e.g. [11,18,37,324]
        tmp = fgetl(fid); % line containing start date
        startdate = sscanf(tmp,'%*s %*s %d %d %d',[3])'; %  array size 1x3
        ede.start = [startdate(3) startdate(2) startdate(1) starttime(1:3)]; % array size 1x6, e.g. [2013,10,31,11,18,37]
        ede.startms = starttime(4)-1000/ede.srate;
        % the folowing lines are to shift the data by one sample
        start = ede.start; start(6) = start(6)+ede.startms/1000;
        start = datevec(datenum(start));
        startms = round((start(6)-floor(start(6)))*1000*100)/100;
        start(6) = floor(start(6));
        ede.start = start;
        ede.startms = startms;
        
        %         ede.start = ede.start + [0 0 0 0 0 starttime(4)/1000];
        %             es = datevec(datenum(ede.start)-1/ede.srate/3600/24);
        %             es6 = floor(es(6));
        %             es6ms = round((es(6)-floor(es(6)))*1000);
        %             ede.start(6) = es6+str2num(['0.' num2str(es6ms)]);
        tmp = fgetl(fid); % Empty line
        tmp = fgetl(fid); % Line with stop time
        tmp = fgetl(fid); % Line with stop date
        tmp = fgetl(fid); % Empty line
        tmp = fgetl(fid); % e.g.  "SAMPLE COUNTER  : 3546112"
        ede.Nsmp = sscanf(tmp,'%*s %*s %*s %d',[1])'; % Number of samples as it is defined in soh-file
    end
    
end
if(version==3)
    %disp('Reading: EDE File Version 2014');
    obj.systemSN = sscanf(tmp,' %*s %*s %s');
    tmp = fgetl(fid);
    tmp = fgetl(fid); % tmp contains something like: "START DATUM     : 311013" -> row 2 of soh-file
    date = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]); % e.g.: "311013" for 31. Oktober 2013
    tmp = fgetl(fid); % Latitude
    ede.lat = (sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]));
    tmp = fgetl(fid); % Longitude
    ede.lon = (sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]));
    tmp = fgetl(fid); % e.g.  DELAY FROM 1PPS : 80.290000 us
    ede.timeshift = str2num(sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]))*10^(-6);
    tmp = fgetl(fid); % Read empty line
    tmp = fgetl(fid); % e.g.:  "SAMPLERATE      : 500 HZ"
    ede.srate = sscanf(tmp,'%*s %*s  %d Hz',[1]);
    tmp = fgetl(fid); % line after that...
    
    % Now: Distinguish between file version of Jan. 2014 and Febr. 2014
    if ~isempty(strfind(tmp,'STARTTIME'))
        %disp('File Version: Jan. 2014');
        starttime = sscanf(tmp,'%*s %*s %d %d %d %d',[4])'; %  array size 1x4, e.g. [11,18,37,324]
        %             ede.start = [2000+str2num(date(5:6)) str2num(date(3:4)) str2num(date(1:2)) starttime(1:3)]; % array size 1x6
        ede.start = [2000+str2num(date(4:5)) str2num(date(2:3)) str2num(date(1)) starttime(1:3)]; % array size 1x6, e.g. [2013,10,31,11,18,37]
        ede.start = ede.start + [0 0 0 0 0 starttime(4)/1000];
        tmp = fgetl(fid); % Line with stop date
        tmp = fgetl(fid); % Empty line
        tmp = fgetl(fid); tmp = fgetl(fid); % e.g.  "SAMPLE COUNTER  : 3546112"
        ede.Nsmp = sscanf(tmp,'%*s %*s %*s %d',[1])'; % Number of samples as it is defined in soh-file
    else
        %disp('File Version: Feb. 2014');
        starttime = sscanf(tmp,'%*s %*s %d %d %d %d',[4])'; %  array size 1x4, e.g. [11,18,37,324]
        tmp = fgetl(fid); % line containing start date
        startdate = sscanf(tmp,'%*s %*s %d %d %d',[3])'; %  array size 1x3
        ede.start = [startdate(3) startdate(2) startdate(1) starttime(1:3)]; % array size 1x6, e.g. [2013,10,31,11,18,37]
        ede.startms = starttime(4);%-1000/ede.srate;
        % the folowing lines are to shift the data by one sample
        start = ede.start; start(6) = start(6)+ede.startms/1000;
        start = datevec(datenum(start));
        startms = round((start(6)-floor(start(6)))*1000*100)/100;
        start(6) = floor(start(6));
        ede.start = start;
        ede.startms = startms;
        
        %         ede.start = ede.start + [0 0 0 0 0 starttime(4)/1000];
        %             es = datevec(datenum(ede.start)-1/ede.srate/3600/24);
        %             es6 = floor(es(6));
        %             es6ms = round((es(6)-floor(es(6)))*1000);
        %             ede.start(6) = es6+str2num(['0.' num2str(es6ms)]);
        tmp = fgetl(fid); % Empty line
        tmp = fgetl(fid); % Line with stop time
        tmp = fgetl(fid); % Line with stop date
        tmp = fgetl(fid); % Empty line
        tmp = fgetl(fid); % e.g.  "SAMPLE COUNTER  : 3546112"
        ede.Nsmp = sscanf(tmp,'%*s %*s %*s %d',[1])'; % Number of samples as it is defined in soh-file
    end
    
end
fclose(fid);
end