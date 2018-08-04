function [] = plotEDI(edipath,sname,varargin)
for is = 1:numel(varargin)/2
    st(is) = read_edi(fullfile(edipath,varargin{2*is-1}));
    
end
stm = st(1);
stm.data.periods = [];
stm.data.tf      = [];
stm.data.tf_se = [];
stm.data.sigs = [];
stm.data.sige = [];
stm.data.use = {};

for is = 1:numel(st)
    perrange = varargin{2*is};
    periods  = st(is).data.periods;
    ind = find(periods>=min(perrange) & periods <= max(perrange));
    stm.data.periods = [stm.data.periods st(is).data.periods(ind)];
    stm.data.tf    = cat(3,stm.data.tf, st(is).data.tf(:,:,ind));
    stm.data.tf_se = cat(3,stm.data.tf_se, st(is).data.tf_se(:,:,ind));
    stm.data.sigs  = cat(3,stm.data.sigs, st(is).data.sigs(:,:,ind));
    stm.data.sige  = cat(3,stm.data.sige, st(is).data.sige(:,:,ind));
end
stm.data.nper = numel(stm.data.periods);
for ilch = 1:(stm.loc.nch)
    stm.data.use(ilch) = {1:stm.data.nper};
end

ztf.locname = sname;
ztf.lnch    = stm.loc.nch;
ztf.lchname = stm.loc.chname;
ztf.lchid   = stm.loc.chid;
ztf.bname  =  sname;
ztf.bnch    = stm.ref.nch;
ztf.bchname = stm.ref.chname;
ztf.bchid   = stm.ref.chid;
% if irs, ztf.rname = snames(rbs); end
ztf.nper = stm.data.nper;
ztf.periods = stm.data.periods';
ztf.tf   = -(stm.data.tf);
ztf.tf_se = stm.data.tf_se;
ztf.lon  = 0;
ztf.lat = 0;

%write_edi(ztf,fullfile(edipath,[sname '.edi']),'raw');
sp_plottf(ztf,sname);
%set(gcf,'Paperpositionmode','auto');
%print(gcf,'-depsc',fullfile(edipath,[sname '.eps']));
end

function st = read_edi(fname)

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
Zxxr = -Zxxr; Zxxi = -Zxxi;
Zxyr = -Zxyr; Zxyi = -Zxyi;
Zyxr = -Zyxr; Zyxi = -Zyxi;
Zyyr = -Zyyr; Zyyi = -Zyyi;
if ~isempty(iskey{4})
    Z.xx =   Zxxr+i*Zxxi;
    Z.xy =   Zxyr+i*Zxyi;
    Z.yx =   Zyxr+i*Zyxi;
    Z.yy =   Zyyr+i*Zyyi;
else
    Z.xx = zeros(length(f)); Z.xx_se = zeros(length(f));
    Z.xx = zeros(length(f)); Z.xy_se = zeros(length(f));
    Z.yx = zeros(length(f)); Z.yx_se = zeros(length(f));
    Z.yy = zeros(length(f)); Z.yy_se = zeros(length(f));
end

if ~isempty(iskey{16})
    T.x  =   Txr+i*Txi;  T.x_se = zeros(length(f),1)'+0.001;
    T.y  =   Tyr+i*Tyi;   T.y_se = zeros(length(f),1)'+0.001;
else
    T.x = zeros(length(f),1)'; T.x_se = zeros(length(f),1)'+0.001;
    T.y = zeros(length(f),1)'; T.y_se = zeros(length(f),1)'+0.001;
end

if isempty(iskey{18})
    T.x_se = zeros(length(f),1)'+0.001;
    T.y_se = zeros(length(f),1)'+0.001;
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
% st          =   MT_tf;
st.name     =   sname;
st.loc.name =   sname;
st.loc.nch  =   length(chmap);
st.loc.chname=  chmap;
st.loc.chid =   chid;
st.loc.orient =  orient;
st.loc.tilt =  tilt;
st.loc.lon  =   gps.lon;
st.loc.lat  =   gps.lat;
st.loc.alt  =   gps.elev;
st.ref.name =   sname;
st.ref.lon  =   gps.lon;
st.ref.lat  =   gps.lat;
st.ref.alt  =   gps.elev;
st.ref.nch  =   2;
st.ref.chname=  {'Hx' 'Hy'};
st.ref.chid =  [1 2];
st.ref.orient= [0 90];
st.ref.tilt =  [0 0];
st.data.nper=  length(f);
st.data.periods     = 1./f;
chid = find(strcmp(chmap,'Hz'));
if ~isempty(chid)
st.data.tf(chid,1,:)   = T.x;   st.data.tf(chid,2,:)  = T.y;
st.data.tf_se(1,1,:)  = T.x_se;    st.data.tf_se(1,2,:)  = T.y_se;
end
chid = find(strcmp(chmap,'Ex'));
if ~isempty(chid)
st.data.tf(2,1,:)   = Z.xx;   st.data.tf(2,2,:)  = Z.xy;
st.data.tf_se(2,1,:)  = Z.xx_se;   st.data.tf_se(2,2,:)  = Z.xy_se;
end
chid = find(strcmp(chmap,'Ey'));
if ~isempty(chid)
st.data.tf(3,1,:)   = Z.yx;   st.data.tf(3,2,:)  = Z.yy;
st.data.tf_se(3,1,:)  = Z.yx_se;   st.data.tf_se(3,2,:)  = Z.yy_se;
end
% s1122 = (T.x_se./T.y_se + Z.xx_se./Z.xy_se + Z.yx_se./Z.yy_se)/3;
% sigs = zeros(2,2,st.data.nper);
sig1122 = 1;
if isfield(T,'x')
    sigs(1,1,:) = T.x_se; sigs(2,2,:) = T.y_se;
else
    sigs(1,1,:) = 0.01;sigs(2,2,:) = 0.01;
    T.x_se = 0.01; T.y_se = 0.01;
end
sige        = zeros(length(chmap),length(chmap),st.data.nper);
sige(1,1,:) = 1;
if isfield(Z,'xy')
T.y_se(T.y_se==0)=0.001;
T.x_se(T.x_se==0)=0.001;
sige(2,2,:) = Z.xy_se./T.y_se;
sige(3,3,:) = Z.yx_se./T.x_se;
end
st.data.sigs = sigs;
st.data.sige = sige;
if isfield(T,'x')
st.data.use{1} = usez;
end
if isfield(Z,'xy')
st.data.use{2} = usex;
st.data.use{3} = usey;
end
if lzrot | ltrot    %   assume the same rot angle for all
    st.rot.angle = zrot(1)*pi/180;;
    st.rot.nper = st.data.nper;
    st.rot.periods = st.data.periods;
    st.rot.use = st.data.use;
    st.rot.tf = tfr;
    st.rot.tf_se = tfr_se;
end
end

function    []  =   write_edi(st,file,type)

disp([' - Exporting site ' st.locname ' to ' file ' ...']); 
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
index = []; indey = []; indbz = [];
if any(strcmp(loc.chname,'Ex')) ,  index   =   find(strcmp(loc.chname,'Ex')); end
if any(strcmp(loc.chname,'Ey')) ,  indey   =   find(strcmp(loc.chname,'Ey')); end
if any(strcmp(loc.chname,'Hz'))     ,  indbz   =   find(strcmp(loc.chname,'Hz'));
elseif any(strcmp(loc.chname,'Bz')) ,  indbz   =   find(strcmp(loc.chname,'Bz'));
end
usex = [];
if ~isempty(index)
    chidx    = loc.chid(index)-2;
    usex    = use;
end
usey = [];
if ~isempty(indey)
    chidy    = loc.chid(indey)-2;
    usey    = use;
end
usez = [];
if ~isempty(indbz)
    chidz    = loc.chid(indbz)-2;
    usez    = use;
end
use = sort([usex usey usez]);
usexyz(1) = use(1);
for iuse = 1:length(use)
    if use(iuse)>usexyz(end)
        usexyz = [usexyz use(iuse)];
    end
end
% usex = usexyz; usey = usexyz; usez = usexyz;

%fname    =   strcat('s',(num2str(s,'%02d')),'.zss');
fid      =   fopen(file,'w+');

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
        if any(usex==p)
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
        if any(usex==p)
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
        if any(usex==p)
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
        if any(usex==p)
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
        if any(usey==p)
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
         if any(usey==p)
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
         if any(usey==p)
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
         if any(usey==p)
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
         if any(usez==p)
            fprintf(fid,'%.5e ',-real(tf(chidz,1,p))); %negative sign; mjc 08.31.2016
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
        if any(usez==p)
            fprintf(fid,'%.5e ',-imag(tf(chidz,1,p))); %negative sign; mjc 08.31.2016
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
        fprintf(fid,'%.5e ',tf_se(chidz,1,p)); % why 10^-3 ?; mjc 08.31.2016
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
        if any(usez==p)
            fprintf(fid,'%.5e ',-real(tf(chidz,2,p))); %negative sign; mjc 08.31.2016
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
        if any(usez==p)
            fprintf(fid,'%.5e ',-imag(tf(chidz,2,p))); %negative sign; mjc 08.31.2016
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
        fprintf(fid,'%.5e ',tf_se(chidz,2,p)); % why 10^-3 ? mjc 08.31.2016
        if floor(p/5)==p/5
            fprintf(fid,'\n ');
        end
    end
    fprintf(fid,'\n');
end
%------------------------------------------------------------------
fprintf(fid,'>END\n');

fclose(fid);

end