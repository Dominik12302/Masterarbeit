%% Load MT spectra data, calculate mahalanobis distance and plot 97.5 % 
% quantile of chi2 distribution as ellipse

clear all


% %% real data from 6300B -> Bx, By and 6320T -> Ex (fourier-coefficients, dec. 1)
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,1)); % By field
b = real(Y(1:10000,1)); % Ex field
c = real(X(1:10000,2));

mean_ab = mean([a b]); % for Mahalanobis
cov_ab = cov([a b]);
[rew_ab,raw_ab] = DetMCD([a b],'plots',0);
d = rew_ab.md;


%% cut-off value for mahalanobis distance
alpha = sqrt(chi2inv(0.975,2)); % alpha quantile chi2 dist, 97.5 % of data
p_chi = d < alpha;
a_p = a(p_chi);
b_p = b(p_chi);
sum(p_chi)/100

% %% cut-off values for robust distances (MCD)
% 
% % calculations for c and m
% n = numel(a);
% p = 2;
% % h = floor((n+p+1)/2);
% h = rew_ab.h;
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
% m = m_asy;
% 
% % cut-off value f distri
% alpha = finv(0.975,p,m-p+1);
% p_f = (c*(m-p+1)/(p*m))*d.^2 < alpha;
% a_p = a(p_f);
% b_p = b(p_f);
% sum(p_f)/100


%% plot data points and confidence ellipse
figure
plot(real(a),real(b),'.')
hold on
% plot(real(a_p),real(b_p),'.')

%% calculate eigenvalues/-vectors for ellipse plot (Mahalanobis)
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
h1 = plot(ellipse(:,1)+mean_ab(1),ellipse(:,2)+mean_ab(2),'LineWidth',1.5);

%% calculate eigenvalues/-vectors for ellipse plot (robust)
mean_ab = rew_ab.center;
cov_ab = rew_ab.cov;
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
h2 = plot(ellipse(:,1)+mean_ab(1),ellipse(:,2)+mean_ab(2),'LineWidth',1.5);

%% make the plot nicer
ylabel('\Re(B_y)')
xlabel('\Re(E_x)')
% title('Tolerance ellipse 97.5%, Chi²-distribution')
legend([h1 h2],{'Mahalanobis','Robust'})