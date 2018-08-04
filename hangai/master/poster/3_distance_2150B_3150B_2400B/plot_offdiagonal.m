%% simply plots the magnetic tfs in a smoother way
clear all;
close all;

sites = {'2400B','3150B'};

% sites = {'1100B';'1150B';'1200B';'2050B';...
%     '2150B';'3080B';'3100B';'3200B';'3250B';'3300B';...
%     '3350B';'3400B';'1300B';'1350B';...
%     '2300B';'2400B';'1050B';'3000B';...
%     '2200B';'2250B';'3150B'};

base = '2150B';   % base site
itfs_folder = '~/Masterarbeit/master/itfs/'; % folder with .mat-files
itfs_folder = '~/Masterarbeit/master/poster/3_distance_2150B_3150B_2400B/';

for i = 1:numel(sites)
    filepath = strcat(itfs_folder,char(sites(i)),'_',base,'_all.mat');
    % filepath = strcat(itfs_folder,base,'_',char(sites(i)),'.mat');
    if (exist(filepath, 'file') ~= 0)
        load(filepath);
        if (exist('mtfs', 'var'))
            mtfs(end+1) = tfs;
        else
            mtfs = tfs;
            load(strcat(itfs_folder,char(sites(i)),'_',base,'_all.mat'));
        end
    end
end

for i = 1:numel(sites)
    if (i == 1)
        figure('Position',[600 500 600 350],'Renderer','painter')
        %title(strcat(mtfs(i).locname,' and ',{' '},mtfs(i+1).locname))
        ylabel('Root mean square (diagonals)')
        ylabel('Real parts of |T_{xy}| and |T_{yx}|')
        xlabel('Periods [s]')
        ylim([0 0.35])
        xlim([0.3 3000]);
        xticks([1 10 100 1000])
        xticklabels({'1' '10' '100' '1000'});
        yticks([0:0.1:1]);
        yticklabels({'0' '0.1' '0.2' '0.3' '0.4' '0.5' '0.6' '0.7' '0.8' '0.9' '1'});
        set(gca,'XScale','log','LineWidth',2,'FontSize',12,'FontWeight','bold','box','on');
    end
    hold on
    xx = reshape(real(mtfs(i).tf(1,1,:)),[1,mtfs(i).nper]);
    xy = reshape(real(mtfs(i).tf(1,2,:)),[1,mtfs(i).nper]);
    yx = reshape(real(mtfs(i).tf(2,1,:)),[1,mtfs(i).nper]);
    yy = reshape(real(mtfs(i).tf(2,2,:)),[1,mtfs(i).nper]);
    offdiag = [];
    for k = 1:numel(xx)
        offdiag(k) = sqrt(xy(k)^2+yx(k)^2)/2;
        diag(k) = (xx(k)+yy(k))/2;
    end    
    % plot(mtfs(i).periods,smooth(xx,'sgolay'),'-','LineWidth',2)
    if i == 1
        p1 = plot(mtfs(i).periods(15:35),smooth(abs(xy(15:35)),'sgolay'),'-','LineWidth',1.5,'Color','blue');
        plot(mtfs(i).periods(15:35),smooth(abs(yx(15:35)),'sgolay'),'--','LineWidth',1.5,'Color','blue');
    else
        p2 = plot(mtfs(i).periods(15:35),smooth(abs(xy(15:35)),'sgolay'),'-','LineWidth',1.5,'Color','red');
        plot(mtfs(i).periods(15:35),smooth(abs(yx(15:35)),'sgolay'),'--','LineWidth',1.5,'Color','red');  
    end
    % plot(mtfs(i).periods(1:39),smooth(diag(1:39),'sgolay'),'-','LineWidth',1.5) 
    %plot(mtfs(i).periods,smooth(yy,'sgolay'),'-','LineWidth',2) 
    % savepath = strcat(itfs_folder,'nice',mtfs(i).locname,'_',base,'.png');
    %saveas(gcf,savepath,'png');
end
grid on
legend([p1 p2],'2400B','3150B')





 
 