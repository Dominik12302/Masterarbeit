%% plot map for TFs with corresponding base site
clear all;
% load 'E:/map_local_basesites/GPS_spam_ede.mat'
load '~/Masterarbeit/master/map_local_basesites/tfswithbases_correct.mat' 

%% empty empty empty
[nlines,~] = size(gps_data);
lat = [];
long = [];
site = {};
lat_b = [];
long_b = [];
site_b = {};
base1 = {};
base2 = {};


%% read latitude, longitude and sitename from table
for i=1:nlines
    if ~isempty(strfind(gps_data(i).sitename,'B'))
        lat_b(end+1) = gps_data(i).lat;
        long_b(end+1) = gps_data(i).long;
        site_b{end+1} = gps_data(i).sitename;
    else
        lat(end+1) = gps_data(i).lat;
        long(end+1) = gps_data(i).long;
        site{end+1} = gps_data(i).sitename;
        if isempty(gps_data(i).base1)
            base1{end+1} = {};
        else
            base1{end+1} = gps_data(i).base1;
        end
        if isempty(gps_data(i).base2)
            base2{end+1} = {};
        else
            base2{end+1} = gps_data(i).base2;
        end
    end
end


%% write data to structure
tfs_base = {};
for i=1:numel(site_b)
    tfs_base(i).base = site_b(i);
    tfs_base(i).baselat = lat_b(i);
    tfs_base(i).baselong = long_b(i);
    i_site = 1;
    i_site2 = 1;
    for j=1:numel(site)
        comp = strfind(base1{j},char(site_b(i)));
        if ~isempty(comp)
            tfs_base(i).site(i_site) = site(j);
            tfs_base(i).lat(i_site) = lat(j);
            tfs_base(i).long(i_site) = long(j);
            i_site = i_site + 1;
        end
        comp = strfind(base2{j},char(site_b(i)));
        if ~isempty(comp)
            tfs_base(i).site2(i_site2) = site(j);
            tfs_base(i).lat2(i_site2) = lat(j);
            tfs_base(i).long2(i_site2) = long(j);
            i_site2 = i_site2 + 1;
        end
    end
end


%% projection properties
ax = axesm('MapProjection','mercator','MeridianLabel','on','ParallelLabel','on',...
    'MapLatLimit',[45.5 49],'MapLonLimit',[99 103],'grid','on','Frame','off');
% title('Sites with corresponding base')
ax.Color = [0.467 0.675 0.188];
set(gcf,'Position',[200 10  900 900]);
hold on


% % request TEM modell
% layers = wmsfind('nasa.network*elev', 'SearchField', 'serverurl');
% layers = wmsupdate(layers);
% aster = layers.refine('earthaster', 'SearchField', 'layername');
% latlim = [45.1 49.3];
% lonlim = [98.1 103];
% cellSize = dms2degrees([0,1,0]);
% cellSize = 0.016667;
% [ZA, RA] = wmsread(aster, 'Latlim', latlim, 'Lonlim', lonlim, ...
%    'CellSize', cellSize, 'ImageFormat', 'image/bil');
% geoshow(ZA, RA, 'DisplayType', 'texturemap');
% demcmap(double(ZA));

%% plot base stations
base_color = {};
for i=1:numel([tfs_base.baselat])
    % base_color{end+1} = rand(1,3);
    base_color{end+1} = [0.6 0.6 0.6];
    if (isempty(num2cell(tfs_base(i).site)))
        base(i) = plotm(tfs_base(i).baselat,tfs_base(i).baselong,'o','MarkerFaceColor','white','MarkerSize',11,...
            'MarkerEdgeColor','k');
    else
%         plotm(tfs_base(i).baselat,tfs_base(i).baselong,'o','MarkerFaceColor',base_color{i},'MarkerSize',10,...
%             'MarkerEdgeColor','k')
        base(i) = plotm(tfs_base(i).baselat,tfs_base(i).baselong,'o','MarkerFaceColor','red','MarkerSize',11,...
            'MarkerEdgeColor','k');
        % textm(tfs_base(i).baselat-0.04,tfs_base(i).baselong+0.06,tfs_base(i).base,'Color','r')
    end
end


%% plot sites with lines to corresponding base station
for i=1:numel([tfs_base.baselat])
    if ~isempty(tfs_base(i).lat)
        sites = plotm(tfs_base(i).lat,tfs_base(i).long,'^','MarkerFaceColor',base_color{i},'MarkerEdgeColor','k');
        for j = 1:numel([tfs_base(i).lat])
            plotm([tfs_base(i).baselat tfs_base(i).lat(j)],[tfs_base(i).baselong tfs_base(i).long(j)],...
                'LineStyle','--','Color','k','LineWidth',1.5);
        end
        if ~isempty(tfs_base(i).lat2)
            for j = 1:numel([tfs_base(i).lat2])
                plotm([tfs_base(i).baselat tfs_base(i).lat2(j)],[tfs_base(i).baselong tfs_base(i).long2(j)],...
                'LineStyle','--','Color','k','LineWidth',1.5);
            end    
        end
    end
end

for i=1:numel([tfs_base.baselat])
    if ~isempty(tfs_base(i).lat)
        sites = plotm(tfs_base(i).lat,tfs_base(i).long,'^','MarkerFaceColor',base_color{i},'MarkerEdgeColor','k');
    end
end


%setm(gca,'MLineLocation',1,'PLineLocation',1,'MLabelLocation',1,'PLabelLocation',1,'FlineWidth',2,...
%    'Fontweight','bold','FontSize',11)
%gridm('reset')
% legend([base(1) sites],{'full mt','telluric'},'location','southeast')

uistack(base,'top')


