%% components with distance... easy peasy
clear all
close all

% all sites on 1000, 2000 and 3000 line
% sites = {'1100B';'1150B';'1200B';'2050B';...
%     '2150B';'3080B';'3100B';'3200B';'3250B';'3300B';...
%     '3350B';'3400B';'1300B';'1350B';...
%     '2300B';'2400B';'1050B';'3000B';...
%     '2200B';'2250B';'3150B'};
sites = {'3150B','2200B','1050B','3100B','1300B','2400B','2300B','2050B'};

% only the 2000 line (without 2100B)
% sites = {'2050B';...
%     '2150B';'2300B';'2400B';'2200B';'2250B'};

itfs_folder = '~/Masterarbeit/master/itfs/'; % folder with .mat-files


%% base sites
base = '2150B';

base2000 = '2000B';
load(strcat(itfs_folder,base2000,'_','2400B','.mat'));
base_lat(2) = tfs.lat;
base_lon(2) = tfs.lon;

base1000 = '1050B'; % from this base the distance is calculated for 1000 line
load(strcat(itfs_folder,base1000,'_','2150B','.mat'));
base_lat(1) = tfs.lat;
base_lon(1) = tfs.lon;

base3000 = '3000B'; % from this base the distance is calculated for 3000 line
load(strcat(itfs_folder,base3000,'_','2150B','.mat'));
base_lat(3) = tfs.lat;
base_lon(3) = tfs.lon;

%% read .mat-files with tfs
for i = 1:numel(sites)
    filepath = strcat(itfs_folder,char(sites(i)),'_',base,'.mat');
    if (exist(filepath, 'file') ~= 0)
        load(filepath);
        if (exist('mtfs', 'var'))
            mtfs(end+1) = tfs;
        else
            mtfs = tfs;
            load(strcat(itfs_folder,char(sites(i)),'_',base,'.mat'));
        end
    end
end



%% plot for linear trend of deviation with distance to base station
R = earthRadius/1000;

% calculate distance in km using the Haversine formula
for i = 1:numel(mtfs)
    % distance
    n = str2num(mtfs(i).locname(1));
    delta_lat = deg2rad(mtfs(i).lat - base_lat(n));
    delta_lon = deg2rad(mtfs(i).lon - base_lon(n));
    a = sin(delta_lat/2)^2 + cos(deg2rad(base_lat(n))) * cos(deg2rad(mtfs(i).lat)) * sin(delta_lon/2)^2;
    c = 2 * atan2(sqrt(a),sqrt(1-a));
    dist(i) = R * c;
    if n == 1
        dist(i) = dist(i) + 50;
    end
    
    xx = [];
    xy = [];
    yx = [];
    yy = [];
    
    % kill the outliers! Nobody likes them!
    for j = 1:mtfs(i).nper
        if (abs(real(mtfs(i).tf(1,1,j))) < 1)
            xx(end+1) = real(mtfs(i).tf(1,1,j));
        end
        if (abs(real(mtfs(i).tf(1,2,j))) < 1)
            xy(end+1) = real(mtfs(i).tf(1,2,j));
        end
        if (abs(real(mtfs(i).tf(2,1,j))) < 1)
            yx(end+1) = real(mtfs(i).tf(2,1,j));
        end
        if (abs(real(mtfs(i).tf(2,2,j))) < 1)
            yy(end+1) = real(mtfs(i).tf(2,2,j));
        end
    end
    
    % root mean square over all frequencies
    mtfs(i).rms(1,1) = rms(xx);
    mtfs(i).rms(2,1) = rms(yx);
    mtfs(i).rms(1,2) = rms(xy);
    mtfs(i).rms(2,2) = rms(yy);
    
    % write rms to vector (plotting won't work with structure :-( )
    rms_xx(i) = mtfs(i).rms(1,1);
    rms_xy(i) = mtfs(i).rms(1,2);
    rms_yx(i) = mtfs(i).rms(2,1);
    rms_yy(i) = mtfs(i).rms(2,2);
    sitenames{i} = mtfs(i).locname;
end

%% combine both off-diagonals and both diagonals (take the mean)
for i = 1:numel(mtfs)
    diag(i) = 1 - (rms_xx(i)+rms_yy(i))/2;
    off_diag(i) = (rms_xy(i)+rms_yx(i))/2;
end

figure('Position',[100 100 1000 500],'Renderer','painters')
hold on
%% simple plot of all components (rms of frequencies)
% [dist perm] = sort(dist);
% rms_xx = rms_xx(perm);
% rms_xy = rms_xy(perm);
% rms_yx = rms_yx(perm);
% rms_yy = rms_yy(perm);
% plot(dist,smooth(rms_xx,'loess'))
% plot(dist,smooth(rms_xy,'loess'))
% plot(dist,smooth(rms_yx,'loess'))
% plot(dist,smooth(rms_yy,'loess'))


%% plot absolute mean of diagonal and off-diagonal (shifted to 0)
[dist perm] = sort(dist);
diag = diag(perm);
off_diag = off_diag(perm);
%plot(dist,smooth(abs(diag),'loess'),'-')
plot(dist,smooth(abs(off_diag),'loess'),'o')
plot(dist,smooth(abs(off_diag),'loess'),'--','LineWidth',1.5)
set(gca,'FontSize',12,'FontWeight','bold','box','on','LineWidth',2);



%% plot only off-diagonal
% [dist perm] = sort(dist);
% rms_xy = rms_xy(perm);
% rms_yx = rms_yx(perm);
% plot(dist,abs(rms_xy))
% plot(dist,abs(rms_yx))


%% plot off-diagonals with fit
% [dist perm] = sort(dist);
% rms_xy = rms_xy(perm);
% rms_yx = rms_yx(perm);
% 
% % rms XY
% xy = plot(dist,rms_xy,'o','MarkerFaceColor','g','MarkerEdgeColor','black');
% coeff = polyfit(dist,rms_xy,5);
% fit_x = linspace(min(dist), max(dist), 200);
% fit_y = polyval(coeff, fit_x);
% plot(fit_x,fit_y,'--','Color','g')
% 
% % rms YX
% yx = plot(dist,rms_yx,'o','MarkerFaceColor','b','MarkerEdgeColor','black');
% coeff = polyfit(dist,rms_yx,5);
% fit_x = linspace(min(dist), max(dist), 200);
% fit_y = polyval(coeff, fit_x);
% plot(fit_x,fit_y,'--','Color','b')

%% last try: interpolate between points
% [dist perm] = sort(dist);
% rms_xy = rms_xy(perm);
% rms_yx = rms_yx(perm);
% rms_yy = rms_yy(perm);
% rms_xx = rms_xx(perm);
% sampl = 20;
% plot(interp(dist,sampl,2),interp(rms_xy,sampl,2),'-')
% plot(interp(dist,sampl,2),interp(rms_yx,sampl,2),'-')
% plot(interp(dist,sampl,2),interp(abs(1-rms_yy),sampl,2),'-')
% plot(interp(dist,sampl,2),interp(abs(1-rms_xx),sampl,2),'-')

%% labels
% hline = refline(0);
% hline.Color = 'g';
% hline.LineStyle = '--';
ylim([0 0.35])
x(1:numel(dist)) = 0.95;
text(dist,abs(off_diag),sitenames(perm),'FontWeight','bold')
% title('N-S Profile');
xlabel(strcat('distance [km]'));
ylabel('Off-diagonals T_{xy} and T_{yx} (RMS)')
grid on
