%%
% class definition of MTUs
%
classdef MTUs < EMSites% discrete block model
    properties        
        mseedfiles   = {''};  % mseed/mseed2files
        inffiles     = {''};  % configuration.inf
        inifiles     = {''};  % recorder.ini
        gpsfiles     = {''};  % gps files
    end    
    methods
        function obj    = MTUs(varargin)
            %% set defaults
            obj.system       = 'MTU2000';
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
                if isa(varargin{1},'MTUs') && isdir(varargin{2})
                    obj         = varargin{1}; % Creates mtu object from file with values of given mtu object
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{2}]); end
                    obj = mtu_read(obj,varargin{2});
                    obj.usech = 1:obj.Nch;
                else return; end
            elseif nargin == 1  
                if isdir(varargin{1})     % Creates new mtu object from files in given directory with default values
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{1}]); end
                    obj = mtu_read(obj,varargin{1});
                    obj.usech = 1:obj.Nch;
                else return; end
            end
        end               
        function dataint    = get_dataint(obj)   % Reads in data from datafile / Voltage in single precision
            dataint = zeros(numel(obj.usech),(obj.usesmp(2)-obj.usesmp(1)+1)); % Allocate Memory for data
            offset = 0;
            for ifile = 1:numel(obj.usefiles)
                ind = obj.usefiles(ifile);
                readsmp = [max(obj.usesmp(1),obj.Nsmpfile(ind,1)) min(obj.usesmp(2),obj.Nsmpfile(ind,2))];                
                if obj.debuglevel == 2; rstmp = readsmp; end
                if ind > 1
                    readsmp = readsmp-obj.Nsmpfile(ind-1,2);
                end                
                if obj.debuglevel == 2                    
                    disp([' - reading samples ' num2str(readsmp(1),'%09d') '-' num2str(readsmp(end),'%09d') ' (position in run: ' num2str(rstmp(1),'%09d') '-' num2str(rstmp(end),'%09d') ') from ...']);
                end                                
                
                for ch = 1 : numel(obj.usech)   
                    if obj.debuglevel == 2;
                        disp(['    ',fullfile(obj.source{1},obj.mseedfiles{ind,ch})]);
                    end
                    X = rdmseed(fullfile(obj.source{1},obj.mseedfiles{ind,ch}));
                    N = [cumsum([1 cell2mat({X(1:end-1).NumberSamples})]); cumsum(cell2mat({X(:).NumberSamples}))];
                    
                    first_seg = find(N(1,:)<=readsmp(1),1,'last');
                    last_seg  = find(N(2,:)>=readsmp(2),1,'first');
                    
                    if first_seg > 1; first_el = N(2,first_seg-1); else first_el = 0; end                    
                    first_el = readsmp(1)-first_el;
                    
                    if last_seg > 1; last_el = N(2,last_seg-1); else last_el = 0; end
                    last_el = readsmp(2) - last_el;
                    
                    s1 = offset + 1;
                    for ind2 = first_seg : last_seg                        
                        if ind2 == first_seg;
                            fe = first_el;
                        else
                            fe = 1;
                        end
                        if ind2 == last_seg
                            le = last_el;
                        else
                            le = X(ind2).NumberSamples;
                        end
                        tmp = X(ind2).d(fe:le);
                        s2 = s1 + numel(tmp) - 1;                                                
                        dataint(ch,s1:s2) = tmp;
                        s1 = s2 + 1;                        
                    end
                    
                end
                offset = offset + diff(readsmp)+1;

            end
            for ich = 1:numel(obj.usech)
                if ~isempty(obj.premult)
                    dataint(ich,:) = dataint(ich,:)*obj.premult(obj.usech(ich));
                end
            end
        end        
    end    
end % classdef

