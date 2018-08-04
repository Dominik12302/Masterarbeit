function st = read_mtf(fname)

KEY =   [{'>FORMAT'} ;{'>NUMBER_PERIODS'};{'//SECTION=COMMENTS'};{'//SECTION=INFORMATION'};{'//SECTION=SYSTEM_RESPONSE'}; ...
    {'//SECTION=IMP'}; {'//SECTION=HTF'};{'//SECTION=TIP'}];

fid =   fopen(fname,'r');
iskey = zeros(size(KEY));
mtf_file  = fscanf(fid,'%s');
iskey = regexp(mtf_file,KEY);
% fclose(fid);
[PATHSTR,sname,EXT,VERSN] = fileparts(fname);
lname = sname(1:3);
sname = {sname};
fseek(fid,0,'bof');
if ~isempty(iskey{1})
    key = '>FORMAT';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    ind=strfind(line,':');
    format = {line(ind+1:end)};
end
fseek(fid,0,'bof');
if ~isempty(iskey{1})
    key = '>NUMBER_PERIODS';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    ind=strfind(line,':');
    np = str2num(line(ind+1:end));
end
fseek(fid,0,'bof');
if ~isempty(iskey{6})
    key = '//SECTION=IMP';
    df = 'imp';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    for ip = 1:np
    data(ip,:) = fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f',[1 14]);
    end
end
fseek(fid,0,'bof');
if ~isempty(iskey{7})
    key = '//SECTION=HTF';
    df = 'htf';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    for ip = 1:np
    data(ip,:) = fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f',[1 14]);
    end
end
fseek(fid,0,'bof');
if ~isempty(iskey{8})
    key = '//SECTION=TIP';
    df = 'tip';
    while isempty(strfind(fgetl(fid),key)) ,    lpos    =   ftell(fid); end     % search x-identifier
    fseek(fid,lpos,'bof'); line        =   fgetl(fid);                          % rewind file pointer by one line
    for ip = 1:np
    data(ip,:) = fscanf(fid,'%f %f %f %f %f %f %f %f',[1 8]);
    end
end
fclose(fid);
st          =   MT_tf;
st.name     =   sname;
st.loc.name =   {lname};
st.ref.name =   {lname};
switch df
    case 'imp'
        st.loc.nch  =   2;
        st.loc.chname=  {'Ex' 'Ey'};
        st.loc.chid =  [3 4];
        st.loc.orient=  [0 90];
        st.loc.tilt =  [0 0];
%         st.ref.name =  sname;
        st.data.nper=  np;
        Z.xx = data(:,3)+i*data(:,4); Z.xx_se = data(:,5); Z.xy = data(:,6)+i*data(:,7);  Z.xy_se = data(:,8);
        Z.yx = data(:,9)+i*data(:,10);Z.yx_se = data(:,11); Z.yy = data(:,12)+i*data(:,13);Z.yy_se = data(:,14);
        st.data.tf(1,1,:)   = Z.xx;   st.data.tf(1,2,:)  = Z.xy;
        st.data.tf(2,1,:)   = Z.yx;   st.data.tf(2,2,:)  = Z.yy;
        st.data.tf_se(1,1,:)  = Z.xx_se;   st.data.tf_se(1,2,:)  = Z.xy_se;
        st.data.tf_se(2,1,:)  = Z.yx_se;   st.data.tf_se(2,2,:)  = Z.yy_se;
        sig1122 = 1;
        sigs(1,1,:) = ones(size(Z.xy_se)); sigs(2,2,:)=ones(size(Z.xy_se));
        sige        = zeros(2,2,st.data.nper);
        sige(1,1,:) = Z.xy_se;
        sige(2,2,:) = Z.yx_se;
        st.data.sigs = sigs;
        st.data.sige = sige;
        usex = 1:np;usey = 1:np;
        st.data.use{1} = usex;
        st.data.use{2} = usey;
    case 'htf'
        st.loc.nch  =   2;
        st.loc.chname=  {'Hx' 'Hy'};
        st.loc.chid =  [3 4];
        st.loc.orient=  [0 90];
        st.loc.tilt =  [0 0];
%         st.ref.name =  sname;
        st.data.nper=  np;
        Z.xx = data(:,3)-i*data(:,4); Z.xx_se = (data(:,5)).^2; Z.xy = data(:,6)-i*data(:,7);  Z.xy_se = (data(:,8)).^2;
        Z.yx = data(:,9)-i*data(:,10);Z.yx_se = (data(:,11)).^2; Z.yy = data(:,12)-i*data(:,13);Z.yy_se = (data(:,14)).^2;
        st.data.tf(1,1,:)   = Z.xx;   st.data.tf(1,2,:)  = Z.xy;
        st.data.tf(2,1,:)   = Z.yx;   st.data.tf(2,2,:)  = Z.yy;
        st.data.tf_se(1,1,:)  = Z.xx_se;   st.data.tf_se(1,2,:)  = Z.xy_se;
        st.data.tf_se(2,1,:)  = Z.yx_se;   st.data.tf_se(2,2,:)  = Z.yy_se;
        sig1122 = 1;
        sigs(1,1,:) = ones(size(Z.xy_se)); sigs(2,2,:)=ones(size(Z.xy_se));
        sige        = zeros(2,2,st.data.nper);
        sige(1,1,:) = Z.xy_se;
        sige(2,2,:) = Z.yx_se;
        st.data.sigs = sigs;
        st.data.sige = sige;
        usex = 1:np;usey = 1:np;
        st.data.use{1} = usex;
        st.data.use{2} = usey;
        case 'tip'
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

end

st.data.periods     = data(:,1)';
st.ref.nch   =   2;
st.ref.chname=  {'Hx' 'Hy'};
st.ref.chid  =  [1 2];
st.ref.orient= [0 90];
st.ref.tilt  =  [0 0];

return