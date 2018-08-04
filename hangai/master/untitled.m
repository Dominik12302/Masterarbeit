%% plot the intention... easier than this stupid gimp
clear all;
close all;
figure('position',[300 300 380 340]);
axes('box','on','Color',[0.467 0.675 0.188],'XTickLabelMode','manual',...
    'YTickLabelMode','manual','XTickMode','manual','YTickMode','manual');
xlim([0 1])
ylim([0 1])
hold on
plot([0.72 0.72],[0 1],'--','LineWidth',2,'Color','k')
plot([0.72 0.3],[0.84 0.84],'--','LineWidth',2,'Color','k')
plot([0.72 0.3],[0.16 0.16],'--','LineWidth',2,'Color','k')
plot([0.3 0.3],[0.16 0.84],'-','LineWidth',2,'Color','k')
plot([0.3],[0.82],'^','MarkerFaceColor','k','MarkerEdgeColor','k',...
    'MarkerSize',7,'LineWidth',1)
plot([0.3],[0.18],'v','MarkerFaceColor','k','MarkerEdgeColor','k',...
    'MarkerSize',7,'LineWidth',1)
plot(0.72,0.84,'o','MarkerFaceColor','red','MarkerEdgeColor','k',...
    'MarkerSize',35,'LineWidth',2)
plot(0.72,0.16,'o','MarkerFaceColor','red','MarkerEdgeColor','k',...
    'MarkerSize',35,'LineWidth',2)
plot([0.72 0.72 0.72 0.72],[0.29 0.42 0.55 0.68],'^','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor','k',...
    'MarkerSize',14,'LineWidth',2)

