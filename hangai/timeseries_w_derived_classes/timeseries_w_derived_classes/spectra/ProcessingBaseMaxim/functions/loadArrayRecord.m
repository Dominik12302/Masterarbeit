function [FC,nSitesMiss] = loadArrayRecord(Array,iBand,MaxMiss,lpack)
%
%   Usage:  [FC] = loadArrayRecord(Array,iBand);
%           [FC] = loadArrayRecord(Array,iBand,MaxMiss);
%           [FC] = loadArrayRecord(Array,iBand,MaxMiss,lpack);
%
%   Optional arguments MaxMiss (defaults to 0)
%                       lpack  (defaults to false (0))
%   
%   Returns frequency domain "Array Data Record" a structure
%   containing all FCs (aligned/ordered by set numbers)
%   for all files in "Array" data structure, for band defined
%   by "iBand".  If optional argument MaxMiss = 0 
%    then only sets with FCs for all sites are included 
%     (i.e., the FC array is full, with no missing data.)  
%   Otherwise all sets for which there are at
%   least MaxMiss sites have data returned, with NaN's denoting
%   missing FCs.  MaxMiss defaults to 0.
%

if nargin < 4
   lpack = 0;
end


if nargin < 3
   MaxMiss = 0;
end

id = iBand.id;
ib1 = iBand.iband(1);
ib2 = iBand.iband(2);
nF = ib2-ib1+1;
iSetMin = Inf;
iSetMax = -Inf;
Ncht = 0;
nSites = length(Array);
ih = ones(nSites+1,1);


%  loop over sites to find total number of channels, max and min
%   set numbers, and set ih, etc.
for k = 1:nSites
   %  we will assume that all files for a site agree with regard
   %   to number of channesl, etc.  Could write a consistency check
   %   routine.
   nch =  Array{k}(1).FChead.nch;
   if lpack
      irecl = nch+1;
   else
      irecl = 2*nch+1;
   end
   Ncht = Ncht + nch;
   ih(k+1) = 1 + Ncht;
   %   "nTape" is number of FC files for station #k
   nTape = length(Array{k});
   for l = 1:nTape
      if length(Array{k}(l).FChead.iSets{id}) > 0
         iSetMin = min(iSetMin,Array{k}(l).FChead.iSets{id}(1));
         iSetMax = max(iSetMax,Array{k}(l).FChead.iSets{id}(end));
      end
   end
end

%  figure out which sets are common to the files
nSetsAll = iSetMax-iSetMin+1;
iSetInd = zeros(nSetsAll,nSites,2);
for k = 1:nSites
   nTape = length(Array{k});
   for l = 1:nTape
      ind = Array{k}(l).FChead.iSets{id}-iSetMin+1;
      nsets = length(ind);
      iSetInd(ind,k,1) = l;
      iSetInd(ind,k,2) = [1:nsets];
   end
end

%  indices in array iSetInd for which enough sites are present
nSitesMiss = nSites-sum((squeeze(iSetInd(:,:,1))>0),2);
%    2-7-2013 : add the condition that there is data for at least one site
iuse = find(nSitesMiss <= MaxMiss & nSitesMiss < nSites);
nSets = length(iuse);
iSetInd = iSetInd(iuse,:,:);
X = NaN(Ncht,nF,nSets);
X = X+1i*X;
setNumbers = zeros(nSites,nSets);

%  Now read FCs for each file, retaining those sets with data 
%   available for enough sites
for k = 1:nSites
   nTape = length(Array{k});
   for l = 1:nTape
      %   use gives the indicies in file l, site k of the FCs
      %    that will be put into the "array record" X
      %   ind gives the positions in X where these FCs will go
      ind = find(iSetInd(:,k,1)==l);
      use = iSetInd(ind,k,2);

      Endian = Array{k}(l).FChead.Endian;
      fid = fopen(Array{k}(l).file,'r',Endian);
      nch = Array{k}(l).FChead.nch;
      if lpack
          irecl = nch+1;
      else
          irecl = 2*nch+1;
      end
      nch1 = nch+1;
      for ib = ib1:ib2
         iStart = Array{k}(l).FChead.startFreqs(id,ib);
         fseek(fid,iStart,'bof');
         head = fread(fid,irecl,'integer*4');
         nsets = head(3);
         if nsets > 0   
            if lpack
               head = fread(fid,nch1,'real*4');
               scales = head(1:nch);
               scales = (scales/1000.);
               ifc = fread(fid,[nch1,nsets],'integer*4');
               X(ih(k):ih(k+1)-1,ib-ib1+1,ind) = unpack(ifc(2:nch1,use),scales);
               if(ib == ib1)
                  setNumbers(k,ind) = ifc(1,use); 
               end
            else
               fseek(fid,4*irecl,'cof');
               fc = zeros(2*nch,nsets);
               ic  = zeros(nch,nsets);
               for iset = 1:nsets
                   %   read set number
                   ic(iset) = fread(fid,1,'integer*4');
                   %   read FCs for one segment, nch channels ... 
                   fc(:,iset) = fread(fid,2*nch,'real*4');
               end
               %   put into appropriate slots in data array
               X(ih(k):ih(k+1)-1,ib-ib1+1,ind) = fc(1:2:end,use)+1i*fc(2:2:end,use);
               if(ib == ib1)
                  setNumbers(k,ind) = ic(use); 
               end
            end
         end
      end
      fclose(fid);
   end
end

%  only need to keep a single copy of set numbers
setNumbers = max(setNumbers,[],1); 

FC = struct('X',X,'ih',ih,'iBand',iBand,'setNumbers',setNumbers);
