%%
% class definition of EMRobustProcessing
%
% - calling sequences
%
% obj = EMRobustProcessing
%     generates a default EMSpectra object
% obj = EMRobustProcessing(Y,X);
% obj = EMRobustProcessing(Y,X,Xr);
% obj = EMRobustProcessing(Y,X,usey,usex);
% obj = EMRobustProcessing(Y,X,Xr,usey,usex,usexr);
%
% where
%
% Y is the output or predicted channel of dimension Nfc x Nsets x Nslepian x Noutput
% X are the input or predicting channels of dimension Nfc x Nsets x Nslepian x Ninput
% Xr are the reference channels (if any) of dimension size(X)
% Ym, Xm, Xrm are the data with the emasked entries replaced with nans
% YmN, XmN, XrmN are the masked data rearranged into dimension (Nfs*Nsets*Nk x Nch)
% masky, maskx, maskxr are logical masking (false/true) matrices of corresponding dimensions
%
% - public fields
% obj.smooth    smoothing method for coherency and transfer function estimates
% obj.avrange   Nfsc x Nsets averaging area for smoothing
%
% - private methods
% obj.bicoh     bivariate coherencies for individual pixels of the
%               smoothed image in time-frequency domain
% obj.tfs       transfer function estimates for individual pixels of the
%               smoothed image in time-frequency domain
%
% - plotting example
%
%
%% MB 2013
classdef EMRobustProcessing % discrete block model
    properties
        Nfc      =   0;         % number of Fcs
        Nsets    =   0;         % number of sets
        Nk       =   0;         % number of Slepian squences
        Noutput  =   0;         % number of input channels
        Ninput   =   0;         % number of output channels = 1
        Nrefs    =   0;         % number of reference channels
        f        =   [];
        t        =   [];
        input    =   {};
        output   =   {};
        Y        =   [];        % predicted channel   Nfcs x Nsets x Nslepians x Ninput
        X        =   [];        % predicting channels Nfcs x Nsets x Nslepians x Noutpout
        Xr       =   [];        % remote reference chanel of same dimensions as x
        useY     =   [];        % logical mask of Y with dim Nfcs x Nsets x Ninput
        useX     =   [];        % logical mask of Y Nfcs x Nsets x Noutput
        useXr    =   [];
        huber    =   1.5;       % huber constant
        reg      =   'Mestimate'       % regression on 'fc' or 'spectra'
        smooth   =   'runav'    % 'none', 'runav' or 'smoothn'
        avrange  =   [2 5];     % [Nfc Nset] , averaging area (volume) for computing spectra, coherencies,
        bicohthresg= {};        % {[min max],[],...} Noutput global coherency thresholds, applied to individual piyels of the Nfc x Nsets image
        bicohthrest= {};        % {[min max],[],...} Noutput cohrency threshold applied to frequency averaged coherencies, i.e. pull out individual time windows
        bicohthresf= {};        % {[min max],[],...} Noutput coherency threshold applied to time averaged coherencies, i.e. pull out individual fourier coefficients
        tfsthres =   {};          % {[zr+1i*zi, radius, iinput],[],...} include points within cirle drawn by radius around point zr+1i*zi in the complex plane
        % iinput indexes the input channel, i.e. let the two output channels be Ex and Ey, then Zyx is masked with
        % the following syntax {[],[zr+1i*zi, radius, 1], where 1 refers to Hx
        debuglevel = 1;
        all_good     = false;   % JK, only set to true if things went fine
    end
    properties (Dependent = true,  SetAccess = private)
        maskY                   % mask, made dependent on threshold and with logical and with useY
        maskX
        maskXr
        Ym                      % Y with masked entries set to nan
        Xm                      % X with masked entries set to nan
        Xrm                     % Xr with masked entries set to nan
        YmN                     % Ym, reshaped to N x Noutput matrix, with N=Nfc x Nsets x Nk
        XmN                     % Xm, reshaped to N x Ninput matrix, with N=Nfc x Nsets x Nk
        XrmN                    % Xrm, reshaped to N x Ninput matrix, with N=Nfc x Nsets x Nk
        YY                      % autospectrum Y.*conj(Y)
        XX                      % cross spectral matrix X.*conj(X)
        XXr                     % autospectrum Xr.*conj(Xr)
        YX                      % crossspectrum X.*conj(Y)
        XY                      % ...
        YYs                     %  autospectrum Y.*conj(Y)
        XXs                     % smoothed cross spectral matrix X.*conj(X)
        XXrs                    % smoothed autospectrum Xr.*conj(Xr)
        YXs                     % smoothed crossspectrum X.*conj(Y)
        XYs                     % ...
        YYm                     % autospectrum  conj(Y).*Y, with masked entries set to nan
        XXm                     % cross spectral matrix conj(X).*X, with masked entries set to nan
        XXrm                    % cross spectral matrix conj(Xr).*Xr, with masked entries set to nan
        YXm                     % crossspectrum conj(Y).*X, with masked entries set to nan
        XYm                     % crossspectrum conj(X).*X, with masked entries set to nan
        YYmN                    % YYm, reshaped to N x Noutput*Noutput matrix, with N=Nfc x Nsets x Nk
        XXmN                    % XXm, reshaped to N x Ninput*Noutput matrix, with N=Nfc x Nsets
        XXrmN                   % XXrm, reshaped to N x Ninput*Ninput matrix, with N=Nfc x Nsets
        YXmN                    % YXm, reshaped to N x Ninput*Noutput matrix, with N=Nfc x Nsets
        XYmN                    % YXm, reshaped to N x Ninput*Noutput matrix, with N=Nfc x Nsets
        YYmNs                   % YYm, reshaped to N x Noutput*Noutput matrix, with N=Nfc x Nsets x Nk
        XXmNs                   % XXm, reshaped to N x Ninput*Noutput matrix, with N= Nsets and averaged over all non-masked fcs
        XXrmNs                  % XXrm, reshaped to N x Ninput*Ninput matrix, with N= Nsets and averaged over all non-masked fcs
        YXmNs                   % YXm, reshaped to N x Ninput*Noutput matrix, with N= Nsets and averaged over all non-masked fcs
        XYmNs                   % YXm, reshaped to N x Ninput*Noutput matrix, with N= Nsets and averaged over all non-masked fcs   
        tfs                     % lsq transfer functions for each estimate of the smoothed spectra
        pol
        unicoh
        bicoh
        leverage
        resid
        %         tf
    end
    methods
        %% constructor
        function obj = EMRobustProcessing(varargin)
            Os = size(varargin{1}); if numel(Os)==2, Os = [Os 1]; end; if numel(Os)==3, Os = [Os 1]; end
            Is = size(varargin{2}); if numel(Is)==2, Is = [Is 1]; end; if numel(Is)==3, Is = [Is 1]; end
            %             obj.f = varargin{1};
            
            % JK: I added "return" here to not bother ... and keep
            % obj.all_good == false
            if Os(1) == Is(1), obj.Nfc     = Os(1); else disp('116 matrix dimensions must agree'); return; end
            if Os(2) == Is(2), obj.Nsets   = Os(2); else disp('117 matrix dimensions must agree'); return; end
            if Os(3) == Is(3), obj.Nk      = Os(3); else disp('118 matrix dimensions must agree'); return; end            
            obj.all_good = true;
            
            obj.Ninput  = Is(4);
            obj.Noutput = Os(4);
            if nargin
                if nargin == 2
                    obj.Y = varargin{1};
                    obj.X = varargin{2};
                    obj.useY = true([obj.Nfc,obj.Nsets,obj.Noutput]);
                    obj.useX = true([obj.Nfc,obj.Nsets,obj.Ninput]);
                elseif nargin == 3
                    obj.Y = varargin{1};
                    obj.X = varargin{2};
                    obj.Xr = varargin{3};
                    obj.useY = true([obj.Nfc,obj.Nsets,obj.Noutput]);
                    obj.useX = true([obj.Nfc,obj.Nsets,obj.Ninput]);
                    obj.useXr= true([obj.Nfc,obj.Nsets,obj.Ninput]);
                elseif nargin == 4
                    obj.Y = varargin{1};
                    obj.X = varargin{2};
                    obj.useY = varargin{3};
                    obj.useX = varargin{4};
                elseif nargin == 6
                    obj.Y = varargin{1};
                    obj.X = varargin{2};
                    obj.Xr = varargin{3};
                    obj.useY = varargin{4};
                    obj.useX = varargin{5};
                    obj.useXr = varargin{6};
                end
            end
        end
        %% apply mask
        function maskY = get.maskY(obj)
            maskY = true([obj.Nfc,obj.Nsets,obj.Noutput]);
            % global coherency thresholding
            if ~isempty(obj.bicohthresg)
                tmpY  = false([obj.Nfc, obj.Nsets]);
                if numel(obj.bicohthresg) ~= obj.Noutput
                    if obj.debuglevel, disp(' - Error:  numel(obj.bicohthresg) ~= obj.Noutput'); end
                else
                    for it = 1:obj.Noutput
                        thres = obj.bicohthresg{it};
                        if ~isempty(thres)
                            if ~exist('bicoh','var'), bicoh = obj.bicoh; end                            
                            maskY(:,:,it) = maskY(:,:,it) & ...
                                (bicoh(:,:,it) > min(thres) & bicoh(:,:,it)<=max(thres));                                                                                        
                            tmpY = tmpY | maskY(:,:,it);
                        end
                    end
                    % use same mask for all output channels: logical or
                    if any(tmpY)
                        for it = 1:obj.Noutput
                            maskY(:,:,it) = tmpY;
                        end
                    end
                end
            end
            % frequency averaged coherency thresholding
            if ~isempty(obj.bicohthrest)
                tmpY  = false([obj.Nfc, obj.Nsets]);
                if numel(obj.bicohthrest) ~= obj.Noutput
                    if obj.debuglevel, disp(' - Error:  numel(obj.bicohthrest) ~= obj.Noutput'); end
                else
                    for it = 1:obj.Noutput
                        thres = obj.bicohthrest{it};
                        if ~isempty(thres)
                            if ~exist('bicoh','var'), bicoh = obj.bicoh; end
                            bicoht = mean(bicoh(:,:,it),1);
                            maskYt = bicoht > min(thres) & bicoht<=max(thres);
                            maskY(:,:,it) = maskY(:,:,it) & maskYt(ones(obj.Nfc,1),:);
                            tmpY = tmpY | maskY(:,:,it);
                        end
                        
                    end
                    % use same maske for all output channels: logical or
                    if any(tmpY)
                        for it = 1:obj.Noutput
                            maskY(:,:,it) = tmpY;
                        end
                    end
                end
            end
            % time averaged coherency thresholding
            if ~isempty(obj.bicohthresf)
                tmpY  = false([obj.Nfc, obj.Nsets]);
                if numel(obj.bicohthresf) ~= obj.Noutput
                    if obj.debuglevel, disp(' - Error:  numel(obj.bicohthrest) ~= obj.Noutput'); end
                else
                    for it = 1:obj.Noutput
                        thres = obj.bicohthresf{it};
                        if ~isempty(thres)
                            if ~exist('bicoh','var'), bicoh = obj.bicoh; end
                            bicohf = mean(bicoh(:,:,it),2);
                            maskYf = bicohf > min(thres) & bicohf<=max(thres);
                            maskY(:,:,it) = maskY(:,:,it) & maskYf(:,ones(1,obj.Nsets));
                            tmpY = tmpY | maskY(:,:,it);
                        end
                    end
                    % use same maske for all output channels: logical or
                    if any(tmpY)
                        for it = 1:obj.Noutput
                            maskY(:,:,it) = tmpY;
                        end
                    end
                end
            end
            if ~isempty(obj.tfsthres)
                % tmpY  = false([obj.Nfc, obj.Nsets]);
                if numel(obj.tfsthres) ~= obj.Noutput
                    if obj.debuglevel, disp(' - Error:  numel(obj.bicohthrest) ~= obj.Noutput'); end
                else
                    for it = 1:obj.Noutput
                        thres = obj.tfsthres{it};
                        if ~isempty(thres)
                            if ~exist('tfs','var'), tfs = obj.tfs; end
                            %                             f = obj.f';
                            %                             f = f(:,ones(obj.Nsets,1));
                            Z   = tfs(:,:,(it-1)*2+thres(4));
                            Rho = Z;
                            %                             Rho = log10(abs(Z).^2./f/5).*exp(1i*angle(Z));
                            tmpY = sqrt((real(Rho)-thres(1)).^2+(imag(Rho)-thres(2)).^2) <= thres(3);
                            maskY(:,:,it) = maskY(:,:,it) & tmpY;
                        end
                    end
                end
            end
        end
        function maskX = get.maskX(obj)
            maskX = obj.useX;
        end
        function maskXr = get.maskXr(obj)
            maskXr = obj.useXr;
        end
        function Ym = get.Ym(obj)
            Ym = obj.Y;
            for lch = 1:obj.Noutput
                for k = 1:obj.Nk
                    tmp = Ym(:,:,k,lch);
                    tmp(~obj.useY(:,:,lch)) = nan;
                    Ym(:,:,k,lch) = tmp;
                end
            end
        end
        function Xm = get.Xm(obj)
            Xm = obj.X;
            for rch = 1:obj.Ninput
                for k = 1:obj.Nk
                    tmp = Xm(:,:,k,rch);
                    tmp(~obj.useX(:,:,rch)) = nan;
                    Xm(:,:,k,rch) = tmp;
                end
            end
        end
        function Xrm = get.Xrm(obj)
            if ~isempty(obj.Xr)
                Xrm = obj.Xr;
                for rch = 1:obj.Ninput
                    for k = 1:obj.Nk
                        tmp = Xrm(:,:,k,rch);
                        tmp(~obj.useX(:,:,rch)) = nan;
                        Xrm(:,:,k,rch) = tmp;
                    end
                end
            else
                Xrm = [];
            end
        end
        %% reshape
        function YmN = get.YmN(obj)
            N = obj.Nfc*obj.Nsets*obj.Nk;
            Ym  = permute(obj.Ym,[2 1 3 4]);           
            YmN = reshape(Ym,N,obj.Noutput);
            
            %             YmN = zeros(N,obj.Noutput);
            %             for ich = 1:obj.Noutput
            %                 YmN(:,ich) = reshape(obj.Ym(:,:,:,ich),N,1);
            %             end
        end
        function XmN = get.XmN(obj)
            N = obj.Nfc*obj.Nsets*obj.Nk;
            Xm  = permute(obj.Xm,[2 1 3 4]);
            XmN = reshape(Xm,N,obj.Ninput);
            %             XmN = zeros(N,obj.Ninput);
            %             for ich = 1:obj.Ninput
            %                 XmN(:,ich) = reshape(obj.Xm(:,:,:,ich),N,1);
            %             end
        end
        function XrmN = get.XrmN(obj)
            if ~isempty(obj.Xrm)
                N = obj.Nfc*obj.Nsets*obj.Nk;
                Xrm  = permute(obj.Xrm,[2 1 3 4]);
                XrmN = reshape(Xrm,N,obj.Ninput);
                %                 XrmN = zeros(N,obj.Ninput);
                %                 for ich = 1:obj.Ninput
                %                     XrmN(:,ich) = reshape(obj.Xrm(:,:,:,ich),N,1);
                %                 end
            else
                XrmN = [];
            end
        end
        %% auto- and crosspower spectra
        function YY = get.YY(obj) % here in general form for Noutput output channels
            YY = zeros(obj.Nfc,obj.Nsets,obj.Nk,obj.Noutput^2);
            ich = 0;
            for lch = 1:obj.Noutput
                for rch = 1:obj.Noutput
                    ich = ich+1;
                    YY(:,:,:,ich) = conj(obj.Y(:,:,:,lch)).*obj.Y(:,:,:,rch);
                end
            end
        end
        function XX = get.XX(obj) % here in general form for Ninput input channels
            XX = zeros(obj.Nfc,obj.Nsets,obj.Nk,obj.Ninput^2);
            ich = 0;
            for lch = 1:obj.Ninput
                for rch = 1:obj.Ninput
                    ich = ich+1;
                    XX(:,:,:,ich) = conj(obj.X(:,:,:,lch)).*obj.X(:,:,:,rch);
                end
            end
        end
        function YX = get.YX(obj) % here in general form for Ninput input  and Noutput output channels
            YX = zeros(obj.Nfc,obj.Nsets,obj.Nk,(obj.Noutput*obj.Ninput));
            ich = 0;
            for lch = 1:obj.Noutput
                for rch = 1:obj.Ninput
                    ich = ich+1;
                    YX(:,:,:,ich) = conj(obj.Y(:,:,:,lch)).*obj.X(:,:,:,rch);
                end
            end
        end
        function XY = get.XY(obj) % here in general form for Ninput input and Noutput output channels
            XY = zeros(obj.Nfc,obj.Nsets,obj.Nk,(obj.Ninput*obj.Noutput));
            ich = 0;
            for lch = 1:obj.Ninput
                for rch = 1:obj.Noutput
                    ich = ich+1;
                    XY(:,:,:,ich) = conj(obj.X(:,:,:,lch)).*obj.Y(:,:,:,rch);
                end
            end
        end
        %% smmothing spectra
        function YYs = get.YYs(obj)
            switch obj.smooth
                case 'none'
                    if obj.debuglevel
                        disp('   -> no averaging makes no sense for coherence calculation (wasting time now ...).');
                    end
                    YYs = squeeze(sum(obj.YY,3));
                case 'freqav'
                    if obj.debuglevel
                        disp('   -> averaging over frequencies');
                    end
                    YYs = squeeze(sum(obj.YY,3));
                    useY = obj.useY(:,:,1);
                    useYY = useY;
                    for is = 2:obj.Noutput^2
                        useYY = cat(3,useYY,useY);
                    end
                    YYs = sum(YYs.*useYY,1);
                case 'timeav'
                    if obj.debuglevel
                        disp('   -> averaging over time windows');
                    end
                    YYs = squeeze(sum(obj.YY,3));
                    useY = obj.useY(:,:,1);
                    useYY = useY;
                    for is = 2:obj.Noutput^2
                        useYY = cat(3,useYY,useY);
                    end
                    YYs = sum(YYs.*useYY,2);
                case 'runav'
                    if obj.debuglevel
                        disp(['   -> averaging YY with running average of Nfc x Nsets = ',num2str(obj.avrange(1)) ' x ' num2str(obj.avrange(2))]);
                    end
                    YYs = zeros(obj.Nfc,obj.Nsets,obj.Noutput^2);
                    for ich = 1:obj.Noutput^2
                        % take the sum over all slepian squences
                        YYs(:,:,ich) = runav2D(squeeze(sum(obj.YY(:,:,:,ich),3)),obj.avrange);
                    end
                case 'smoothn'
                    if obj.debuglevel
                        if ~isempty(obj.avrange)
                            disp(['   -> smoothing YY with smoothn, S = ',num2str(obj.avrange(1)) ]);
                        else
                            disp('   -> smoothing YY with smoothn' );
                        end
                    end
                    YYs = zeros(obj.Nfc,obj.Nsets,obj.Noutput*obj.Ninput);
                    for ich = 1:obj.Noutput^2
                        % take the sum over all slepian squences
                        YYs(:,:,ich) = smoothn(squeeze(sum(obj.YY(:,:,:,ich),3)),obj.avrange);
                    end
            end
        end
        function XXs = get.XXs(obj)
            switch obj.smooth
                case 'none'
                    if obj.debuglevel
                        disp('   -> no averaging makes no sense for coherence calculation (wasting time now ...).');
                    end
                    XXs = squeeze(sum(obj.XX,3));
                case 'freqav'
                    if obj.debuglevel
                        disp('   -> averaging over frequencies');
                    end
                    XXs = squeeze(sum(obj.XX,3));
                    useX = obj.useX(:,:,1);
                    useXX = useX;
                    for is = 2:obj.Ninput^2
                        useXX = cat(3,useXX,useX);
                    end
                    XXs = sum(XXs.*useXX,1);
                case 'timeav'
                    if obj.debuglevel
                        disp('   -> averaging over time windows');
                    end
                    XXs = squeeze(sum(obj.XX,3));
                    useX = obj.useX(:,:,1);
                    useXX = useX;
                    for is = 2:obj.Ninput^2
                        useXX = cat(3,useXX,useX);
                    end
                    XXs = sum(XXs.*useXX,2);
                case 'runav'
                    if obj.debuglevel
                        disp(['   -> averaging XX with running average of Nfc x Nsets = ',num2str(obj.avrange(1)) ' x ' num2str(obj.avrange(2))]);
                    end
                    XXs = zeros(obj.Nfc,obj.Nsets,obj.Ninput^2);
                    for ich = 1:obj.Ninput^2
                        % take the sum over all slepian squences
                        XXs(:,:,ich) = runav2D(squeeze(sum(obj.XX(:,:,:,ich),3)),obj.avrange);
                    end
                case 'smoothn'
                    if obj.debuglevel
                        if ~isempty(obj.avrange)
                            disp(['   -> smoothing YY with smoothn, S = ',num2str(obj.avrange(1)) ]);
                        else
                            disp('   -> smoothing YY with smoothn' );
                        end
                    end
                    XXs = zeros(obj.Nfc,obj.Nsets,obj.Ninput^2);
                    for ich = 1:obj.Ninput^2
                        % take the sum over all slepian squences
                        XXs(:,:,ich) = smoothn(squeeze(sum(obj.XX(:,:,:,ich),3)),obj.avrange,'robust');
                    end
            end
        end
        function XYs = get.XYs(obj)
            switch obj.smooth
                case 'none'
                    if obj.debuglevel
                        disp('   -> no averaging makes no sense for coherence calculation (wasting time now ...).');
                    end
                    XYs = squeeze(sum(obj.XY,3));
                case 'freqav'
                    if obj.debuglevel
                        disp('   -> averaging over frequencies');
                    end
                    XYs = squeeze(sum(obj.XY,3));
                    useY = obj.useY(:,:,1);
                    useXY = useY;
                    for is = 2:obj.Ninput*obj.Noutput
                        useXY = cat(3,useXY,useY);
                    end
                    XYs = sum(XYs.*useXY,1);
                case 'timeav'
                    if obj.debuglevel
                        disp('   -> averaging over time windows');
                    end
                    XYs = squeeze(sum(obj.XY,3));
                    useY = obj.useY(:,:,1);
                    useXY = useY;
                    for is = 2:obj.Ninput*obj.Noutput
                        useXY = cat(3,useXY,useY);
                    end
                    XYs = sum(XYs.*useXY,2);
                case 'runav'
                    if obj.debuglevel
                        disp(['   -> averaging XY with running average of Nfc x Nsets = ',num2str(obj.avrange(1)) ' x ' num2str(obj.avrange(2))]);
                    end
                    XYs = zeros(obj.Nfc,obj.Nsets,obj.Noutput*obj.Ninput);
                    for ich = 1:obj.Ninput*obj.Noutput
                        % take the sum over all slepian squences
                        XYs(:,:,ich) = runav2D(squeeze(sum(obj.XY(:,:,:,ich),3)),obj.avrange);
                    end
                case 'smoothn'
                    if obj.debuglevel
                        if ~isempty(obj.avrange)
                            disp(['   -> smoothing YY with smoothn, S = ',num2str(obj.avrange(1)) ]);
                        else
                            disp('   -> smoothing YY with smoothn');
                        end
                    end
                    XYs = zeros(obj.Nfc,obj.Nsets,obj.Noutput*obj.Ninput);
                    for ich = 1:obj.Ninput*obj.Noutput
                        % take the sum over all slepian squences
                        XYs(:,:,ich) = smoothn(squeeze(sum(obj.XY(:,:,:,ich),3)),obj.avrange,'robust');
                    end
            end
        end
        function YXs = get.YXs(obj)
            switch obj.smooth
                case 'none'
                    if obj.debuglevel
                        disp('   -> no averaging makes no sense for coherence calculation (wasting time now ...).');
                    end
                    YXs = squeeze(sum(obj.YX,3));
                case 'freqav'
                    if obj.debuglevel
                        disp('   -> averaging over frequencies');
                    end
                    YXs = squeeze(sum(obj.YX,3));
                    useY = obj.useY(:,:,1);
                    useYX = useY;
                    for is = 2:obj.Ninput*obj.Noutput
                        useYX = cat(3,useYX,useY);
                    end
                    YXs = sum(YXs.*useYX,1);
                case 'timeav'
                    if obj.debuglevel
                        disp('   -> averaging over time windows');
                    end
                    YXs = squeeze(sum(obj.YX,3));
                    useY = obj.useY(:,:,1);
                    useYX = useY;
                    for is = 2:obj.Ninput*obj.Noutput
                        useYX = cat(3,useYX,useY);
                    end
                    YXs = sum(YXs.*useYX,2);
                case 'runav'
                    if obj.debuglevel
                        disp(['   -> averaging YX with running average of Nfc x Nsets = ',num2str(obj.avrange(1)) ' x ' num2str(obj.avrange(2))]);
                    end
                    YXs = zeros(obj.Nfc,obj.Nsets,obj.Noutput*obj.Ninput);
                    for ich = 1:obj.Ninput*obj.Noutput
                        % take the sum over all slepian squences
                        YXs(:,:,ich) = runav2D(squeeze(sum(obj.YX(:,:,:,ich),3)),obj.avrange);
                    end
                case 'smoothn'
                    if obj.debuglevel
                        if ~isempty(obj.avrange)
                            disp(['   -> smoothing YY with smoothn, S = ',num2str(obj.avrange(1)) ]);
                        else
                            disp('   -> smoothing YY with smoothn');
                        end
                    end
                    YXs = zeros(obj.Nfc,obj.Nsets,obj.Noutput*obj.Ninput);
                    for ich = 1:obj.Ninput*obj.Noutput
                        % take the sum over all slepian squences
                        YXs(:,:,ich) = smoothn(squeeze(sum(obj.YX(:,:,:,ich),3)),obj.avrange,'robust');
                    end
            end
        end
        %% masked smoothed auto- and cross spectra
        function YYm = get.YYm(obj)
            YYm = obj.YYs;
            for lch = 1:obj.Noutput
                tmp = YYm(:,:,lch);
                tmp(~obj.useY(:,:,lch)) = nan;
                YYm(:,:,lch) = tmp;
            end
        end
        function XXm = get.XXm(obj)
            XXm = obj.XXs;
            for lch = 1:obj.Ninput
                tmp = XXm(:,:,lch);
                tmp(~obj.useX(:,:,lch)) = nan;
                XXm(:,:,lch) = tmp;
            end
        end
        function XYm = get.XYm(obj)
            XYm = obj.XYs;
            for rch = 1:obj.Ninput
                for lch = 1:obj.Noutput
                    tmp = XYm(:,:,(lch-1)*obj.Ninput+rch);
                    tmp(~obj.useY(:,:,lch)) = nan;
                    tmp(~obj.useX(:,:,rch)) = nan;
                    XYm(:,:,(lch-1)*obj.Ninput+rch) = tmp;
                end
            end
        end
        function YXm = get.YXm(obj)
            YXm = obj.YXs;
            for lch = 1:obj.Noutput
                for rch = 1:obj.Ninput
                    tmp = YXm(:,:,(rch-1)*obj.Noutput+lch);
                    tmp(~obj.useY(:,:,lch)) = nan;
                    tmp(~obj.useX(:,:,rch)) = nan;
                    YXm(:,:,(rch-1)*obj.Noutput+lch) = tmp;
                end
            end
        end
        %% reshape
        function YYmN = get.YYmN(obj)
            N = obj.Nfc*obj.Nsets;
            YYmN = reshape(obj.YYm,N,obj.Noutput.^2);
        end
        function XXmN = get.XXmN(obj)
            N = obj.Nfc*obj.Nsets;
            XXmN = reshape(obj.XXm,N,obj.Ninput^2);
        end
        function XXrmN = get.XXrmN(obj)
            if ~isempty(obj.Xrm)
                N = obj.Nfc*obj.Nsets;
                XXrmN = reshape(obj.XXrm,N,obj.Ninput^2);
            else
                XXrmN = [];
            end
        end
        function XYmN = get.XYmN(obj)
            N = obj.Nfc*obj.Nsets;
            XYmN = reshape(obj.XYm,N,obj.Ninput*obj.Noutput);
        end
        function YXmN = get.YXmN(obj)
            N = obj.Nfc*obj.Nsets;
            YXmN = reshape(obj.YXm,N,obj.Ninput*obj.Noutput);
        end
        %%
        function pol = get.pol(obj)
            XX = obj.XXs;
            if obj.debuglevel == 1, disp(' - computing polarization direction of spectral matrix of input channels ... may take while'); end
            if size(XX,3)==4
                for ifc = 1:size(XX,1)
                    for isets = 1:size(XX,2)
                        [V,D] = eigs([XX(ifc,isets,1) XX(ifc,isets,2); ...
                            XX(ifc,isets,3) XX(ifc,isets,4)],2);  
                        %or(ifc,isets,:,:) = V;
                        or(ifc,isets)     = atan2(-real(V(2,1)),-real(V(1,1)))*180/pi;
                        deg(ifc,isets,:,:) = -diff(diag(D))/sum(diag(D));
                    end
                end
            end
            
            pol.or = or;
            pol.deg = deg;
        end
        function unicoh = get.unicoh(obj)
            if obj.debuglevel
                disp(' - computing univariate coherencies');
            end
            unicoh = abs(obj.XYs).^2./(obj.XXs.*obj.YYs);
        end
        function tfs = get.tfs(obj) 
            % Assumes two input and one output channel! ****************
            % *************** This must be generalized *****************
            if obj.debuglevel
                disp(' - computing transfer functions');
            end
            XX = obj.XXs;
            XY = obj.XYs;       
            denom = XX(:,:,1).*XX(:,:,4) - abs(XX(:,:,2)).^2;
            %             tfs = zeros(obj.Nfc,obj.Nsets,obj.Noutput*obj.Ninput);
            tfs = zeros(size(XX,1),size(XX,2),obj.Noutput*obj.Ninput);
            for lch = 1:obj.Noutput
                if obj.Noutput == 1
                    Z1num = XY(:,:,1).*XX(:,:,4) - XX(:,:,2).*XY(:,:,2);
                    Z2num = XX(:,:,1).*XY(:,:,2) - XX(:,:,3).*XY(:,:,1);
                elseif obj.Noutput == 2
                    if lch == 1
                        Z1num = XY(:,:,1).*XX(:,:,4) - XX(:,:,2).*XY(:,:,3);
                        Z2num = XX(:,:,1).*XY(:,:,3) - XX(:,:,3).*XY(:,:,1);
                    elseif lch == 2
                        Z1num = XY(:,:,2).*XX(:,:,4) - XX(:,:,2).*XY(:,:,4);
                        Z2num = XX(:,:,1).*XY(:,:,4) - XX(:,:,3).*XY(:,:,2);
                    end
                end
                for rch = 1:obj.Ninput
                    if rch == 1, tfs(:,:,(lch-1)*2+rch)   = Z1num./denom; end
                    if rch == 2, tfs(:,:,(lch-1)*2+rch)   = Z2num./denom; end
                end
            end
        end
        function bicoh = get.bicoh(obj)  
             % Assumes two input and one output channel! ****************
            % *************** This must be generalized *****************
            if obj.Ninput == 2
                if obj.debuglevel
                    disp(' - computing bivariate coherencies');
                end
            else
                disp(' - Warning: two input channels required to calculte bivariate coherencies');
                bicoh = [];
                return
            end
            XX = obj.XXs;
            XY = obj.XYs;
            YX = obj.YXs;
            YY = obj.YYs;
            denom = XX(:,:,1).*XX(:,:,4) - abs(XX(:,:,2)).^2;
            if all(denom==0); warning('Determinant 0 !!!'); end
            bicoh = zeros(obj.Nfc,obj.Nsets,obj.Noutput);
            for lch = 1:obj.Noutput
                if obj.Noutput == 1
                    Z1num = XY(:,:,1).*XX(:,:,4) - XX(:,:,2).*XY(:,:,2);
                    Z2num = XX(:,:,1).*XY(:,:,2) - XX(:,:,3).*XY(:,:,1);
                    Z1 = Z1num./denom;
                    Z2 = Z2num./denom;
                    %compute bivariate coherency
                    %                     rb = real((Z1.*YXx + Z2.*YXy)./YY);
                    rb = real((Z1.*YX(:,:,1) + Z2.*YX(:,:,2))./YY(:,:,1));
                elseif obj.Noutput == 2
                    if lch == 1
                        Z1num = XY(:,:,1).*XX(:,:,4) - XX(:,:,2).*XY(:,:,3);
                        Z2num = XX(:,:,1).*XY(:,:,3) - XX(:,:,3).*XY(:,:,1);
                        Z1 = Z1num./denom;
                        Z2 = Z2num./denom;
                        %compute bivariate coherency
                        %                     rb = real((Z1.*YXx + Z2.*YXy)./YY);
                        rb = real((Z1.*YX(:,:,1) + Z2.*YX(:,:,2))./YY(:,:,1));
                    elseif lch == 2
                        Z1num = XY(:,:,2).*XX(:,:,4) - XX(:,:,2).*XY(:,:,4);
                        Z2num = XX(:,:,1).*XY(:,:,4) - XX(:,:,3).*XY(:,:,2);
                        Z1 = Z1num./denom;
                        Z2 = Z2num./denom;
                        rb = real((Z1.*YX(:,:,3) + Z2.*YX(:,:,4))./YY(:,:,4));
                    end
                elseif obj.Noutput > 2
                    disp(' - Warning: bivariate coherencies not et implemented for more than two output channels.');
                    rb = [];
                end
                bicoh(:,:,lch) = rb;
            end
            bicoh(bicoh>1) = 1; bicoh(bicoh<0) = 0;
        end
        function [Z,Zse,varargout] = computetf(obj)
            %             obj.useY = obj.maskY & obj.useY;
            switch obj.reg
                case 'regress'
                    X = obj.XmN;
                    Y = obj.YmN;
                    X = [ones(size(X,1),1) X];
                    [ztf,a,b] = regress(Y,X);
                    ztf = ztf(2:3,1);
                    stats.se = 0.05*abs(ztf);
                    stats.resid = b;
                 case 'mcdregress'       % regression on fourier coefficients
                    % Note that obj.XrmN = [] implies single site
                    % processing, otherwise obj.XrmN is of dimension
                    % obj.XmN and corresponds to the reference channels
                    X = obj.XmN;
                    Y = obj.YmN;
                    X(isnan(Y(:,1)),:) = [];
                    Y(isnan(Y(:,1)),:) = [];
                    %result=rpcr(XmN,YmN,'k',2,'plots',0);
                    xr = [real(X(:,1)) -imag(X(:,1)) real(X(:,2)) -imag(X(:,2))];
                    yr = real(Y);
                    xi = [imag(X(:,1)) real(X(:,1)) imag(X(:,2)) real(X(:,2))];
                    yi = imag(Y);
                    x  = [xr;xi];
                    y  = [yr;yi];
                     [rew] = mcdregres(x,y,'intercept',0,'plots',0,'ntrial',500);%numel(y)/10);
                    %                     ztf = raw.coefficients;
                    ztf = rew.slope;
                    ztf = [ztf(1,1)+1i*ztf(2,1) ztf(1,2)+1i*ztf(2,2); ztf(3,1)+1i*ztf(4,1) ztf(3,2)+1i*ztf(4,2)];
                    stats.se = 0.01*abs(ztf);
                case 'ltsregress'
                    X = obj.XmN;
                    Y = obj.YmN;
                    X(isnan(Y(:,1)),:) = [];
                    Y(isnan(Y(:,1)),:) = [];
                    xr = [real(X(:,1)) -imag(X(:,1)) real(X(:,2)) -imag(X(:,2))];
                    yr = real(Y);
                    xi = [imag(X(:,1)) real(X(:,1)) imag(X(:,2)) real(X(:,2))];
                    yi = imag(Y);
                    x  = [xr;xi];
                    y  = [yr;yi];
                    [rew,raw] = ltsregres(x,y,'intercept',0,'plots',0,'ntrial',numel(y)/10);
                    %                     ztf = raw.coefficients;
                    ztf = rew.slope;
                    ztf = [ztf(1)+1i*ztf(2); ztf(3)+1i*ztf(4)];
                    stats.se = 0.01*abs(ztf);
                    N = numel(y);
                    stats.resid = rew.res(1:N/2)+1i*rew.res(N/2+1:end);
                case 'Mestimate'       % regression on fourier coefficients
                    % Note that obj.XrmN = [] implies single site
                    % processing, otherwise obj.XrmN is of dimension
                    % obj.XmN and corresponds to the reference channels
                    X = obj.XmN;
                    Y = obj.YmN;
                    Xr = obj.XrmN;
                    
                    isn = find(isnan(real(Y(:,1))));
                    
                    % JK catch if all are NaN
                    if all(isnan(Y(:,1))); 
                        Z = NaN; Zse = NaN; stats = [];
                        if nargout == 3; varargout = {stats}; end; 
                        return; 
                    end
                    
                    Y(isn,:) = [];
                    X(isn,:) = [];
                    if ~isempty(Xr), Xr(isn,:) = []; end
                    
                    try     
                        stats  = regstats(Y,X,'linear','leverage');
                    catch
                        disp('error with REGSTATS');
                        Z = NaN; Zse = NaN; stats = [];
                        if nargout == 3; varargout = {stats}; end; 
                        return;  
                    end
                    
                    
                    levind = find(stats.leverage<5/numel(Y) & stats.leverage>0.1/numel(Y));
                    if numel(levind) > 50, else levind = 1:numel(Y);end
                    if ~isempty(Xr)
                        [ztf,stats] = ts_robustfit(X(levind,:),Xr(levind,:),Y(levind,:),'huber',obj.huber,'off');
                    else
                        [ztf,stats] = ts_robustfit(X(levind,:),[],Y(levind,:),'huber',obj.huber,'off');
                    end
%                     if ~isempty(Xr)
%                         [ztf,stats] = ts_robustfit(X(:,:),Xr(:,:),Y(:,:),'huber',obj.huber,'off');
%                     else
%                         [ztf,stats] = ts_robustfit(X(:,:),[],Y(:,:),'huber',obj.huber,'off');
%                     end
                    
%                     [ztf,stats] = ts_robustfitfit(obj.XmN,obj.XrmN,obj.YmN,'huber',obj.huber,'off');
                
                case 'egbert'
                    X = obj.XmN;
                    Y = obj.YmN;
                    Xr = obj.XrmN;
                    ITER = IterControl;
                    ITER.rdscnd = 1;
                    ITER.iterMax = 30;
                    ITER.saveCleaned = 1;
                    %                    
                    isn = find(isnan(real(Y(:,1))));
                    Y(isn,:) = [];
                    X(isn,:) = [];
                    if ~isempty(Xr), Xr(isn,:) = []; end
                    stats  = regstats(Y,X,'linear','leverage');
                    levind = find(stats.leverage<5/numel(Y) & stats.leverage>0.1/numel(Y));
                    if numel(levind) > 50, else levind = 1:numel(Y);end
                    if isempty(Xr)
                        robobj = TRME(X,Y,ITER);
                        ztf = Estimate(robobj);
                        stats.se = sqrt(diag(real(robobj.Cov_SS*robobj.Cov_NN)));%0.05*abs(ztf);
                        stats.cov_NN = robobj.Cov_NN;
                        stats.Yc = robobj.Yc;
                    else
                        robobj = TRME_RR(X,Y,Xr,ITER);
                        Estimate(robobj);
                        ztf = robobj.b;
                        stats.se = sqrt(diag(real(robobj.Cov_SS*robobj.Cov_NN)));%0.01*abs(ztf);
                        stats.cov_NN = robobj.Cov_NN;
                        stats.Yc = robobj.Yc;
                    end
                    
                case 'spectra'  % regression on auto- and crossspectra
                    XX = obj.XXmN;
                    XY = obj.XYmN;
                    isn = find(isnan(XY(:,1)));
                    XY(isn,:) = [];
                    XX(isn,:) = [];
                    %                     Y = [XY(:,1); XY(:,2)]; %#ok<*PROP>
                    %                     X = [XX(:,1) XX(:,3); XX(:,2) XX(:,4)];
                    denom = XX(:,1).*XX(:,4) - abs(XX(:,2)).^2;
                    Z1num = XY(:,1).*XX(:,4) - XX(:,2).*XY(:,2);
                    Z2num = XX(:,1).*XY(:,2) - XX(:,3).*XY(:,1);
                    [tf,stat] = ts_robustfitfit(Z1num,[],denom,'huber',obj.huber,'off');
                    ztf(1) = 1./tf;
                    stats.se(1) = stat.se./abs(tf).^2;
                    [tf,stat] = ts_robustfitfit(Z2num,[],denom,'huber',obj.huber,'off');
                    ztf(2) = 1./tf;
                    stats.se(2) = stat.se./abs(tf).^2;
            end
            Z = ztf.';
            Zse = stats.se.';
            if nargout == 3
                varargout = {stats};
            else
                varargout = {};
            end
        end
        function plottfs(obj,rhorange,varargin) %% tfs, useY
            if nargin> 3 && ~isempty(varargin)
                tfs = varargin{1};
            else
                tfs = obj.tfs;
            end
            if nargin> 4 && ~isempty(varargin)
                maskY = varargin{2};
            else
                maskY = obj.useY;
            end
            for lch = 1:obj.Noutput
                switch obj.output{lch}
                    case 'Ex', xlab = 'Z real'; ylab = 'Z imag';
                    case 'Ey', xlab = 'Z real'; ylab = 'Z imag';
                    case 'Bz', xlab = 'real'; ylab = 'imag';
                    case 'Bx', xlab = 'real'; ylab = 'imag';
                    case 'By', xlab = 'real'; ylab = 'imag';
                end
                figure;
                set(gcf,'Position',[ 285  337  1448  641])
                f = obj.f';
                f = f(:,ones(obj.Nsets,1));
                for rch = 1:obj.Ninput
                    q   = axes;
                    set(q,'Position',[0.075+(rch-1)*0.5 0.11 0.4 0.815],'Fontsize',14,'Xlim',rhorange{rch},'Ylim',rhorange{rch},'Nextplot','add','box','on')
                    grid on
                    Z   = tfs(:,:,(lch-1)*2+rch);
                    %                     Rho = log10(abs(Z).^2./f/5).*exp(1i*angle(Z));
                    Rho = Z;%./sqrt(f);
                    switch obj.smooth
                        case {'freqav' , 'timeav'}
                            plot(Rho(:),'o','Markersize',3,'Markeredgecolor',[1 0 0],'Markerfacecolor',[1 0.5 0.5]); hold on
                        otherwise
                            plot(Rho(:),'.','Markersize',.5,'Markeredgecolor',[0.5 0.5 0.5]); hold on
                            Rho = Rho(maskY(:,:,lch));
                            plot(Rho(:),'o','Markersize',2,'Markeredgecolor',[1 0 0],'Markerfacecolor',[1 0 0]); hold on
                    end
                    title([obj.output{lch} ' - ' obj.input{rch}],'Fontsize', 14)
                    xlabel(xlab,'Fontsize',14);
                    ylabel(ylab,'Fontsize',14);
                end
                
            end
        end

    end
end % classdef

