classdef TRME_RR < TRegression
    properties
        Z
    end
    % 2009 Gary Egbert , Maxim Smirnov
    % Oregon State University
    
    %  (Complex) Robust remote reference estimator, for arbitray number of
    %     input channels (i.e., columns of design matrix).
    %    X gives the local input, Z is the reference
    %       (matrices of the same size)
    %  As for TRME the model  is Y = X*b, and multiple columns
    %    of Y (predicted or output variables) are allowed (estimates
    %    of b for each column are computed separately)
    %  Allows multiple columns of Y, but estimates b for each column separately
    %    no missing data is allowed for the basic RR class
    %
    %   S and N are estimated signal and noise covariance
    %    matrices, which together can be used to compute
    %    error covariance for the matrix of regression coefficients b
    %  R2 is squared coherence (top row is using raw data, bottom
    %    cleaned, with crude correction for amount of downweighted data)
    
    %  Parameters that control regression M-estimates are defined in ITER

    methods
        
        function obj = TRME_RR(X,Y,Z,iter)
            %   class constructor for TRME_RR objects
            %    Robust remote reference estimator, for arbitray number of
            %     input channels (i.e., columns of design matrix).
            %    X gives the local input, Z is the reference
            %       (matrices of the same size)
            %  As for regrM.m the model  is Y = X*b, and multiple columns
            %    of Y (predicted or output variables) are allowed (estimates
            %    of b for each column are computed separately)
            %
            %   Usage: obj = TRME_RR(X,Z,Y,iter);
            
            if nargin >= 3
                if sum(sum(isnan(X)))>0 || sum(sum(isnan(Y)))>0 || sum(sum(isnan(Z)))>0
                    error('Missing data not allowed for TRME_RR class')
                end
                [nData,~] = size(Y);
                [nX,nParam] = size(X);
                if nX ~= nData
                    error('data (Y) and design matrix (X) do not have same number of rows')
                end
                if nParam > nData
                    error(['not enough data for RR estimate: # param = ' ....
                        num2str(nParam) ', # data = ' num2str(nData)]);
                end
                if any(size(X) ~= size(Z))
                    error('sizes of local and remote do not agree in RR estimation routine')
                end
                obj.X = X;
                obj.Y = Y;
                obj.Z = Z;
                if nargin ==4
                    if class(iter == 'IterControl')
                        obj.ITER  = iter;
                    else
                        obj.ITER =  IterControl;
                    end
                else
                    obj.ITER = IterControl;
                end
            end
        end
        
        function  Estimate(obj)
            %   function that does the actual remote reference estimate
            %
            %   Usage:  [b]  = Estimate(obj);
            %    (Object has all outputs; estimate of coefficients is also returned
            %              as function output)
            
            
            %   note that ITER is a handle object, so mods to ITER properties are
            %   already made also to obj.ITER!
            ITER = obj.ITER;
            
            [nData,~] = size(obj.Y);
            [~,nParam] = size(obj.X);
            %  initial LS RR estimate b0, error variances sigma
            [Q,~] = qr(obj.Z,0);
            QTX = Q'*obj.X;
            QTY = Q'*obj.Y;
            b0 = QTX\QTY;
            %  predicted data
            Yhat = obj.X*b0;
            %   intial estimate of error variance
            res = obj.Y-Yhat;
            sigma = sum(res.*conj(res),1)/nData;
            %cfac = 1./(2*(1.-(1.+ITER.r0)*exp(-ITER.r0) ));
            if ITER.iterMax > 0
                notConverged = 1;
                cfac = 1./(1.-exp(-ITER.r0));
                %cfac = 1./(2*(1.-(1.+ITER.r0)*exp(-ITER.r0) ));
            else
                notConverged = 0;
                E_psiPrime = 1;
                Yhat = obj.X*b0;
                obj.b = b0;
                obj.Yc = obj.Y;
            end
            
            %   convergence stuff
            ITER.niter = 0;
            
            while notConverged
                ITER.niter = ITER.niter+1;
                %  cleaned data
                [obj.Yc,E_psiPrime] = HuberWt(obj.Y,Yhat,sigma,ITER.r0);
                %  updated error variance estimates, computed using cleaned data
                QTY = Q'*obj.Yc;
                obj.b = QTX\QTY;
                Yhat = obj.X*obj.b;
                res = obj.Yc-Yhat;
                sigma = cfac*sum(res.*conj(res),1)/nData;
                notConverged = cvgcTest(ITER,obj.b,b0);
                b0 = obj.b;
            end
            
            if ITER.rdscnd
                %  one iteration with redescending influence curve
                %  cleaned data
                [obj.Yc,E_psiPrime] = RedescendWt(obj.Y,Yhat,sigma,ITER.u0);
                %  updated error variance estimates, computed using cleaned data
                QTY = Q'*obj.Yc;
                obj.b = QTX\QTY;
                Yhat = obj.X*obj.b;
                res = obj.Yc-Yhat;
                %   crude estimate of expectation of psi' ... accounting for
                %    redescending influence curve
                E_psiPrime = 2*E_psiPrime-1;
            end
            
            %   compute error covariance matrices
            obj.Cov_SS = (obj.Z'*obj.X)\(obj.X'*obj.X)/(obj.X'*obj.Z);
            %   need to look at how we should compute adjusted residual cov
            %   to make consistent with tranmt
            SSRC = conj(res'*res);
            res = obj.Yc-Yhat;
            SSR = conj(res'*res);
            %SSY = real(sum(Y.*conj(Y),1));
            SSYC = real(sum(obj.Yc.*conj(obj.Yc),1));
            obj.Cov_NN = diag(1./(E_psiPrime.^2))*SSRC/(nData-nParam);
            obj.R2 = 1-diag(real(SSR))'./SSYC;
            obj.R2(obj.R2<0) = 0;
            %R2 = 1-[diag(real(SSR))'./SSY; ...
            %   (1./E_psiPrime).*diag(real(SSRC))'./SSYC];
            % R2(R2<0) = 0;
            
        end
        
    end %methods
    
end %class
