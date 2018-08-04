%%
% class definition of ADUs
%
classdef ADUs < EMSites % discrete block model
    properties                
        atsfiles     = {''};
        headerlength = 1024;                
    end
    methods
        function obj    = ADUs(varargin)
            %% set defaults
            obj.system       = 'ADU07e';
            obj.lsb          = 1;                % conversion of int to mV
            obj.Nch          = 5;                % No of channels
            obj.chnames      = {'Bx' 'By' 'Bz' 'Ex' 'Ey'};      % names of channels
            obj.dipole       = [1 1 1 1 1];            % dipole length
            obj.orient       = [0 90 0 0 90];           % degrees from north
            obj.tilt         = [0 0 90 0 0];            % tilt (deviation from horizontal position)
            obj.sens_sn      = {0 0 0 [0 0] [0 0]};    % serial numbers
            obj.sens_name    = {'MFS06e' 'MFS06e' 'MFS06e' 'AgAgCl' 'AgAgCl'};
            obj.usech        = [1 2 3 4 5];
                        
            if nargin == 2
                if isa(varargin{1},'ADUs') && isdir(varargin{2})
                    obj         = varargin{1}; % Creates ede object from file with values of given ede object
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{2}]); end
                    obj = ats_read(obj,varargin{2});
                    obj.usech = 1:obj.Nch;
                    %obj.premult = ones(1,obj.Nch);
                else return; end
            elseif nargin == 1  
                if isdir(varargin{1})     % Creates new ede object from files in given directory with default values
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{1}]); end
                    obj = ats_read(obj,varargin{1});
                    obj.usech = 1:obj.Nch;
                    %obj.premult = ones(1,obj.Nch);
                else return; end
            end
        end        
        function dataint    = get_dataint(obj)   % Reads in data from datafile
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
                
                if obj.debuglevel == 2,
                    str = obj.atsfiles{ind,1}(13:16);
                    disp([' - reading samples ' num2str(readsmp(1),'%09d') '-' num2str(readsmp(end),'%09d') ' from ' ...
                        fullfile(obj.source{1},['*' str '*.ats']) ' ...']);
                end
                for ch=1:numel(obj.usech)    % loop to read in channels defined in field 'usech'
                    fid = fopen(fullfile(obj.source{1},obj.atsfiles{ind,obj.usech(ch)}),'r');
                    fseek(fid,obj.headerlength,'bof');
                    fseek(fid,(readsmp(1)-1)*4,'cof');
                    dataint(ch,dataind) = fread(fid,[1 (readsmp(2)-readsmp(1)+1)],'int32');
                    fclose(fid);
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

