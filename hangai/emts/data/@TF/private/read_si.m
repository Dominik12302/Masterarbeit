
function obj = read_si(obj,fname)

indicator = 'SI';
clear block;
clear data;

dtxt = textread(fname,'%s','delimiter','\n', 'whitespace', '');
tmp =   strfind(dtxt,indicator);
index = [];
for k = 1:length(tmp)
    if ~isempty(tmp{k})
        index = [index k];
    end
end
tmp = dtxt(index);
for k = 1:length(tmp)
    data.f(k) = sscanf(tmp{k},'%f %*s %*s %*s %*s %*s %*s %*s');
end

for k = 1:length(index)-1
    data.block{k}   =   dtxt(index(k):index(k+1)-1);
end
data.block{k+1} =   dtxt(index(k+1):end);


periods = 1./data.f;
np      = length(periods);

for ip = 1:np
    [sname] = strread(data.block{ip}{1},'%*f %*f %s %*s %*s %*s %*s %*f');
    for iv = 2:length(data.block{ip})
        block(ip,iv-1,:) = sscanf(data.block{ip}{iv},'%f %f %f %f %f %f',[1 6]);
    end
end

Z.xx    = block(:,1,1)'+i*block(:,1,2)';
Z.xx_se = block(:,1,3)'/2;
Z.xy    = block(:,1,4)'+i*block(:,1,5)';
Z.xy_se = block(:,1,6)'/2;
Z.yx    = block(:,2,1)'+i*block(:,2,2)';
Z.yx_se = block(:,2,3)'/2;
Z.yy    = block(:,2,4)'+i*block(:,2,5)';
Z.yy_se = block(:,2,6)'/2;
T.x     = block(:,3,1)'+i*block(:,3,2)';
T.x_se  = block(:,3,3)'/2;
T.y     = block(:,3,4)'+i*block(:,3,5)';
T.y_se  = block(:,3,6)'/2;

T.x_se(T.x_se==0)=1;
T.y_se(T.y_se==0)=1;
T.x_se(isnan(T.x_se))=1;
T.y_se(isnan(T.y_se))=1;
Z.xy_se(Z.xy_se==0)=1;
Z.yx_se(Z.yx_se==0)=1;
Z.xy_se(isnan(Z.xy_se))=1;
Z.yx_se(isnan(Z.yx_se))=1;
Z.xx_se(Z.xx_se==0)=1;
Z.yy_se(Z.yy_se==0)=1;
Z.xx_se(isnan(Z.xx_se))=1;
Z.yy_se(isnan(Z.yy_se))=1;

[path,sname,ext]=fileparts(fname);
sname = {sname};
obj.sname     =   sname;
obj.lname   =   sname;
%st.loc.nch  =   length(chmap);
obj.output  =  {'Hz' 'Ex' 'Ey'};
% st.loc.chid =   chid;
% st.loc.orient =  orient;
% st.loc.tilt =  tilt;
% st.loc.lon  =   gps.lon;
% st.loc.lat  =   gps.lat;
% st.loc.alt  =   gps.elev;
obj.bname   =   sname;
obj.llatlong =   [0 0];
obj.blatlong  =   [0 0];

obj.input   =  {'Hx' 'Hy'};
% st.ref.chid =  [1 2];
% st.ref.orient= [0 90];
% st.ref.tilt =  [0 0];
% st.data.nper=  length(f);
obj.f     = data.f;
chid = find(strcmp(obj.output,'Hz'));
if ~isempty(chid)
obj.tf(chid,1,:)   = T.x;   obj.tf(chid,2,:)  = T.y;
obj.tfse(1,1,:)  = T.x_se;    obj.tfse(1,2,:)  = T.y_se;
end
chid = find(strcmp(obj.output,'Ex'));
if ~isempty(chid)
obj.tf(2,1,:)   = Z.xx;   obj.tf(2,2,:)  = Z.xy;
obj.tfse(2,1,:)  = Z.xx_se;   obj.tfse(2,2,:)  = Z.xy_se;
end
chid = find(strcmp(obj.output,'Ey'));
if ~isempty(chid)
obj.tf(3,1,:)   = Z.yx;   obj.tf(3,2,:)  = Z.yy;
obj.tfse(3,1,:)  = Z.yx_se;   obj.tfse(3,2,:)  = Z.yy_se;
end

% disp(k);

% st          =   MT_tf;
% st.name     =   {name};
% st.loc.name =   sname;
% st.loc.nch  =   3;
% st.loc.chname=  {'Hz' 'Ex' 'Ey'};
% st.loc.chid =  [3 4 5];
% st.loc.orient =  [0 0 90];
% st.loc.tilt =  [-90 0 0];
% st.ref.name =   sname;
% st.ref.nch  =   2;
% st.ref.chname=  {'Hx' 'Hy'};
% st.ref.chid =  [1 2];
% st.ref.orient= [0 90];
% st.ref.tilt =  [0 0];
% st.data.nper=  np;
% st.data.periods = periods;
% st.data.tf(1,1,:)  = T.x;   st.data.tf(1,2,:)  = T.y;
% st.data.tf(2,1,:)  = Z.xx;   st.data.tf(2,2,:)  = Z.xy;
% st.data.tf(3,1,:)  = Z.yx;   st.data.tf(3,2,:)  = Z.yy;
% st.data.tf_se(1,1,:)  = T.x_se;    st.data.tf_se(1,2,:)  = T.y_se;
% st.data.tf_se(2,1,:)  = Z.xx_se;   st.data.tf_se(2,2,:)  = Z.xy_se;
% st.data.tf_se(3,1,:)  = Z.yx_se;   st.data.tf_se(3,2,:)  = Z.yy_se;
%  
% % s1122 = (T.x_se./T.y_se + Z.xx_se./Z.xy_se + Z.yx_se./Z.yy_se)/3;
% % sigs = zeros(2,2,st.data.nper);
% sig1122 = 1;
% 
% 
% sigs(1,1,:) = T.x_se; sigs(2,2,:) = T.y_se;
% sige        = zeros(3,3,st.data.nper);
% sige(1,1,:) = 1;
% sige(2,2,:) = Z.xy_se./T.y_se;
% sige(3,3,:) = Z.yx_se./T.x_se;
% st.data.sigs = sigs;
% st.data.sige = sige;
% for k = 1:st.loc.nch
%     st.data.use{k} = 1:st.data.nper;
% end
% st.data.use{1} = find(T.x~=0 & T.y~=0);
% st.data.use{2} = find(Z.xy~=0);
% st.data.use{3} = find(Z.yx~=0);

%     site(k).name    =       file{k};
% %     site(k).rot     =       0;
%     site(k).np      =       np;
%     site(k).periods =       periods;
%     site(k).Z       =       [];
%     site(k).SIG_E   =       [T.x_se;zeros(1,length(periods));zeros(1,length(periods));zeros(1,length(periods));Z.xy_se;zeros(1,length(periods));zeros(1,length(periods));zeros(1,length(periods));Z.yx_se].^2;
%     site(k).SIG_S   =       [ones(1,length(periods));zeros(1,length(periods));zeros(1,length(periods));ones(1,length(periods))];
%     site(k).Z2x2    =       [Z.xx; Z.xy; Z.yx; Z.yy];
%     site(k).Z2x2_se =       ([Z.xx_se; Z.xy_se; Z.yx_se; Z.yy_se]).^2;
%     site(k).Z3x2    =       [T.x;T.y;site(k).Z2x2];
%     Z2x2            =       site(k).Z2x2;
%     Z2x2_se         =       site(k).Z2x2_se;
%     R2x2            =       [ abs(Z2x2(1,:)).^2.*periods/5; abs(Z2x2(2,:)).^2.*periods/5; abs(Z2x2(3,:)).^2.*periods/5; abs(Z2x2(4,:)).^2.*periods/5 ];
%     P2x2            =       [ 180/pi*angle(Z2x2(1,:)); 180/pi*angle(Z2x2(2,:)); 180/pi*angle(-Z2x2(3,:)); 180/pi*angle(-Z2x2(4,:)) ];
%     R2x2_se         =       [ sqrt(2*periods.*R2x2(1,:).*Z2x2_se(1,:)/5); sqrt(2*periods.*R2x2(2,:).*Z2x2_se(2,:)/5); sqrt(2*periods.*R2x2(3,:).*Z2x2_se(3,:)/5); sqrt(4*periods.*R2x2(4,:).*Z2x2_se(2,:)/5) ];
%     P2x2_se         =       180./(pi*abs(Z2x2)).*sqrt(Z2x2_se/2);
%
%     site(k).R2x2    =       R2x2;
%     site(k).R2x2_se =       R2x2_se;
%     site(k).P2x2    =       P2x2;
%     site(k).P2x2_se =       P2x2_se;
%     site(k).T1x2    =       [T.x;T.y];
%     site(k).T1x2_se =       ([T.x_se;T.y_se]).^2;
%     [Rx,Ry,Ix,Iy]   =       ind_arrows(site(k).T1x2(1,:),site(k).T1x2(2,:));
%     site(k).Rx      =       Rx;
%     site(k).Ry      =       Ry;
%     site(k).Ix      =       Ix;
%     site(k).Iy      =       Iy;
%     site(k).Z_ind   =       [1:1:max(size(periods))];
%     site(k).T_ind   =       [1:1:max(size(periods))];
%     site(k).strike  =       0;
%     site(k).alt     =       0;
%     site(k).north   =       0;
%     site(k).east    =       0;

% end
% close(h);
return