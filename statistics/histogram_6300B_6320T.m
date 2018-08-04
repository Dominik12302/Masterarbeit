%% histogram plot with distribution
clear all


% %% real data from 6300B -> Bx, By and 6320T -> Ex (fourier-coefficients, dec. 1)
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,2)); % By field
b = real(Y(1:10000,1)); % Ex field

figure('Position',[400 400 1050 420])
%% histogram for By
subplot(1,2,1)
histogram(a,'Normalization','pdf','LineWidth',0.5)
set(gca,'LooseInset',get(gca,'TightInset'))
% title('Histogram for B_y')
hold on
y = min(a):abs(min(a)-max(a))/500:max(a);

% plot normal distribution with sample mean and sample covariance
mu_sample = mean(a);
sigma_sample = std(a);
f = exp(-(y-mu_sample).^2./(2*sigma_sample^2))./(sigma_sample*sqrt(2*pi));
h1 = plot(y,f,'LineWidth',1.5);

% plot normal distribution with robust mean and robust covariance
[rew raw] = DetMCD(a,'plots',0);
mu_mcd = rew.center;
sigma_mcd = sqrt(rew.cov);
f = exp(-(y-mu_mcd).^2./(2*sigma_mcd^2))./(sigma_mcd*sqrt(2*pi));
h2 = plot(y,f,'LineWidth',1.5);
legend([h1 h2],{'sample','robust'})
ylabel('PDF')
xlabel('B_y')
hold off

%% histogram for Ex
subplot(1,2,2)
histogram(b,'Normalization','pdf','LineWidth',0.5)
set(gca,'LooseInset',get(gca,'TightInset'))
% title('Histogram for E_x')
hold on
y = min(b):abs(min(b)-max(b))/500:max(b);

% plot normal distribution with sample mean and sample covariance
mu_sample = mean(b);
sigma_sample = std(b);
f = exp(-(y-mu_sample).^2./(2*sigma_sample^2))./(sigma_sample*sqrt(2*pi));
h1 = plot(y,f,'LineWidth',1.5);

% plot normal distribution with robust mean and robust covariance
[rew raw] = DetMCD(b,'plots',0);
mu_mcd = rew.center;
sigma_mcd = sqrt(rew.cov);
f = exp(-(y-mu_mcd).^2./(2*sigma_mcd^2))./(sigma_mcd*sqrt(2*pi));
h2 = plot(y,f,'LineWidth',1.5);
legend([h1 h2],{'sample','robust'})
ylabel('PDF')
xlabel('E_x')
hold off



