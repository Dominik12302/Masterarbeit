% %% this is a matlab script for some simple testing and some more fun
clear all
close all

%% generated data
% for i = 1:5000
mu = [0,0];
sigma = [1,1.5;1.5,3];
var_x = mvnrnd(mu,sigma,5000);
center = [mu(1) mu(2)];
plot(var_x(:,1),var_x(:,2),'.')
hold on
plot(center(1),center(2),'o')
mahal_dist = mahalanobis(var_x,mu,'cov',cov(var_x));
p_mahal = sqrt(mahal_dist) < chi2inv(0.975,2);
mahal_dist=mahal_dist(p_mahal);
var_x = var_x(p_mahal',:);
plot(var_x(:,1),var_x(:,2),'.')

% calculate the 97.5% quantile of chi square distribution with p degrees of
% freedom
chi2 = chi2cdf(mahal_dist,2);
figure
plot(sort(mahal_dist),sort(chi2))
% bla(i) = numel(var_x(:,1))/5000;
% end
% mean(bla)
% % mahal_xy = mahal(var_x(:,1),var_x(:,2));
% % mahal_yx = mahal(var_x(:,2),var_x(:,1));
% % p_xy = mahal_xy > 2;
% % p_yx = mahal_yx > 2;
% % p = p_xy+p_yx;
% % p = p == 0;
% % x = var_x(:,1);
% % y = var_x(:,2);
% % plot(x(p),y(p),'.')
% 
% 
% 
% %% real data from 6300B -> Bx, By and 6320T -> Ex (fourier-coefficients, dec. 1)
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:2000,1));
b = real(Y(1:2000,1));
cov_ab = nancov([a b]);
mean_ab = mean([a b]);
d = mahalanobis([a b],mean_ab,'cov',cov_ab);
alpha = chi2inv(0.975,2)+1; % alpha quantile chi2 dist, 97.5 % of data
p = sqrt(d) < alpha;
a_p = a(p);
b_p = b(p);
figure
plot(a,b,'.')
hold on
plot(a_p,b_p,'.')
numel(a_p)/numel(a)

[V,D] = eig(cov_ab); % calculate eigenvalues for ellipse plot
[~,I] = max(D(:));
[i,~] = ind2sub(size(D),I); % index of largest eigenvektor
ax_a = alpha*sqrt(max(D(:))); % main axis a
if i == 1 % index of smallest eigenvalue
    j = 2;
else 
    j = 1;
end
ax_b = alpha*sqrt(D(j,j)); % minor axis b
angle = atan(V(2,i)/V(1,i)); % angle for ellipse
if(angle < 0) % move to 0 to 2*pi
    angle = angle + 2*pi;
end
grid_ellipse = linspace(0,2*pi);
ellipse_a  = ax_a*cos(grid_ellipse);
ellipse_b  = ax_b*sin(grid_ellipse);
R = [cos(angle) sin(angle); -sin(angle) cos(angle)]; % Rotate ellipse
ellipse = [ellipse_a;ellipse_b]'*R;
plot(ellipse(:,1)+mean_ab(1),ellipse(:,2)+mean_ab(2))

% % Z = [real(X(:,1)) real(Y(:))];
% 
% 
% %% plot mahalanobis distance for, cut of at distance 3xstd (standard deviation)
% center = [mean(Z(:,1)) mean(Z(:,2))];
% figure
% plot(Z(:,1),Z(:,2),'.')
% hold on
% plot(center(1),center(2),'o')
% mahal_xy = mahal(Z,Z);
% p = mahal_xy < 3;
% Z = Z(p,:); % Z now only contains data with mahalanobis distance of 3 or less
% plot(Z(:,1),Z(:,2),'.')
% 
% 
% %% parabola for data q(d) = (d - mean(d))^2, multiplied by p.d.f. gives variance of data
% % only for Bx (Z(:,1))
% figure
% mu_Bx = mean(Z(:,2));
% q_Bx = (Z(:,2) - mu_Bx).^2;
% plot(Z(:,2),q_Bx,'x');
% 
% %% p.d.f from Bx p(d) calculated at points given in X
% x_pdf = [-100:0.001:100];
% mu_Bx = mean(Z(:,2));
% std_Bx = std(Z(:,2));
% pdf_Bx = pdf('Normal',Z(:,2),mu_Bx,std_Bx);
% plot(Z(:,2),pdf_Bx,'.');
% qp_Bx = q_Bx.*pdf_Bx; % variance is the area under the curve of var_Bx
% plot(Z(:,2),qp_Bx,'.')
% var_Bx = (1/(numel(Z(:,2))-1))*sum(q_Bx.*pdf_Bx);
% trapz(qp_Bx)

%% Is the mean of a complex number our beloved mean? And what about the cov?
plot(real(Z(:,1)),imag(Z(:,1)),'.')
hold on
k = mean(Z(:,1));
plot(real(k),imag(k),'o')
for i = 1:numel(Z(1,:))
    for j = 1:numel(Z(1,:))
        sum = 0;
        for m = 1:numel(Z(:,1))
            sum = sum + ( (Z(m,i)-mean(Z(:,i)))*(Z(m,j)-mean(Z(:,j)))' );
            C(i,j) = (1/(numel(Z(:,1))-1)) * sum;
            m
            i
            j
        end
    end
end

%% do it yourself-mahalanobis distance

Ex = Y;
Bx = X(:,1);
By = X(:,2);

mu_Ex = mean(Ex);
mu_Bx = mean(Bx);
mu_By = mean(By);
mu = [mu_Ex mu_Bx mu_By];

Z = [Ex Bx By]';
cov_Z = nancov(Z);

d = sqrt((Z-mu)'*inv(cov_Z)*(Z-mu));




















