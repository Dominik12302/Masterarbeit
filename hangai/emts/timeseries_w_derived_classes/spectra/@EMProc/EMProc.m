%%
% class definition of EMProc
%
classdef EMProc % discrete block model
    properties
        propath     = {};
        fcpath      = {'fc'};
        tfpath      = {'tf'};
        datapath    = {['EDE',filesep,'meas*'] ['ADU',filesep,'meas*'] ['spam4',filesep,'run*'] ['MTU',filesep,'run*'] ['EDL' filesep 'run*']};     %
        lsname      = {}; % local site name
        lsrate      = [];
        bsname      = {}; % base site name
        bsrate      = [];
        rsname      = {}; % ref. site name
        rsrate      = []; 
        asname      = {}; % array site names
        asrate      = [];  
        input       = {'Bx' 'By'};
        output      = {'Ex' 'Ey'};
        ref         = {'Bx' 'By'};
        arraych     = {'Bx' 'By' 'Bz' 'Ex' 'Ey'};       
        bandsetup   = 'MT';
        usedec      = 1;
        mindec      = 1;
        maxdec      = [];
        usetime     = [];        
        usesites    = {'all'};
        usesrates   = [];
        fcrange     = [];
        procdef     = [];
        debuglevel  = 1;
        
        
    end
    properties (Dependent = false,  SetAccess = private)
        site      = {};
        reftime   = [];
    end
    properties (Dependent = true,  SetAccess = private)
        lsind               % index into local site: local time series objects are available from obj.site{obj.lsind}
        lNruns              % number of runs for local site
        lsrates             % available sampling schemes for local site
        lsrateind           % index vector  into runs at local site with sampling rate obj.lsrate;
                            % to access these, use obj.sites{obj.lsind}(obj.lsrateind)
        localsite           % the time series objects of the local site for the desired sampling rate srate
        
        bsind
        bNruns
        bsrates
        bsrateind
        basesite         % the time series objects of the base site for the desired sampling rate obj.bsrate

        rsind
        rNruns
        rsrates
        rsrateind
        refsite         % the time series objects of the reference sites for the desired sampling rate obj.asrate

        asind
        aNruns
        asrates
        asrateind
        array           % the time series objects of the array sites for the base site at sampling obj.bsrate

        Ndecmax         % highets decimation level common to local and base site
        trw             % overlapping sets (windows) of local, base and refsite for current
                        % decimation level and within obj.usetime range
        trwa             % overlapping sets (windows) of all sites within array for current
                        % decimation level and within obj.usetime range
        
        Y               
        X
        Xr
        Xa              % all array data of dimension Nch x nsets x nfreq
        f               % current frequencies
        win             % indices into overlapping sets of input site
        wout            % indices into overlapping sets of output site
        wref            % indices into overlapping sets of reference site
        
        trs             % central time of overlapping sets in secs relative to reftime
        trh             % central time of overlapping sets in secs relative to reftime
        trd             % central time of overlapping sets in secs relative to reftime
        utc             % central time of overlapping sets in secs relative to reftime  
        
        pol
        tf              % transfer functions (sounding curves)
        coh             % uni- or bivariate coherencies, depending on number of input channels
        tfs             %
        zxxfile         % this writes the transfer functions into egberts zxx format
        edifile         % this writes the transfer functions into edi format
        mvar
        
        srates              % sampling rates of sites and runs  
        useind              % index into sites and runs matching usesites and usesrates
        usesitesind         % index into currently used sites
        sratesusedsites     % sampling rates of the usesites for all runs
        sites               % site names
        snames              % site names for each run
        runtimes            % runtimes for useind runs and usedec
    end
    methods
        % unique to EMProc
        function obj    = EMProc(varargin)
            if nargin == 1
                if isdir(varargin{1}{1})
                    if obj.debuglevel,
                        disp(['-----------------------------------------']);
                        disp([' - Project directory is ' varargin{1}{1}]);
                        disp(['-----------------------------------------']);
                    end
                    obj.propath = varargin{1};
                else
                    error('Project does not exist; Check project path.');
                end
            elseif nargin == 2
                if isa(varargin{1},'EMProc') && iscell(varargin{2})
                    obj         = varargin{1}; % Creates EMTimeSeries object from file with values of given ede object
                    sites       = varargin{2};
                    [obj] = proc_import(obj,sites);
                end
            else
                disp(['**Error: Unknown format of input args']);
                return;
            end
        end          
        function Ndecmax = get.Ndecmax(obj)
            if ~isempty(obj.array)
                Ndec_array = [];
                a = obj.array;
                for ia = 1:numel(a)
                    for ir = 1:numel(a{ia})
                        Ndec_array = [Ndec_array a{ia}{ir}.Ndec];
                    end
                end
                Ndecmax = min(Ndec_array); 
            elseif ~isempty(obj.localsite), spls = obj.localsite;
                if isempty(obj.bsname), spbs =obj.localsite; else spbs = obj.basesite{1}; end
                for ils = 1: numel(spls), Ndec_output(ils) = spls{ils}.Ndec; end
                for ibs = 1: numel(spbs),  Ndec_input(ibs) = spbs{ibs}.Ndec; end
                [Ndec_output,iout] = max(Ndec_output); % should be max instead of min
                [Ndec_input,iin]   = max(Ndec_input); % but doesn't work for now
                Ndecmax = min(Ndec_output,Ndec_input);
            end
            % check if data are available at this decimation level            
        end
        function f = get.f(obj)
             spls = obj.localsite;
             for ils = 1:numel(spls)                
                spl = spls{ils};
                if spl.Ndec >= obj.usedec, 
                    spl.usedec = obj.usedec;
                    spl.fcrange = obj.fcrange;
                    f = spl.f; break; 
                end
             end
        end
        function trwa = get.trwa(obj)
            if isempty(obj.asname), trwa = []; return;
            else array = obj.array; end
            win = []; wout = []; wref = []; tin = []; tout = []; tref = [];
            for ia = 1:numel(array)
                spls = array{ia};
                wout = []; tout = [];
                for out = 1:numel(spls)
                    spl = spls{out};
                    if spl.Ndec >= obj.usedec,
                        spl.usedec = obj.usedec;
                        wout = [wout spl.wr];
                        T = spl.T(obj.usedec,:);
                        % JK 2016/01/20
                        % rounding errors may cause wout and tout to have
                        % different lengths. Therefore, I replace T(2) with a
                        % correct multiple of T(3). Also return a warning if
                        % this causes a change of more than half a sample
                        if 2*abs(T(2) - ( T(1) + ( numel(spl.wr) - 1)*T(3)) ) > T(3)
                            disp('get.trwa: rounding issues >half a sample detected!!');
                        end
                        T(2) = T(1) + ( numel(spl.wr) - 1)*T(3);             
                        tout = [tout T(1):T(3):T(2)];
                    end
                end
                w{ia} = wout;
                t{ia} = tout;
            end
            trwa = intersectAllSet(w);
            [~,a,~] = intersect(w{1},trwa);
            
            % jochens fix (who does not know why index out of bounds is happening)
            % JK 2016/01/20, hopefully it does not happen anymore now... if
            % yes, REPORT!
            if any(a>numel(t{1})) || any(a<1); a(a>numel(t{1}) | a<1) = []; 
                disp('problems in get.trwa which really should not occur any longer!!!'); 
            end
            
            tin = t{1}(a);
            if numel(obj.usetime)==12
               ind = (tin >= etime(obj.usetime(1:6),obj.reftime) & tin <= etime(obj.usetime(7:12),obj.reftime));
               trwa = trwa(ind);
            end
            % tout = tout(b);
        end        
        function trw = get.trw(obj)
            spls = obj.localsite;
            if isempty(obj.bsname), spbs =obj.localsite;
            else spbs = obj.basesite{1}; end
            if isempty(obj.rsname), sprs =[];
            else sprs = obj.refsite{1}; end
            win = []; wout = []; wref = []; tin = []; tout = []; tref = [];
            
            % get first and last indices of time windows 
            % based on private property EMSpectra.W
            
            % for localsite
            for out = 1:numel(spls)
                spl = spls{out};
                if spl.Ndec >= obj.usedec,                     
                    spl.usedec = obj.usedec; 
                    wout = [wout spl.wr];
                    T = spl.T(obj.usedec,:);                                                            
                    % JK 2015/12/07
                    % rounding errors may cause wout and tout to have
                    % different lengths. Therefore, I replace T(2) with a
                    % correct multiple of T(3). Also return a warning if
                    % this causes a change of more than half a sample
                    if 2*abs(T(2) - ( T(1) + ( numel(spl.wr) - 1)*T(3)) ) > T(3)
                        disp('get.trw: localsite: rounding issues >half a sample detected!!');                                                	     
                        disp(['end time: ', num2str(T(2)),...
                            '   computed end time: ',num2str(T(1)+(numel(spl.wr)-1)*T(3)),...
                            '   difference: ',num2str(T(2) - ( T(1)+(numel(spl.wr)-1)*T(3)) ),...
                            '   delta T: ', num2str(T(3))]);
                    end
                    T(2) = T(1) + ( numel(spl.wr) - 1)*T(3);                    
                    tout = [tout T(1):T(3):T(2)];
                end
            end
            
            % for basesite
            for in = 1:numel(spbs)
                spb = spbs{in};
                if spb.Ndec >= obj.usedec, 
                    spb.usedec = obj.usedec; 
                    win = [win spb.wr]; 
                    T = spb.T(obj.usedec,:);
                    
                    % JK 2015/12/07, see above
                    if 2*abs(T(2) - ( T(1) + ( numel(spb.wr) - 1)*T(3) ) ) > T(3)
                        disp('get.trw:  basesite: rounding issues >half a sample detected!!');
                        disp(['end time: ', num2str(T(2)),...
                            '   computed end time: ',num2str(T(1)+(numel(spl.wr)-1)*T(3)),...
                            '   difference: ',num2str(T(2) - (T(1)+(numel(spl.wr)-1)*T(3))),...
                            '   delta T: ', num2str(T(3))]);                        
                    end
                    T(2) = T(1) + ( numel(spb.wr) - 1)*T(3);                    
                    tin = [tin T(1):T(3):T(2)];
                end
            end
            
            % for reference site
            if ~isempty(sprs)
                for ref = 1:numel(sprs)
                    spr = sprs{ref};
                    if spr.Ndec >= obj.usedec,
                        spr.usedec = obj.usedec;
                        wref = [wref spr.wr];
                        T = spr.T(obj.usedec,:);
                        
                        % JK 2015/12/07, see above
                        if 2*abs(T(2) - ( T(1) + ( numel(spr.wr) - 1)*T(3) ) ) > T(3)
                            disp('check out get.trw!!!');
                        end
                        T(2) = T(1) + ( numel(spr.wr) - 1)*T(3);                    
                        tref = [tref T(1):T(3):T(2)];
                    end
                end
            end
            
            % get those indices that all have in common
            if ~isempty(wref)
                [trw,a,b,c] = intersect3(win,wout,wref);
            else
                [trw,a,b] = intersect(win,wout);
            end
            
            % jochens fix (who does not know why index out of bounds is happening)
            % JK 2015/12/07, hopefully it does not happen anymore now... if
            % yes, REPORT!
            if any(a>numel(tin)) || any(a<1); a(a>numel(tin) | a<1) = []; 
                disp('problems in get.trw which really should not occur any longer!!!'); 
            end
            
            tin = tin(a);
            if numel(obj.usetime)==12
               ind = (tin >= etime(obj.usetime(1:6),obj.reftime) & tin <= etime(obj.usetime(7:12),obj.reftime));
               trw = trw(ind);
            end
            % tout = tout(b);
        end
        function trs = get.trs(obj)
            spls = obj.localsite;
            %wout = obj.wout;
            trw = obj.trw;
            trs  = {};
            for ils = 1:numel(spls)
                spl = spls{ils};
                if spl.Ndec >= obj.usedec, 
                    spl.usedec = obj.usedec;
                    [a,b,c] = intersect(trw,spl.wr); 
                    trs{ils}= spl.trs(c); 
                end
            end
        end
        function trh = get.trh(obj)
            trs = obj.trs;
            trh = {};
            for ils = 1:numel(trs), trh{ils}= trs{ils}/3600; end
        end
        function trd = get.trd(obj)
            trs = obj.trs;
            trd = {};
            for ils = 1:numel(trs), trd{ils}= trs{ils}/3600/24; end
        end
        function utc = get.utc(obj)
            trd = obj.trd;
            utc = {};
            for ils = 1:numel(trd),
                if ~isempty(trd{ils})
                    utc{ils} = datenum(obj.reftime)+trd{ils};
                end
            end
        end
        function win = get.win(obj)
            if isempty(obj.bsname), spbs =obj.localsite;
            else spbs = obj.basesite{1}; end
            w       = obj.trw;
            win    = {};
            for ibs = 1:numel(spbs), spb = spbs{ibs};
                if spb.Ndec >= obj.usedec
                    spb.usedec = obj.usedec;
                    [a,b,c] = intersect(w,spb.wr);
                    if ~isempty(c), win{ibs} = c; end
                end
            end
        end
        function wout = get.wout(obj)
            spls    = obj.localsite;
            w       = obj.trw;
            wout    = {};
            for ils = 1:numel(spls), spl = spls{ils};
                if spl.Ndec >= obj.usedec
                    spl.usedec = obj.usedec;
                    [a,b,c] = intersect(w,spl.wr);
                    if ~isempty(c), wout{ils} = c; end
                end
            end
        end
        function wref = get.wref(obj)
            sprs    = obj.refsite;
            w       = obj.trw;
            wref    = {};
            for ils = 1:numel(sprs), spr = sprs{ils};
                if spr.Ndec >= obj.usedec
                    spr.usedec = obj.usedec;
                    [a,b,c] = intersect(w,spr.wr);
                    if ~isempty(c), wref{ils} = c; end
                end
            end
        end
        function Y = get.Y(obj) % collect output channel data for current sets and fcrange
            spls    = obj.localsite;
            w       = obj.trw;
            cind    = 0;
            for ils = 1:numel(spls)
                spl = spls{ils};
                if spl.Ndec >= obj.usedec
                    spl.usedec = obj.usedec;
                    spl.output = obj.output;
                    [a,b,c] = intersect(w,spl.wr);
                    if isempty(obj.fcrange)
                        spl.fcrange = [];
                    else
                        spl.fcrange=obj.fcrange;
                    end
                    if ~isempty(c)
                        spl.setrange = c;
                        spl.debuglevel = 1;
                        Y(:,cind+[1:numel(c)],:,:) = spl.Y;
                        cind = cind+numel(c);
                    end
                
                end
            end
        end
        function X = get.X(obj) % collect input channel data for current sets and fcrange
            if isempty(obj.bsname), spbs =obj.localsite;
            else spbs = obj.basesite{1}; end
            w       = obj.trw;
            cind    = 0;
            for ibs = 1:numel(spbs)
                spb = spbs{ibs};
                if spb.Ndec >= obj.usedec
                    spb.usedec = obj.usedec;
                    spb.input = obj.input;
                    [a,b,c] = intersect(w,spb.wr);
                    if isempty(obj.fcrange)
                        spb.fcrange = [];
                    else
                        spb.fcrange=obj.fcrange;
                    end
                    if ~isempty(c)
                        spb.setrange = c;
                        spb.debuglevel = 1;
                        X(:,cind+[1:numel(c)],:,:) = spb.X;
                        cind = cind+numel(c);
                    end
                
                end
            end
            % JK sometimes, obj.trw is empty. Then we don't want a result..
            % it appears that it is not intended for X to ever be empty.
            % Why does it happen anyway?
            if ~exist('X','var'); X = []; end 
        end
        function Xr = get.Xr(obj) % collect output channel data for current sets and fcrange
            if isempty(obj.rsname),
                Xr = [];
            elseif numel(obj.ref) ~= numel(obj.input)
                disp('Warning: Number of ref channels does not match number of input channels. Slip RR proc.');
                Xr = [];
            else
                sprs = obj.refsite{1};
                w       = obj.trw;
                cind    = 0;
                for ibs = 1:numel(sprs)
                    spr = sprs{ibs};
                    if spr.Ndec >= obj.usedec
                        spr.usedec = obj.usedec;
                        spr.input = obj.ref;
                        [a,b,c] = intersect(w,spr.wr);
                        if isempty(obj.fcrange)
                            spr.fcrange = [];
                        else
                            spr.fcrange=obj.fcrange;
                        end
                        if ~isempty(c)
                            spr.setrange = c;
                            spr.debuglevel = 1;
                            Xr(:,cind+[1:numel(c)],:,:) = spr.X;
                            cind = cind+numel(c);
                        end
                    else
                        Xr = [];
                    end
                end
            end
        end
        function Xa = get.Xa(obj) % collect input channel data for current sets and fcrange
            Xa = [];
            if isempty(obj.asname), 
                return;
            else array = obj.array; end
            w       = obj.trwa;
            for ia = 1:numel(array)
                spbs = array{ia};
                X = [];
                cind    = 0;
                for ibs = 1:numel(spbs)
                    spb = spbs{ibs};
                    if spb.Ndec >= obj.usedec
                        spb.usedec = obj.usedec;
                        spb.input = obj.arraych;
                        [a,b,c] = intersect(w,spb.wr);
                        if isempty(obj.fcrange)
                            spb.fcrange = [];
                        else
                            spb.fcrange=obj.fcrange;
                        end
                        if ~isempty(c)
                            spb.setrange = c;
                            spb.debuglevel = 1;
                            X(:,cind+[1:numel(c)],:,:) = spb.X;
                            cind = cind+numel(c);
                        end
                    end
                end
                if ia == 1, Xa = X;
                else Xa = cat(4,Xa,X);end
            end
        end
        function coh = get.coh(obj)
            Y = obj.Y;
            coh = zeros(size(Y));
            for ich = 1:numel(obj.output)
                proc        = EMRobustProcessing(Y(:,:,1,ich),obj.X);
                if ~isempty(obj.procdef)
                    procdef       = fieldnames(obj.procdef);
                    for iprocdef = 1:numel(procdef)
                        if isprop(proc,procdef{iprocdef})
                            proc = setfield(proc,procdef{iprocdef},getfield(obj.procdef,procdef{iprocdef}));
                        end
                    end
                end
                proc.output = obj.output;
                proc.input  = obj.input;
                if numel(proc.input)==1, coh(:,:,1,:) = proc.unicoh;
                elseif numel(proc.input)==2, coh(:,:,1,ich) = proc.bicoh; end
                
            end
        end        
        function pol = get.pol(obj)
            proc        = EMRobustProcessing(obj.Y(:,:,1,1),obj.X);
            if ~isempty(obj.procdef)
                procdef       = fieldnames(obj.procdef);
                for iprocdef = 1:numel(procdef)
                    if isprop(proc,procdef{iprocdef})
                        proc = setfield(proc,procdef{iprocdef},getfield(obj.procdef,procdef{iprocdef}));
                    end
                end
            end
            pol = proc.pol;            
        end        
        function tfs = get.tfs(obj)
            Y = obj.Y;
            tfs = zeros(size(Y,1),size(Y,2),numel(obj.input)*numel(obj.output));
            for ich = 1:numel(obj.output)
                proc        = EMRobustProcessing(Y(:,:,1,ich),obj.X);
                if ~isempty(obj.procdef)
                    procdef       = fieldnames(obj.procdef);
                    for iprocdef = 1:numel(procdef)
                        if isprop(proc,procdef{iprocdef})
                            proc = setfield(proc,procdef{iprocdef},getfield(obj.procdef,procdef{iprocdef}));
                        end
                    end
                end
                tfs(:,:,(ich-1)*numel(obj.input)+[1 numel(obj.input)]) = proc.tfs;
            end
        end        
        function tf = get.tf(obj)
            spls = obj.localsite;
            if isempty(obj.bsname), spbs =obj.localsite; else spbs = obj.basesite{1}; end
            if isempty(obj.rsname), sprs = []; else sprs = obj.refsite{1}; end
            for iout = 1:numel(spls), if spls{iout}.Ndec>= obj.Ndecmax, break; end; end
            fi = 0;
            sp = spls{iout};
            if obj.debuglevel, fprintf(1,' + Robust transfer function estimation\n'); end
            if isempty(obj.maxdec)
                Ndecmax = obj.Ndecmax;
            elseif obj.maxdec < obj.Ndecmax
                Ndecmax = obj.maxdec;
            else
                Ndecmax = obj.Ndecmax;
            end
            for idec = obj.mindec:Ndecmax
                obj.usedec = idec;  
                for ib = 1:numel(sp.bsfcenter{idec})
                    fi          = fi+1;
                    sp.usedec   = idec;
                     
                    
                    sp.fcrange  = [sp.bsfc{idec}{ib}(1) sp.bsfc{idec}{ib}(end)];
                    obj.fcrange = sp.fcrange; 
                    X           = obj.X;                                       
                    Xr          = obj.Xr;
                    f(fi)       = sp.bsfcenter{idec}(ib);  
                    ff          = sqrt(sp.f'./f(fi));
                    
                    % if there is no data, the rest is irrelevant
                    if isempty(X); 
                        for ich = 1:numel(obj.output)   
                            Z(ich,:,fi)      = NaN(1,2,1);
                            Zse(ich,:,fi)    = NaN(1,2,1);
                        end
                        
                        
                        continue; 
                    end
                   
                    for iinch = 1:numel(obj.input)
                        switch obj.input{iinch}
                            case {'Ex' 'Ey'}
%                                 ff = sqrt(spb.f'./f(fi));
                                % !!! this will not work for multi-taper spectra
                                X(:,:,1,iinch)  = X(:,:,1,iinch)./ff(:,ones(1,size(X,2)));
                            case {'Bx' 'By'}
                                % ff = sqrt(spb.f'./f(fi));
                                % !!! this will not work for multi-taper spectra
                                
                        end
                    end
                    for iinch = 1:numel(obj.ref)
                        switch obj.ref{iinch}
                            case {'Ex' 'Ey'}
%                                 ff = sqrt(spb.f'./f(fi));
                                % !!! this will not work for multi-taper spectra
                                Xr(:,:,1,iinch)  = Xr(:,:,1,iinch)./ff(:,ones(1,size(Xr,2)));
                            case {'Bx' 'By'}
                                % ff = sqrt(spb.f'./f(fi));
                                % !!! this will not work for multi-taper spectra
                                
                        end
                    end
                    %Y = zeros(numel(spb.f),numel(w),1,1);   
                    output = obj.output;
                    for ich = 1:numel(output)   
                        obj.output = output(ich);
                        Y = obj.Y;
                        switch output{ich}
                            case {'Ex' 'Ey'}
                                %                                 tm = 1.*f(fi);
                                %                                 tn = 1.*sp.f';
                                %                                 pf = (tn+1i*tm)./1i;
                                %                                 fac = 1i./(tm+1i*tm);
                                %                                 Y  = Y.*pf(:,ones(1,size(Y,2)));
                                fac = 1;
                                Y  = Y./ff(:,ones(1,size(Y,2)));
                            otherwise
                                fac = 1;
                        end
                        if obj.debuglevel,
                            fprintf(1,' - Decimation level %d, Period: %.3f, %d sets, output channel: %s\n',idec,1/f(fi),size(Y,2),output{ich});
                        end
                        if exist('Xr','var')
                            proc        = EMRobustProcessing(Y,X,Xr);
                        else
                            proc        = EMRobustProcessing(Y,X);
                        end
                        if ~proc.all_good; 
                                Z(ich,:,fi)      = NaN(1,2,1);
                                Zse(ich,:,fi)    = NaN(1,2,1);
                            continue; 
                        end
                        if ~isempty(obj.procdef)
                            procdef       = fieldnames(obj.procdef);
                            for iprocdef = 1:numel(procdef)
                                if isprop(proc,procdef{iprocdef})
                                    proc = setfield(proc,procdef{iprocdef},getfield(obj.procdef,procdef{iprocdef}));
                                end
                            end
                        end
                        proc.output = output(ich);
                        proc.input  = obj.input;
                        proc.f      = f;
                        proc.useY        = proc.maskY;
                        %useY(:,:,ich) = proc.useY;
                        [Zf,Zfse,stats]        = computetf(proc);
                        Z(ich,:,fi)      = Zf*fac;
                        Zse(ich,:,fi)    = Zfse*fac;
                        if 0
                            if ich == 1, figure(1);
                                Yp = Z(ich,1,fi)*X(:,:,1,1)+Z(ich,2,fi)*X(:,:,1,2);
                                imagesc(obj.utc{1},obj.f,log10(abs(Yp-obj.Y)./stats.ols_s.*proc.useY));
                                %                             imagesc(obj.utc{2},obj.f,log10(abs(Yp-obj.Y)./stats.ols_s));
                                
                                hold on;
                                %alpha(proc.useY/0.7+0.3)
                                set(gca,'Yscale','log','Ydir','normal')
                                ylim([0.01 100])
                                caxis([-1 1]);
                            end
                            if ich == 2, figure(2);
                                Yp = Z(ich,1,fi)*X(:,:,1,1)+Z(ich,2,fi)*X(:,:,1,2);
                                %                             imagesc(obj.utc{2},obj.f,log10(abs(Yp-obj.Y)./stats.ols_s));
                                imagesc(obj.utc{1},obj.f,log10(abs(Yp-obj.Y)./stats.ols_s.*proc.useY));
                                
                                hold on;
                                set(gca,'Yscale','log','Ydir','normal')
                                ylim([0.01 100])
                                caxis([-1 1])
                            end
                        end
                    end
                    obj.output = output;
%                       %%
%                       figure;
%                       iutc = 1;
%                       set(gcf,'Position',[113         474        1183         504]);
%                       X = permute(squeeze(obj.X(6,:,1,:)),[2 1]);
%                       Yp = squeeze(Z(:,:,fi))*X;
%                       obj.output = {'Ex' 'Ey'};
%                       Y = obj.Y;
%                       a=axes;
%                       set(gca,'Position',[ 0.1300    0.6057    0.6358    0.3072]);
%                       plot(obj.utc{iutc},real(Yp(1,:)),'-r'); hold on; plot(obj.utc{iutc}',squeeze(real(Y(6,:,1,1))),'-b')
%                       hold on; 
%                       u = useY(6,:,1);
%                       plot(obj.utc{iutc}(u),real(Yp(1,u)),'or','Markersize',3,'Markerfacecolor',[0.7 0 0]); 
%                       datetick('x')
%                       legend('observed','predicted')
%                       title(['obs. and pred. Ex field (real part) at site ' obj.lsname{1} ' @' num2str(obj.f(6)) ' Hz'],'Fontsize',12)
%                       %xlabel('utc time (Mar 24)')
%                       ylabel('Ex real')
%                       ylim([-20 20])
%                       b=axes;
%                       set(gca,'Position',[ 0.8233    0.6057    0.1538    0.3072]);
%                       plot((Yp(1,:)-squeeze(Y(6,:,1,1)))./stats.ols_s,'ok','Markersize',3,'Markerfacecolor',[0.7 0.7 0.7]); axis equal; xlim([-3 3]); ylim([-3 3]);
%                       hold on;
%                       plot((Yp(1,u)-squeeze(Y(6,u,1,1)))./stats.ols_s,'or','Markersize',3,'Markerfacecolor',[0.7 0 0]); axis equal; xlim([-3 3]); ylim([-3 3]);
% 
%                       title('norm. residuals','Fontsize',12)
%                       xlabel('Ex real')
%                       ylabel('Ex imag')
%                       a=axes;
%                       set(gca,'Position',[ 0.1300    0.1557    0.6358    0.3072]);
%                       plot(obj.utc{iutc},real(Yp(2,:)),'-r'); hold on; plot(obj.utc{iutc}',squeeze(real(Y(6,:,1,2))),'-b')
%                       
%                       u = useY(6,:,2);
%                       plot(obj.utc{iutc}(u),real(Yp(2,u)),'or','Markersize',3,'Markerfacecolor',[0.7 0 0]); 
%                       datetick('x')
%                       %legend('observed','predicted')
%                       title(['obs. and pred. Ey field (real part) at site ' obj.lsname{1} ' @' num2str(obj.f(6)) ' Hz'],'Fontsize',12)
%                       xlabel('utc time (Mar 24)')
%                       ylabel('Ey real')
%                       ylim([-20 20])
%                       b=axes;
%                       set(gca,'Position',[ 0.8233    0.1557    0.1538    0.3072]);
%                       plot((Yp(2,:)-squeeze(Y(6,:,1,2)))./stats.ols_s,'ok','Markersize',3,'Markerfacecolor',[0.7 0.7 0.7]); axis equal; xlim([-3 3]); ylim([-3 3]);
%                       hold on;
%                       plot((Yp(1,u)-squeeze(Y(6,u,1,1)))./stats.ols_s,'or','Markersize',3,'Markerfacecolor',[0.7 0 0]); axis equal; xlim([-3 3]); ylim([-3 3]);
%                       title('norm. residuals','Fontsize',12)
%                       xlabel('Ey real')
%                       ylabel('Ey imag')
                    %%
                    fprintf(1,'\n');
                end
            end
            
            % JK: NaNs produced on the way need removing
            rem = [];
            for ind = 1 : size(Z,3);
                tmp = Z(:,:,ind);
                if any(isnan(tmp));
                    rem = [rem; ind];
                end
            end
            Z(:,:,rem) = [];
            Zse(:,:,rem) = [];
            f(rem) = [];
            
            
            ztf.locname = [spls{1}.name];
            ztf.lnch    = numel(obj.output);
            ztf.lchname = obj.output;
            ztf.lchid   = [1:numel(obj.output)]+2;
            ztf.bname  =  spbs{1}.name;
            ztf.bnch    = numel(obj.input);
            ztf.bchname = obj.input;
            ztf.bchid   = 1:numel(obj.input);
            % if irs, ztf.rname = snames(rbs); end
            ztf.nper = numel(f);
            ztf.periods = 1./f';
            ztf.tf   = Z;
            ztf.tf_se = Zse;
            ztf.lon  = obj.site{obj.lsind}{1}.lon;
            ztf.lat = obj.site{obj.lsind}{1}.lat;
            
            if ~isempty(obj.bsname) && ~isempty(obj.rsname)
                fname = [obj.lsname{1} '-' obj.bsname{1} '-ref' obj.rsname{1} '.edi'];
            elseif ~isempty(obj.bsname)
                fname = [obj.lsname{1} '-' obj.bsname{1} '.edi'];
            elseif ~isempty(obj.rsname)
                fname = [obj.lsname{1} '-ref' obj.rsname{1} '.edi'];
            else
                fname = [obj.lsname{1} '.edi'];
            end
            if ~isdir(fullfile(obj.propath{1},obj.lsname{1},obj.tfpath{1}))
                mkdir(fullfile(obj.propath{1},obj.lsname{1},obj.tfpath{1}));
            end
            pname = fullfile(obj.propath{1},obj.lsname{1},obj.tfpath{1});
            try
                write_edi(ztf,fullfile(pname,fname),'raw')
                tf = ztf;
                fh = sp_plottf(ztf,fname);  
                
                set(fh,'Paperpositionmode','auto');
                print(fh,'-dpng',[fullfile(pname,fname) '.png']);
            catch
                disp('The last issue....................FINDME');
                tf = [];
            end
%             title(fname,'Fontsize',14);
        end     
        function mvar = get.mvar(obj)
            sp = obj.array{1}{1};
            if obj.debuglevel, fprintf(1,' + Robust multivariate analysis\n'); end
            if isempty(obj.maxdec), Ndecmax = obj.Ndecmax;
            elseif obj.maxdec < obj.Ndecmax , Ndecmax = obj.maxdec;
            else Ndecmax = obj.Ndecmax;
            end
            fi = 0;
            for idec = obj.mindec:Ndecmax
                obj.usedec = idec;
                obj.fcrange = [];
                % Perhaps an idea to preselect some time segments based
                % on coherency between local and base sites (which are
                % defined separately with the lsname and bsname properties,
                % and with the lsrate and bsrate properties. To include
                % coherency thresholding, uncomment the lines below, as
                % well as line 906-909
                %                 obj.input = {'Ex' 'Ey'};
                %                 obj.output = {'Ex'};
                %                 cohx = obj.coh;
                %                 %plotcoh(proc);
                %                 obj.output = {'Ey'};
                %                 cohy = obj.coh;
                %                 %plotcoh(proc);
                
                for ib = 1:numel(sp.bsfcenter{idec})
                    fi          = fi+1;
                    sp.usedec   = idec;
                    obj.fcrange = [sp.bsfc{idec}{ib}(1) sp.bsfc{idec}{ib}(end)];
                    fcrange     = min(obj.fcrange):max(obj.fcrange);
                    Xa          = obj.Xa;           % collect all fcs from the array nto one large matrix
                    [nf nsets nk nch] = size(Xa);
                    f(fi)       = sp.bsfcenter{idec}(ib);
                    disp([' - Period is ' num2str(1/f(fi),'%.4f')]);
                    X   = reshape(permute(Xa,[4,2,1,3]),nch,nsets*nf);
                    Xcopy = sparse(X*0);
                    %                     use = (cohx(fcrange,:)>0.9 | cohy(fcrange,:)>0.9);
                    %                     use = reshape(use',1,nsets*nf);
                    %                     X(:,~use)=[];
                    result = robpca(X.','classic',0,'plots',0,'k',5,'kmax',10);
                    mvar(fi).f = f(fi);
                    result.X = X;
                    mvar(fi).result = result;
                    % that's it; the rest was to produce some figures
                    %%
                    % use the first two components to compute transfer functions
                    % here, use output E09 and input E03
                    if 0
                        chs     = [9 10 23 24]; % first two are input, latter are output 
                        P       = 1:2;
                        Xp      = Xcopy;
                        U       = conj(result.P);
                        A       = result.T.';
                        tmp     = result.M.';
                        M       = tmp(:,ones(1,size(result.T,1)));
                        Xp(:,use)= U(:,P)*A(P,:);%+M;
                        Xp      = reshape(full(Xp),nch,nsets,nf);
                        Xp      = permute(Xp,[3 2 4 1]); 
                        Xinp    = Xp(:,:,:,chs(1:2));
                        Yout    = Xp(:,:,:,chs(3:4));                          
                        outch   = {'Ex' 'Ey'};
                        inch   = {'Ex' 'Ey'};
                        for iout = 1:2
                            proc        = EMRobustProcessing(squeeze(Yout(:,:,:,iout)),Xinp);
                            proc.output = outch(iout);
                            proc.input  = inch;
                            proc.f      = f;
                            if iout == 1
                                proc.useY = (cohx(fcrange,:)>0.8);%reshape(use,nsets,nf)';
                            else
                                proc.useY = (cohy(fcrange,:)>0.8);
                            end
                            %useY(:,:,ich) = proc.useY;
                            [Zf,Zfse,stats]        = computetf(proc);
                            Z(iout,:,fi)      = Zf;
                            Zse(iout,:,fi)    = Zfse;
                        end
                    end
                    %% this makes some plots of residuals
                    if 0
                        chs = 21:24;
                        for ic = 1:numel(chs)
                            ich = chs(ic);
                            P = 1:2;
                            Xap = Xcopy;
                            Xa2 = Xcopy;
                            U       = conj(result.P);
                            A       = result.T.';
                            tmp     = result.M.';
                            M       = tmp(:,ones(1,size(result.T,1)));
                            Xp      = U(:,P)*A(P,:);
                            Xm      = X-M;
                            Xa2(:,use) = Xm;
                            Xa2 = reshape(full(Xa2),nch,nsets,nf);
                            Xap(:,use) = Xp;
                            usep     = Xcopy;
                            usep     = reshape(use,nsets,nf);
                            Xap = reshape(full(Xap),nch,nsets,nf);
                            
                            %imagesc(obj.utc{1},obj.f,log10(abs(Yp-obj.Y)./stats.ols_s.*proc.useY));
                            tmp = squeeze(Xa2(ich,:,:)).*usep;
                            rms = sqrt(tmp(:)'*tmp(:)/numel(tmp));
                            bla = log10(abs(squeeze(Xap(ich,:,:)-Xa2(ich,:,:)))'.*usep'/rms);
                            bla(bla<-1 & bla > -inf)=-0.9;
                            figure(ich);
                            imagesc(obj.utc{2},obj.f,bla);
                            hold on;
                            %alpha(proc.useY/0.7+0.3)
                            set(gca,'Yscale','log','Ydir','normal')
                            ylim([0.01 100])
                            caxis([-1 1]);
                            %                             figure(ich)
                            %                             bla = abs(squeeze(Xa2(ich,:,:)))'.*usep'/rms;
                            %                             bla(bla==0) = -1;
                            %                             imagesc(obj.utc{2},obj.f,bla);
                            %                             hold on
                            %                             set(gca,'Yscale','log','Ydir','normal')
                            %                             caxis([-1 1])
                            %                             ylim([0.01 100])
                            %                             figure(ich+100)
                            %
                            %                             bla = abs(squeeze(Xap(ich,:,:)))'.*usep'/rms;
                            %                             bla(bla==0) = -1;
                            %                             imagesc(obj.utc{2},obj.f,bla);
                            %                             hold on
                            %                             set(gca,'Yscale','log','Ydir','normal')
                            %                             caxis([-1 1])
                            %                             ylim([0.01 100])

                            
                        end
                    end
                    %%
                end
            end
            if 0 % plot transfer functions 
                ztf.locname = {'E09'};
                ztf.lnch    = 2;
                ztf.lchname = {'Ex' 'Ey'};
                ztf.lchid   = 3:4;
                ztf.bname  =  {'E03'};
                ztf.bnch    = 2;
                ztf.bchname = {'Ex' 'Ey'};
                ztf.bchid   = 1:2;
                % if irs, ztf.rname = snames(rbs); end
                ztf.nper = numel(f);
                ztf.periods = 1./f';
                ztf.tf   = Z;
                ztf.tf_se = Zse;
                ztf.lon  = 0;
                ztf.lat = 0;
                sp_plottf(ztf);
            end
        end
        function varargout = plotspectra(obj,varargin)
            
            if nargin, end
            %coh = obj.coh;
            Y = obj.Y;
            Y = Y.*conj(Y);
            fscale = 'Hz';
            switch fscale
                case 'kHz', f = obj.f/1000; ylab = 'frequency';
                case 'Hz',  f = obj.f; ylab ='frequency';
                case 'sec', f = 1./obj.f;ylab = 'period';
            end
            tscale = 'utc';
            switch tscale
                %case 'sets',t = obj.w;
                case 'relative sets',t = obj.trw;
                case 'relative s',  t = obj.trs;
                case 'relative h',  t = obj.trh;
                case 'relative d',  t = obj.trd;
                case {'utc' 'UTC'}, t = obj.utc;
                otherwise, disp(['** Error plot: unknown time format <' time '>']);
            end
            
            for ich = 1:numel(obj.output)
                t0 = 0;
                figure;
                set(gcf,'Position',[624 337 1109 641])
                doannotation = 1;
                tmin = [];
                tmax = [];
                for it = 1:numel(t)
                    ti  = t{it};

                    if ~isempty(ti)
                        [tmp,bla] = min(ti);
                        tmin(end+1) = tmp;
                        [tmp,bla] = max(ti);
                        tmax(end+1) = tmp;
                        tind = t0+[1:numel(ti)];
                        t0 = tind(end);
                        if isinf(f(1)), fr = 2:numel(f); elseif f(1)==0, fr = 2:numel(f); else fr = 1:numel(f); end
                        F = f(ones(numel(tind),1),fr);
                        imagesc(ti,(f(fr)),(log10(squeeze(Y(fr,tind,:,ich)).*sqrt(F'))));
                        hold on
                        set(gca,'Ydir','normal');
                        %alpha(maskY(:,:,ich)*.7+0.3);
                        if doannotation
                            title([obj.output{ich} ' - power spectrum' ],'Fontsize', 14)                            
                            doannotation = 0;
                            ylabel([ylab ' (' fscale ')'],'Fontsize',14);
                            xlabel(['time (' tscale ')'],'Fontsize',14);
                            set(gca,'Fontsize',14);
                            %load('coherence_cmap.mat');
                            %colormap(cmap);
                            colormap(jet)
                            ch = colorbar;
                            set(ch,'Fontsize',14,'Yaxislocation','right');
                            if strfind(obj.output{ich},'E')
                            ylabel(ch,'log10 (mV/km/sqrt(Hz))','Fontsize',14);
                            elseif strfind(obj.output{ich},'B')
                            ylabel(ch,'log10 (mV/nT/sqrt(Hz))','Fontsize',14);
                            end
                            
                        end
                        [x1,bla] = min(tmin);
                        [x2,bla] = max(tmax);
                        xlim([x1,x2])
                        switch tscale
                            case {'utc','UTC'}, datetick('x','keeplimits');
                        end
                        
                    end
                end
            end
            if nargout, varargout = {hax}; else varargout = {}; end
        end
        function varargout = plotpol(obj,varargin)
            
            if nargin, end
            pol = obj.pol;
            
            fscale = 'Hz';
            switch fscale
                case 'kHz', f = obj.f/1000; ylab = 'frequency';
                case 'Hz',  f = obj.f; ylab ='frequency';
                case 'sec', f = 1./obj.f;ylab = 'period';
            end
            tscale = 'utc';
            switch tscale
                %case 'sets',t = obj.w;
                case 'relative sets',t = obj.trw;
                case 'relative s',  t = obj.trs;
                case 'relative h',  t = obj.trh;
                case 'relative d',  t = obj.trd;
                case {'utc' 'UTC'}, t = obj.utc;
                otherwise, disp(['** Error plot: unknown time format <' time '>']);
            end
            t0 = 0;
            
            figure;
            set(gcf,'Position',[624 337 1109 641])
            doannotation = 1;
            for it = 1:numel(t)
                ti  = t{it};
                if ~isempty(ti)
                    tind = t0+[1:numel(ti)];
                    t0 = tind(end);
                    if isinf(f(1)), fr = 2:numel(f); elseif f(1)==0, fr = 2:numel(f); else fr = 1:numel(f); end
                    imagesc(ti,f(fr),pol.deg(fr,tind));
                    hold on
                    %alpha(maskY(:,:,ich)*.7+0.3);
                    if doannotation
                            title(['degree of polarization - S{' obj.input{1} obj.input{2} '}'],'Fontsize', 14)
                        doannotation = 0;
                        ylabel([ylab ' (' fscale ')'],'Fontsize',14);
                        xlabel(['time (' tscale ')'],'Fontsize',14);
                        set(gca,'Fontsize',14);
                        load('coherence_cmap.mat');
                        colormap(cmap);
                        caxis([0 1]);
                        ch = colorbar;
                        set(ch,'Fontsize',14,'Yaxislocation','right');
                        %ylabel(ch,'coherency','Fontsize',14);
                    end
                    switch tscale
                        case {'utc','UTC'}, datetick('x','keeplimits');
                    end
                end
            end
            t0 = 0;
   
                figure;
                set(gcf,'Position',[624 337 1109 641])
                doannotation = 1;
                for it = 1:numel(t)
                    ti  = t{it};
                    if ~isempty(ti)
                        tind = t0+[1:numel(ti)];
                        t0 = tind(end);
                        if isinf(f(1)), fr = 2:numel(f); elseif f(1)==0, fr = 2:numel(f); else fr = 1:numel(f); end
                        imagesc(ti,f(fr),pol.or(fr,tind));
                        hold on
                        %alpha(maskY(:,:,ich)*.7+0.3);               
                        if doannotation
                            title(['angle of polarization - S(' obj.input{1} obj.input{2} ')'],'Fontsize', 14)

                            doannotation = 0;
                            ylabel([ylab ' (' fscale ')'],'Fontsize',14);
                            xlabel(['time (' tscale ')'],'Fontsize',14);
                            set(gca,'Fontsize',14);
                            load('coherence_cmap.mat');
                            colormap(cmap);
                            caxis([-180 180]);
                            ch = colorbar;
                            
                            set(ch,'Fontsize',14,'Yaxislocation','right');
                            ylabel(ch,'degree','Fontsize',14);
                        end
                        switch tscale
                            case {'utc','UTC'}, datetick('x','keeplimits');
                        end
                    end
                end
            
            if nargout, varargout = {hax}; else varargout = {}; end
        end
        function varargout = plotcoh(obj,varargin)
            
            if nargin, end
            coh = obj.coh;
            
            fscale = 'Hz';
            switch fscale
                case 'kHz', f = obj.f/1000; ylab = 'frequency';
                case 'Hz',  f = obj.f; ylab ='frequency';
                case 'sec', f = 1./obj.f;ylab = 'period';
            end
            tscale = 'utc';
            switch tscale
                %case 'sets',t = obj.w;
                case 'relative sets',t = obj.trw;
                case 'relative s',  t = obj.trs;
                case 'relative h',  t = obj.trh;
                case 'relative d',  t = obj.trd;
                case {'utc' 'UTC'}, t = obj.utc;
                otherwise, disp(['** Error plot: unknown time format <' time '>']);
            end
            t0 = 0;
            for ich = 1:numel(obj.output)
                figure;
                set(gcf,'Position',[624 337 1109 641])
                doannotation = 1;
                for it = 1:numel(t)
                    ti  = t{it};
                    if ~isempty(ti)
                        tind = t0+[1:numel(ti)];
                        t0 = tind(end);
                        if isinf(f(1)), fr = 2:numel(f); elseif f(1)==0, fr = 2:numel(f); else fr = 1:numel(f); end
                        imagesc(ti,f(fr),coh(fr,tind,ich));
                        hold on
                        %alpha(obj.maskY(:,:,ich)*.7+0.3);
                        
                        
                        if doannotation
                            if numel(obj.input) == 2
                                title([obj.output{ich} ' - ' obj.input{1} ', ' obj.input{2}],'Fontsize', 14)
                            elseif numel(obj.input) == 1
                                title([obj.output{ich} ' - ' obj.input{1}],'Fontsize', 14)
                            end
                            doannotation = 0;
                            ylabel([ylab ' (' fscale ')'],'Fontsize',14);
                            xlabel(['time (' tscale ')'],'Fontsize',14);
                            set(gca,'Fontsize',14);
                            %load('coherence_cmap.mat');
                            %colormap(cmap);
                            colormap(jet)
                            ch = colorbar;
                            set(ch,'Fontsize',14,'Yaxislocation','right');
                            ylabel(ch,'coherency','Fontsize',14);
                        end
                        switch tscale
                            case {'utc','UTC'}, datetick('x','keeplimits');
                        end
                    end
                end
            end
            if nargout, varargout = {hax}; else varargout = {}; end
        end        
        function varargout = plottfs(obj,varargin)
            
            if nargin, end
            tfs = obj.tfs;
            coh = obj.coh;
            fscale = 'Hz';
            switch fscale
                case 'kHz', f = obj.f/1000; ylab = 'frequency';
                case 'Hz',  f = obj.f; ylab ='frequency';
                case 'sec', f = 1./obj.f;ylab = 'period';
            end
            f = f(:);
            tscale = 'utc';
            switch tscale
                %case 'sets',t = obj.w;
                case 'relative sets',t = obj.trw;
                case 'relative s',  t = obj.trs;
                case 'relative h',  t = obj.trh;
                case 'relative d',  t = obj.trd;
                case {'utc' 'UTC'}, t = obj.utc;
                otherwise, disp(['** Error plot: unknown time format <' time '>']);
            end
            
            for och = 1:numel(obj.output)
                for ich = 1:numel(obj.input)
                    figure;
                    set(gcf,'Position',[624 337 1109 641])
                    doannotation = 1;
                    t0 = 0;
                    
                    for it = 1:numel(t)
                        ti  = t{it};
                        if ~isempty(ti)
                            tind = t0+[1:numel(ti)];
                            t0 = tind(end);
                            if isinf(f(1)), fr = 2:numel(f); elseif f(1)==0, fr = 2:numel(f); else fr = 1:numel(f); end
                            F = f(fr,ones(1,numel(tind)));
                            rho = abs(tfs(fr,tind,(och-1)*numel(obj.input)+ich).^2./(5*F));
                            phi = (angle(tfs(fr,tind,(och-1)*numel(obj.input)+ich))*180/pi);
                           
                            %                             hi=imagesc(ti,f(fr),real(tfs(fr,tind,(och-1)*numel(obj.input)+ich)));
%                             hi = imagesc(ti,f(fr),log10(rho));
                            hi = imagesc(ti,f(fr),phi);
                            hold on
                            a = coh(fr,tind,och)>0.9;
%                             alpha(hi,a*0.7+0.3)
                            %alpha(maskY(:,:,ich)*.7+0.3);
                            if doannotation
                                if numel(obj.input) == 2
                                    title(['TF ' obj.output{och} ' - ' obj.input{ich} ],'Fontsize', 14)
                                elseif numel(obj.input) == 1
                                    title(['TF ' obj.output{och} ' - ' obj.input{ich}],'Fontsize', 14)
                                end
                                doannotation = 0;
                                ylabel([ylab ' (' fscale ')'],'Fontsize',14);
                                xlabel(['time (' tscale ')'],'Fontsize',14);
                                set(gca,'Fontsize',14);
                                load('coherence_cmap.mat');
                                colormap(cmap);
                                ch = colorbar;
                                set(ch,'Fontsize',14,'Yaxislocation','right');
                                ylabel(ch,'real part','Fontsize',14);
                            end
                            
                        end
                       
                    end
                    switch tscale
                                case {'utc','UTC'}, datetick('x','keeplimits');
                            end
                end
            end
            if nargout, varargout = {hax}; else varargout = {}; end
        end
        
        % common with EMTimeSeries        
        function lsind = get.lsind(obj)
            lsind = [];
            if ~isempty(obj.lsname), lsind = find(strcmp(obj.sites,obj.lsname{1})); end
            if isempty(lsind) && ~isempty(obj.lsname), if obj.debuglevel, disp([' - Warning: could not find local site ',obj.lsname{1}]); end; end
        end
        function lNruns = get.lNruns(obj)
            lNruns = 0;
            if ~isempty(obj.lsind), lNruns = numel(obj.site{obj.lsind}); end
        end
        function lsrates = get.lsrates(obj)
            lsrates = [];
            if ~isempty(obj.lsind)
                for is = 1:obj.lNruns, lsrates(is) = obj.site{obj.lsind}{is}.srate; end
            end
        end
        function lsrateind = get.lsrateind(obj)
            lsrateind = [];
            if ~isempty(obj.lsrate),
                lsrateind = find(obj.lsrates == obj.lsrate);
                
                if isempty(lsrateind)
                    if obj.debuglevel, disp([' - Warning: could not find recordings at ' num2str(obj.lsrate) ' Hz']); end
                end
            end
        end
        function bsind = get.bsind(obj)
            bsind = [];
            if ~isempty(obj.bsname),
                d = 0;
                for ibs = 1:numel(obj.bsname)
                    ind = find(strcmp(obj.sites,obj.bsname{ibs})); 
                    if ~isempty(ind)
                        d = d+1;
                        bsind(d) = ind;
                    else
                        if obj.debuglevel, disp([' - Warning: could not find base site ',obj.bsname{ibs}]); end;
                    end
                end
            end
        end
        function bNruns = get.bNruns(obj)
            bNruns = 0;
            if ~isempty(obj.bsind), 
                for ibs = 1:numel(obj.bsind)
                    bNruns(ibs) = numel(obj.site{obj.bsind(ibs)});
                end
            end
        end
        function bsrates = get.bsrates(obj)
            bsrates = [];
            if ~isempty(obj.bsind)
                for ibs = 1:numel(obj.bsind)
                    for is = 1:obj.bNruns(ibs), bsrates{ibs}(is) = obj.site{obj.bsind(ibs)}{is}.srate; end
                end
            end
        end
        function bsrateind = get.bsrateind(obj)
            bsrateind = {}; 
            if ~isempty(obj.bsrate),
                for ibs = 1:numel(obj.bsind)
                    ind = [];
                    for isr = 1:numel(obj.bsrate)
                        ind = [ind find(obj.bsrates{ibs} == obj.bsrate(isr))];
                    end
                    bsrateind{ibs} = ind;
                end
            else
                for ibs = 1:numel(obj.bsind)
                    bsrateind{ibs} = 1:numel(obj.bsrates{ibs});
                end
            end             
        end
        function localsite = get.localsite(obj)
            localsite = {};
            lsind     = obj.lsind;
            lsrateind = obj.lsrateind;
            if ~isempty(lsind) && ~isempty(lsrateind), localsite = obj.site{obj.lsind}(lsrateind); end
        end
        function basesite = get.basesite(obj)
            basesite = {};
            bsind     = obj.bsind;
            bsrateind = obj.bsrateind;
            if ~isempty(bsind) && ~isempty(bsrateind),
                for ibs = 1:numel(bsind)
                    basesite{ibs} = obj.site{obj.bsind(ibs)}(bsrateind{ibs}); 
                end
            end
        end
        function srates    = get.srates(obj)
            srates = [];
            for is = 1:numel(obj.sites)
                for ir = 1:numel(obj.site{is})
                    srates{is}(ir) = obj.site{is}{ir}.srate;
                end
            end
        end        
        function sites     = get.sites(obj)
            sites = cell(1,numel(obj.site));
            for ind = 1 : numel(obj.site)
                sites{ind} = obj.site{ind}{1}.name;
                for ind2 = 2 : numel(obj.site{ind})
                    if ~isequal(sites{ind},obj.site{ind}{ind2}.name);
                        disp('Warning: Runs have different sitenames, using first!');
                    end
                end
            end
        end        
        % newly added to EMProc
        function snames     = get.snames(obj)            
            ind = obj.useind;
            snames = cell(1,numel(ind));
            for ir = 1:numel(ind)
                snames(ir) = obj.sites(ind{ir}(1));
            end
        end
        function sratesusedsites = get.sratesusedsites(obj)
            sratesusedsites = obj.srates(obj.usesitesind);
        end
        function useind    = get.useind(obj)
            useind = {};
            id     = 1;
            for is = 1:numel(obj.usesitesind)
                k = obj.usesitesind(is);
                if ~isempty(obj.usesrates)
                    for ir = 1:numel(obj.srates{k})
                        if any(obj.usesrates == obj.srates{k}(ir))
                            useind{id} = [k,ir];
                            id = id+1;
                        end
                    end
                else
                    for ir = 1:numel(obj.srates{k})
                        useind{id} = [k,ir];
                        id = id+1;
                    end
                end
            end
        end               
        function usesitesind = get.usesitesind(obj)
            if strcmp(obj.usesites,'all')
                sind = 1:numel(obj.sites);
            else
                sind = [];
                for is = 1:numel(obj.usesites)
                    tmp = strfind(obj.sites,obj.usesites{is});
                    sind = [sind tmp{1}];
                end
            end
            usesitesind = sind;
        end        


        % common but with different implementation
        function obj = remove_site(obj,sname)
            if numel(sname) > 1
                for ind = 1 : numel(sname)
                    obj = obj.remove_site(sname(ind));
                end
                return
            end
            found_site = strcmp(obj.sites,sname);
            if any(found_site);
                if strcmp(obj.lsname, sname);
                    obj.lsname = [];
                end
                if strcmp(obj.rsname, sname);
                    obj.rsname = [];
                end
                if any(strcmp(obj.bsname, sname));
                    obj.bsname(strcmp(obj.bsname, sname)) = [];
                end
                obj.site(found_site) = [];
            end     
        end
        % common but different implementation, newly added
        function plotruntimes(obj,varargin)
            if nargin
                if any(strcmp(varargin,'time'))
                    ind = find(strcmp(varargin,'time'));
                    time = varargin{ind+1};
                else
                    time = 'utc';
                end
                if any(strcmp(varargin,'systems'))
                    ind = find(strcmp(varargin,'systems'));
                    sys = varargin{ind+1};
                else
                    sys = [];
                end
                if any(strcmp(varargin,'Nsites'))
                    ind = find(strcmp(varargin,'Nsites'));
                    Nsites = varargin{ind+1};
                else
                    Nsites = numel(obj.site);
                end
                if any(strcmp(varargin,'axes'))
                    ind = find(strcmp(varargin,'axes'));
                    hax = varargin{ind+1};
                    delete(get(hax,'Children'));
                else
                    hax = [];
                end
                if any(strcmp(varargin,'srates'))
                    ind = find(strcmp(varargin,'srates'));
                    srates = varargin{ind+1};
                else
                    srates = [];
                end
            end
            obj.usesrates = srates;
            
            % check which decimation levels are available
            ndec = 0;
            for is = 1 : numel(obj.site)
                for ir  = 1 : numel(obj.site{is})
                    ndec = max(ndec, obj.site{is}{ir}.Ndec);
                end
            end
            
            for idec = 1 : ndec
                obj.usedec = idec;
                runtimes = obj.runtimes;
                ind = obj.useind;
                ylab = []; isy = 0;
                for ir = 1:numel(runtimes)
                    is = ind{ir}(1);
                    sr = ind{ir}(2);
                    
                    % system variable not set unknown
                    %system{ir} = obj.site{is}{sr}.system;
                                        
                    if isempty(ylab)
                        ylab{1} = obj.sites{ind{ir}(1)};
                        isy = isy+1;
                    elseif ~strcmp(ylab,obj.sites{ind{ir}(1)})
                        ylab{end+1} = obj.sites{ind{ir}(1)};
                        isy = isy+1;
                    end
                    switch time
                        case 'utc'
                            start = datenum(runtimes{ir}(1:6));
                            stop  = datenum(runtimes{ir}(7:12));
                        case 'relative s'
                            start = etime(runtimes{ir}(1:6),obj.reftime);
                            stop  = etime(runtimes{ir}(7:12),obj.reftime);
                        case 'relative h'
                            start = etime(runtimes{ir}(1:6),obj.reftime)/3600;
                            stop  = etime(runtimes{ir}(7:12),obj.reftime)/3600;
                        case 'relative d'
                            start = etime(runtimes{ir}(1:6),obj.reftime)/3600/24;
                            stop  = etime(runtimes{ir}(7:12),obj.reftime)/3600/24;
                    end
                    x(ir,:) = [start start stop stop];
                    del = 0.3/ndec;
                    y(ir,:) = [isy-del isy+del isy+del isy-del]-0.3+idec/ndec*0.6;                    
                    c(ir)   = 1;
                    runstr{ir} = [num2str(sr,'%03d')];
                    runstrxy(ir,:)   = [isy (start+stop)/2];
                    
                    % system unknown
                    %switch system{ir}(1:3)
                    %    case 'EDE'
                    %        cdata(ir,:)   = [.3 1 .3];
                    %    case 'ADU'
                    %        cdata(ir,:)   = [1 .3 .3];
                    %    case 'SP4'
                    %        cdata(ir,:)   = [1 .7 .3];
                    %    case 'EDL'
                    %        cdata(ir,:)   = [.3 .7 1];
                    %    otherwise
                    %        cdata(ir,:)   = [.7 .7 .7];
                    % end
                    cdata(ir,:)   = [.7 .7 .7]*(0.5+0.5*idec/ndec);
                end
                if idec == 1
                    if isempty(hax)
                        figure;
                        set(gcf,'Position',[42 309  1170 663]);
                        hax = axes;
                    end
                    axes(hax);
                    set(hax,'Nextplot','replace','XTickmode','auto'); plot(1,1); delete(get(hax,'children'));
                end
                p = patch(x',y',c,'Edgecolor',[0.3 .3 .3]);
                set(p,'FaceColor','flat',...
                    'FaceVertexCData',cdata)
                set(gca,'Ytick',[1:numel(ylab)],'YTicklabel',ylab,'Ygrid','on','Fontsize',14,'box','on','Fontname','Hevetica','Yaxislocation','right');
                hold on
                if idec == ndec
                    for ir = 1:numel(runstr)
                        text(runstrxy(ir,2),runstrxy(ir,1),runstr{ir},'Fontsize',14,'Fontname','Courier','HorizontalAlignment','center');
                    end
                end
            end
            switch time
                case 'utc'
                    datetick('x',6,'keepticks');
            end
            ylim([0 Nsites+1]);
            xlabel(time,'Fontsize',14)
        end                
        function runtimes  = get.runtimes(obj)
            % for a given usedec
            runtimes = {};
            useind = obj.useind;
            site = obj.site;
            for ir = 1:numel(useind)
                st = useind{ir}(1);
                r = useind{ir}(2);
                tsite = site{st}{r};   
                utc = tsite.utc;
                start = datevec(utc(1));
                stop = datevec(utc(end));                
                runtimes{ir} = [start stop];
            end
        end
        
        % could be common, but is not
        function rsind = get.rsind(obj)
            rsind = [];
            if ~isempty(obj.rsname),
                d = 0;
                for ibs = 1:numel(obj.rsname)
                    ind = find(strcmp(obj.sites,obj.rsname{ibs})); 
                    if ~isempty(ind)
                        d = d+1;
                        rsind(d) = ind;
                    else
                        if obj.debuglevel, disp([' - Warning: could not find ref site ',obj.rsname{ibs}]); end;
                    end
                end
            end
        end
        function rNruns = get.rNruns(obj)
            rNruns = 0;
            if ~isempty(obj.rsind), 
                for ibs = 1:numel(obj.rsind)
                    rNruns(ibs) = numel(obj.site{obj.rsind(ibs)});
                end
            end
        end
        function rsrates = get.rsrates(obj)
            rsrates = [];
            if ~isempty(obj.rsind)
                for ibs = 1:numel(obj.rsind)
                    for is = 1:obj.rNruns(ibs), rsrates{ibs}(is) = obj.site{obj.rsind(ibs)}{is}.srate; end
                end
            end
        end
        function rsrateind = get.rsrateind(obj)
            rsrateind = {}; 
            if ~isempty(obj.rsrate),
                for ibs = 1:numel(obj.rsind)
                    ind = [];
                    for isr = 1:numel(obj.rsrate)
                        ind = [ind find(obj.rsrates{ibs} == obj.rsrate(isr))];
                    end
                    rsrateind{ibs} = ind;
                end
            else
                for ibs = 1:numel(obj.rsind)
                    rsrateind{ibs} = 1:numel(obj.rsrates{ibs});
                end
            end             
        end
        function asind = get.asind(obj)
            asind = [];
            if ~isempty(obj.asname),
                d = 0;
                for ibs = 1:numel(obj.asname)
                    ind = find(strcmp(obj.sites,obj.asname{ibs})); 
                    if ~isempty(ind)
                        d = d+1;
                        asind(d) = ind;
                    else
                        if obj.debuglevel, disp([' - Warning: could not find base site ',obj.asname{ibs}]); end;
                    end
                end
            end
        end
        function aNruns = get.aNruns(obj)
            aNruns = 0;
            if ~isempty(obj.asind), 
                for ibs = 1:numel(obj.asind)
                    %ibs
                    aNruns(ibs) = numel(obj.site{obj.asind(ibs)});
                end
            end
        end
        function asrates = get.asrates(obj)
            asrates = [];
            if ~isempty(obj.asind)
                for ibs = 1:numel(obj.asind)
                    for is = 1:obj.aNruns(ibs), asrates{ibs}(is) = obj.site{obj.asind(ibs)}{is}.srate; end
                end
            end
        end
        function asrateind = get.asrateind(obj)
            asrateind = {}; 
            if ~isempty(obj.asrate),
                for ibs = 1:numel(obj.asind)
                    ind = [];
                    for isr = 1:numel(obj.asrate)
                        ind = [ind find(obj.asrates{ibs} == obj.asrate(isr))];
                    end
                    asrateind{ibs} = ind;
                end
            else
                for ibs = 1:numel(obj.asind)
                    asrateind{ibs} = 1:numel(obj.asrates{ibs});
                end
            end             
        end
        function refsite = get.refsite(obj)
            refsite = {};
            rsind     = obj.rsind;
            rsrateind = obj.rsrateind;
            if ~isempty(rsind) && ~isempty(rsrateind),
                for ibs = 1:numel(rsind)
                    refsite{ibs} = obj.site{obj.rsind(ibs)}(rsrateind{ibs}); 
                end
            end
        end
        function array = get.array(obj)
            array = {};
            asind     = obj.asind;
            asrateind = obj.asrateind;
            if ~isempty(asind) && ~isempty(asrateind),
                for ibs = 1:numel(asind)
                    array{ibs} = obj.site{obj.asind(ibs)}(asrateind{ibs}); 
                end
            end
        end
                

    end
    
end % classdef

