classdef TLTS < TRegression
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

   function obj = TLTS(X,Y,iter)
   %   class constructor for RME object
   %
   %   Usage: obj = RME(X,Y,iter);

      if nargin >= 2
         obj.X = X;
         obj.Y = Y;
         if nargin ==3
            if class(iter == 'IterControl')
               obj.ITER  = iter;
            else
                obj.ITER = IterControl;
            end
         else
             obj.ITER = IterControl;
         end
      end
   end   
    
   function result = Estimate(obj)           
   %   function that does the actual regression-M estimate
   %
   %   Usage:  [b]  = Estimate(obj);
   %    (Object has all outputs; estimate of coefficients is also returned 
   %              as function output)

    
   %   note that ITER is a handle object, so mods to ITER properties are
   %   already made also to obj.ITER!
   ITER = obj.ITER; 
   %   Q-R decomposition of design matix
     [nData,K] = size(obj.Y);
     [nX,nParam] = size(obj.X);
     if nX ~= nData
        error('data (Y) and design matrix (X) do not have same number of rows')
     end
     if nParam > nData
        % overdetermined problem ... use svd to invert, return
        %   NOTE: the solution IS non-unique ... and by itself RME
        %    is not set up to do anything sensible to resolve the
        %    non-uniqueness (no prior info is passed!)
        %  This is stop-gap, to prevent errors when using RME as part of
        %   some other estimation scheme!
        [u,s,v] = svd(obj.X,'econ');
        sInv = 1./diag(s);
        obj.b = v*diag(sInv)*u'*obj.Y;
        if ITER.returnCovariance 
           obj.Cov_NN = zeros(K,K);
           obj.Cov_SS = zeros(nParam,nParam);
        end
        result = obj.b;
        return
     end

     for dim=1:size(obj.Y,2)
       reg_res = ltsregres(obj.X,obj.Y,'plots',0,'intercept',0,'alpha',0.5);
       obj.b(:,dim) = reg_res.slope;
       sigma(:,dim) = real(reg_res.rsquared);
       obj.Yc(:,dim) = reg_res.fitted;
       res(:,dim) = reg_res.res;
     end;
     
%    raw.coefficients : Vector of raw LTS coefficient estimates (including the 
%                       intercept, when options.intercept=1).
%          raw.fitted : Vector like y containing the raw fitted values of the response.
%             raw.res : Vector like y containing the raw residuals from the regression.
%           raw.scale : Scale estimate of the raw residuals.
       
     if ITER.returnCovariance 
        %   compute error covariance matrices
        [Q,R] = qr(obj.X,0);
        obj.Cov_SS = inv(R'*R);
     
        %   need to look at how we should compute adjusted residual cov
        %   to make consistent with tranmt
        SSRC = conj(res'*res);
        SSYC = real(sum(obj.Yc.*conj(obj.Yc),1));
        obj.Cov_NN = SSRC/(nData-nParam);
   
        obj.R2 = 1-diag(real(SSRC))'./SSYC;
        obj.R2(obj.R2<0) = 0;
     end
   end  % RM_Est
        
end %methods
    
end %class
