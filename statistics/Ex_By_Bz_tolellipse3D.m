%% 3d ultra plots from distances... ATTENTION: SUPER AWESOME
% quantile of chi2 distribution as ellipse

clear all


% %% real data from 6300B -> Bx, By and 6320T -> Ex (fourier-coefficients, dec. 1)
load('E_Ex.mat')
load('B_X.mat')
a = real(Y(1:10000,1)); % Ex field
b = real(X(1:10000,1)); % Bx field
c = real(X(1:10000,2)); % By field

mean_ab = mean([a b]);
cov_ab = cov([a b]);
mean_ac = mean([a c]);
cov_ac = cov([a c]);
[rew_ab,raw_ab] = DetMCD([a b],'plots',0);
[rew_ac,raw_ac] = DetMCD([a c],'plots',0);
d_ab = rew_ab.md;
d_ac = rew_ac.md;

%% cut-off value for mahalanobis distance
alpha = sqrt(chi2inv(0.975,2)); % alpha quantile chi2 dist, 97.5 % of data
p_b = d_ab < alpha; % for Ex-Bx
p_c = d_ac < alpha; % for Ex-By
a_pb = a(p_b);
b_pb = b(p_b);
a_pc = a(p_c);
c_pc = b(p_c);



%% calculate eigenvalues/-vectors for ellipse plot Ex and Bx
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
ellipse_ab = [ellipse_a;ellipse_b]'*R; 


%% calculate eigenvalues/-vectors for ellipse plot Ex and By
[V,D] = eig(cov_ac);
[~,I] = max(D(:));
[i,~] = ind2sub(size(D),I); % index of largest eigenvektor
if i == 1 % index of smallest eigenvalue
    j = 2;
else 
    j = 1;
end

% define ellipse properties
ax_a = alpha*sqrt(max(D(:))); % main axis a
ax_c = alpha*sqrt(D(j,j)); % minor axis b
angle = atan(V(2,i)/V(1,i)); % angle for ellipse
if(angle < 0) % move to 0 to 2*pi
    angle = angle + 2*pi;
end

grid_ellipse = linspace(0,2*pi);
ellipse_a  = ax_a*cos(grid_ellipse);
ellipse_c  = ax_c*sin(grid_ellipse);
R = [cos(angle) sin(angle); -sin(angle) cos(angle)]; % rotate ellipse
ellipse_ac = [ellipse_a;ellipse_c]'*R; 

% points for main axis a
el1c = [mean_ac(2) mean_ac(1)] + V(2,:); 
el2c = [mean_ac(2) mean_ac(1)] - V(2,:); 


%% plot data points and confidence ellipse
figure('Position',[400 600 1000 400])

% plot Ex and Bx
subplot(1,2,1) 
plot3(b,0*c,a,'.'); % Bx
axis manual
hold on
xlabel('Bx')
ylabel('By')
zlabel('Ex')
[z1] = zlim;
plot3(rew_ab.center(2),0,rew_ab.center(1),'x'); % Bx
plot3([rew_ab.center(2) rew_ab.center(2)],[0 0],[z1(1) rew_ab.center(1)],'--','Color','k')
[x1] = xlim;
plot3([x1(1) rew_ab.center(2)],[0 0],[rew_ab.center(1) rew_ab.center(1)],'--','Color','k')
plot3(ellipse_ab(:,2)+mean_ab(2),ellipse_ab(:,2)*0,ellipse_ab(:,1)+mean_ab(1),'LineWidth',1.5);
grid on
ylim([-1 0]);

% plot Ex and By
subplot(1,2,2)
plot3(0*b,c,a,'.') % By
axis manual
hold on
xlabel('Bx')
ylabel('By')
zlabel('Ex')
[z1] = zlim;
plot3(0,rew_ac.center(2),rew_ac.center(1),'x') % By
h1 = plot3([0 0],[rew_ac.center(2) rew_ac.center(2)],[z1(1) rew_ac.center(1)],'--','Color','k');
[y1] = ylim;
plot3([0 0],[y1(1) rew_ac.center(2)],[rew_ac.center(1) rew_ac.center(1)],'--','Color','k')
plot3(ellipse_ab(:,2)*0,ellipse_ac(:,2)+mean_ac(2),ellipse_ac(:,1)+mean_ac(1),'LineWidth',1.5);
grid on
xlim([-1 0]);

% % all comps
% mean_bca = mean([b c a]);
% cov_bca = cov([b c a] - mean_bca);
% [U,D,V] = svd(cov_bca);
% ax_a = alpha*sqrt(D(1,1)); % main axis a
% ax_b = alpha*sqrt(D(2,2)); % minor axis b
% ax_c = alpha*sqrt(D(3,3)); % minor axis c
% [x_el,y_el,z_el] = ellipsoid(ax_a,ax_b,ax_c,mean_bca(1),mean_bca(2),mean_bca(3));
% 
% % 3d plot with ellisoid for Bx,By against Ex
% figure
% plot3(b,c,a,'.')
% axis manual
% hold on
% grid on
% xlabel('Bx')
% ylabel('By')
% zlabel('Ex')
% plot3(y_el,z_el,x_el)
