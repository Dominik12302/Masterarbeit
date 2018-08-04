%% load MCD regression plots with changing alpha and make them nice!
clear all;
%% For 7205B
xlimit = [40 50000];
ylimit = [1 1E4];
ylabelcorr = [20 0 0];
width = [0 0 100 0]; % substracted from position
col = {'r','b','m','g'};


openfig('2400L_MCDregress_coh095_RR2300L.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-width);
plotaxes = get(gcf,'children');

% phase
set(plotaxes(1),'xlim',xlimit);
yhandle = get(plotaxes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);

yyaxis right
yhandle = get(plotaxes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(plotaxes(2),'xlim',xlimit);
set(plotaxes(2),'ylim',ylimit);
yhandle = get(plotaxes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr - [0 80 0]);
set(get(plotaxes(2),'Title'),'String','2400L-rr2300L - MCD regression')

axes_child = get(plotaxes(2),'children');
set(axes_child(1),'Visible','off');
set(axes_child(3),'Visible','off');
set(axes_child(5),'Visible','off');
set(axes_child(7),'Visible','off');

axes(plotaxes(2));

hold on
plot(10^(log10(min(xlimit))+0.2+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.5],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
text(10^(log10(min(xlimit))+0.35+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.5],'Zxx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
plot(10^(log10(min(xlimit))+0.85+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.5],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
text(10^(log10(min(xlimit))+1.0+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.5],'Zxy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
plot(10^(log10(min(xlimit))+0.2+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.7],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
text(10^(log10(min(xlimit))+0.35+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.7],'Zyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
plot(10^(log10(min(xlimit))+0.85+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.7],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
text(10^(log10(min(xlimit))+1.0+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.7],'Zyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');


export_fig('2400L_MCDregress_coh095_RR2300L.png','-painters','-r300','-p0.01')


%% For 7205B

openfig('2400L_Mestimate_coh095_RR2300L.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-width);
plotaxes = get(gcf,'children');

% phase
set(plotaxes(1),'xlim',xlimit);
yhandle = get(plotaxes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);

yyaxis right
yhandle = get(plotaxes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(plotaxes(2),'xlim',xlimit);
set(plotaxes(2),'ylim',ylimit);
yhandle = get(plotaxes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr - [0 80 0]);
set(get(plotaxes(2),'Title'),'String','2400L-rr2300L - MCD regression')

axes_child = get(plotaxes(2),'children');
set(axes_child(1),'Visible','off');
set(axes_child(3),'Visible','off');
set(axes_child(5),'Visible','off');
set(axes_child(7),'Visible','off');

axes(plotaxes(2));

hold on
plot(10^(log10(min(xlimit))+0.2+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.5],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
text(10^(log10(min(xlimit))+0.35+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.5],'Zxx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
plot(10^(log10(min(xlimit))+0.85+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.5],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
text(10^(log10(min(xlimit))+1.0+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.5],'Zxy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
plot(10^(log10(min(xlimit))+0.2+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.7],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
text(10^(log10(min(xlimit))+0.35+log10(max(xlimit))-3),10.^[log10(max(ylimit))-0.7],'Zyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
plot(10^(log10(min(xlimit))+0.85+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.7],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
text(10^(log10(min(xlimit))+1.0+log10(max(xlimit))-3.1),10.^[log10(max(ylimit))-0.7],'Zyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');


export_fig('2400L_Mestimate_coh095_RR2300L.png','-painters','-r300','-p0.01')
