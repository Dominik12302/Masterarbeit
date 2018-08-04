function [FChead] = fcOpen(cfile,lpack,Endian);

% Opens one FC file, reads header, saves some useful info about file
%    in data structure FChead
%
% Usage: [FChead] = fcOpen(cfile);
% Usage: [FChead] = fcOpen(cfile,lpack);
% Usage: [FChead] = fcOpen(cfile,lpack,Endian);
%
% Optional arguments: lpack (defaults to  false (0) )
%                      Endian (defaults to 'n')
%   
%
%   WARNING: at present need to set lpack explicitly!!!!
%   
%    Modified from fc_open to return header info in a single data
%    structure; also does (for one file, but all decimation levels)
%    what was done previously by mk_start_freqs 
%    (i.e., a list of file positions for start of FCs for a
%    decimation level/frequency # is constructed and stored in the 
%    structure)

if nargin<2
   lpack = 0;
end

if nargin < 3
   Endian = 'n';
end

%cform1 = 'nch %d nd %d nfmx %d';
nhdrec = 20;

fid = fopen(cfile,'r',Endian);
if(fid < 0 )
   fprintf(1,'file not found/n')
   FChead = -1;
   return
end
line = fgets(fid);
if(line == -1)
   FChead = -1;
   return
end

i0 = 4; i1 = 8;
nch = sscanf(line(i0:i1),'%d',1);
i0 = 11; i1 = 16;
nd = sscanf(line(i0:i1),'%d',1);
i0 = 21; i1 = 24;
nf = sscanf(line(i0:i1),'%d',1);

i0 = 28 + 1;
i1 = 28+8*nd;
decs = sscanf(line(i0:i1),'%d',[2,nd]);
i0 = i1+5;
i1 = i0 + nd*12 - 1;
drs = sscanf(line(i0:i1),'%e',nd);
i1 = i1+8;
chid = []; orient = [];
for ich = 1:nch
  i0 = i1 + 1 ;
  i1 = i0+5; 
  chid = [chid;line(i0:i1)];
  i0 = i1 + 1;
  i1 = i0 + 13;
  orien = sscanf(line(i0:i1),'%f',2);
  orient = [orient , orien ];
end
i0 = i1 + 5; i1 = i0+7;
stdec(1) = sscanf(line(i0:i1),'%f'); 
i0 = i1 + 1; i1 = i0+7;
stdec(2) = sscanf(line(i0:i1),'%f'); 
i0 = i1 + 5; i1 = i0+7;
decl = sscanf(line(i0:i1),'%f'); 

startFreqs = zeros(nd,nf);

%  Find positions in file where each decimation level/frequency
%    band start
if lpack
   irecl = nch+1;
else
   irecl = 2*nch+1;
end

fseek(fid,nhdrec*4*irecl,'bof');
head = fread(fid,irecl,'long');
idec = head(1); ifreq = head(2); nsegs = head(3);
nskip = 4*irecl*(nsegs + 1 );
for k=1:nd
   start_dec(k) = ftell(fid)-4*irecl;
   for l = 1:nf
      if idec > k  
      %   done with decimation level k ...
         break
      else
         startFreqs(idec,ifreq) = ftell(fid)-4*irecl; 
         status = fseek(fid,nskip,'cof');
         if status < 0
             break
         end
         [head,count] = fread(fid,irecl,'long');
         if count==0 
             break
         end
         idec = head(1); ifreq = head(2); nsegs = head(3); 
         nskip = 4*irecl*(nsegs + 1 );
      end   
   end
end

%  Make list of set numbers in file for each decimation level
iSets = cell(nd,1);
iskip = 4*(irecl-1);
nskip = 4*(2*irecl-3);

for id = 1:nd
   fseek(fid,start_dec(id),'bof');
   head = fread(fid,3,'long');
   nsets = head(3);
   isets = zeros(nsets,1);
   fseek(fid,nskip,'cof');
   for l=1:nsets
      isets(l) = fread(fid,1,'long');
      fseek(fid,iskip,'cof');
   end
   iSets{id} = isets;
end

FChead = struct('nd',nd,'nf',nf,'nch',nch,'file',cfile,'Endian',Endian,....
	'chid',chid,'orient',orient,'drs',drs,'stcor',stdec(1:2),...
	'decl',decl,'decs',decs,'start_dec',start_dec,...
	'startFreqs',startFreqs,'iSets',{iSets});

fclose(fid);
