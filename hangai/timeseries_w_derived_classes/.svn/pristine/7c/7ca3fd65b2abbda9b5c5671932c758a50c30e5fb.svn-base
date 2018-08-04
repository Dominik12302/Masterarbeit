function    []  =   write_edi(st,file,type)

if isempty(st.tf); 
    disp([' - Nothing to export for site ' st.locname]); 
    return    
else
    disp([' - Exporting site ' st.locname ' to ' file ' ...']); 
end

switch type
    case 'raw'
        tf      =   st.tf;
        tf_se   =   st.tf_se;
        periods =   st.periods;
        nper    =   st.nper;
        rot     =   0.0;
        use     =   1:nper;
%     case 'rot'
%         tf      =   st.rot.tf;
%         tf_se   =   st.rot.tf_se;
%         periods =   st.rot.periods;
%         nper    =   st.rot.nper;
%         rot     =   st.rot.angle*180/pi;
%         use     =   st.rot.use;
%     case 'rot+2Derrors'
%         tf      =   st.rot.tf;
%         tf_se   =   st.gad.tf_se;
%         periods =   st.rot.periods;
%         nper    =   st.rot.nper;
%         rot     =   st.rot.angle*180/pi;
%         use     =   st.rot.use;
%     case 'udist'
%         tf      =   st.gad.tf;
%         tf_se   =   st.gad.tf_se;
%         periods =   st.gad.periods;
%         nper    =   st.gad.nper;
%         rot     =   st.gad.angle*180/pi;
%         use     =   st.gad.use;
% end
end

loc.chname     =   st.lchname;
loc.chid       =   st.lchid;
index = []; indey = []; indbx = []; indby = []; indbz = [];
if any(strcmp(loc.chname,'Ex')) ,  index   =   find(strcmp(loc.chname,'Ex')); end
if any(strcmp(loc.chname,'Ey')) ,  indey   =   find(strcmp(loc.chname,'Ey')); end
if any(strcmp(loc.chname,'Hx'))     ,  indbx   =   find(strcmp(loc.chname,'Hx'));
elseif any(strcmp(loc.chname,'Bx')) ,  indbx   =   find(strcmp(loc.chname,'Bx'));
end
if any(strcmp(loc.chname,'Hy'))     ,  indby   =   find(strcmp(loc.chname,'Hy'));
elseif any(strcmp(loc.chname,'By')) ,  indby   =   find(strcmp(loc.chname,'By'));
end
if any(strcmp(loc.chname,'Hz'))     ,  indbz   =   find(strcmp(loc.chname,'Hz'));
elseif any(strcmp(loc.chname,'Bz')) ,  indbz   =   find(strcmp(loc.chname,'Bz'));
end
useex = [];
if ~isempty(index)
    chidx    = loc.chid(index)-2;
    useex    = use;
end
useey = [];
if ~isempty(indey)
    chidy    = loc.chid(indey)-2;
    useey    = use;
end
usebx = [];
if ~isempty(indbx)
    chidx    = loc.chid(indbx)-2;
    usebx    = use;
end
useby = [];
if ~isempty(indby)
    chidy    = loc.chid(indby)-2;
    useby    = use;
end
usebz = [];
if ~isempty(indbz)
    chidz    = loc.chid(indbz)-2;
    usebz    = use;
end
use = sort([useex useey usebx useby usebz]);
usexyz(1) = use(1);
for iuse = 1:length(use)
    if use(iuse)>usexyz(end)
        usexyz = [usexyz use(iuse)];
    end
end
% useex = usexyz; useey = usexyz; usebz = usexyz;

%fname    =   strcat('s',(num2str(s,'%02d')),'.zss');
fid      =   fopen(file,'w');

fprintf(fid,'>HEAD\n\n');
fprintf(fid,'DATAID=%s\n',st.locname);
fprintf(fid,'ACQBY=tf_mt\n');
fprintf(fid,'FILEBY=tf_mt\n');
fprintf(fid,'ACQDATE=01/01/04\n');
fprintf(fid,'FILEDATE=01/01/04\n');
fprintf(fid,'PROSPECT=OLD\n');
fprintf(fid,'LOC=%s\n',st.locname);
loc.lat = st.lat;
loc.lon = st.lon;
loc.alt = 0;
lat.deg =   fix(loc.lat); lat.min =   fix((loc.lat-lat.deg)*60);
lat.sec =   ((loc.lat-lat.deg-lat.min/60)*3600);
lon.deg =   fix(loc.lon); lon.min =   fix((loc.lon-lon.deg)*60);
lon.sec =   ((loc.lon-lon.deg-lon.min/60)*3600);
lat.min = abs(lat.min); lat.sec = abs(lat.sec); 
lon.min = abs(lon.min); lon.sec = abs(lon.sec); 
if sign(loc.lat)<0
    fprintf(fid,'LAT=-%02d:%02d:%05.2f\n',abs(lat.deg),lat.min,lat.sec);
else
fprintf(fid,'LAT=%+02d:%02d:%05.2f\n',lat.deg,lat.min,lat.sec);
end
if sign(loc.lon)<0
    fprintf(fid,'LONG=-%03d:%02d:%05.2f\n',abs(lon.deg),lon.min,lon.sec);
else
fprintf(fid,'LONG=%+03d:%02d:%05.2f\n',lon.deg,lon.min,lon.sec);
end
fprintf(fid,'ELEV=%.2f\n',0);
fprintf(fid,'STDVERS=1.0\n');
fprintf(fid,'PROGVERS=1.0\n');
fprintf(fid,'PROGDATE=01/01/04\n');
fprintf(fid,'MAXSCT=1\n');
fprintf(fid,'EMPTY=1.0E32\n\n');

fprintf(fid,'>INFO MAXINFO 5000\n\n');
fprintf(fid,'empty\n\n');

fprintf(fid,'>=DEFINEMEAS\n\n');

fprintf(fid,' MAXCHAN=7\n');
fprintf(fid,' MAXRUN=99\n');
fprintf(fid,' MAXMEAS=9999\n');
fprintf(fid,' UNITS=M\n');
if sign(loc.lat)<0
    fprintf(fid,'REFLAT=-%02d:%02d:%05.2f\n',abs(lat.deg),lat.min,lat.sec);
else
fprintf(fid,'REFLAT=%+02d:%02d:%05.2f\n',lat.deg,lat.min,lat.sec);
end
if sign(loc.lon)<0
    fprintf(fid,'REFLONG=-%03d:%02d:%05.2f\n',abs(lon.deg),lon.min,lon.sec);
else
fprintf(fid,'REFLONG=%+03d:%02d:%05.2f\n',lon.deg,lon.min,lon.sec);
end
fprintf(fid,'REFELEV=%.2f\n',loc.alt);

fprintf(fid,'>HMEAS ID= 11.001 CHTYPE=HX X= 0 Y= 0 AZM= 0.\n');
fprintf(fid,'>HMEAS ID= 12.001 CHTYPE=HY X= 0 Y= 0 AZM= 90.\n');
fprintf(fid,'>HMEAS ID= 13.001 CHTYPE=HZ X= 0 Y= 0 AZM= 0.\n');
fprintf(fid,'>EMEAS ID= 14.001 CHTYPE=EX X= 0 Y= 0 X2= 0 Y2= 0\n');
fprintf(fid,'>EMEAS ID= 15.001 CHTYPE=EY X= 0 Y= 0 X2= 0 Y2= 0\n\n');

fprintf(fid,'>=MTSECT\n\n');
fprintf(fid,'SECTID=%s\n',st.locname);
fprintf(fid,'NFREQ=%d\n\n',nper);

fprintf(fid,'HX= 11.001\n');
fprintf(fid,'HY= 12.001\n');
fprintf(fid,'HZ= 13.001\n');
fprintf(fid,'EX= 14.001\n');
fprintf(fid,'EY= 15.001\n\n');

% write frequencies
fprintf(fid,'>FREQ NFREQ=%d ORDER=DEC // %d\n ',nper,nper);
for p   =   1:nper
    fprintf(fid,'%.5e ',1./periods(p));
    if floor(p/5)==p/5
        fprintf(fid,'\n ');
    end
end
fprintf(fid,'\n');


%------------------------------------------------------------------
%   write ZxxR
if ~isempty(index)
%     chid   = loc.chid(index)-2;
    fprintf(fid,'>ZXXR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(useex==p)
            fprintf(fid,'%.5e ',real(tf(chidx,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write ZxxI
    fprintf(fid,'>ZXXI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(useex==p)
            fprintf(fid,'%.5e ',imag(tf(chidx,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write Zxx.VAR
    fprintf(fid,'>ZXX.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidx,1,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %------------------------------------------------------------------
    %   write ZxyR
    fprintf(fid,'>ZXYR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(useex==p)
            fprintf(fid,'%.5e ',real(tf(chidx,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write ZxyI
    fprintf(fid,'>ZXYI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(useex==p)
            fprintf(fid,'%.5e ',imag(tf(chidx,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write Zxy.VAR
    fprintf(fid,'>ZXY.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidx,2,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end
%------------------------------------------------------------------
%   write ZyxR
if ~isempty(indey)
%     chid   = loc.chid(indey)-2;
    fprintf(fid,'>ZYXR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(useey==p)
            fprintf(fid,'%.5e ',real(tf(chidy,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write ZxxI
    fprintf(fid,'>ZYXI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(useey==p)
            fprintf(fid,'%.5e ',imag(tf(chidy,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write Zxx.VAR
    fprintf(fid,'>ZYX.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidy,1,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %------------------------------------------------------------------
    %   write ZyyR
    fprintf(fid,'>ZYYR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(useey==p)
            fprintf(fid,'%.5e ',real(tf(chidy,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write ZxyI
    fprintf(fid,'>ZYYI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(useey==p)
            fprintf(fid,'%.5e ',imag(tf(chidy,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write Zxy.VAR
    fprintf(fid,'>ZYY.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidy,2,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end
%------------------------------------------------------------------
%   write TxR
if ~isempty(indbz)
%     chidz   = loc.chid(indbz)-2;
    fprintf(fid,'>TXR.EXP ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(usebz==p)
            fprintf(fid,'%.5e ',real(tf(chidz,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write ZxxI
    fprintf(fid,'>TXI.EXP ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebz==p)
            fprintf(fid,'%.5e ',imag(tf(chidz,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write Zxx.VAR
    fprintf(fid,'>TXVAR.EXP ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidz,1,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end

%------------------------------------------------------------------
%   write TyR
if ~isempty(indbz)
%     chid   = loc.chid(indbz)-2;
    fprintf(fid,'>TYR.EXP ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebz==p)
            fprintf(fid,'%.5e ',real(tf(chidz,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write TyI
    fprintf(fid,'>TYI.EXP ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebz==p)
            fprintf(fid,'%.5e ',imag(tf(chidz,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write Ty.VAR
    fprintf(fid,'>TYVAR.EXP ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidz,2,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end

%------------------------------------------------------------------
%   write HMTxxR
if ~isempty(indbx)
%     chid   = loc.chid(index)-2;
    fprintf(fid,'>HMTXXR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebx==p)
            fprintf(fid,'%.5e ',real(tf(chidx,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxxI
    fprintf(fid,'>HMTXXI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebx==p)
            fprintf(fid,'%.5e ',imag(tf(chidx,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxx.VAR
    fprintf(fid,'>HMTXX.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidx,1,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %------------------------------------------------------------------
    %   write HMTxyR
    fprintf(fid,'>HMTXYR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebx==p)
            fprintf(fid,'%.5e ',real(tf(chidx,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxyI
    fprintf(fid,'>HMTXYI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(usebx==p)
            fprintf(fid,'%.5e ',imag(tf(chidx,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxy.VAR
    fprintf(fid,'>HMTXY.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidx,2,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end
%------------------------------------------------------------------
%   write HMTyxR
if ~isempty(indby)
%     chid   = loc.chid(indey)-2;
    fprintf(fid,'>HMTYXR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        if any(useby==p)
            fprintf(fid,'%.5e ',real(tf(chidy,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxxI
    fprintf(fid,'>HMTYXI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(useby==p)
            fprintf(fid,'%.5e ',imag(tf(chidy,1,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,1,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxx.VAR
    fprintf(fid,'>HMTYX.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidy,1,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %------------------------------------------------------------------
    %   write HMTyyR
    fprintf(fid,'>HMTYYR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(useby==p)
            fprintf(fid,'%.5e ',real(tf(chidy,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',real(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxyI
    fprintf(fid,'>HMTYYI ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
         if any(useby==p)
            fprintf(fid,'%.5e ',imag(tf(chidy,2,p)));
        else
            fprintf(fid,'%.5e ',1e32);
        end
%         fprintf(fid,'%.5e ',imag(tf(chid,2,p)));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');

    %   write HMTxy.VAR
    fprintf(fid,'>HMTYY.VAR ROT=%.1f // %d\n ',rot,nper);
    for p   =   1:nper
        fprintf(fid,'%.5e ',tf_se(chidy,2,p));
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end





fprintf(fid,'>END\n');

fclose(fid);

return