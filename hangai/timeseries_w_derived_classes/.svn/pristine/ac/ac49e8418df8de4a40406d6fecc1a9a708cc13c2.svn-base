%%
% class definition of IMUs
%
% 1-12  - insdata [N] x 12
%               [1-3]   AccX/AccY/AccZ      in m/s^2
%               [4-6]   OmgX/OmgY/OmgZ      in rad/s
%               [7-9]   Roll/Pitch/Yaw      in rad
%               [10-12] VelX/VelY/VelZ      in m/s
% 13      - lat [N]         Latitude        in degree (readily rad2deg converted)
% 14      - lon [N]         Longitude       in degree (readily rad2deg converted)
% 15      - height          Altitude        in m
%
% WE USE AVIATION TERMINOLOGY
%
%

classdef IMUs < EMSites % discrete block model
    properties
        binfile     = {''};
        dataraw     = [];
    end
    methods
        function obj    = IMUs(varargin)
            %% set defaults
            obj.system       = 'IMU';
            obj.lsb          = [1 1 1 180./pi 180./pi 180./pi 180./pi 180./pi 180./pi 1 1 1 1 1 1]; % conversion of rad to deg
            obj.Nch          = 15;                   % No of channels
            obj.chnames      = {'AccX' 'AccY' 'AccZ' 'Wx' 'Wy' 'Wz' 'Roll' 'Pitch' 'Yaw' 'VelX' 'VelY' 'VelZ' 'Lat' 'Lon' 'height'};         % names of channels
            obj.dipole       = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];               % dipole length
            obj.usech        = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
            obj.dataraw      = [];
            
            if nargin == 3
                fname = varargin{3};
                if isa(varargin{1},'IMUs') && isdir(varargin{2})
                    if strcmp(fname(end-3:end),'.mat');
                        obj         = varargin{1}; % Creates ede object from file with values of given ede object
                        if obj.debuglevel, disp([' - Entering directory is ' varargin{2}]); end
                        load(fullfile(varargin{2},varargin{3}));
                        dataraw         = [insdata lat lon height]';
                        obj.dataraw     = dataraw;
                        obj.Nsmp        = numel(height);
                        obj.Nsmpfile    = obj.Nsmp;
                        obj.usech       = 1:obj.Nch;
                        obj.starttime   = starttime;
                        obj.starttimems = starttimems;
                        length = obj.Nsmp*(1/obj.srate)/(3600*24); % in sec
                        stoptime = datevec(datenum(starttime)+length);
                        obj.stoptimems = mod(stoptime(6),1)*1000
                        obj.stoptime   = [stoptime(1) stoptime(2) stoptime(3) stoptime(4) stoptime(5) floor(stoptime(6))];
                        fprintf('CONSIDER LEAP SECONDS (GPS-UTC): currently (since july 2015) its 17 Seconds\nits not included in simple .bin->.mat conversion\n')
                    elseif strcmp(fname(end-3:end),'.bin');
                        status = read_inssol(varargin{3},varargin{2},'save');
                        disp([' - IMU-Data succesfully converted to mat file imudata.mat ,Please use this file now' ]); 
                    end
                else return; end
            elseif nargin == 2
                if isdir(varargin{1})     % Creates new ede object from files in given directory with default values
                    obj         = varargin{1}; % Creates ede object from file with values of given ede object
                    if obj.debuglevel, disp([' - Entering directory is ' varargin{2}]); end
                    load(fullfile(varargin{2},varargin{3}));
                    dataraw         = [insdata lat lon height]';
                    obj.dataraw     = dataraw;
                    obj.Nsmp        = numel(height);
                    obj.Nsmpfile    = obj.Nsmp;
                    obj.usech       = 1:obj.Nch;
                    obj.starttime   = starttime;
                    obj.starttimems = starttimems;
                    length = obj.Nsmp*(1/obj.srate)/(3600*24); % in sec
                    stoptime = datevec(datenum(starttime)+length);
                    obj.stoptimems = mod(stoptime(6),1)*1000
                    obj.stoptime   = [stoptime(1) stoptime(2) stoptime(3) stoptime(4) stoptime(5) floor(stoptime(6))];
                else return; end
            end
        end
        function dataint    = get_dataint(obj)   % Reads in data from datafile
            dataint = zeros(numel(obj.usech),(obj.usesmp(2)-obj.usesmp(1)+1)); % Allocate Memory for data
            for ich = 1:numel(obj.usech)
                dataint(ich,:) = obj.dataraw(obj.usech(ich),obj.smp);
            end
        end
        function R          = R(obj);
            r   = obj.dataint(7,:);
            p   = obj.dataint(8,:);
            y   = obj.dataint(9,:);
            R = cell(1,numel(r));
            for ii = 1:numel(r);
                Rz = [cos(y(ii)) -sin(y(ii)) 0; sin(y(ii)) cos(y(ii)) 0; 0 0 1];
                Ry = [cos(p(ii)) 0 sin(p(ii));0 1 0 ; -sin(p(ii)) 0 cos(p(ii))];
                Rx = [1 0 0; 0 cos(r(ii)) -sin(r(ii)); 0 sin(r(ii)) cos(r(ii))];
                R{ii}  = [Rz*Ry*Rx];
            end
        end
    end
end % classdef

