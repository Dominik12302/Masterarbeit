
% 2011 (c) Maxim Smirnov, Gary Egbert,  Oregon State University
%
% TFC the main component containing FCs for all segments and channels/sites
% at one decimation level

classdef TFC_FFT < TFC
    % 
    %       
methods

% create the object and preallocate Data array
function TFC = TFC_FFT(NChannels, NSites, NSegments, NPeriods)
  TFC.NChannels =  NChannels;
  TFC.NSites = NSites;
  TFC.NSegments =  0;
  TFC.NPeriods = NPeriods;
  TFC.SegmentInd = ones(1, NSegments);
  for i=0:NSites-1
    k=i*NChannels+1;
    TFC.SiteInd(k:k+NChannels-1) = i+1;      
  end;
  % preallocate memory for fourier coefficients
  %TFC.Data = complex(zeros(NPeriods, (NSites*NChannels), NSegments), zeros(NPeriods, (NSites*NChannels), NSegments));
end; % class constructor


% when Sitesrt from TS, than add construct segment by segment
function result = AddSegment(obj, FFT, SegmentInd, SegmentNumber)
  for k = 1:obj.NSites 
    k1 = (k-1)*obj.NChannels+1; k2 = k*obj.NChannels;
    % much faster this way than direct assignment
    x = FFT(k).Data(:,:); 
    if ~(sum(sum(x==0) == obj.NChannels)) && ( (sum(sum(isnan(x))) == numel(x)) || (sum(sum(isnan(x))) == 0) )
       obj.Data(:,k1:k2,SegmentInd) = x; 
    else
       disp('fuck something wrong');
       % make sure there is no exact zeroes, otherwise it interferes with 
       % TPC procedures where 0 is treated as missing element
       x(:,:) = NaN;
       obj.Data(:,k1:k2,SegmentInd) = x; 
      if (sum(sum(x == 0) > 0)) || ~( (sum(sum(isnan(x))) == numel(x)) || (sum(sum(isnan(x))) == 0) )
          disp('real fuck');
      end; 
    end;
  end;
  obj.SegmentNumber(SegmentInd) = SegmentNumber;
  result = size(obj.Data);
  obj.NSegments = size(obj.Data,3);
end;  %AddSegment


function result = RemoveMissingSegments(obj, ChannelsMiss);
%first eliminate channels which are almost all the time missing
%later will be extended to exclude predefined times

 GOOD = ones(size(obj.Data(1,:,:)));
 GOOD(obj.Data(1,:,:)==0 | isnan(obj.Data(1,:,:)))   = 0;
 obj.Header.NCh = size(obj.Data,2);
 fracCh = squeeze(sum(GOOD,2)/obj.Header.NCh);
 indSeg = find(fracCh < ChannelsMiss);
 %for ib=1:obj.NPeriods
 if length(indSeg) < obj.NSegments/3
  obj.Data(:,:,indSeg) = [];
  obj.SegmentNumber(indSeg) = [];
  obj.NSegments = size(obj.Data,3);
 end;
end;






   
function RemoveMissingChannels(obj, SegmentMiss);
%first eliminate channels which are almost all the time missing
%later will be extended to exclude predefined times

 GOOD = ones(size(obj.Data(1,:,:)));
 GOOD(obj.Data(1,:,:)==0 | isnan(obj.Data(1,:,:)))   = 0;
 fracSeg = sum(GOOD,3)/obj.NSegments;
 indCh = find(fracSeg < SegmentMiss);
 %for ib=1:obj.NPeriods
 obj.Data(:,indCh,:) = [];
 %end;
 indCh = find(fracSeg >= SegmentMiss);   
 if ~isempty(indCh)
  obj.Header = obj.Header.SelectChannels(indCh);
  obj.NSites = obj.Header.NSites;
 else 
  obj.Header.NSites = 0;   
  obj.Header.Nch = 0; 
  obj.Header.NchSites = [];
 end;
 
end;


function LoadFCband(obj,ib)
   obj.X = []; 
   obj.Bands{ib}.iband; 
   f1=obj.Bands{ib}.iband(1); % first frequency
   f2=obj.Bands{ib}.iband(2); % last in the band
   for k = f1:f2    
    % sum(find() 
     obj.X(:,k-f1+1,:) = obj.Data(k,:,:);
   end;
  
   [ncht,nb,nseg] = size(obj.X);   
   obj.X = reshape(obj.X,[ncht,nb*nseg]);
   
   
   obj.SegmentInd = reshape(repmat(obj.SegmentNumber, f2-f1+1,1),1,length(obj.SegmentNumber)*(f2-f1+1));
      
 % do not include segments having more then MaxMiss sites missing
   GOOD = ones(size(obj.X));
   GOOD(isnan(obj.X))   = 0;
      %   first find out which times have a moderate fraction of channels (pCh(1))
   fracCh = sum(GOOD,1);
   indSeg = find(fracCh < (obj.Header.Nch*(1-obj.MaxMiss/obj.NSites)));
      % obj.NSeg = length(obj.indSeg);
      %   next find out which channels have a high  fraction of these segments
   obj.X(:,indSeg) = [];
   obj.SegmentInd(indSeg) = [];
   %obj.NSegments=length(obj.X); 
   
   
   %obj.X(isnan(obj.X)) = 0;   
   %obj.SegmentInd = ones(1,obj.NSegments);   
end


end; %methods
end %class

