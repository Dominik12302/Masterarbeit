% This program reads GPS points from Topcom GPS files and plots them relative to
% the first GPS point (with base station).
clear all;
filename = 'AFC100616.txt';
gps_data_UTM = table2dataset(readtable(filename,'ReadVariableNames',0,'HeaderLines',1));
[nlines,~] = size(gps_data_UTM);
east = zeros(nlines,1);
north = zeros(nlines,1);
heigth = zeros(nlines,1);
for i=1:nlines
    east(i) = double(gps_data_UTM(i,1));
    north(i) = double(gps_data_UTM(i,2));
    heigth(i) = double(gps_data_UTM(i,3));
    utmzone(i,1) = ['3']; %% UTM ZONE
    utmzone(i,2) = ['1'];
    utmzone(i,3) = [' '];
    utmzone(i,4) = ['T'];
end
[Lat,Lon] = UTM2DEG(east,north,utmzone);
figure
axis equal;
plot3(Lon,Lat,heigth,'+')
grid on
xlabel('E-W Lon (°)');
ylabel('N-S Lat (°)');
zlabel('Heigth (m)');
GPS_data_deg = cat(2,dataset(Lat,Lon,heigth),gps_data_UTM(:,5),gps_data_UTM(:,4));
export(GPS_data_deg,'file','bla.txt','Delimiter',';');
GPS_data_deg=sortrows(GPS_data_deg,4);
a = 1;
for i = 2:nlines
    if isequal(GPS_data_deg(i,4),GPS_data_deg(i-1,4));
        a = a + 1;
    else
        file = char(strcat(cellstr(GPS_data_deg(i-1,4)),'.kml'));
        kmlwritepoint(file,double(GPS_data_deg(i-a:i-1,1)),double(GPS_data_deg(i-a:i-1,2)));
        a = 1;
    end
end