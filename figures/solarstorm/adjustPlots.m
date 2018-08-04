clear all

%%

openfig('Kp5_2150B_MCDregress.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-[0 0 150 0]);
axes = get(gcf,'children');

% phase
set(axes(1),'xlim',[0.01 3000])
yhandle = get(axes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + [0.0025 0 0],'Fontsize',12.1);
yyaxis right
yhandle = get(axes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(axes(2),'xlim',[0.01 3000],'ylim',[1 65000])
yhandle = get(axes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + [0.0025 0 0]);
set(get(axes(2),'Title'),'String','2150B - MCD regression')

export_fig('Kp5_2150B_MCDregress.png','-painters','-r300','-p0.01')

%%
openfig('Kp5_2150B_Mestimate.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-[0 0 150 0]);
axes = get(gcf,'children');

% phase
set(axes(1),'xlim',[0.01 3000])
yhandle = get(axes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + [0.0025 0 0]);
yyaxis right
yhandle = get(axes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(axes(2),'xlim',[0.01 3000],'ylim',[1 65000])
yhandle = get(axes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + [0.0025 0 0]);
set(get(axes(2),'Title'),'String','2150B - M-estimator')

export_fig('Kp5_2150B_Mestimate.png','-painters','-r300','-p0.01')

%%
openfig('Kp5_2150B_regress.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-[0 0 150 0]);
axes = get(gcf,'children');

% phase
set(axes(1),'xlim',[0.01 3000])
yhandle = get(axes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + [0.0025 0 0]);
yyaxis right
yhandle = get(axes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(axes(2),'xlim',[0.01 3000],'ylim',[1 65000])
yhandle = get(axes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + [0.0025 0 0]);
set(get(axes(2),'Title'),'String','2150B - ordinary LS')

export_fig('Kp5_2150B_regressAll.png','-painters','-r300','-p0.01')

%% For 2438B
xlimit = [0.1 20000];
ylabelcorr = [0.025 0 0];



openfig('Kp6_2438B_MCDregressAll.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-[0 0 150 0]);
axes = get(gcf,'children');

% phase
set(axes(1),'xlim',xlimit)
yhandle = get(axes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);
yyaxis right
yhandle = get(axes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(axes(2),'xlim',xlimit)
yhandle = get(axes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);
set(get(axes(2),'Title'),'String','2438B - MCD regression')

export_fig('Kp6_2438B_MCDregressAll.png','-painters','-r300','-p0.01')

%%
openfig('Kp6_2438B_MestimateAll.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-[0 0 150 0]);
axes = get(gcf,'children');

% phase
set(axes(1),'xlim',xlimit)
yhandle = get(axes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);
yyaxis right
yhandle = get(axes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(axes(2),'xlim',xlimit)
yhandle = get(axes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);
set(get(axes(2),'Title'),'String','2438B - M-estimator')

export_fig('Kp6_2438B_MestimateAll.png','-painters','-r300','-p0.01')

%%
openfig('Kp6_2438B_regressAll.fig')
set(gcf,'renderer','painter','Color','w','Position',get(gcf,'Position')-[0 0 150 0]);
axes = get(gcf,'children');

% phase
set(axes(1),'xlim',xlimit)
yhandle = get(axes(1),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);
yyaxis right
yhandle = get(axes(1),'Ylabel');
set(yhandle,'Fontsize',12.1);

% app. resistivity
set(axes(2),'xlim',xlimit)
yhandle = get(axes(2),'Ylabel');
set(yhandle,'position',get(yhandle,'position') + ylabelcorr);
set(get(axes(2),'Title'),'String','2438B - ordinary LS')

export_fig('Kp6_2438B_regressAll.png','-painters','-r300','-p0.01')




