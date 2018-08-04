%   read egbert zxx file

function [st]   =   read_zxx(fname)
[path,name,ext,v] = fileparts(fname);
st  =   MT_tf;
st.name =   {name};
fid = fopen(fname,'r');
% skip text on first four lines
cline = fgets(fid); cline = fgets(fid); cline = fgets(fid); cline = fgets(fid);
cline = fgets(fid); stdec = sscanf(cline,'coordinate %f %f declination %f');
cline = fgets(fid); nchnbt = sscanf(cline,'number of channels %d number of frequencies %d');
st.loc.dec      =   stdec(3);
st.ref.dec      =   stdec(3);
st.loc.nch      =   nchnbt(1)-2;
st.data.nper    =   nchnbt(2);

st.ref.nch      =   2;
st.data.nper    =   nchnbt(2);
cline = fgets(fid);
for k=1:nchnbt(1)
   idum(k)  = fscanf(fid,'%d',1);
   orient(1:2,k) = fscanf(fid,'%f',2);
   csta{k}  = fscanf(fid,'%s',1);
   chid{k}  = fscanf(fid,'%s',1);
   cline    = fgets(fid);
end
%   first 2 channels are predicting channels
%    collect site names
if strcmp(csta{1},csta{2}), st.ref.name     =   csta(1);
else st.ref.name     =   csta(1:2); end % hope this will never be the case ...
if isempty(find(~strcmp(csta(3:end),csta{3}))), st.loc.name = csta(3);
%else st.loc.name = csta(3:end); end
else st.loc.name = csta(end); end % assuming last channel to be at local site; 
% skipping all predicted channels, that are not the local site
uselocch = find(strcmp(csta(3:end),st.loc.name{1}));
uselocchnot = find(strcmp(csta(3:end),st.ref.name{1}));
% for nims only
if strcmp(st.loc.name,'pkd')
    st.loc.name = {st.name{1}(4:6)};
    st.ref.name = {st.name{1}(4:6)};
end

st.loc.lon      =   stdec(2)*[1:length(st.loc.name)]';
if st.loc.lon > 180, st.loc.lon = st.loc.lon-360; end
st.loc.lat      =   stdec(1)*[1:length(st.loc.name)]';
if strcmp(st.loc.name{1},st.ref.name{1})
    st.ref.lon      =   stdec(2)*[1:length(st.loc.name)]';
    if st.ref.lon > 180, st.ref.lon = st.ref.lon-360; end
    st.ref.lat      =   stdec(1)*[1:length(st.loc.name)]';
else
    st.ref.lon      =   0*[1:length(st.loc.name)]';
    st.ref.lat      =   0*[1:length(st.loc.name)]';
end
% st.loc.chname =   chid(3:end);
% st.loc.chid   =   idum(3:end);
% st.loc.orient =   orient(1,3:end);
% st.loc.tilt   =   orient(2,3:end);
% st.ref.chname =   chid(1:2);
% st.ref.chid   =   idum(1:2);
% st.ref.orient =   orient(1,1:2);
% st.ref.tilt   =   orient(2,1:2);
st.loc.chname =   chid(uselocch+2);
st.loc.chid   =   idum(uselocch+2);
st.loc.chid   =   st.loc.chid-st.loc.chid(1)+3;
st.loc.orient =   orient(1,uselocch+2);
st.loc.tilt   =   orient(2,uselocch+2);
st.ref.chname =   chid(1:2);
st.ref.chid   =   idum(1:2);
st.ref.orient =   orient(1,1:2);
st.ref.tilt   =   orient(2,1:2);
cline = fgets(fid);

nch = nchnbt(1); nche = nch-2; nbt = nchnbt(2);
z = zeros(2,nche*nbt) + i*zeros(2,nche*nbt);
sig_e = zeros(nche,nche*nbt) + i*zeros(nche,nche*nbt);
sig_s = zeros(2,2*nbt) + i*zeros(2,2*nbt);
ndf = zeros(nbt,1);
for ib = 1:nbt
    cline = fgets(fid);
    periods(ib) = sscanf(cline,'period : %f');
    cline = fgets(fid);
    ndf(ib) = sscanf(cline,'number of data point %d');
    k1 = nche*(ib-1) + 1;
    k2 = nche*ib;
    cline = fgets(fid);
    ztemp = fscanf(fid,'%e',[4,nche]);
    z(1:2,k1:k2) = ztemp(1:2:3,:)+i*ztemp(2:2:4,:);
    chead = fgets(fid);
    chead = fgets(fid);
    stemp = fscanf(fid,'%e',[2,3]);
    ncht = 2;
    for k = 1:ncht
        for l = 1:ncht
            if(l < k ) 
                kl = (k*(k-1))/2+l;
                sig_s(k,2*(ib-1)+l) = stemp(1,kl)+i*stemp(2,kl);
            else
                kl = (l*(l-1))/2+k;
                sig_s(k,2*(ib-1)+l) = stemp(1,kl)-i*stemp(2,kl);
            end
        end
    end
    chead = fgets(fid);
    chead = fgets(fid);
    nse = (nche*(nche+1))/2;
    stemp = fscanf(fid,'%e',[2,nse]);
    if ~isempty(stemp)
    for k = 1:nche
        for l = 1:nche
            if(l < k ) 
                kl = (k*(k-1))/2+l;
                sig_e(k,nche*(ib-1)+l) = stemp(1,kl)+i*stemp(2,kl);
            else
                kl = (l*(l-1))/2+k;
                sig_e(k,nche*(ib-1)+l) = stemp(1,kl)-i*stemp(2,kl);
            end
        end
    end
    end
    cline = fgets(fid);
end  
Znm    =   []; Sig_E    =   [];
for  k = 1:st.loc.nch
    for l = 1:st.ref.nch
        Znm(k,l,:)     =   z(l,k:st.loc.nch:st.loc.nch*st.data.nper-st.loc.nch+k);
    end
    for l = 1:st.loc.nch
        Sig_E(k,l,:)   =   sig_e(l,k:st.loc.nch:st.loc.nch*st.data.nper-st.loc.nch+k);
    end
end
Sig_S    =   [];
for  k = 1:st.ref.nch
    for  l = 1:st.ref.nch
        Sig_S(k,l,:)   =   sig_s(l,k:st.ref.nch:st.ref.nch*st.data.nper-st.ref.nch+k);
    end
end
st.data.tf      =   Znm(uselocch,:,:);
st.data.periods =   periods;
st.data.sigs    =   Sig_S;
st.data.sige    =   Sig_E(uselocch,uselocch,:);
for ip = 1:st.data.nper
    Nii =   diag(st.data.sige(:,:,ip)); Sii = diag(st.data.sigs(:,:,ip));
    st.data.tf_se(:,:,ip) =   kron(Nii,Sii');
end
for k = 1:st.loc.nch
st.data.use{k} = 1:st.data.nper;
st.loc.nch = length(uselocch);
end
return