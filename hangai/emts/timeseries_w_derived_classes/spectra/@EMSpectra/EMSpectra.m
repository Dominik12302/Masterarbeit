%%
% class definition of EMSpectra
%
% - calling sequences
%
% obj = EMSpectra
%     generates a default EMSpectr object
% obj = EMSpectra(<project>);
% where
% - methods
%                                       model parameters stored in m
% - plotting example
%

% % MB 2012
classdef EMSpectra % discrete block model
    properties
        source      =   {''};
        name        =   '000';
        run         =   '001';
        lat         =   0;
        lon         =   0;
        alt         =   0;
        reftime     =   [1970 1 1 0 0 0];
        caldir      =   {''};

        Ndec        =   12;
        decimate    =   [  1   4   4   4   4   4   4   4   4   4   4   4]; 
        wlength     =   [128 128 128 128 128 128 128 128 128 128 128 128];
        noverlap    =   [ 32  32  32  32  32  32  32  64  64  64  64  64];
        prew        =   [ -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1];
      
        
        
        window      =   'hanning';    % window type
        timebandwidth = 5/2;       % 
        Nk          =   1;         % number of tapers for each decimation level
        delayfilt   =   0;   
        bandsetup   =   'MT'       % default band setup
        bsfc        =   {};
        bsfcenter   =   {};
        usedec      =   1;         % current decimation level
        fcrange     =   [];
        setrange    =   [];
        input       =   {'Bx' 'By'}
        output      =   {'Bz'};
        debuglevel  =   1;
    end
    properties (SetAccess = private) 
        global_headerlength  = 1024;
        channel_headerlength = 1024;
        Nch         =   0;      % number of channels
        tssource    =   {''};   % source directory for time series
        chnames     =   {''};
        chtypes     =   {''};
        sens_name   =   {''};
        sens_sn     =   {''};
        calfile     =   {''};
        caldata     =   {''};       
        srate       =   0;         % sampling rate of the undecimated data
        Nsets       =   0;         % number of sets (windows) for each decimation level
        Nf          =   0;         % number of requencies for each decimation level
        W           =   [1 2];     % index of first and last window for each decimaimation level
        T           =   [0 0 0];   % central time of first window and last in seconds since reftime and time 
                                   % spacing between adjacent windows for each decimation level
        F           =   [1 1 0];   % first and last frequency
    end
    properties (Dependent = true,  SetAccess = private)
        sratedec                    % sampling rates for each decimation level
        Nfc                         % total number of fourie coefficients for each decimation level
        Y
        useY
        X
        useX
        f
        w
        wr
        trs
        trh
        trd
        utc
    end
    methods
        function obj = EMSpectra(varargin)
            if nargin
                if nargin == 1 && exist(varargin{1},'file') % just read file
                    obj         = sp_readheaderafc(obj,varargin{1});
                    obj.source  = {varargin{1}};
                    %obj.bandsetup ='RMT';
                    obj         = sp_defaultbs(obj);
                elseif nargin == 2
                    if isa(varargin{1},'EMSpectra') && isa(varargin{2},'EMSites') % compute spectra
                        % read calibration data
                        obj = varargin{1};
                        ts  = varargin{2};
                        obj.srate = ts.srate;
                        obj = sp_readcaldata(obj,ts);
                        obj = sp_defaultbs(obj);
                        obj = sp_writeafc2(obj,ts);
                    elseif isa(varargin{1},'EMSpectra')  && ischar(varargin{2})
                        if exist(varargin{2},'file') % just read file
                        obj         = varargin{1};                                         
                        obj         = sp_readheaderafc(obj,varargin{2});
                        obj.source  = {varargin{2}};
                        obj         = sp_defaultbs(obj);
                        else
                            if obj.debuglevel==2, disp(['**Warning: Could not find spectra file ' varargin{2}]); end
                        end
                    end
                end
            end
        end
        function sratedec = get.sratedec(obj)
            sratedec = obj.srate./cumprod(obj.decimate);
        end
        function Nfc = get.Nfc(obj)
            Nfc = obj.Nf.*obj.Nsets*obj.Nk;
        end
        function Y = get.Y(obj)
            Y = sp_readdata(obj,obj.output);
        end
        function useY = get.useY(obj)
            useY = sp_readmask(obj,obj.output);
        end
        function X = get.X(obj)
            [X] = sp_readdata(obj,obj.input);
        end
        function useX = get.useX(obj)
            useX = sp_readmask(obj,obj.input);
        end
        function f = get.f(obj)
            f = obj.F(obj.usedec,1):obj.F(obj.usedec,3):obj.F(obj.usedec,2);
            if ~isempty(obj.fcrange)
                f = f(min(obj.fcrange):max(obj.fcrange));
            end
        end
        function trs = get.trs(obj)
            trs = obj.T(obj.usedec,1):obj.T(obj.usedec,3):obj.T(obj.usedec,2);
            if ~isempty(obj.setrange)
                trs = trs(obj.setrange);
            end
        end
        function trh = get.trh(obj)
            trh= obj.trs/3600;
        end
        function trd = get.trd(obj)
            trd= obj.trs/3600/24;
        end
        function utc = get.utc(obj)
            utc = datenum(obj.reftime)+obj.trd;
        end
        function w = get.w(obj)
            w = 1+[0:diff(obj.W(obj.usedec,:))];
            if ~isempty(obj.setrange)
                w = w(obj.setrange);
            end
        end
        function wr = get.wr(obj)
            wr = obj.W(obj.usedec,1):obj.W(obj.usedec,2);
            if ~isempty(obj.setrange)
                wr = wr(obj.setrange);
            end
        end
        function varargout = plot(obj,varargin)
            if nargin
                if any(strcmp(varargin,'channel'))
                    ind = find(strcmp(varargin,'channel'));
                    ch  = varargin{ind+1};
                else
                    ch  = 'Bx';
                end
                if any(strcmp(varargin,'time'))
                    ind = find(strcmp(varargin,'time'));
                    time = varargin{ind+1};
                else
                    time = 'sets';
                end
                if any(strcmp(varargin,'frequency'))
                    ind = find(strcmp(varargin,'frequency'));
                    fscale = varargin{ind+1};
                else
                    fscale = 'Hz';
                end
                if any(strcmp(varargin,'clim'))
                    ind = find(strcmp(varargin,'clim'));
                    clim = varargin{ind+1};
                else
                    clim = 'auto';
                end
                if any(strcmp(varargin,'axes'))
                    ind = find(strcmp(varargin,'axes'));
                    hax = varargin{ind+1};
                else
                    hax = [];
                end
            else
                time  = 'sets';
                fscale = 'Hz';
                ch = 'Bx';
                clim  = 'auto';
                hax   =  [];
            end
            obj.output = {ch};
            switch fscale
                case 'kHz', f = obj.f/1000; ylab = 'frequency';
                case 'Hz', f = obj.f; ylab = 'frequency';
                case 'sec', f = 1./obj.f; ylab = 'period';
            end
            switch time
                case 'sets',t = obj.w;
                case 'relative sets',t = obj.wr;
                case 'relative s',  t = obj.trs;
                case 'relative h',  t = obj.trh;
                case 'relative d',  t = obj.trd;
                case {'utc' 'UTC'}, t = obj.utc;
                otherwise, disp(['** Error plot: unknown time format <' time '>']);
            end
            if isempty(hax)
                figure;
                set(gcf,'Position',[42 309  1170 663]);
               
                hax = axes;
                imagesc(t,f(2:end),log10(abs(obj.Y(2:end,:)).^2));
                colorbar;
                caxis(clim);
                title([obj.name ' - ' ch ' autopower'],'Fontsize',14,'Fontname','Helvetica');
                set(gca,'Fontsize',14','Position',[0.1 .1 .75 .8],'box','on');
                ylabel([ylab ' (' fscale ')'],'Fontsize',14)
                xlabel(['time (' time ')'],'Fontsize',14);
                grid on
                switch time
                    case {'utc','UTC'}, datetick(hax,'x','keeplimits');
                end
            end
        end
        
        % % better mov to EMRobustProcessing
        function plotbicoh(obj,proc,fscale,tscale,varargin)
            if nargin> 4 && ~isempty(varargin)
                bicoh = varargin{1};
            else
                bicoh = proc.bicoh;
            end
            if nargin> 5 && ~isempty(varargin)
                maskY = varargin{2};
            else
                maskY = proc.maskY;
            end
            switch fscale
                case 'kHz', f = obj.f/1000; ylab = 'frequency';
                case 'Hz', f = obj.f; ylab ='frequency';
                case 'sec', f = 1./obj.f;ylab = 'period';
            end
            switch tscale
                case 'sets',t = obj.w;
                case 'relative sets',t = obj.wr;
                case 'relative s',  t = obj.trs;
                case 'relative h',  t = obj.trh;
                case 'relative d',  t = obj.trd;
                case {'utc' 'UTC'}, t = obj.utc;
                otherwise, disp(['** Error plot: unknown time format <' time '>']);
            end
            for ich = 1:proc.Noutput
                figure;
                set(gcf,'Position',[624 337 1109 641])
                imagesc(t,f,bicoh(:,:,ich));
                alpha(maskY(:,:,ich)*.7+0.3);
                title([obj.output{ich} ' - ' obj.input{1} ', ' obj.input{2}],'Fontsize', 14)
                ylabel([ylab ' (' fscale ')'],'Fontsize',14);
                xlabel(['time (' tscale ')'],'Fontsize',14);
                set(gca,'Fontsize',14);
                load('coherence_cmap.mat');
                colormap(cmap);
                ch = colorbar;
                set(ch,'Fontsize',14,'Yaxislocation','right');
                ylabel(ch,'bivariate coherency','Fontsize',14);
                switch tscale
                    case {'utc','UTC'}, datetick('x','keeplimits');
                end
            end
        end
    end
end % classdef

