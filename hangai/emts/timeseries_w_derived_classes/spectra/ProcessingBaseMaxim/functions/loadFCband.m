function [X,T] = loadFCband(TFC,ib)
  X = squeeze(TFC.Data(TFC.Bands(ib).iband(1),:,:));  
  for i=(TFC.Bands(ib).iband(1)+1):TFC.Bands(ib).iband(2) 
    X = horzcat(X, squeeze(TFC.Data(i,:,:)) );
    %  compute period from info in FC files
    T = TFC.T( (TFC.Bands(ib).iband(2)+TFC.Bands(ib).iband(1))/2 );
  end;
  %X = squeeze(X);
end

