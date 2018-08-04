% This script calculates and plots the derivation from zero for all
% parts of the horizontal magnetic transfer function
clear all
close all

sites = {'1100B';'1150B';'1200B';'2050B';'2100B';'2105B';...
    '2150B';'3080B';'3100B';'3200B';'4200B';'3250B';'3300B';...
    '3350B';'3400B';'4265B';'4300B';'4350B';'1300B';'1350B';...
    '2300B';'2350B';'2400B';'1050B';'2000B';'3000B';'3050B';...
    '4000B';'4050B';'2200B';'2250B';'3150B';'4100B';'4150B'};

%for p = 1:numel(sites)
p = 24
clear mtfs
    
    
base = char(sites(p));   % base site
itfs_folder = '~/Masterarbeit/master/itfs/'; % folder with .mat-files
for i = 1:numel(sites)
    filepath = strcat(itfs_folder,char(sites(i)),'_',base,'.mat');
    if (exist(filepath, 'file') ~= 0)
        load(filepath);
        if (exist('mtfs', 'var'))
            mtfs(end+1) = tfs;
        else
            mtfs = tfs;
            load(strcat(itfs_folder,base,'_',char(sites(i)),'.mat'));
            base_lat = tfs.lat;
            base_lon = tfs.lon;
        end
    end
end



figure('Position',[10 100 1600 800])

for i = 1:numel(mtfs)
    % nper = mtfs(i).nper; % number of periods
    nper = mtfs(i).nper-5;
    mask_per = 1; % cut higher periods
    
    % deviation from zero (root mean square)
    mtfs(i).rms(1,1) = rms(real(mtfs(i).tf(1,1,mask_per:nper)));
    mtfs(i).rms(2,1) = rms(real(mtfs(i).tf(2,1,mask_per:nper)));
    mtfs(i).rms(1,2) = rms(real(mtfs(i).tf(1,2,mask_per:nper)));
    mtfs(i).rms(2,2) = rms(real(mtfs(i).tf(2,2,mask_per:nper)));

    bias_diag = reshape(real(mtfs(i).tf(1,1,:)-mtfs(i).tf(2,2,:)),[1,mtfs(i).nper]);
    bias_off_diag = reshape(real(mtfs(i).tf(2,1,:)-mtfs(i).tf(1,2,:)),[1,mtfs(i).nper]);

    % plot bias 
    subplot(ceil(numel(mtfs)/4),4,i)
    hold on
    plot(mtfs(i).periods(mask_per:nper),bias_off_diag(mask_per:nper),'blue')
    plot(mtfs(i).periods(mask_per:nper),bias_diag(mask_per:nper),'green')
    title(mtfs(i).locname)
    ylabel('bias')
    xlabel('periods [s]')
    ylim([-1 1])
    set(gca,'XScale','log');
    hline = refline(0);
    hline.Color = 'r';
    hline.LineStyle = '--';
    % text(1,0.9,mtfs(i).locname)
end



%% plot for linear trend of deviation with distance to base station
% base_lat = [45.8844120000000];
% base_lon = [101.362944000000];
R = earthRadius/1000;


% calculate distance in km using the Haversine formula
for i = 1:numel(mtfs)
    % distance
    delta_lat = deg2rad(mtfs(i).lat - base_lat);
    delta_lon = deg2rad(mtfs(i).lon - base_lon);
    a = sin(delta_lat/2)^2 + cos(deg2rad(base_lat)) * cos(deg2rad(mtfs(i).lat)) * sin(delta_lon/2)^2;
    c = 2 * atan2(sqrt(a),sqrt(1-a));
    dist(i) = R * c;
    
    % deviation to vector for plot (don't know why structure won't work)
    rms_xx(i) = mtfs(i).rms(1,1);
    rms_xy(i) = mtfs(i).rms(1,2);
    rms_yx(i) = mtfs(i).rms(2,1);
    rms_yy(i) = mtfs(i).rms(2,2);
    sitenames{i} = mtfs(i).locname;
end

% subplot(ceil(numel(mtfs)/4),5,numel(mtfs)+1)
figure('Position',[100 100 1000 500])
hold on

% rms XX
xx = plot(dist,rms_xx,'o','MarkerFaceColor','r','MarkerEdgeColor','black');
coeff = polyfit(dist,rms_xx,1);
fit_x = linspace(min(dist), max(dist), 200);
fit_y = polyval(coeff, fit_x);
plot(fit_x,fit_y,'--','Color','r')

% rms XY
xy = plot(dist,rms_xy,'o','MarkerFaceColor','g','MarkerEdgeColor','black');
coeff = polyfit(dist,rms_xy,1);
fit_x = linspace(min(dist), max(dist), 200);
fit_y = polyval(coeff, fit_x);
plot(fit_x,fit_y,'--','Color','g')

% rms YX
yx = plot(dist,rms_yx,'o','MarkerFaceColor','b','MarkerEdgeColor','black');
coeff = polyfit(dist,rms_yx,1);
fit_x = linspace(min(dist), max(dist), 200);
fit_y = polyval(coeff, fit_x);
plot(fit_x,fit_y,'--','Color','b')

% rms YY
yy = plot(dist,rms_yy,'o','MarkerFaceColor','y','MarkerEdgeColor','black');
coeff = polyfit(dist,rms_yy,1);
fit_x = linspace(min(dist), max(dist), 200);
fit_y = polyval(coeff, fit_x);
plot(fit_x,fit_y,'--','Color','y')


% labels
text(dist,rms_yx-rand*0.1,sitenames)
legend([xx xy yx yy],{'RMS_{xx}','RMS_{xy}','RMS_{yx}','RMS_{yy}'},'Location','southoutside','Orientation','horizontal');
title('Deviation(RMS) with distance')
ylim([-0.1 1.5])
xlim([min(dist)-30 max(dist)+30])
xlabel(strcat('distance to base',{' '},base,' [km]'));
ylabel('RMS')

savepath = strcat(itfs_folder,'bias_dist_',base,'.png')
%saveas(gcf,savepath,'png')

%end


