%%
% definition of base class EMSites which other classes (EDEs, ADUs, SPAM4s,
% IMUs
% ...) are derived from
%
classdef EMSites
    properties
        source       = {''};    % directory of mtd/txt files. Each
        name         = '000';   % stationname
        system
        systemSN     = '001';
        run          = '000';
        lat          = 0;                % geog N decimal degree
        lon          = 0;                % geog E
        alt          = 0;                % in m
        lsb                              % conversion of int to mV
        Nch                              % No of channels
        chnames                          % names of channels
        dipole                           % dipole length
        % CODE4+ TO BE added
        % coil_static
        premult      
        chorder      
        orient                           % degrees from north
        tilt                             % tilt (deviation from horizontal position)
        sens_sn                          % serial numbers
        sens_name    
        srate        = 0;                % sampling rate (freq)
        Nsmp         = 0;                % total number of samples
        starttime    = [0 0 0 0 0 0];    %  Example: [2013,10,24,12,45,07]
        starttimems  = 0;                % if needed additional milliseconds of start time
        stoptime     = [0 0 0 0 0 0];    %  Example: [2013,10,24,12,45,07]
        stoptimems   = 0;                % if needed additional milliseconds of start time
        ppsdelay     = 0;                % delay of samples
        reftime      = [1970 1 1 0 0 0]; % Reference time which is used fot time axis, default: 1. Jan 1970
        Nfiles       = 0;                
        startstopfile= [];
        Nsmpfile     = 0;                % total number of samples in file        
        usech                            % read channels <usech>
        usesmp       = [1 2];            % time from which to use samples. Format:[[yyyy,mm,dd,hh,mm,ss] [yyyy,mm,dd,hh,mm,ss]], Example: [[2013,10,24,12,45,07] [2013,10,24,12,47,07]]
        dec          = 1;                % decimate by a factor of dec
        resmpfreq    = 0;                % resample to  resmplfreq. 0 for no resmapling
        delay_filter = 0;                % delay in seconds for delay_filter. applied in for get.dataint
        notch_filter = 0;                % must be N x 2, N frequencies and N (relative) filter widths
        debuglevel   = 1;
        atsoutdir    = {''};             % output direct. for time series converted into ats; empty string implies to use obj.source as the output dir
        afcoutdir    = {''};             % output direct. for fourier coefficient file; empty string implies to use obj.source as the output dir                
    end
    properties (Dependent = true,  SetAccess = private)
        starttimestr    % Starttime as a string
        stoptimestr
        usetime         % time ranges to be used; derived from usesmp
        usefiles        % files which contain the data defined by usesmp
        dataint         % integer data as stored in the file; these data can not be resampled
        dataproc        % resampled or decimated data; if no action is required, dataproc is the same as dataint
        data            % the dataproc after multiplication by lsb
        dataphys        % the dataproc converted into electric field (mV/m)
        smp             % samples relative to start of recording
        rsmp            % samples relative to reftime
        trs             % seconds relative to reftime
        trh             % hours relative to reftime
        trd             % days relative to reftime
        utc             % utc time axis
        usesmpr         % samples used for resampling; these are a subset of usesmp, such that it fits exactl into a full second scheme
        Nsmpr           % number of samples of the resampled dat
        smpr            % samples of the resampled data relative to start of recording; in case of a starttime with fractional seconds, this will be rounded
        rsmpr           % samples of the resampled data relative to reftime
        trsr            % seconds of the resampled data relative to reftime of the resampled data
        trhr            % hours of the resampled data relative to reftime  of the resampled data
        trdr            % days of the resampled data relative to reftime  of the resampled data
        utcr            % utc time axis of the resampled data
        
        atsheader       % this is an ats header for each channel
        atsfile         % this writes the data into ats format
    end
    properties (Dependent = false,  SetAccess = private)
        atswrite     = 0;                % logical flag to output ats files
    end    
    methods
        function obj = EMSites(varargin)
        end
        function starttimestr = get.starttimestr(obj)
            starttimestr = datestr(obj.starttime);
        end
        function stoptimestr = get.stoptimestr(obj)
            stoptimestr = datestr(obj.stoptime);
        end
        function smp        = get.smp(obj)
            use = obj.usesmp;
            smp = [use(1):use(2)];
        end
        function rsmp       = get.rsmp(obj)
            rsmp  = (etime(obj.starttime,obj.reftime)+obj.starttimems/1000)*obj.srate+obj.smp;
        end
        function trs        = get.trs(obj)
            trs  = etime(obj.starttime,obj.reftime)+obj.starttimems/1000+(obj.smp-1)/obj.srate;
        end
        function trh        = get.trh(obj)
            trh  = (etime(obj.starttime,obj.reftime)+obj.starttimems/1000+(obj.smp-1)/obj.srate)/3600;
        end
        function trd        = get.trd(obj)
            trd  = (etime(obj.starttime,obj.reftime)+obj.starttimems/1000+(obj.smp-1)/obj.srate)/3600/24;
        end
        function utc        = get.utc(obj)
            utc  = datenum(obj.reftime)+obj.trd;
        end
        function usesmpr    = get.usesmpr(obj)
            if obj.resmpfreq
                usesmp0 = obj.usesmp;
                if usesmp0(1)<1 || usesmp0(2) >= obj.Nsmp,
                    usesmp  = [max(usesmp0(1),1) min(usesmp0(2),obj.Nsmp)];
                    if obj.debuglevel, disp(['** Warning: adjusting obj.usesmp to bnds [ ' num2str(usesmp0(1),'%08d') ' ' num2str(usesmp0(2),'%08d') ']']); end
                else
                    usesmp = usesmp0;
                end
                % distance of first sample from full second
                dist = (usesmp(1)-1)/obj.srate+obj.starttimems/1000;
                dist =  round((dist-floor(dist))*obj.srate);
                if dist > 0 % ok, try to remove one more second
                    if obj.debuglevel, disp(['** Warning: omitting first ' num2str(obj.srate-dist) ' samples and start at next full second']);end
                end
                if usesmp(1)-dist+obj.srate <= obj.Nsmp % ok, can start here
                    if dist>0
                        frst = usesmp(1)-dist+obj.srate;
                    else
                        frst = usesmp(1);
                    end
                else
                    disp('** Error: segment too close to end of recording: check obj.usesmp');
                    return;
                end
                dist = usesmp(2)/obj.srate+obj.starttimems/1000;
                dist = round((dist-floor(dist))*obj.srate); % distamce in number of seconds from the previous full second ( minus one sample)
                if dist > 0
                    if obj.debuglevel, disp(['** Warning: omitting last ' num2str(dist) ' samples and stop at prev. full second (minus one sample)']);end
                end
                if usesmp(2)-dist >= frst-1+obj.srate % ok, try to add one more second
                    last = usesmp(2)-dist;
                else
                    disp('** Error: segment too short: check obj.usesmp');
                    return;
                end
                usesmpr = [frst last];
            else
                usesmpr = obj.usesmp;
            end
        end
        function usefiles   = get.usefiles(obj)
            usefiles = find(obj.usesmp(1)<=obj.Nsmpfile(:,2) & obj.usesmp(2)>=obj.Nsmpfile(:,1));
        end        
        function Nsmpr      = get.Nsmpr(obj)
            Nsmpr = ceil(diff(obj.usesmpr)+1)*obj.resmpfreq/obj.srate;
        end
        function smpr       = get.smpr(obj)
            if obj.resmpfreq
                frst = obj.usesmpr(1);
                frstsmp = (frst-1)*obj.resmpfreq/obj.srate;
                smpr = (1:obj.Nsmpr)+frstsmp;
            else
                smpr = obj.smp;
            end
        end
        function rsmpr      = get.rsmpr(obj)
            if obj.resmpfreq
                rsmpr  = (etime(obj.starttime,obj.reftime)+obj.starttimems/1000)*obj.resmpfreq+obj.smpr;
            else
                rsmpr = obj.rsmp;
            end
        end
        function trsr       = get.trsr(obj)
            trsr  = etime(obj.starttime,obj.reftime)+obj.starttimems/1000+(obj.smpr-1)/obj.resmpfreq;
        end
        function trhr       = get.trhr(obj)
            trhr  = (etime(obj.starttime,obj.reftime)+obj.starttimems/1000+(obj.smpr-1)/obj.resmpfreq)/3600;
        end
        function trdr       = get.trdr(obj)
            trdr  = (etime(obj.starttime,obj.reftime)+obj.starttimems/1000+(obj.smpr-1)/obj.resmpfreq)/3600/24;
        end
        function utcr       = get.utcr(obj)
            utcr  = datenum(obj.reftime)+obj.trdr;
        end
        function usesmp     = get_usesmp(obj,usetime)
            if isempty(usetime)
                usesmp = [1 obj.Nsmp];
            elseif numel(usetime)==12
                Nsamples = etime(usetime(7:end),usetime(1:6))*obj.srate;                
                startsmp = 1+round(etime(usetime(1:6),obj.starttime)*obj.srate-obj.starttimems*obj.srate/1000);
                usesmp = startsmp+[0 Nsamples-1];
                if usesmp(2) < 2, usesmp = []; return; end
                if usesmp(1) < 1, usesmp(1) = 1; end
                if usesmp(1) > obj.Nsmp-1, usesmp = []; return; end
                if usesmp(2) > obj.Nsmp, usesmp(2) = obj.Nsmp; end
            else
                disp('**Error: format of obj.usetime must be [yyyy mm dd hh mm ss yyyy mm dd hh mm ss]');
                return;
            end
        end        
        function varargout  = plot(obj,varargin)
            if nargin
                if any(strcmp(varargin,'time'))
                    ind = find(strcmp(varargin,'time'));
                    time = varargin{ind+1};
                else
                    time = 'smp';
                end
                if any(strcmp(varargin,'units'))
                    ind = find(strcmp(varargin,'units'));
                    units = varargin{ind+1};
                else
                    units = 'mV';
                end
                if any(strcmp(varargin,'color'))
                    ind = find(strcmp(varargin,'color'));
                    col = varargin{ind+1};
                else
                    col = 'k';
                end
                if any(strcmp(varargin,'elim'))
                    ind = find(strcmp(varargin,'elim'));
                    elim = varargin{ind+1};
                else
                    elim = 'auto';
                end
                if any(strcmp(varargin,'axes'))
                    ind = find(strcmp(varargin,'axes'));
                    hax = varargin{ind+1};
                    %                     col = [1 0 0];
                else
                    hax = [];
                    %                     col = [0 0 0];
                end
                if any(strcmp(varargin,'factor'))
                    ind = find(strcmp(varargin,'factor'));
                    fac = varargin{ind+1};
                else
                    fac = [];
                end
            else
                time  = 'smp';
                units = 'mV';
                elim  = 'auto';
                hax   =  [];
                fac   =  [];
            end
            
            if isempty(hax)
                figure;
                set(gcf,'Position',[42 309  1170 663]);
                for ich = 1:numel(obj.usech)
                    if strcmp(units,'physical') && ~isempty(strfind(obj.chnames{ich},'E'))
                        ylab = 'mV/m'; 
                    elseif strcmp(units,'physical') && ~isempty(strfind(obj.chnames{ich},'E'))
                        ylab = 'nT'; 
                    else
                        ylab = units;
                    end
                    
                    hax(ich) = axes;
                    h   = 0.8/numel(obj.usech)-0.03;
                    if ich == numel(obj.usech)
                        h0       = (numel(obj.usech)-ich)*h+0.15;
                        set(hax(ich),'Position',[0.15 h0 0.8 h],'Fontsize',14,'box','on','Nextplot','add','XGrid','on', 'Ygrid','on');
                        xlabel(['time (' time ')'],'Fontsize',14);
                        ylabel([obj.chnames{ich} ' (' ylab ')']);
                        ylim(elim);
                    elseif ich == 1
                        h0       = (numel(obj.usech)-ich)*h+0.15;
                        set(hax(ich),'Position',[0.15 h0+(numel(obj.usech)-ich)*0.03 0.8 h],'Fontsize',14,'box','on','XAxisLocation','top','Nextplot','add','XGrid','on', 'Ygrid','on');
                        ylabel([obj.chnames{ich} ' (' ylab ')'],'Fontsize',14);
                        ylim(elim);
                    else
                        h0       = (numel(obj.usech)-ich)*h+0.15;
                        set(hax(ich),'Position',[0.15 h0+(numel(obj.usech)-ich)*0.03 0.8 h],'Fontsize',14,'box','on','XTick',[],'Nextplot','add','XGrid','on', 'Ygrid','on');
                        ylabel([obj.chnames{ich} ' (' ylab ')'],'Fontsize',14);
                        ylim(elim);
                    end
                end
            else
                if numel(hax) ~= numel(obj.usech)
                    disp('** Error plot: Number of axis handles must match number of channels to plot (check obj.usech)');
                    return
                else
                    for ich = 1:numel(hax), set(hax(ich),'Nextplot','add'); end
                end
            end
            if obj.resmpfreq && ~strcmp(units,'int')
                switch time
                    case 'smp' ,        t = obj.smpr;
                    case 'relative smp' ,t = obj.rsmpr;
                    case 'relative s',  t = obj.trsr;
                    case 'relative h',  t = obj.trhr;
                    case 'relative d',  t = obj.trdr;
                    case {'utc' 'UTC'}, t = obj.utcr;                       
                    otherwise, disp(['** Error plot: unknown time format <' time '>']);
                end
                switch units
                    case 'mV',       data = obj.data;
                    case 'IMU',      data = obj.data;
                    case 'IMU',      data = obj.data;
                    case {'physical', 'mV/m', 'mV/nT'}, data = obj.dataphys;
                    otherwise, disp(['** Error plot: unknown data scaling <' units '>']);
                end
            else
                switch time
                    case 'smp' ,        t = obj.smp;
                    case 'relative smp' ,t = obj.rsmp;
                    case 'relative s',  t = obj.trs;
                    case 'relative h',  t = obj.trh;
                    case 'relative d',  t = obj.trd;
                    case {'utc' 'UTC'}, t = obj.utc;
                    otherwise, disp(['** Error plot: unknown time format <' time '>']);
                end
                switch units
                    case 'int' ,     data = obj.dataint; 
                    case 'mV',       data = obj.data;
                    case 'IMU',      data = obj.data;
                    case {'physical', 'mV/m', 'mV/nT'}, data = obj.dataphys;
                    otherwise, disp(['** Error plot: unknown data scaling <' units '>']);
                end
                
            end
            if ~isempty(fac)
                for ich = 1:numel(obj.usech)
                    data(ich,:) = data(ich,:)*fac(ich);
                end
            end
            for ich = 1:numel(obj.usech)
                data(ich,:) = detrend(data(ich,:));
                plot(hax(ich),t,data(ich,:)-mean(data(ich,:)),'color',col,'Linewidth',2)
                switch time
                    case {'utc','UTC'}, datetick(hax(ich),'x','keeplimits');
                end
            end
            if nargout, varargout = {hax}; else varargout = {}; end
        end     
        function dataproc   = get.dataproc(obj)
            if obj.debuglevel == 1
                disp([' - reading samples ' num2str(obj.usesmp(1),'%09d') '-' num2str(obj.usesmp(2),'%09d') ' from ' ...
                    fullfile(obj.source{1},'*.XXX') ' ...']);
            end
            
            % JK
            % resmpfreq get's set somewhere to identical to srate... 
            % probably because writing only happens if the code enters in
            % the second case of the if below. Consider finding out where
            % this happens and clean it up
            if (~obj.resmpfreq ) && obj.dec == 1            
                dataproc = obj.dataint;                
            elseif obj.resmpfreq > 0
                % resample data
                % use packages of 60 min
                dataproc = [];
                if obj.debuglevel, disp([' - resampling data to ' num2str(obj.resmpfreq) ' Hz']); end
                usesmp0 = obj.usesmp;
                usesmpr = obj.usesmpr;
                frst = usesmpr(1); last = usesmpr(2);
                N       = 1*60*60*obj.srate;              
                Ns = floor((diff([frst last])+1)/N);
                rest = (diff([frst last])+1)-Ns*N; 
                if obj.atswrite % open atsfile and write header, if requested
                    atsheader    = obj.atsheader;
                    if isempty(obj.atsoutdir{1}),obj.atsoutdir = obj.source; else
                        if ~exist(obj.atsoutdir{1},'file'),
                            if ~mkdir(obj.atsoutdir{1});
                            disp(['** Error: output directory ' obj.atsoutdir{1} ' does not exist!']);
                            return
                            end
                        end
                    end
                    for ich = 1:numel(obj.usech)
                        atsfile{ich} = write_ats_header(atsheader(ich), obj.atsoutdir, obj.debuglevel);
                    end
                    dataproc = atsfile;
                end
                
                for is = 1:Ns
                    if frst-obj.srate >= 1 % start srate samples to the left
                        addleft = 1;
                        left = frst-obj.srate;
                        Nsamples = N+2*obj.srate;
                    else % start with frst
                        addleft = 0;
                        left = frst;
                        Nsamples = N+1*obj.srate;
                    end
                    if left+Nsamples <=obj.Nsmp
                        addright = 1;
                        right = left+Nsamples-1;
                    else
                        addright = 0;
                        right = left+Nsamples-obj.srate-1;
                    end
                    obj.usesmp = [left right];
                    tmpdata = obj.dataint;
                    tmpdatar = [];
                    %                     smpresampled = 1:ceil((Nsamples+1)*512/500);
                    %                     tresampled   = [0:Nsamples]/obj.resmpfreq;
                    
                    for ich = 1:numel(obj.usech)
                        if obj.resmpfreq < obj.srate
                            tmpdatar(ich,:) = resample(tmpdata(ich,:)',obj.resmpfreq,obj.srate)';
                        elseif obj.resmpfreq > obj.srate
                            t = [0:(numel(tmpdata(1,:))-1)];
                            tr= [0:(numel(t)*obj.resmpfreq/obj.srate-1)]*obj.srate/obj.resmpfreq;
                            tmpdatar(ich,:) = interp1(t,tmpdata(ich,:),tr,'spline');
                        else
                            tmpdatar(ich,:) = tmpdata(ich,:);
                        end
                    end
                    if addleft,  tmpdatar = tmpdatar(:,obj.resmpfreq+1:end); end
                    if addright, tmpdatar = tmpdatar(:,1:end-obj.resmpfreq); end
                    if obj.atswrite % output to atsfile
                        for ich = 1:numel(obj.usech)
                            fid = fopen(atsfile{ich},'a');
                            fwrite(fid,int32(tmpdatar(ich,:)),'int32');
                            fclose(fid);
                        end
                    else % keep in memory
                        dataproc = [dataproc tmpdatar];
                    end
                    frst = frst+N;
                end
                N = rest;
                if frst-obj.srate >= 1 % start srate samples to the left
                    addleft = 1;
                    left = frst-obj.srate;
                    Nsamples = N+2*obj.srate;
                else % start with frst
                    addleft = 0;
                    left = frst;
                    Nsamples = N+1*obj.srate;
                end
                if left+Nsamples <=obj.Nsmp
                    addright = 1;
                    right = left+Nsamples-1;
                else
                    addright = 0;
                    right = left+Nsamples-obj.srate-1;
                end
                obj.usesmp  = [left right];
                tmpdata = obj.dataint;
                tmpdatar = [];
                for ich = 1:numel(obj.usech)
                    %                 tmpdatar = resample(tmpdata',obj.resmpfreq,obj.srate)';
                    if obj.resmpfreq < obj.srate
                        tmpdatar(ich,:) = resample(tmpdata(ich,:)',obj.resmpfreq,obj.srate)';
                    elseif obj.resmpfreq > obj.srate
                        t = [0:(numel(tmpdata(1,:))-1)];
                        tr= [0:(numel(t)*obj.resmpfreq/obj.srate-1)]*obj.srate/obj.resmpfreq;
                        tmpdatar(ich,:) = interp1(t,tmpdata(ich,:),tr,'spline');
                    else
                        tmpdatar(ich,:) = tmpdata(ich,:);
                    end
                end
                if addleft,  tmpdatar = tmpdatar(:,obj.resmpfreq+1:end); end
                if addright, tmpdatar = tmpdatar(:,1:end-obj.resmpfreq); end
                if obj.atswrite % output to atsfile
                    for ich = 1:numel(obj.usech)
                        fid = fopen(atsfile{ich},'a');
                        fwrite(fid,int32(tmpdatar(ich,:)),'int32');
                        fclose(fid);
                    end
                else % keep in memory
                    dataproc = [dataproc tmpdatar];
                end
                frst = frst+N;
                obj.usesmp = usesmp0;
            end
        end                 
        function dataphys   = get.dataphys(obj)
            dataphys = obj.data;
            if ~isempty(dataphys),
                for ich = 1:numel(obj.usech);
                    % just to make sure ...
                    if ~(obj.dipole(obj.usech(ich))==0)
                        dataphys(ich,:) = dataphys(ich,:)/obj.dipole(obj.usech(ich));
                    else
                        dataphys(ich,:) = dataphys(ich,:);
                    end
                end
                % CODE4+ TO BE added
                % for ich = 1:numel(obj.usech);
                %    % just to make sure ...
                %    if ~(obj.coil_static(obj.usech(ich))==0)
                %        dataphys(ich,:) = dataphys(ich,:)/obj.coil_static(obj.usech(ich));
                %    else
                %        dataphys(ich,:) = dataphys(ich,:);
                %    end
                % end
            end
        end
        function data       = get.data(obj)                                    
            data = obj.dataproc;    
            for ich = 1:numel(obj.usech)
                data(ich,:) = data(ich,:)*obj.lsb(obj.usech(ich));
            end
        end
        
        % if you want to override a get.STH method in subclasses, 
        % define a get_STH method with the standard behaviour (or none at
        % all if none can be specified (return sth empty for example)
        % and redefine get_STH in the subclass with the specific behaviour.
        % This is necessary because matlab does not allow to override
        % get.STH -like methods in subclasses (why?)
        function dataint    = get.dataint(obj)
            
            if ~obj.delay_filter
                dataint = get_dataint(obj);
            else                                    
                % JK: only integer delays are possible now. 
                
                % compute delay
                smp_delay = obj.srate * obj.delay_filter;
                
                if smp_delay - round(smp_delay) < 1e-10;
                    smp_delay = round(smp_delay);
                end
                
                % the target frequency does not work straight away, then
                if ~isint( smp_delay  )                    
                    disp(['filter_delay is :',num2str(obj.delay_filter),' at a sampling rate of ',num2str(obj.srate),' resulting in non-integer number of delay samples: ',num2str(smp_delay)]);
                    disp('This is currently not yet supported');
                    return
                end
                
                % get one delay more ..
                usesmp_old = obj.usesmp;
                usesmp_new = usesmp_old;
                usesmp_new(2) = usesmp_new(2) + smp_delay;
                % if this worked, fine, discard them at the end, otherwise
                % go back and taper instead
                if usesmp_new(2) <= obj.Nsmp
                    discard_end = true;
                    obj.usesmp = usesmp_new;
                else
                    discard_end = false;
                    obj.usesmp = usesmp_old;
                end                                    

                dataint = get_dataint(obj);                                                
                
                disp(['Applying delay filter with delay: ',num2str(obj.delay_filter),' seconds (',num2str(smp_delay),' samples)']);                
                dataint(:,1:end-smp_delay) = dataint(:,1:end-smp_delay) - dataint(:,1+smp_delay:end);
                
                if discard_end
                    dataint = dataint(:,1 : diff(usesmp_old)+1);
                    obj.usesmp = usesmp_old;
                else
                    % the last part (2*delay) is tapered using a half-gaussian
                    % chosen such that the non delay-filtered tail is damped at 
                    % least 1/3000
                    taper = gausswin(smp_delay*4,8);
                    taper = taper(2*smp_delay+1:end);                
                    taper = repmat(taper.',[size(dataint,1), 1]);                                
                    dataint(:,1+end-2*smp_delay:end) = dataint(:,1+end-2*smp_delay:end).*taper;
                end                

%                 the following was an experiment, reference in the function 
%                 dataint = get_dataint(obj);
%                 for ind2 = 1 : obj.nch
%                     dataint(ind2,:) = ac_filter(dataint(ind2,:),smp_delay);
%                 end                                
            end
            
            if obj.notch_filter
            
                bad_f = obj.notch_filter(:,1);                
                width = obj.notch_filter(:,2);
                                                
                t = 0:1/obj.srate:(size(dataint,2)-1)/obj.srate;
                f = fft_frequency_axis(t);
                ft = ones(size(f));
                for ind = 1 : numel(bad_f)                                        
                    ft = ft .* (1 - exp( - ( ( f - bad_f(ind) )./ ( sqrt(2) * bad_f(ind) * width(ind) ) ).^2 ) - exp( - ( ( f + bad_f(ind) )./ ( sqrt(2) * bad_f(ind) * width(ind) ) ).^2 ) );
                end                
                ft = repmat(ifftshift(ft),[size(dataint,1), 1]);
                dataint = ifft(ft.*fft(dataint,[],2),[],2);                
                dataint = dataint - repmat(mean(dataint,2),[1 size(dataint,2)]);
                            
            end            
                
        end
        function dataint    = get_dataint(obj)
            dataint = [];
        end        
        
        function atsheader  = get.atsheader(obj)
            atsheader = get_atsheader(obj);
        end
        function atsfile    = get.atsfile(obj)
            obj.atswrite = 1;
            atsfile      = 0;
            if ~obj.resmpfreq, obj.resmpfreq = obj.srate; end
            atsfile = obj.dataproc;            
        end            
    end
end