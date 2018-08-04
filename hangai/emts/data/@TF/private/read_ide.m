function st = read_ide(fname)

fid =   fopen(fname,'r');
C = textscan(fid,'# SITE: %s FREQS: %d LAT: %f LONG: %f SOURCE: %s'); 
sname = C{1};
np = C{2};
gps.lat = C{3};
gps.lon = C{4};
tmp = fgetl(fid);
tmp = fgetl(fid);
data = fscanf(fid,'%f %f %f %f %f %f %f %f',[8,np]);
data = data';
fclose(fid);


st          =   MT_tf;
st.name     =   sname;
st.loc.name =   sname;
st.ref.name =   sname;
st.loc.nch  =   1;
st.loc.chname=  {'Hz'};
st.loc.chid =  [3];
st.loc.orient=  [0];
st.loc.tilt =  [-90];
%         st.ref.name =  sname;
st.data.nper=  np;
Z.xx = data(:,3)-i*data(:,4); Z.xx_se = (data(:,5)).^2; Z.xy = data(:,6)-i*data(:,7);  Z.xy_se = (data(:,8)).^2;
st.data.tf(1,1,:)   = Z.xx;   st.data.tf(1,2,:)  = Z.xy;
st.data.tf_se(1,1,:)  = Z.xx_se;   st.data.tf_se(1,2,:)  = Z.xy_se;
sig1122 = 1;
sigs(1,1,:) = ones(size(Z.xy_se)); ones(size(Z.xy_se));
sige        = zeros(1,1,st.data.nper);
sige(1,1,:) = Z.xy_se;
st.data.sigs = sigs;
st.data.sige = sige;
usez = 1:np;
st.data.use{1} = usez;



st.data.periods     = 1./data(:,1)';
st.ref.nch   =   2;
st.ref.chname=  {'Hx' 'Hy'};
st.ref.chid  =  [1 2];
st.ref.orient= [0 90];
st.ref.tilt  =  [0 0];
st.loc.lon  =   gps.lon;
st.loc.lat  =   gps.lat;
st.loc.alt  =   0;
st.ref.lon  =   gps.lon;
st.ref.lat  =   gps.lat;
st.ref.alt  =   0;

