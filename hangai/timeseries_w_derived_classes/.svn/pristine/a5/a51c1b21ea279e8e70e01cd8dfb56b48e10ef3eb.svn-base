classdef TSiegel < TRegression
% 2009 Gary Egbert , Maxim Smirnov
% Oregon State University

%  
%  (Complex) regression-M estimate for the model  Y = X*b
%
%  Allows multiple columns of Y, but estimates b for each column separately
%
%   S and N are estimated signal and noise covariance
%    matrices, which together can be used to compute     
%    error covariance for the matrix of regression coefficients b
%  R2 is squared coherence (top row is using raw data, bottom
%    cleaned, with crude correction for amount of downweighted data)    

%  Parameters that control regression M-estimates are defined in ITER

methods

%   class constructor
function obj = TSiegel(X,Y, iter)
  obj.X = X;
  obj.Y = Y;
  if nargin == 3
     if isobject(iter)
        obj.ITER  = iter;
     else
        obj.ITER = IterControl;
        obj.ITER.iterMax = iter;
     end
  else
     obj.ITER = IterControl;
     obj.ITER.iterMax = length(obj.Y);
  end
end


function result = Estimate(obj)           
% Siegel's Repeated Medians algorithm
% breakdown point is 50%
% Simple Monte Carlo randomizing algorithm

     
  N=length(obj.Y);    % sample size
  P=size(obj.X,2);    % number of parameters to be estimated 
  logN = round(log(N)); % reduce breakdown point, but increase efficiency 
                      % fast version of algorithm requires  Nlog(N)
                      % computations. If itermax==N, then SS  log(N) would
                      % do it
                      
  if (P*logN > N); Pn=P+1; 
      else Pn = P*logN;
  end;
  % limit number randomized iterations
  if obj.ITER.iterMax > N;  iter = N;
      else iter = obj.ITER.iterMax;
  end;
  
  if Pn < N
    for i=1:iter
      ind = randperm(N,Pn); 
      if rank(obj.X(ind,:)) == P;  
         b(:,i) = obj.X(ind,:)\obj.Y(ind); 
      end;
    end;   
    if ~isempty(b)
      obj.b = median(b,2);      
      obj.Yc = obj.X*obj.b;
  
      if obj.ITER.returnCovariance
      % compute noise variance using MAD and inv signal covariance
        res = 1.4826*median(abs(obj.Y - obj.Yc));
        obj.Cov_NN = res^2;
        obj.Cov_SS = inv(obj.X'*obj.X);
      end; 
    end;
  else
    disp('Can not solve underdetermined system. Using damped LS');
    obj.b = pinv(obj.X)*obj.Y;
  end;
end  % Estimate
        

end %methods    
end %class
