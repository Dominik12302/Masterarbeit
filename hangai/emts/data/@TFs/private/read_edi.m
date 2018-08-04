function obj = read_edi(obj,fname)

T = []; Z = [];
fid =   fopen(fname,'r');
KEY =   [{'REFLAT'} ;{'REFLON'}  ;{'>FREQ'}   ; ...
         {'>ZXXR'};{'>ZXXI'};{'>ZXX.VAR'}; ...
         {'>ZXYR'};{'>ZXYI'};{'>ZXY.VAR'}; ...
    {'>ZYXR'};{'>ZYXI'};{'>ZYX.VAR'}; ...
    {'>ZYYR'};{'>ZYYI'};{'>ZYY.VAR'}; ...
    {'>TXR'} ;{'>TXI'} ;{'>TXVAR'}  ; ...
    {'>TYR'} ;{'>TYI'} ;{'>TYVAR'}  ; ...
    {'>RHOXY'}; {'>RHOYX'};  ...
    {'>PHSXY'}; {'>PHSYX'};
    {'>RHOXY.FIT'}; {'>RHOYX.FIT'};  ...
    {'>PHSXY.FIT'}; {'>PHSYX.FIT'}; ...
    {'>ZROT'}; {'>TROT'}; {'>RHOROT'};{'REFELEV'}];

%   search for Keywords in file
gps.elev = 0;
iskey = zeros(size(KEY));
edi_file = fscanf(fid,'%s');
iskey = regexp(edi_file,KEY);
fseek(fid,0,'bof');
if ~isempty(iskey{1})
    key =   'REFLAT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);% rewind file pointer by one line
    if ~isempty(strfind(line,':'))
    ind=sort([strfind(line,'=')  strfind(line,':')]);
    deg=abs(str2num(line(ind(1)+1:ind(2)-1)));
    if ~isempty(strfind(line(ind(1)+1:end),'-')), signdeg = -1; else signdeg = 1; end
    min=signdeg*str2num(line(ind(2)+1:ind(3)-1));
    sec=signdeg*str2num(line(ind(3)+1:end));
    gps.lat =   signdeg*deg+min/60+sec/3600;
    else
        ind=strfind(line,'=');
        gps.lat=str2num(line(ind(1)+1:end));
    end 
    fseek(fid,0,'bof');
end

if ~isempty(iskey{2})
    key =   'REFLON';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    if ~isempty(strfind(line,':'))
    ind=sort([strfind(line,'=')  strfind(line,':')]);
    deg=abs(str2num(line(ind(1)+1:ind(2)-1)));
    if ~isempty(strfind(line(ind(1)+1:end),'-')), signdeg = -1; else signdeg = 1; end
    min=signdeg*str2num(line(ind(2)+1:ind(3)-1));
    sec=signdeg*str2num(line(ind(3)+1:end));
    gps.lon =   signdeg*deg+min/60+sec/3600;
    else
        ind=strfind(line,'=');
        gps.lon=str2num(line(ind(1)+1:end));
    end 
    fseek(fid,0,'bof');
end

if ~isempty(iskey{3})
    key =   '>FREQ';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    f   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{4})
    key =   '>ZXXR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zxxr   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{5})
    key =   '>ZXXI';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zxxi   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{7})
    key =   '>ZXYR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zxyr   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{8})
    key =   '>ZXYI';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zxyi   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{10})
    key =   '>ZYXR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zyxr   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{11})
    key =   '>ZYXI';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zyxi   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{13})
    key =   '>ZYYR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zyyr   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{14})
    key =   '>ZYYI';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Zyyi   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{16})
    key =   '>TXR';
    while isempty(strfind(fgetl(fid),key)),    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Txr   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{17})
    key =   '>TXI';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Txi   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{19})
    key =   '>TYR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Tyr   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{20})
    key =   '>TYI';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Tyi   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{6})
    key =   '>ZXX.VAR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Z.xx_se   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{9})
    key =   '>ZXY.VAR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Z.xy_se   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{12})
    key =   '>ZYX.VAR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Z.yx_se   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{15})
    key =   '>ZYY.VAR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    Z.yy_se   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{18})
    key =   '>TXVAR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    T.x_se   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{21})
    key =   '>TYVAR';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    T.y_se   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{22})
    key =   '>RHOXY';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    rho.xy   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{23})
    key =   '>RHOYX';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    rho.yx   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{24})
    key =   '>PHSXY';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    phs.xy   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end
if ~isempty(iskey{25})
    key =   '>PHSYX';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    phs.yx   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{26})
    key =   '>RHOXY.FIT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    fit.rho.xy   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{27})
    key =   '>RHOYX.FIT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    fit.rho.yx   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end

if ~isempty(iskey{28})
    key =   '>PHSXY.FIT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    fit.phs.xy   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end
if ~isempty(iskey{29})
    key =   '>PHSYX.FIT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    fit.phs.yx   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end
if ~isempty(iskey{30})
    key =   '>ZROT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    zrot   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end
if ~isempty(iskey{31})
    key =   '>TROT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    trot   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end
if ~isempty(iskey{32})
    key =   '>RHOROT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    nfreq = str2num(line((strfind(line,'//')+2):end));
    fit.rot   =   fscanf(fid,'%f',[1 nfreq]);
    fseek(fid,0,'bof');
end
if ~isempty(iskey{33})
    key =   'REFELEV';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    ind=sort([strfind(line,'=')  strfind(line,':')]);
    gps.elev =   str2num(line(ind+1:end));
    fseek(fid,0,'bof');
end
fclose(fid);

if ~isempty(iskey{4})
    Z.xx =   -Zxxr-i*Zxxi;
    Z.xy =   -Zxyr-i*Zxyi;
    Z.yx =   -Zyxr-i*Zyxi;
    Z.yy =   -Zyyr-i*Zyyi;
else
    Z.xx = zeros(length(f)); Z.xx_se = zeros(length(f));
    Z.xx = zeros(length(f)); Z.xy_se = zeros(length(f));
    Z.yx = zeros(length(f)); Z.yx_se = zeros(length(f));
    Z.yy = zeros(length(f)); Z.yy_se = zeros(length(f));
end

if ~isempty(iskey{18})
    T.x  =   -Txr-i*Txi;
    T.y  =   -Tyr-i*Tyi;
else
    T.x = zeros(length(f),1)'; T.x_se = zeros(length(f),1)'+0.001;
    T.y = zeros(length(f),1)'; T.y_se = zeros(length(f),1)'+0.001;
end

if isempty(iskey{22})
    rho.xy = zeros(length(f),1)'; rho.yx = zeros(length(f),1)';
    phs.xy = zeros(length(f),1)'; phs.yx = zeros(length(f),1)';
end

if isempty(iskey{26})
    fit.rho.xy = zeros(length(f),1)'; fit.rho.yx = zeros(length(f),1)';
    fit.phs.xy = zeros(length(f),1)'; fit.phs.yx = zeros(length(f),1)';
end
if isempty(iskey{30})
    zrot = zeros(length(f),1)';
    lzrot   =   0;
else lzrot = 1;
end
if isempty(iskey{31})
    trot = zeros(length(f),1)';
    ltrot   =   0;
else ltrot = 1;
    trot = trot*0+zrot(1);
end
chmap = [];
orient = [];
chid = [];
tilt = [];
if isfield(T,'x')
    usez = find(T.x~=1e32*(1+i));% & T.x~=0*(1+i));
    T.x_se(find(T.x==1e32*(1+i))) = 1; T.y_se(find(T.y==1e32*(1+i))) = 1;
    if ltrot
        tfr(1,1,:) = T.x; tfr(1,2,:) = T.y;
        tfr_se(1,1,:) = T.x_se; tfr_se(1,2,:) = T.y_se;
        for ip = 1:length(f)
            TMP = [T.x(ip); T.y(ip)];
            phi =   trot(ip)*pi/180;
            R   = [cos(phi) sin(phi); -sin(phi) cos(phi)];
            BLA =   R'*TMP;
            T.x(ip) = BLA(1); T.y(ip) = BLA(2);
        end
    end
    chmap = [chmap {'Hz'}]; chid = [chid length(chid)+3]; orient = [orient 0]; tilt = [tilt -90];
end
if isfield(Z,'xy')
    usex = find(Z.xy~=1e32*(1+i));
    Z.xx_se(find(Z.xx==1e32*(1+i))) = 1; Z.xy_se(find(Z.xy==1e32*(1+i))) = 1;

    usey = find(Z.yx~=1e32*(1+i));
    Z.yy_se(find(Z.yy==1e32*(1+i))) = 1; Z.yx_se(find(Z.yx==1e32*(1+i))) = 1;
    chmap = [chmap {'Ex' 'Ey'}];  chid = [chid length(chid)+3]; chid = [chid length(chid)+3]; orient = [orient 0 90]; tilt = [tilt 0 0];
    tfr = zeros(3,2,length(f));
    tfr_se = zeros(3,2,length(f));
    if lzrot
        tfr(2,1,:) = Z.xx; tfr(2,2,:) = Z.xy;
        tfr(3,1,:) = Z.yx; tfr(3,2,:) = Z.yy;
        tfr_se(2,1,:) = Z.xx_se; tfr_se(2,2,:) = Z.xy_se;
        tfr_se(3,1,:) = Z.yx_se; tfr_se(3,2,:) = Z.yy_se;
        for ip = 1:length(f)
            TMP = [Z.xx(ip) Z.xy(ip); Z.yx(ip) Z.yy(ip)];
            phi =   zrot(ip)*pi/180;
            R   = [cos(phi) sin(phi); -sin(phi) cos(phi)];
            BLA =   R'*TMP*R;
            Z.xx(ip) = BLA(1,1); Z.xy(ip) = BLA(1,2); Z.yx(ip) = BLA(2,1); Z.yy(ip) = BLA(2,2);
        end
    end
end

[PATHSTR,sname,EXT] = fileparts(fname);
sname = {sname};
%st          =   MT_tf;
obj.sname     =   sname;
obj.lname   =   sname;
%st.loc.nch  =   length(chmap);
obj.output  =  chmap;
% st.loc.chid =   chid;
% st.loc.orient =  orient;
% st.loc.tilt =  tilt;
% st.loc.lon  =   gps.lon;
% st.loc.lat  =   gps.lat;
% st.loc.alt  =   gps.elev;
obj.bname   =   sname;
obj.llatlong =   [gps.lon gps.lat];
obj.blatlong  =   [gps.lon gps.lat];

obj.input   =  {'Hx' 'Hy'};
% st.ref.chid =  [1 2];
% st.ref.orient= [0 90];
% st.ref.tilt =  [0 0];
% st.data.nper=  length(f);
obj.f     = f;
chid = find(strcmp(chmap,'Hz'));
if ~isempty(chid)
obj.tf(chid,1,:)   = T.x;   obj.tf(chid,2,:)  = T.y;
obj.tfse(1,1,:)  = T.x_se;    obj.tfse(1,2,:)  = T.y_se;
end
chid = find(strcmp(chmap,'Ex'));
if ~isempty(chid)
obj.tf(2,1,:)   = Z.xx;   obj.tf(2,2,:)  = Z.xy;
obj.tfse(2,1,:)  = Z.xx_se;   obj.tfse(2,2,:)  = Z.xy_se;
end
chid = find(strcmp(chmap,'Ey'));
if ~isempty(chid)
obj.tf(3,1,:)   = Z.yx;   obj.tf(3,2,:)  = Z.yy;
obj.tfse(3,1,:)  = Z.yx_se;   obj.tfse(3,2,:)  = Z.yy_se;
end
% s1122 = (T.x_se./T.y_se + Z.xx_se./Z.xy_se + Z.yx_se./Z.yy_se)/3;
% sigs = zeros(2,2,st.data.nper);
% sig1122 = 1;
% if isfield(T,'x')
%     sigs(1,1,:) = T.x_se; sigs(2,2,:) = T.y_se;
% else
%     sigs(1,1,:) = 0.01;sigs(2,2,:) = 0.01;
%     T.x_se = 0.01; T.y_se = 0.01;
% end
% sige        = zeros(length(chmap),length(chmap),st.data.nper);
% sige(1,1,:) = 1;
% if isfield(Z,'xy')
% T.y_se(T.y_se==0)=0.001;
% T.x_se(T.x_se==0)=0.001;
% sige(2,2,:) = Z.xy_se./T.y_se;
% sige(3,3,:) = Z.yx_se./T.x_se;
% end
% st.data.sigs = sigs;
% st.data.sige = sige;
% if isfield(T,'x')
% st.data.use{1} = usez;
% end
% if isfield(Z,'xy')
% st.data.use{2} = usex;
% st.data.use{3} = usey;
% end
% if lzrot | ltrot    %   assume the same rot angle for all
%     st.rot.angle = zrot(1)*pi/180;;
%     st.rot.nper = st.data.nper;
%     st.rot.periods = st.data.periods;
%     st.rot.use = st.data.use;
%     st.rot.tf = tfr;
%     st.rot.tf_se = tfr_se;
% end
return