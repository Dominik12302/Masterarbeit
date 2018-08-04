clear all;
%% loads data and calculates tf for specific period and channel /and site)
proc = EMProc({'/syn06/d_harp01/Hangai_2017/'});
proc = EMProc(proc,{ '7205B' });
proc.bandsetup = 'MT';
proc.lsname = { '7205B' };
proc.lsrate = 512;
proc.input = {'Bx' 'By'};
proc.output = {'Ex' 'Ey'};
ich = 1; % which output?
coh = [0.8 1];
period = 1; % which period?

hist = 0; % histogram of real and imag of residuals
pplot = 1; % probability plot of absoulte residuals
splot = 0; % stabilized PP- and QQ-plot with confidence intervals of real part
qplot = 0; % QQ plot of absolute residuals


%% specify period
sp = proc.localsite;
sp = sp{1};
bsfcenter = sp.bsfcenter; %  shows possible periods
[~,ifreq] = min(abs([bsfcenter{:}]-(1/period)));

for j = 1:numel([bsfcenter{:}])
    if ifreq <= numel([bsfcenter{1}])
        proc.usedec = 1;
        ib = ifreq;
        break;
    elseif ifreq <= numel([bsfcenter{1:j}])
        proc.usedec = j;
        ib = ifreq - numel([bsfcenter{1:j-1}]);
        break;
    end
end
idec = proc.usedec;

sp.fcrange  = [sp.bsfc{idec}{ib}(1) sp.bsfc{idec}{ib}(end)];
proc.fcrange = sp.fcrange; 
f = sp.bsfcenter{idec}(ib);
period = 1/f;

%% choose output channel
proc.output = proc.output(ich);
output = proc.output;
% proc.usetime = [2017 6 26 15 0 0  2017 6 27 15 0 0];
% proc.usetime = [];
X = proc.X;
Y = proc.Y;

%% get spectra and residuals from RobustProcessing
proc = EMRobustProcessing(Y,X);
proc.f = f;
proc.avrange = [4 4];
proc.bicohthresg = {coh};
proc.useY = proc.maskY;

X = proc.XmN;
Y = proc.YmN;
X(isnan(Y(:,1)),:) = [];
Y(isnan(Y(:,1)),:) = [];

fprintf(1,' - Decimation level %d, Period: %.3f, %d fcs, output channel: %s\n',idec,1/f,size(Y,1),output{1});

proc.reg = 'Mestimate';
[Z1,Zse1,stats1] = computetf(proc);
res1 = stats1.resid;
proc.reg = 'mcdregress';
[Z2,Zse2,stats2] = computetf(proc);
res2 = stats2.rew.res;
%res2 = res2(stats2.rew.flag);
proc.reg = 'regress';
[Z3,Zse3,stats3] = computetf(proc);
res3 = Y-X*Z3';

res1= res1(~isnan(res1));  % M-estimator
res2= res2(~isnan(res2));  % MCD regression
res3= res3(~isnan(res3));  % OLS regression
%% statistical plots 1: histogram
if hist == 1
figure
set(gcf,'Position',[624 337 800 370])

xc = mean(std(res1,'omitnan'));
stepx = 2*xc/31;
edges = [-10*xc -2*xc:stepx:2*xc 10*xc];

% plot real parts
subplot(1,2,1)
h1=histogram(real(res2),edges,'Normalization','pdf');
hold on
ylabel('counts','Fontsize',12,'Fontweight','bold')
xlabel('real part of residuals','Fontsize',12,'Fontweight','bold')

h2=histogram(real(res1),edges,'Normalization','pdf','FaceAlpha',0.65);
ylabel('counts','Fontsize',12,'Fontweight','bold')
xlim([-2.2*xc 2.2*xc])


% pdf MCDregression
y = -2.2*xc:xc/50:2.2*xc;
mcd = mcdcov(real(res2),'plots',0);
mu = mcd.center;
sigma = sqrt(mcd.cov);
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(y,f,'LineWidth',1.5,'Color','blue')

% pdf Mestimator
y = -2.2*xc:xc/50:2.2*xc;
mcd = mcdcov(real(res1),'plots',0);
mu = mcd.center;
sigma = sqrt(mcd.cov);
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(y,f,'LineWidth',1.5,'Color','red')


legend('MCD regression','M-estimator')

% plot imaginary parts
subplot(1,2,2)
h1=histogram(imag(res2),edges,'Normalization','pdf');
hold on
ylabel('counts','Fontsize',12,'Fontweight','bold')
xlabel('imaginary part of residuals','Fontsize',12,'Fontweight','bold')

h2=histogram(imag(res1),edges,'Normalization','pdf','FaceAlpha',0.65);
ylabel('counts','Fontsize',12,'Fontweight','bold')
xlim([-2.2*xc 2.2*xc])

% pdf MCDregression
y = -2.2*xc:xc/50:2.2*xc;
mcd = mcdcov(imag(res2),'plots',0);
mu = mcd.center;
sigma = sqrt(mcd.cov);
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(y,f,'LineWidth',1.5,'Color','blue')

% pdf Mestimator
y = -2.2*xc:xc/50:2.2*xc;
mcd = mcdcov(imag(res1),'plots',0);
mu = mcd.center;
sigma = sqrt(mcd.cov);
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(y,f,'LineWidth',1.5,'Color','red')


legend('MCD regression','M-estimator')
end
%% statistical plots 2: probability plot
if pplot == 1
figure
set(gcf,'Position',[624 337 900*0.7 370*1.4])
res1_st = stats1.rstud;

% H2 = X*inv(X'*X)*X';
% lev2 = sqrt(1-diag(H2));
% res2_st = res2./(stats2.s(1,1)*lev2(stats2.rew.flag,:));

while length(res1) ~= length(res2)
    if length(res1) <= length(res2)
        res1(end+1) = NaN;
    else
        res2(end+1) = NaN;
    end
end

pd = makedist('Rayleigh');
probplot(pd,[abs(res2) abs(res1)])
legend('MCD regression','M-estimator','location','NW')
title(['Probability plot for site ' sp.name ' (' output{1} ', T= ' num2str(period) 's)'])
xlabel('Absolute of residuals','Fontsize',13,'Fontweight','bold')
ylabel('CDF (Rayleigh)','Fontsize',13,'Fontweight','bold')

% figure
% set(gcf,'Position',[624 337 900*0.7 370*1.4])
% probplot(pd,abs(res3))
% legend('OLS','location','NW')
% title(['Probability plot for site ' sp.name ' (' output{1} ', T= ' num2str(period) 's)'])
% xlabel('Absolute of residuals','Fontsize',13,'Fontweight','bold')
% ylabel('CDF (Rayleigh)','Fontsize',13,'Fontweight','bold')

end
%% statistical plots 3: variance-stabilized pp- and qq-plot
if splot == 1
    
test = real(res2);
test = zscore(test(~isnan(test)));
[~,~,~,cv] = kstest(test,'alpha',0.05);
mu_2 = mean(test,'omitnan');
std2 = std(test,'omitnan');

figure
set(gcf,'Position',[624 337 900*1.2 370*1.2])

subplot(1,2,1)
Nu = length(test);
vec = 1:Nu;
u = (vec-0.5)'/Nu;
r = 2*asin(sqrt(u))/pi;
plot(r, 2/pi*asin(sqrt(normcdf(sort(test), mu_2, std2))), '.')
hold on
plot(r, 2/pi*asin(sqrt(min(1, sin(pi*r/2).^2 + cv))),'k')
plot(r, 2/pi*asin(sqrt(max(0, sin(pi*r/2).^2 - cv))),'k')
title(['Percentile-percentile plot, real'])
xlabel('Sin quantiles','Fontsize',10,'Fontweight','bold')
ylabel('Transformed residuals','Fontsize',10,'Fontweight','bold')
B = r(:)\(2/pi*asin(sqrt(normcdf(sort(test), mu_2, std2))));                  
fittedX = linspace(min(r), max(r), 200);
fittedY = B*fittedX;
plot(fittedX, fittedY,'LineWidth',1,'Color','red','LineStyle','--','HandleVisibility','off');
hold off

subplot(1,2,2)
test = imag(res2);
test = zscore(test(~isnan(test)));
[~,~,~,cv] = kstest(test,'alpha',0.05);
mu_2 = mean(test,'omitnan');
std2 = std(test,'omitnan');
Nu = length(test);
vec = 1:Nu;
u = (vec-0.5)'/Nu;
r = 2*asin(sqrt(u))/pi;
plot(r, 2/pi*asin(sqrt(normcdf(sort(test), mu_2, std2))), '.')
hold on
plot(r, 2/pi*asin(sqrt(min(1, sin(pi*r/2).^2 + cv))),'k')
plot(r, 2/pi*asin(sqrt(max(0, sin(pi*r/2).^2 - cv))),'k')
title(['Percentile-percentile plot, imaginary'])
xlabel('Sin quantiles','Fontsize',10,'Fontweight','bold')
ylabel('Transformed residuals','Fontsize',10,'Fontweight','bold')
B = r(:)\(2/pi*asin(sqrt(normcdf(sort(test), mu_2, std2))));                  
fittedX = linspace(min(r), max(r), 200);
fittedY = B*fittedX;
plot(fittedX, fittedY,'LineWidth',1,'Color','red','LineStyle','--','HandleVisibility','off');
hold off


% QQ plot with intervals not necessary
% x = norminv(u, mu_2, std2);
% plot(x, sort((test - mu_2)/std2),'.')
% hold on
% plot(x, norminv(u + cv,mu_2,std2),'k') 
% plot(x, norminv(u - cv,mu_2,std2),'k')
% title(['Quantile-quantile plot'])
% xlabel('Normal quantiles','Fontsize',10,'Fontweight','bold')
% ylabel('Scaled residuals','Fontsize',10,'Fontweight','bold')
% B = x(:)\sort((test - mu_2)/std2);                  
% fittedX = linspace(min(x), max(x), 200);
% fittedY = B*fittedX;
% plot(fittedX, fittedY,'LineWidth',1,'Color','red','LineStyle','--','HandleVisibility','off');

end
%% statistical plots 4: Q-Q plots of absolute res
if qplot == 1
figure
set(gcf,'Position',[624 337 900*0.6 370*1.2],'renderer','painter','Color','w');
test1 = abs(res1);
test1 = test1(~isnan(test1));
test2 = abs(res2);
test2 = test2(~isnan(test2));
if numel(test1)<30
    dotscale = 3;
else
    dotscale = 1;
end

% Mest
Nu = length(test1);
vec = 1:Nu;
u = (vec-0.5)'/Nu;
x = raylinv(u);
plot(x, sort((test1)),'.','Color','red','Markersize',8*dotscale)
hold on
B = x(:)\sort((test1));                  
fittedX = linspace(0, max(x), 200);
fittedY = B*fittedX;
plot(fittedX, fittedY,'LineWidth',1.5,'Color','red','LineStyle','--','HandleVisibility','off');

% MCD regress
Nu = length(test2);
vec = 1:Nu;
u = (vec-0.5)'/Nu;
x = raylinv(u);
plot(x, sort((test2)),'.','Color','blue','Markersize',8*dotscale)
hold on
B = x(:)\sort((test2));                  
fittedX = linspace(0, max(x), 200);
fittedY = B*fittedX;
plot(fittedX, fittedY,'LineWidth',1.5,'Color','blue','LineStyle','--','HandleVisibility','off');

set(gca,'Fontsize',13)
title(['site ' sp.name ' (' output{1} ', T= ' num2str(round(period,3)) 's)'])
xlabel('Rayleigh quantiles','Fontsize',13,'Fontweight','bold')
ylabel('Absolute of residuals','Fontsize',13,'Fontweight','bold')
legend('M-estimator','MCD regression','location','NW')

export_fig([sp.name '_QQplot_' output{1} '_coh' num2str(coh(1)) '_' num2str(round(period,3)) 's.png'],'-painters','-r300','-p0.01');

end

%% BONUS:
% figure
% test = real(res3);
% 
% xc = mean(std(test,'omitnan'));
% stepx = 2*xc/141;
% edges = [-1*xc -1*xc:stepx:1*xc 1*xc];
% 
% h1=histogram(test,edges,'Normalization','pdf');
% hold on
% ylabel('counts','Fontsize',12,'Fontweight','bold')
% xlabel('real part of residuals (OLS)','Fontsize',12,'Fontweight','bold')
% 
% 
% y = -1*xc:xc/50:1*xc;
% mcd = mcdcov(test,'plots',0);
% mu = mcd.center;
% sigma = sqrt(mcd.cov);
% f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
% h2 = plot(y,f,'LineWidth',1.5,'Color','red');
% 
% xlim([-xc xc])
% set(gca,'Fontsize',13)
% legend([h2],'Normal PDF')















