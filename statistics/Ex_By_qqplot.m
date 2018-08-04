%% Load MT spectra data, make a Q-Q-plot

clear all


%% real data from 6300B -> Bx, By and 6320T -> Ex (fourier-coefficients, dec. 1)
load('E_Ex.mat')
load('B_X.mat')
a = real(X(1:10000,2)); % By field
b = real(Y(1:10000,1)); % Ex field

%% make QQ-plot
qqplot(a,b)
% title('Q-Q-plot of E_x and B_y')