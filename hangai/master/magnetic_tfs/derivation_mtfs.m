% This script calculates and plots the derivation from zero for all
% parts of the horizontal magnetic transfer function
clear all;

load '~/Masterarbeit/master/itfs/1350B_1300B.mat';

nper = tfs.nper; % number of periods
txx = rms(real(tfs.tf(1,1,:)));
tyx = rms(real(tfs.tf(2,1,:)));
txy = rms(real(tfs.tf(1,2,:)));
tyy = rms(real(tfs.tf(2,2,:)));
