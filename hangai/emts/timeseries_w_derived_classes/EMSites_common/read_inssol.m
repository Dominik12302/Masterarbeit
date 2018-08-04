function varargout = read_inssol(fname,pathname,varargin);
%% Function to read INS Solution data from iNAT-RQT-4003 IMU data which was
% recorded to the internal storage with a sampling rate of 400 Hz. 
% INS Solution includes the following data:
% 
% Variables and [vector size]
% - insdata [N] x 12
%           [1-3]   AccX/AccY/AccZ  in m/s^2
%           [4-6]   OmgX/OmgY/OmgZ  in rad/s
%           [7-9]   Roll/Pitch/Yaw  in rad
%           [10-12] VelX/VelY/VelZ  in m/s
% - lat [N]         Latitude        in degree (readily rad2deg converted)
% - lon [N]         Longitude       in degree (readily rad2deg converted)
% - height [N]      Flight Height   in m
% - starttime [6]   Date vector of first sample  [Year Month Day Hour Min Sec]
% - starttimems [1] milliseconds of first sample [Miliseconds]
%
% CN 2016, 
if nargin < 1 | nargin >3
  warning('Incorrect number of arguments');
  return;
end
% data paths
% path        = 'C:\mlab\desmex\swing_hil\';
% fname       = 'iXCOMstream_swing.bin';
fid         = fopen(fullfile(pathname,fname));
% Check length of the file and total header numbers
% File
fseek(fid,0,'eof');
nfile       = ftell(fid);
fseek(fid,0,'bof');
inds        = 0;
isd         = 0;
fprintf(1,'Evaluating Number of Data \n');
while ftell(fid) ~= nfile
    fseek(fid,4,'cof');
    length      = fread(fid,1,'uint16');           % 2
    fseek(fid,length-16+10,'cof');
    inds = inds+1;
    if length == 92;
        isd = isd+1;
    end
end
ind = 1:inds;
% Allocate Memory 
n = numel(ind);
sync       = [];     % 1
id         = zeros(n,1);     % 1
fc         = [];
res        = [];
length     = zeros(n,1);
week       = [];
time       = zeros(n,1);
times      = zeros(isd,1);
data       = zeros(isd,12);      % 12*4
lat        = zeros(isd,1);
lon        = zeros(isd,1);
height     = zeros(isd,1);
diffage    = [];
datasel    = [];
status     = [];
crc        = [];
idd        = 0;
fseek(fid,0,'bof');
fprintf(1,' Reading Data:       ');

for ifi = ind
    fprintf(1,'\b\b\b\b%03d%%',round(ifi/numel(ind)*100));
    sync        = fread(fid,1,'uint8');      % 1
    id(ifi)      = fread(fid,1,'uint8');     % 1
    fc          = fread(fid,1,'uint8');      % 1
    res         = fread(fid,1,'uint8');      % 1
    length(ifi)  = fread(fid,1,'uint16');    % 2
    week        = fread(fid,1,'uint16');     % 2
    gpssec      = fread(fid,1,'uint32');     % 4
    gpsmsec     = fread(fid,1,'uint32');     % 4
    time(ifi)    = gpssec+gpsmsec*1e-6;
    if id(ifi) == 3; % INSSolution indicated by 3
        idd = idd +1;
        data(idd,:)  = fread(fid,[1,12],'float');        % 12*4
        lat(idd)     = rad2deg(fread(fid,1,'double'));   % 8
        lon(idd)     = rad2deg(fread(fid,1,'double'));   % 8
        height(idd)  = fread(fid,1,'float');             % 4
        diffage     = fread(fid,1,'uint16');             % 2
        datasel     = fread(fid,1,'uint16');             % 2
        status      = fread(fid,1,'uint16');             % 2
        crc         = fread(fid,1,'uint16');             % 2
        times(idd)   = gpssec+gpsmsec*1e-6;
    elseif id(ifi) ~= 3 % Other possibilities, which are 15,16,18,24,25, etc ... see iXCOM IDC
        fseek(fid,length(ifi)-16,'cof');
    end
end
fclose(fid);
%%
startsec    = ceil(times(1));
skipsec     = abs(ceil(times(1))-times(1));
dum         = find(times<startsec);
startsec    = times(dum(end));
trueind2    = ones(numel(height),1)*true;
trueind2(dum) = false;
trueind2    = logical(trueind2);

data        = data(trueind2,:);
lat         = lat(trueind2);
lon         = lon(trueind2);
height      = height(trueind2);
times       = times(trueind2);
%% Time correction, -->     sampling rate correction 

%resample to 400 Hz
data        = resample(data   ,times,400);
lat         = resample(lat    ,times,400);
lon         = resample(lon    ,times,400);
[height,nt] = resample(height ,times,400);
times = nt;

[date,msec]     = time2cal(nt(1)-17,week); % 385303
starttime       = date;
starttimems     = msec;
insdata         = data;

if strcmp(varargin,'save')
    save([pathname 'imudata.mat'],'insdata','lat','lon','height','starttime','starttimems')
    varargout = {1};
else
    varargout = {insdata,lat,lon,height,starttime,starttimems}
end

%%
% times = max(times)-times;
% xl = [times(1) max(times)];
% xl = [min(times) max(times)];
% %
% % xl = [times(1843088) times(1843088+400*60)]
% figure;
% subplot(3,1,1)
% a =    plot(times,rad2deg(data(:,7)))
%     ylabel('roll (deg)');
%     xlim(xl)
% subplot(3,1,2)
% b =    plot(times,rad2deg(data(:,8)))
%     ylabel('pitch (deg)');
%         xlim(xl)
% 
% subplot(3,1,3)
% c =    plot(times,rad2deg(data(:,9)))
%     ylabel('yaw (deg)');
%     xlabel('sec');
%         xlim(xl)
% 
%     %
% % xl = [times(385303) times(385303+400*60)]
% figure;
% subplot(3,1,1)
% a =    plot(times,data(:,10))
%     ylabel('VelX m/s');
%     xlim(xl)
% subplot(3,1,2)
% b =    plot(times,data(:,11))
%     ylabel('VelY m/s');
%         xlim(xl)
% subplot(3,1,3)
% c =    plot(times,data(:,12))
%     ylabel('VelZ m/s');
%     xlabel('sec');
%         xlim(xl)
%             %
% % xl = [times(385303) times(385303+400*60)]
% figure;
% subplot(3,1,1)
% a =    plot(times,data(:,1))
%     ylabel('AccX m/s^2');
%     xlim(xl)
% subplot(3,1,2)
% b =    plot(times,data(:,2))
%     ylabel('AccY m/s^2');
%         xlim(xl)
% subplot(3,1,3)
% c =    plot(times,data(:,3))
%     ylabel('AccZ m/s^2');
%     xlabel('sec');
%         xlim(xl)
%         %
% % xl = [times(385303) times(385303+400*60)]
% figure;
% subplot(3,1,1)
% a =    plot(times,rad2deg(data(:,4)))
%     ylabel('Wx (deg/s)');
%     xlim(xl)
% subplot(3,1,2)
% b =    plot(times,rad2deg(data(:,5)))
%     ylabel('Wy (deg/s)');
%         xlim(xl)
% 
% subplot(3,1,3)
% c =    plot(times,rad2deg(data(:,6)))
%     ylabel('Wz (deg/s)');
%     xlabel('sec');
%         xlim(xl)
end

