%% Load MT spectra data, calculate mahalanobis distance and plot 97.5 % 
% quantile of chi2 distribution as ellipse

% clear all


% %% real data from 6300B -> Bx, By and 6320T -> Ex (fourier-coefficients, dec. 1)
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,2)); % By field
b = real(Y(1:10000,1)); % Ex field
c = (X(1:10000,1));

% robust estimate of covariance and mean
dmcd = DetMCD([real(a) real(b)],'plots',0);
[rew,raw] = DetMCD([a b],'plots',0);
cov_ab = dmcd.cov;
mean_ab = dmcd.center;
d = rew.rd;

% robust estimate with Matlab function
% [cov_ab,mean_ab] = robustcov([a b]);
% d = sqrt(mahalanobis([a b],mean_ab,'cov',cov_ab));


% cut off data with mahalanobis distance > alpha quantile of chi2 dist.
alpha = sqrt(chi2inv(0.975,2)); % alpha quantile chi2 dist, 97.5 % of data
p = d < alpha;
a_p = real(a(p));
b_p = real(b(p));
numel(a_p)/numel(a); % how much percent of data is in the distance range
numel(b_p)/numel(b); % how much percent of data is in the distance range


% plot data points and confidence ellipse
figure
plot(real(a),real(b),'.')
hold on
plot(a_p,b_p,'.')

% calculate eigenvalues/-vectors for ellipse plot
[V,D] = eig(cov_ab);
[~,I] = max(D(:));
[i,~] = ind2sub(size(D),I); % index of largest eigenvektor
if i == 1 % index of smallest eigenvalue
    j = 2;
else 
    j = 1;
end

% define ellipse properties
ax_a = alpha*sqrt(max(D(:))); % main axis a
ax_b = alpha*sqrt(D(j,j)); % minor axis b
angle = atan(V(2,i)/V(1,i)); % angle for ellipse
if(angle < 0) % move to 0 to 2*pi
    angle = angle + 2*pi;
end

grid_ellipse = linspace(0,2*pi);
ellipse_a  = ax_a*cos(grid_ellipse);
ellipse_b  = ax_b*sin(grid_ellipse);
R = [cos(angle) sin(angle); -sin(angle) cos(angle)]; % rotate ellipse
ellipse = [ellipse_a;ellipse_b]'*R; 
plot(ellipse(:,1)+mean_ab(1),ellipse(:,2)+mean_ab(2))



%% BONUS: classical mean and so on
% covariance and mean, not robust
cov_ab = nancov([a b]);
mean_ab = mean([a b]);

% calculate eigenvalues/-vectors for ellipse plot
[V,D] = eig(cov_ab);
[~,I] = max(D(:));
[i,~] = ind2sub(size(D),I); % index of largest eigenvektor
if i == 1 % index of smallest eigenvalue
    j = 2;
else 
    j = 1;
end

% define ellipse properties
ax_a = alpha*sqrt(max(D(:))); % main axis a
ax_b = alpha*sqrt(D(j,j)); % minor axis b
angle = atan(V(2,i)/V(1,i)); % angle for ellipse
if(angle < 0) % move to 0 to 2*pi
    angle = angle + 2*pi;
end

grid_ellipse = linspace(0,2*pi);
ellipse_a  = ax_a*cos(grid_ellipse);
ellipse_b  = ax_b*sin(grid_ellipse);
R = [cos(angle) sin(angle); -sin(angle) cos(angle)]; % rotate ellipse
ellipse = [ellipse_a;ellipse_b]'*R; 
plot(ellipse(:,1)+mean_ab(1),ellipse(:,2)+mean_ab(2),'-','LineWidth',2)



% % asymptotic cutoff values n = 500, p = 10 Table 3.1.1 p. 941
% n = 50;
% p = 5;
% h = floor((n+p+1)/2);
% alpha = (n-h)/n;
% q_alpha = chi2inv(1-alpha,p);
% Pq_alpha2 = chi2cdf(q_alpha,p+2);
% c_alpha = (1-alpha)/Pq_alpha2;
% c2 = -Pq_alpha2/2;
% Pq_alpha4 = chi2cdf(q_alpha,p+4);
% c3 = -Pq_alpha4/2;
% c4 = 3*c3;
% b1 = c_alpha*(c3-c4)/(1-alpha);
% b2 = 0.5 + c_alpha/(1-alpha)*(c3-(q_alpha/p*(c2+(1-alpha)/2)));
% v1 = (1-alpha)*b1^2*(alpha*(c_alpha*q_alpha/p-1)^2-1)-2*c3*c_alpha^2*(3*...
%     (b1-p*b2)^2+(p+2)*b2*(2*b1-p*b2));
% v2 = n*(b1*(b1-p*b2)*(1-alpha))^2*c_alpha^2;
% v = v1/v2;
% m_asy = 2/(c_alpha^2*v); % m
% m_pred = m_asy*exp(0.725-0.00663*p-0.0780*log(n));
% Phn = chi2inv(h/n,p);
% c = chi2cdf(Phn,p+2)/(h/n); % c
% 
% 
% 
% finv(0.99,p,m_asy-p+1)*p*m_asy/(c*(m_asy-p+1))
% 
% 
% 
% %% qq plot which works
% qqplot(sort(chi2inv([0:0.0001:0.9999],2)),sort(dmcd.rd))
% 
% p = 5
% parfor i = 1:1000    
%     aarg = mvnrnd(zeros(p,1),(zeros(p,1)+0.5)',50);
%     dmcd = DetMCD(aarg,'plots',0,'scale_est',3);
%     d = dmcd.rd;
%     cut = sqrt(chi2inv(0.01,p));
%     % cut = sqrt(finv(0.05,c,m_asy))
%     logic = raw.md < cut;
%     bla = aarg(logic,:);
%     [sz2,~] = size(bla);
%     [sz1,~] = size(aarg);
%     mu(i) = sz2/sz1;
% end
% mean(mu)
% lo = mu > 0.05;
% sum(lo)/numel(mu)*100
% 
% 
% d_2 = (c*(m_asy-p+1)/(p*m_asy)).*(d.^2);
% q = fpdf(1:50,p,m_asy-p+1);
% finv(0.95,p,m_asy-p+1)/(c*(m_asy-p+1)/(p*m_asy));
% 


%% cut-off values for robust distances (MCD)

% calculations for c and m
n = 10000;
p = 4;
% h = floor((n+p+1)/2);
h = 7500;
alpha = (n-h)/n;
q_alpha = chi2inv(1-alpha,p);
Pq_alpha2 = chi2cdf(q_alpha,p+2);
c_alpha = (1-alpha)/Pq_alpha2;
c2 = -Pq_alpha2/2;
Pq_alpha4 = chi2cdf(q_alpha,p+4);
c3 = -Pq_alpha4/2;
c4 = 3*c3;
b1 = c_alpha*(c3-c4)/(1-alpha);
b2 = 0.5 + c_alpha/(1-alpha)*(c3-(q_alpha/p*(c2+(1-alpha)/2)));
v1 = (1-alpha)*b1^2*(alpha*(c_alpha*q_alpha/p-1)^2-1)-2*c3*c_alpha^2*(3*...
    (b1-p*b2)^2+(p+2)*b2*(2*b1-p*b2));
v2 = n*(b1*(b1-p*b2)*(1-alpha))^2*c_alpha^2;
v = v1/v2;
m_asy = 2/(c_alpha^2*v); % m
m_pred = m_asy*exp(0.725-0.00663*p-0.0780*log(n));
Phn = chi2inv(h/n,p);
c = chi2cdf(Phn,p+2)/(h/n); % c
m = m_asy;

% cut-off value chi2 distri
cut_chi = chi2inv(0.975,p);
p_chi = d.^2 < cut_chi;
sum(p_chi)/100

% cut-off value f distri
cut_f = finv(0.975,p,m-p+1);
p_f = (c*(m-p+1)/(p*m))*d.^2 < cut_f;
sum(p_f)/100
% a_p = a(p_f);
% b_p = b(p_f);


%% PCA
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,2)); % By field
b = real(X(1:10000,1)); % Ex field
dmcd = DetMCD([real(a) real(b)],'plots',0);
% [rew,raw] = DetMCD([a b],'plots',0);
cov_ab = dmcd.cov;
mean_ab = dmcd.center;
[V,D] = eig(cov_ab);
Y = V'*[a b]';
plot(Y(1,:),Y(2,:),'.')

hold on
plot(a,b,'.')
ylabel('real part of B_y')
xlabel('real part of E_x')
hold on
c = mean([a b]);
plot(c(1),c(2),'x');


%% histogram plot with distribution
figure
histogram(b,'Normalization','pdf')
hold on
y = -20:0.01:20;
mu = mean(b);
sigma = std(b);
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(y,f,'LineWidth',1.5)


%% has the centered data cloud the same covariance?
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,2)); % By field
b = real(Y(1:10000,1)); % Ex field
d = real(X(1:10000,1)); % By field
c = [a b d];
dmcd = DetMCD(c,'plots',0);
c2 = c-dmcd.center; % substract mean
dmcd2 = DetMCD(c2,'plots',0); % calc cov-matrix
[V,D] = eig(dmcd2.cov); % calc eigenvector/values
[D,I] = sort(max(D),'descend'); % sort eigenvalues
V2 = V(:,I'); % sort eigenvectors
% g = cumsum(D); % energy? Wikipedia
V_reduced = V2(:,1); % reduce dimensions
final = V_reduced'*c2'; % final data

% get back the old data from this
c_orig = ((V_reduced'*final)+dmcd.center'); % components might be s



%% Libra bib for robust PCA
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,2)); % By field
b = real(Y(1:10000,1)); % Ex field
result = robpca([a b],'plots',0,'k',2);










