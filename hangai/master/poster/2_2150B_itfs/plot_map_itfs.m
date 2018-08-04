%% plots the map for itfs
clear all;
close all;

sites = {'1050B','2200B','1300B','4200B','4350B','2400B','4000B','3150B'};

base = '2150B';   % base site
itfs_folder = '~/Masterarbeit/master/poster/'; % folder with .mat-files

load('~/Masterarbeit/master/itfs/2150B_4000B.mat');
base_lat = tfs.lat;
base_lon = tfs.lon;

for i = 1:numel(sites)
    filepath = strcat(itfs_folder,char(sites(i)),'_',base,'.mat');
    % filepath = strcat(itfs_folder,base,'_',char(sites(i)),'.mat');
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



%% projection properties
axesm('MapProjection','mercator','MeridianLabel','on','ParallelLabel','on',...
    'MapLatLimit',[45.1 49.3],'MapLonLimit',[99 103],'grid','on','Frame','on')
title('')
set(gcf,'Position',[200 10  900 900],'Renderer','painters');
hold on


% % request TEM modell
layers = wmsfind('nasa.network*elev', 'SearchField', 'serverurl');
layers = wmsupdate(layers);
aster = layers.refine('earthaster', 'SearchField', 'layername');
latlim = [45.1 49.3];
lonlim = [98.1 103];
cellSize = dms2degrees([0,1,0]);
cellSize = 0.016667;
[ZA, RA] = wmsread(aster, 'Latlim', latlim, 'Lonlim', lonlim, ...
   'CellSize', cellSize, 'ImageFormat', 'image/bil');
geoshow(ZA, RA, 'DisplayType', 'texturemap');
demcmap(double(ZA));

plotm(base_lat,base_lon,'o','MarkerFaceColor','red','MarkerSize',10,...
            'MarkerEdgeColor','k');

for i = 1:numel(sites)
    plotm(mtfs(i).lat,mtfs(i).lon,'o','MarkerFaceColor','white','MarkerSize',10,...
            'MarkerEdgeColor','k');
end
        
setm(gca,'MLineLocation',1,'PLineLocation',1,'MLabelLocation',1,'PLabelLocation',1,'FlineWidth',2,...
    'Fontweight','bold','FontSize',11)
gridm('reset')
        
% savepath = strcat(itfs_folder,'map_2150B.png');
% saveas(gcf,savepath,'png');        
        
