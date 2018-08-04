%% plot all MT sites from Hangai 2016/2017
clear all;
folder = '/syn06/d_harp01/MasterThesis/case_2000line/2d_inversion/EDIs_N2000_masked/';


files = dir(strcat(folder,'*.edi'));
for i = 1:numel({files.name})
    path = strcat(folder,files(i).name);
    Z{i} = read_edi(path);
    Z{i}.file = files(i).name;
end

for i = 1:numel(Z)
    lat(i) = Z{i}.lat;
    lon(i) = Z{i}.lon;
    name(i) = string(Z{i}.file(1:5));
end

idx = strfind(name,'B');
idX = strfind(name,'b');
for i = 1:numel(name)
    if ~isempty([idx{i}]) 
        yes(i) = ([idx{i}] > 0);
    elseif ~isempty([idX{i}])        
        yes(i) = ([idX{i}] > 0);
    else
        yes(i) = 0;
    end
end
latB = lat(yes);
lonB = lon(yes);
nameB = name(yes);

idx = strfind(name,'T');
idX = strfind(name,'t');
for i = 1:numel(name)
    if ~isempty([idx{i}]) 
        yes(i) = ([idx{i}] > 0);
    elseif ~isempty([idX{i}])        
        yes(i) = ([idX{i}] > 0);
    else
        yes(i) = 0;
    end
end
latT = lat(yes);
lonT = lon(yes);
nameT = name(yes);

idx = strfind(name,'L');
idX = strfind(name,'l');
for i = 1:numel(name)
    if ~isempty([idx{i}]) 
        yes(i) = ([idx{i}] > 0);
    elseif ~isempty([idX{i}])        
        yes(i) = ([idX{i}] > 0);
    else
        yes(i) = 0;
    end
end
latL = lat(yes);
lonL = lon(yes);
nameL = name(yes);


for i = 1:numel(nameL)
    charL = char(nameL(i));
    idX = strfind(name,strcat(charL(1:4),'B'));
    idx = strfind(name,strcat(charL(1:4),'b'));
    if ~isempty([idX{:}])
        latL(i) = lat(find(~cellfun(@isempty,idX)));
        lonL(i) = lon(find(~cellfun(@isempty,idX)));
    elseif ~isempty([idx{:}])
        latL(i) = lat(find(~cellfun(@isempty,idx)));
        lonL(i) = lon(find(~cellfun(@isempty,idx)));
    else
        latL(i) = 0;
        lonL(i) = 0;
    end
end


% %% projection properties
% axesm('MapProjection','mercator','MeridianLabel','on','ParallelLabel','on',...
%     'MapLatLimit',[44 50],'MapLonLimit',[94 103],'grid','on','Frame','on')
% title('')
% set(gcf,'Position',[200 10  900 900],'Renderer','painters');
% hold on
% 
% 
% % % request TEM modell
% layers = wmsfind('https://data.worldwind.arc.nasa.gov/elev?', 'SearchField', 'serverurl');
% layers = wmsupdate(layers);
% aster = layers.refine('srtm30', 'SearchField', 'layername');
% latlim = [45.1 49.3];
% lonlim = [98.1 103];
% cellSize = dms2degrees([0,1,0]);
% cellSize = 0.016667;
% [ZA, RA] = wmsread(aster, 'Latlim', latlim, 'Lonlim', lonlim, ...
%    'CellSize', cellSize, 'ImageFormat','image/bil');
% geoshow(ZA2, RA, 'DisplayType');
% demcmap(double(ZA));
% 
% plot(lon,lat,'o','MarkerFaceColor','white','MarkerSize',6,...
%             'MarkerEdgeColor','k');
% 
% % for i = 1:numel(sites)
% %     plotm(mtfs(i).lat,mtfs(i).lon,'o','MarkerFaceColor','white','MarkerSize',10,...
% %             'MarkerEdgeColor','k');
% % end
%         
% setm(gca,'MLineLocation',1,'PLineLocation',1,'MLabelLocation',1,'PLabelLocation',1,'FlineWidth',2,...
%     'Fontweight','bold','FontSize',11)
% gridm('reset')


%%
map = [47.5,50,100.3,103];
readhgt(map,'srtm1','outdir','/syn06/d_harp01/Mongolia_DEM')
h = gcf;
set(gcf,'Position',[624 337 900*1 370*2],'Color','w','renderer','painter');
title('')
hold on 
h1 = plot(lonT,latT,'^','MarkerFaceColor','black','MarkerSize',6,...
            'MarkerEdgeColor','k');
h2 = plot(lonB,latB,'o','MarkerFaceColor','white','MarkerSize',10,...
            'MarkerEdgeColor','k');
h3 = plot(lonL,latL,'o','MarkerFaceColor','red','MarkerSize',6,...
            'MarkerEdgeColor','k');
text(104.2,45,'Elevation (m)','rotation',90,'Fontweight','bold','Fontsize',12)
% h7205 = plot(lon_7205,lat_7205,'o','MarkerFaceColor','red','MarkerSize',12,...
%             'MarkerEdgeColor','k');
% h2300 = plot(lon_2300,lat_2300,'o','MarkerFaceColor','red','MarkerSize',12,...
%             'MarkerEdgeColor','k');
% h2400 = plot(lon_2400,lat_2400,'o','MarkerFaceColor','red','MarkerSize',12,...
%             'MarkerEdgeColor','k');
l1 = legend([h1 h2 h3],'Telluric site','Full MT site (BB)','Full MT site (LP)','location','NW');
set(l1,'Fontsize',12,'Fontweight','bold')

%%
export_fig('map_NorthProfile.png','-painters','-r600','-p0.01')
