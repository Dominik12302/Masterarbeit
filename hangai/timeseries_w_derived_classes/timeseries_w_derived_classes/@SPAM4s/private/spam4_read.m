function obj = spam4_read(obj, pathname)
obj.source = {pathname};
% data files
rawfiles = dir(fullfile(pathname,'*.RAW'));
% XTR files
xtrfiles = dir(fullfile(pathname,'*.XTR'));
if isempty(rawfiles) || isempty(xtrfiles) || numel(rawfiles) ~= numel(xtrfiles)
    if obj.debuglevel==2, disp('** Warning. No data files or number of *.RAW files does not match number of *.XTR files'); end
    return;
else
    if obj.debuglevel, disp(['   found ' num2str(numel(rawfiles)) ' data files']); end
    Nfiles = numel(rawfiles);
    % sort files after time
    % spam files seem to have number ...R###_W###.RAW in the old version
    % and ...R###_T####.RAW in the new version
    number = [];
    for ind = 1 : Nfiles
        if strcmpi(rawfiles(ind).name(end-7),'W')       % old file naming convention
            number = [number; str2num(rawfiles(ind).name(end-7:end-9)) str2num(rawfiles(ind).name(end-6:end-4))];
        elseif strcmpi(rawfiles(ind).name(end-10),'T')   % new file naming convention
            number = [number; str2num(rawfiles(ind).name(end-18:end-12)) str2num(rawfiles(ind).name(end-9:end-4))];
        else
            disp(' - ERROR: can not understand root names of raw files!');
            return
        end
    end
    [dummy, neworder] = sortrows(number);
    rawfiles = rawfiles(neworder);

    raw = []; xtr = []; 
   
    % collect filenames
    for ifile = 1:Nfiles
        % test for missing data files ... (NOT IMPLEMENTED NOT HAPPENING) 
        
        [p, name, ext]= fileparts(rawfiles(ifile).name);     
        raw = [raw {rawfiles(ifile).name}];
        xtr  = [xtr {[name '.XTR']}];
    end
    obj.rawfiles = raw;
    obj.xtrfiles  = xtr;
    obj.Nfiles   = numel(raw);
    obj.system = 'SP4';
    % read the header information from the first header file
    nshift = 0; % shift by one sample for spam data
    spam4 = read_xtr(fullfile(obj.source{1},obj.xtrfiles{1}),nshift);
    spam4JK = read_xtr_JK(fullfile(obj.source{1},obj.xtrfiles{1}));
    
    for isensor = 1:numel(spam4.sens)
        if strfind(spam4.sens{isensor},'Metronix') 
            if strfind(spam4.sens{isensor},'011')
                sens_name{isensor} = 'MFS11 ';
            elseif strfind(spam4.sens{isensor},'010')
                sens_name{isensor} = 'MFS10 ';
            elseif strfind(spam4.sens{isensor},'007')
                sens_name{isensor} = 'MFS07 ';
            elseif strfind(spam4.sens{isensor},'006')
                sens_name{isensor} = 'MFS06 ';
            elseif strfind(spam4.sens{isensor},'005')
                sens_name{isensor} = 'MFS05 ';
            end
        elseif strfind(spam4.sens{isensor},'Electrode')
            if strfind(spam4.sens{isensor},'AgAgCl')
                sens_name{isensor} = 'AgAgCl';
            elseif strfind(spam4.sens{isensor},'PbCl')
                sens_name{isensor} = 'PbCl  ';
            end
        else
            sens_name{isensor} = 'Unknown';
        end
    end
            
    obj.sens_name = sens_name;
    obj.starttime= spam4.start;
    obj.starttimems = spam4.startms;
    obj.srate    = abs(spam4.sfreq)^(-sign(spam4.sfreq));
    Nsmpfile     = spam4.samples;
    obj.lat      = spam4.lat;
    obj.lon      = spam4.lon;
    obj.ppsdelay = 0; % is this important for SPAM data?
    [stop,stopms,start2,start2ms]     = get_stoptime(obj.starttime,obj.starttimems,Nsmpfile,obj.srate);
    startstopfile = [obj.starttime obj.starttimems stop stopms];
    for ifile = 2:obj.Nfiles
        spam4 = read_xtr(fullfile(obj.source{1},obj.xtrfiles{ifile}),nshift);        
        if all(spam4.start == start2) && spam4.startms == start2ms % continous recording    
            [stop,stopms,start2,start2ms]     = get_stoptime(spam4.start,spam4.startms,spam4.samples,obj.srate);
                startstopfile = [startstopfile; ...
                    [spam4.start spam4.startms stop stopms]];
        else % discontinous recording or some bug in the header file
            if obj.debuglevel == 2
                disp(['** Warning: Detected time gap in file ' obj.xtrfiles{ifile}]);
                fprintf(1,'            >>> Starttime should be a %d %d %d %d %d %d + %.2f us\n',start2, start2ms);
                fprintf(1,'                but was found to be   %d %d %d %d %d %d + %.2f us\n',spam4.start, spam4.startms);
                fprintf(1,'                ignoring... \n');     
            end
            % pretending that the data are correct, but the entries in the text file are wrong
            spam4.start = start2;
            spam4.startms = start2ms;
            [stop,stopms,start2,start2ms]     = get_stoptime(spam4.start,spam4.startms,spam4.samples,obj.srate);
            startstopfile = [startstopfile; ...
                    [spam4.start spam4.startms stop stopms]];
        end
        Nsmpfile = [Nsmpfile spam4.samples];
    end
    obj.startstopfile = startstopfile;
    obj.Nsmpfile      = [cumsum([1 Nsmpfile(1:end-1)])' cumsum(Nsmpfile)'];
    obj.Nsmp          = sum(floor(Nsmpfile));
    obj.stoptime      = stop;
    obj.stoptimems    = stopms;
end

if obj.debuglevel == 2
    disp([' + Station details for site ' obj.name ' - run ' obj.run ':']);
    fprintf(1,'   System:\t\t\t\t %s %s\n',obj.system, obj.systemSN);
    fprintf(1,'   Latitude:\t\t\t %.6f ???\n',obj.lat);
    fprintf(1,'   Longitude:\t\t\t %.6f ???\n',obj.lon);
    fprintf(1,'   Sampling rate \t\t %d Hz\n',obj.srate);
    fprintf(1,'   Start or recording: \t %s',obj.starttimestr);
    fprintf(1,' + %08.4f ms (1st sample)\n',obj.starttimems);
    fprintf(1,'   Stop or recording: \t %s',obj.stoptimestr);
    fprintf(1,' + %08.4f ms (last sample)\n',obj.stoptimems);
    fprintf(1,'   PPS Delay: \t\t\t %.2f us\n',obj.ppsdelay*1000000);
end

obj.dipole = spam4.dipol_length;
obj.orient = spam4.sens_orient;
obj.tilt   = spam4.sens_tilt;
for is = 1:numel(spam4.sens_no)
    if ~isempty(spam4.sens_no{is}), obj.sens_sn{is} = str2num(spam4.sens_no{is});
    else obj.sens_sn{is} = 0;
    end
end
% obj.sens_sn = spam4.sens_sn;
obj.lat = spam4.lat;
obj.lon = spam4.lon;
obj.alt = spam4.elev;
obj.chnames = spam4.ch_type;
obj.Nch = numel(spam4.ch_no);
for ich = 1:obj.Nch
    if strcmp(obj.chnames{ich}(1),'B') || strcmp(obj.chnames{ich}(1),'H')
        obj.lsb(ich) = 1e6*spam4.scaling(ich)/2^28;
    elseif strcmp(obj.chnames{ich}(1),'E')
        obj.lsb(ich) = -1e6*spam4.scaling(ich)/2^28;
    end
end

end

function     [stop,stopms,start2,start2ms]     = get_stoptime(start,startms,Nsmp,srate)
% stop is the time of the last recording of the current file
% start 2 is the time of the first sample in the next file
start(6) = start(6)+startms/1000+(double(Nsmp)-1)/(srate);
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
