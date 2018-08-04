classdef TLibra < TRegression
% 2009  Maxim Smirnov, Gary Egbert
% Oregon State University

%  
%  (Complex) regression for the model  Y = X*b based on Libra staistical library
%
%  Allows multiple columns of Y, but estimates b for each column separately
%
%   S and N are estimated signal and noise covariance
%    matrices, which together can be used to compute     
%    error covariance for the matrix of regression coefficients b
%  R2 is squared coherence (top row is using raw data, bottom
%    cleaned, with crude correction for amount of downweighted data)    

properties
  % Robust parameters
  r0 = 1.5; 
  tol = .005;
  nITmax = 10;
  nIT;
  rdscnd = 0;
  u0 = 2.8;
end

methods

   function obj = TLibra(X,Y,iter)
   %   class constructor for RME object
   %
   %   Usage: obj = RME(X,Y,iter);

      if nargin >= 2
         obj.X = X;
         obj.Y = Y;
         if nargin ==3
            if class(iter == 'IterControl')
               obj.ITER  = iter;
            end
         end
      end
   end   
    
   function result = Estimate(obj)           
%RSIMPLS is a 'Robust method for Partial Least Squares Regression based on the
% SIMPLS algorithm'. It can be applied to both low and high-dimensional predictor variables x
% and to one or multiple response variables y. It is resistant to outliers in the data.
% The RSIMPLS algorithm is built on two main stages. First, a matrix of scores is derived 
% based on a robust covariance criterion (see robpca.m),
% and secondly a robust regression is performed based on the results from ROBPCA. 


     [nData,K] = size(obj.Y);
     [nX,nParam] = size(obj.X);

     result =  rsimpls(obj.X', obj.Y);

     obj.b = result.T; % parameters to be estimated
     obj.Cov_SS = result.Tcov; % signal covariance
     obj.Cov_NN = result.cov; % noise covariance
     %obj.R2 = ;
     obj.Yc = result.fitted; % array of cleaned data

   end  % Estimate
        
end %methods
    
end %class
