clear all;
%%  get complete tf from several regressions
proc = EMProc({'/syn06/d_harp01/Hangai_2017/'});
proc = EMProc(proc,{ '7205B' });
proc.bandsetup = 'MT';
proc.lsname = { '7205B' };
proc.lsrate = 512;
proc.input = {'Bx' 'By'};
proc.output = {'Ex' 'Ey'}; % this bicoherencies are plotted (Y)

proc.usetime = [];
proc.usetime = [2017 6 26 15 0 0  2017 6 27 15 0 0]
proc.mindec = [4];
proc.maxdec = [10];

procdef.avrange = [4 4];
procdef.bicohthresg = {[0.2 1]};
procdef.alpha = 0.5;
reg = {'Mestimate','mcdregress'};

for i = 1:2
procdef.reg = reg{i};
proc.procdef = procdef;
tf(i) = proc.tf;
end

%% plot standard errors
figure
i = 1;
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(1,1,:))),'LineStyle','--','Color','red')
hold on
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(1,2,:))),'LineStyle','-','Color','red','Linewidth',1)
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(2,1,:))),'LineStyle','-.','Color','red','Linewidth',1)
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(2,2,:))),'LineStyle',':','Color','red')

i = 2;
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(1,1,:))),'LineStyle','--','Color','blue')
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(1,2,:))),'LineStyle','-','Color','blue','Linewidth',1)
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(2,1,:))),'LineStyle','-.','Color','blue','Linewidth',1)
loglog(tf(i).periods,squeeze(abs(tf(i).tf_se(2,2,:))),'LineStyle',':','Color','blue')


legend('SE_{xx}','SE_{xy}','SE_{yx}','SE_{yy}',...
    'SE_{xx}','SE_{xy}','SE_{yx}','SE_{yy}','Location','Northeastoutside')



%% plot 1st derivative of app. resistivity

figure
set(gcf,'Position',[ 770    200   627   443]); 

i = 1;
rho_xx  = abs(squeeze(tf(i).tf(1,1,:))).^2.*tf(i).periods/5;
rho_xy  = abs(squeeze(tf(i).tf(1,2,:))).^2.*tf(i).periods/5;
rho_yx  = abs(squeeze(tf(i).tf(2,1,:))).^2.*tf(i).periods/5;
rho_yy  = abs(squeeze(tf(i).tf(2,2,:))).^2.*tf(i).periods/5;

for j = 1:numel(tf(i).periods)-1
    tf(i).periodsMu(j) = mean([tf(i).periods(j) tf(i).periods(j+1)]);
end

for j = 1:numel(tf(i).periodsMu)-1
    tf(i).periodsMu(j) = mean([tf(i).periodsMu(j) tf(i).periodsMu(j+1)]);
end
tf(i).periodsMu(end) = [];


loglog(tf(i).periodsMu,abs(diff(diff(rho_xx))),'LineStyle','--','Color','red')
hold on
loglog(tf(i).periodsMu,abs(diff(diff(rho_xy))),'LineStyle','-','Color','red','Linewidth',1.5)
loglog(tf(i).periodsMu,abs(diff(diff(rho_yx))),'LineStyle','-.','Color','red','Linewidth',1.5)
loglog(tf(i).periodsMu,abs(diff(diff(rho_yy))),'LineStyle',':','Color','red')

i = 2;

rho_xx  = abs(squeeze(tf(i).tf(1,1,:))).^2.*tf(i).periods/5;
rho_xy  = abs(squeeze(tf(i).tf(1,2,:))).^2.*tf(i).periods/5;
rho_yx  = abs(squeeze(tf(i).tf(2,1,:))).^2.*tf(i).periods/5;
rho_yy  = abs(squeeze(tf(i).tf(2,2,:))).^2.*tf(i).periods/5;

for j = 1:numel(tf(i).periods)-1
    tf(i).periodsMu(j) = mean([tf(i).periods(j) tf(i).periods(j+1)]);
end

for j = 1:numel(tf(i).periodsMu)-1
    tf(i).periodsMu(j) = mean([tf(i).periodsMu(j) tf(i).periodsMu(j+1)]);
end
tf(i).periodsMu(end) = [];


loglog(tf(i).periodsMu,abs(diff(diff(rho_xx))),'LineStyle','--','Color','blue')
loglog(tf(i).periodsMu,abs(diff(diff(rho_xy))),'LineStyle','-','Color','blue','Linewidth',1.5)
loglog(tf(i).periodsMu,abs(diff(diff(rho_yx))),'LineStyle','-.','Color','blue','Linewidth',1.5)
loglog(tf(i).periodsMu,abs(diff(diff(rho_yy))),'LineStyle',':','Color','blue')

ylim([1 30000]);
xlim([1e-3 1e+5]);

legend('SE_{xx}','SE_{xy}','SE_{yx}','SE_{yy}',...
    'SE_{xx}','SE_{xy}','SE_{yx}','SE_{yy}','Location','Northoutside','Orientation','horizontal')



