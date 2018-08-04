%%
% class definition of EDLs cinverted before into spam4 raw/xtr format
%
classdef EDLs < EMSites % discrete block model
    properties       
        factor       = 0;        
        rawfiles     = {''};
        xtrfiles     = {''};
        headerlength = 200;   
    end    
    methods
        function obj    = EDLs(varargin)
            %% set defaults
            obj.system       = 'EDL';
            %         obj.lsb          = 1e-3;             % conversion of int to mV, spam data is in Volt (and not int)
            obj.lsb          = 1/2^32;        
            obj.Nch          = 5;                           % No of channels
            obj.chnames      = {'Bx' 'By' 'Bz' 'Ex' 'Ey'};      % names of channels
            obj.dipole       = [1 1 1 1 1];            % dipole length
            obj.orient       = [0 90 0 0 90];           % degrees from north
            obj.tilt         = [0 0 90 0 0];            % tilt (deviation from horizontal position)
            obj.sens_sn      = {0 0 0 [0 0] [0 0]};    % serial numbers
            obj.sens_name    = {'Geomag' 'Geomag' 'Geomag' 'AgAgCl' 'AgAgCl'};
            obj.usech        = [1 2 3 4 5];

            if nargin == 2
                if isa(varargin{1},'EDLs') && isdir(varargin{2})
                    obj         = varargin{1}; % Creates ede object from file with values of given ede object
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{2}]); end
                    obj = spam4_read(obj,varargin{2});
                    obj.usech = 1:obj.Nch;
                else return; end
            elseif nargin == 1  
                if isdir(varargin{1})     % Creates new ede object from files in given directory with default values
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{1}]); end
                    obj = spam4_read(obj,varargin{1});
                    obj.usech = 1:obj.Nch;
                else return; end
            end
        end                
        function dataint    = get_dataint(obj)   % Reads in data from datafile / Voltage in single precision, but transforms it  to int
            dataint = zeros(numel(obj.usech),(obj.usesmp(2)-obj.usesmp(1)+1)); % Allocate Memory for data
            dataind = 0;
            for ifile = 1:numel(obj.usefiles)
                ind = obj.usefiles(ifile);
                readsmp = [max(obj.usesmp(1),obj.Nsmpfile(ind,1)) min(obj.usesmp(2),obj.Nsmpfile(ind,2))];
                if ind > 1
                    readsmp = readsmp-obj.Nsmpfile(ind-1,2);
                end
                %                 dataind = [1:diff(readsmp)+1];
                dataind = dataind(end)+[1:(diff(readsmp)+1)];                
                if obj.debuglevel == 2                    
                    disp([' - reading samples ' num2str(readsmp(1),'%09d') '-' num2str(readsmp(end),'%09d') ' from ' ...
                        fullfile(obj.source{1},'*.RAW') ' ...']);
                end
                % read all channels                
                fid = fopen(fullfile(obj.source{1},obj.rawfiles{ind}),'r');
                nspamch = obj.Nch;
                fseek(fid,obj.headerlength,'bof');
                fseek(fid,(readsmp(1)-1)*4*nspamch,'cof');
                dataread = zeros(nspamch,(readsmp(2)-readsmp(1)+1));
                dataread(:) = fread(fid,[1 (readsmp(2)-readsmp(1)+1)*nspamch],'single'); % MB these values are already scaled by lsb;
                fclose(fid);
                for ch=1:numel(obj.usech)    % loop to select channels defined in field 'usech'                    
                    
                    % MB:
                    % dataint(ch,dataind) = dataread(obj.usech(ch),:); % transform V to mV ; no need to truncate to int 
                    
                    % JK: I think it is necessary because of the dataproc
                    % writes dataint, expecting an integer
                    % dataint(ch,dataind) = round( dataread(obj.usech(ch),:).*1000 ./ obj.lsb(obj.usech(ch))  ); % transform V to mV and then to integer data
                    %
                    % MB: But this breaks down if the dataread > 1; to be
                    % on the safer side, I change this to 23^1;
                    tmp = dataread(obj.usech(ch),:) .* 2^28; % transform to integer numbers
                    % MB: changed rounding to casting
                    tmp2 = round( tmp  ); %  (rounding should not be necessary, but here is a test:
                    if any(abs(tmp(:)) > 2^31)
                        disp([' - Warning: values > 1 V detected; producing wrong int32 number']);
                    end
                    if any(tmp2(:) - tmp(:))
                        m = max(abs(tmp2(:) - tmp(:)));
                        if obj.debuglevel == 2
                            disp(['failed to produce integegers by up to ',num2str(m)]);
                        end
                    end
                    dataint(ch,dataind) = int32(tmp2);                                                                
                    
                    
                end
            end
            for ich = 1:numel(obj.usech)
                if ~isempty(obj.premult)
                    dataint(ich,:) = dataint(ich,:)*obj.premult(obj.usech(ich));
                end
            end
        end                             
    end
    
end % classdef

