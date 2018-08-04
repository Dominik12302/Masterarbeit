%% simply plots the impedance tfs in a smoother way
clear all;
close all;

% sites = {'1050B','1300B','4200B','4350B','2400B','4000B','2200B','4300B'};
sites = {'2150B'};

base = '2150B';   % base site
itfs_folder = '~/Masterarbeit/master/poster/4_Impedance_2150B_2200B/'; % folder with .mat-files

for i = 1:numel(sites)
    filepath = strcat(itfs_folder,char(sites(i)),'_',base,'_imp.mat');
    % filepath = strcat(itfs_folder,base,'_',char(sites(i)),'.mat');
    if (exist(filepath, 'file') ~= 0)
        load(filepath);
        if (exist('mtfs', 'var'))
            mtfs(end+1) = tfs;
        else
            mtfs = tfs;
            load(strcat(itfs_folder,char(sites(i)),'_',base,'_imp.mat'));
        end
    end
end

for i = 1:numel(sites)

figure('Position',[600 500 700 450],'Renderer','painters')
axes('box','on')
hold on
cut_per_low = 1; % 1s
cut_per_up = mtfs(i).nper-4; % 1024s
if (mtfs(i).nper < cut_per_up)
    cut_per_up = mtfs(i).nper;
end
xx = reshape(abs(mtfs(i).tf(1,1,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
xy = reshape(abs(mtfs(i).tf(1,2,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
yx = reshape(abs(mtfs(i).tf(2,1,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
yy = reshape(abs(mtfs(i).tf(2,2,cut_per_low:cut_per_up)),[1,cut_per_up-cut_per_low+1]);
title(strcat(mtfs(i).locname,'- ',mtfs(i).bname))
ylabel('App. Resistivity [Ohm m^{-1}]','FontWeight','bold')
xlabel('Periods [s]','FontWeight','bold')
ylim([0.01 10000])
%xlim([0.3 3000]);
%xticks([0.1 1 10 100 1000]);
%xticklabels({'0.1' '1' '10' '100' '1000'});
%yticks([-1 -0.5 0 0.5 1 1.5 2 3]);
%yticklabels({'-1' '-0.5' '0' '0.5' '1' '1.5' '2' '3'});
set(gca,'FontWeight','bold','fontsize',12,'XScale','log',...
    'Linewidth',1.5,'YScale','log','XMinorTick','off');
plot(mtfs(i).periods(cut_per_low:cut_per_up),xx,'o','LineWidth',2)
plot(mtfs(i).periods(cut_per_low:cut_per_up),xy,'o','LineWidth',2)
plot(mtfs(i).periods(cut_per_low:cut_per_up),yx,'o','LineWidth',2) 
plot(mtfs(i).periods(cut_per_low:cut_per_up),yy,'o','LineWidth',2) 
grid on
legend('Z_{xx}','Z_{xy}','Z_{yx}','Z_{yy}')
%savepath = strcat('/home/d/d_harp01/Masterarbeit/master/poster/2_2150B_itfs/','nice',mtfs(i).locname,'_',base);
%print(gcf,savepath,'-dpng','-r600');


end






 
 