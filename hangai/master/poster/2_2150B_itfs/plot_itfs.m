%% simply plots the magnetic tfs in a smoother way
clear all;
close all;

% sites = {'1050B','1300B','4200B','4350B','2400B','4000B','2200B','4300B','2300B'};
sites = {'4000B','2200B','2400B','2150B'};
% sites = {'1300B'};

base = '2300B';   % base site
itfs_folder = '/syn06/d_harp01/ITFs/'; % folder with .mat-files

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

for i = 1:numel(sites)

figure('Position',[0 0 500 540],'Renderer','painters')
axes('box','on')
hold on
cut_per_low = 1; % 1s
cut_per_up = mtfs(i).nper; % 1024s
if (mtfs(i).nper < cut_per_up)
    cut_per_up = mtfs(i).nper;
end
xx = reshape(abs(mtfs(i).tf(1,1,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
xy = reshape(abs(mtfs(i).tf(1,2,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
yx = reshape(abs(mtfs(i).tf(2,1,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
yy = reshape(abs(mtfs(i).tf(2,2,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
title(strcat('local:',{' '},mtfs(i).locname,' base:',{' '},base))
ylabel('Absolute','FontWeight','bold')
xlabel('Periods [s]','FontWeight','bold')
ylim([-0.05 3])
xlim([0 3000]);
xticks([0.1 1 10 100 1000]);
xticklabels({'0.1' '1' '10' '100' '1000'});
yticks([-1 -0.5 0 0.5 1 1.5 2 3]);
yticklabels({'-1' '-0.5' '0' '0.5' '1' '1.5' '2' '3'});
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontWeight','bold','fontsize',10,'XScale','log',...
    'Linewidth',1.5);
plot(mtfs(i).periods(cut_per_low:cut_per_up),xx,'-','LineWidth',2)
plot(mtfs(i).periods(cut_per_low:cut_per_up),xy,'-','LineWidth',2)
plot(mtfs(i).periods(cut_per_low:cut_per_up),yx,'-','LineWidth',2) 
plot(mtfs(i).periods(cut_per_low:cut_per_up),yy,'-','LineWidth',2)
legend('T_{XX}','T_{XY}','T_{YX}','T_{YY}','location','southoutside','Orientation','horizontal')
grid on

savepath = strcat(itfs_folder,'nice',mtfs(i).locname,'_',base);
print(gcf,savepath,'-dpng','-r600');


end


%% plot opened figures in one window
columns = 2; % number of figures in one row
rows = 1; % number of rows with figures
fh = figure('Position',[0 0 1600 800],'Renderer','painter');
sites = [0 1];
for ii = 1:numel(sites)
    subplot(rows,columns,ii)
    P{ii} = get(gca,'pos');
end

clf

F = findobj('type','figure');

for ii = 2:numel(sites)+1
    ax = findobj(F(ii),'type','axes');
    set(ax,'parent',fh,'pos',P{ii-1})
    close(F(ii))
end




 
 