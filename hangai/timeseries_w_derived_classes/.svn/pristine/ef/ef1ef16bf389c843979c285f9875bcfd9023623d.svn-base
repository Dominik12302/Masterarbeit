%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [YC,E_psiPrime] = HuberWt(Y,YP,sig,r0)

%   inputs are data (Y) and predicted (YP), estiamted
%   error variances (for each column) and Huber parameter r0
%   allows for multiple columns of data

  [nData,K] = size(Y);
  YC = Y;
  E_psiPrime = zeros(K,1);
  for k = 1:K
     r0s = r0*sqrt(sig(k));
     r = abs(Y(:,k)-YP(:,k));
     w = min(r0s./r,1);
     YC(:,k) = w.*Y(:,k)+(1-w).*YP(:,k);
     E_psiPrime(k) = sum(w==1)/nData;
  end;
end
