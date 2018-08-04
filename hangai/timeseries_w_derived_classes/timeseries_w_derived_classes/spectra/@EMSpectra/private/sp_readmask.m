% reads mask from afc file
function [use] = sp_readmask(obj,ch)
chs   = obj.header.chnames;
dec   = obj.usedec;
fcs   = obj.fcrange;
chmap = [];
for ich = 1:numel(ch)
    tmp = find(strcmp(chs,ch{ich}));
    if ~isempty(tmp)
        chmap = [chmap tmp];
    else
        disp(['WARNING from SP_READDATA: channel ' ch{ich} ' not found']);
    end
end

fid = fopen(obj.header.spfile);
fseek(fid,obj.header.global_headerlength,'bof');
fdch.S = [];
fdch.use = [];
lpos = sum(prod(obj.header.Ndata(1:dec-1,:),2))*8+sum(prod(obj.header.Ndata(1:dec-1,1:2),2));

for ich = 1:numel(chmap)
    if obj.debuglevel
        disp([' - reading ' ch{ich} ' mask from ' obj.header.spfile]);
    end
    cch = chmap(ich);
    fseek(fid,obj.header.global_headerlength+cch*obj.header.channel_headerlength+ ...
        (cch-1)*(obj.header.Nfc*8+obj.header.Nfc/obj.header.Nk),'bof');
    fseek(fid,lpos,'cof');
    if isempty(fcs)
        for ik = 1:obj.header.Nk
            fdch(ich).S(:,:,ik) = fread(fid,fliplr(obj.header.Ndata(dec,1:2)),'float32')'+...
                1i*fread(fid,fliplr(obj.header.Ndata(dec,1:2)),'float32')';
        end
        fdch(ich).use = fread(fid,fliplr(obj.header.Ndata(dec,1:2)),'uint8')';
    elseif numel(fcs)==2
        for ik = 1:obj.header.Nk
            fseek(fid,obj.header.global_headerlength+cch*obj.header.channel_headerlength+...
                (cch-1)*(obj.header.Nfc*8+obj.header.Nfc/obj.header.Nk),'bof');
            fseek(fid,lpos+prod(obj.header.Ndata(dec,1:2))*(ik-1)*8,'cof');
            fseek(fid,(fcs(1)-1)*obj.header.Ndata(dec,2)*4,'cof');
            fdch(ich).S(:,:,ik) = fread(fid,[obj.header.Ndata(dec,2) fcs(2)-fcs(1)+1],'float32')'; % real part
            fseek(fid,obj.header.global_headerlength+cch*obj.header.channel_headerlength+...
                (cch-1)*(obj.header.Nfc*8+obj.header.Nfc/obj.header.Nk),'bof');
            fseek(fid,lpos+prod(obj.header.Ndata(dec,1:2))*(ik-1)*8+prod(obj.header.Ndata(dec,1:2))*4,'cof');
            fseek(fid,(fcs(1)-1)*obj.header.Ndata(dec,2)*4,'cof');
            fdch(ich).S(:,:,ik) = fdch(ich).S(:,:,ik)+1i*fread(fid,[obj.header.Ndata(dec,2) fcs(2)-fcs(1)+1],'float32')'; % imag part
        end
        fseek(fid,obj.header.global_headerlength+cch*obj.header.channel_headerlength+...
            (cch-1)*(obj.header.Nfc*8+obj.header.Nfc/obj.header.Nk),'bof');
        fseek(fid,lpos+prod(obj.header.Ndata(dec,:))*4*2,'cof');
        fseek(fid,(fcs(1)-1)*obj.header.Ndata(dec,2)*1,'cof');
        %         fseek(fid,(fcs(1)-1)*Ndata(dec,2),'cof');
        fdch(ich).use = fread(fid,[obj.header.Ndata(dec,2) fcs(2)-fcs(1)+1],'uint8')';
    else
        disp('READSPCTRA: don t know which coefs to read!');
    end
end
fclose(fid);
Nch = numel(fdch);
Nfc = size(fdch(1).S,1);
% Nsets = size(fdch(1).S,2);
% Nsets   = numel(obj.setrange);%size(fdch(1).S,2);

if ~isempty(obj.setrange)
    Nsets   = numel(obj.setrange);
else
    Nsets = size(fdch(1).S,2);
    obj.setrange = [1:Nsets];
end
Nk = obj.header.Nk;
use = zeros(Nfc,Nsets,Nk,Nch);
for ich = 1:Nch
    use(:,:,:,ich) = fdch(ich).use(:,obj.setrange,:);
end
