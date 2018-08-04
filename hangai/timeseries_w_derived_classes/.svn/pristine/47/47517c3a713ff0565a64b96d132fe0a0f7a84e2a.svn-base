% read spectra from afc file
function [S] = sp_readdata(obj,ch)
chs   = obj.chnames;
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
Nfc = sum(obj.Nfc);
fid = fopen(obj.source{1});
fseek(fid,obj.global_headerlength,'bof');
fdch.S = [];
lpos = sum(obj.Nf(1:dec-1).*obj.Nsets(1:dec-1).*obj.Nk)*8+sum(obj.Nf(1:dec-1).*obj.Nsets(1:dec-1));
% lpos = sum(prod(obj.header.Ndata(1:dec-1,:),2))*8+sum(prod(obj.header.Ndata(1:dec-1,1:2),2));

for ich = 1:numel(chmap)
    if obj.debuglevel
        disp([' - reading ' ch{ich} ' spectra from ' obj.source{1}]);
    end
    cch = chmap(ich);
    fseek(fid,obj.global_headerlength+cch*obj.channel_headerlength+ ...
        (cch-1)*(Nfc*8+Nfc/obj.Nk),'bof');
    fseek(fid,lpos,'cof');
    if isempty(fcs)
        for ik = 1:obj.Nk
            Ndata = obj.Nf(dec)*obj.Nsets(dec);
            fdch(ich).S(:,:,ik) = fread(fid,[obj.Nsets(dec) obj.Nf(dec)],'float32')'+...
                1i*fread(fid,[obj.Nsets(dec) obj.Nf(dec)],'float32')';
%                         fdch(ich).S(:,:,ik) = fread(fid,fliplr(obj.header.Ndata(dec,1:2)),'float32')'+...
%                 1i*fread(fid,fliplr(obj.header.Ndata(dec,1:2)),'float32')';

        end
    elseif numel(fcs)==2
        for ik = 1:obj.Nk
            fseek(fid,obj.global_headerlength+cch*obj.channel_headerlength+...
                (cch-1)*(Nfc*8+Nfc/obj.Nk),'bof');
            fseek(fid,lpos+obj.Nf(dec)*obj.Nsets(dec)*(ik-1)*8,'cof');
            fseek(fid,(fcs(1)-1)*obj.Nsets(dec)*4,'cof');
            fdch(ich).S(:,:,ik) = fread(fid,[obj.Nsets(dec) fcs(2)-fcs(1)+1],'float32')'; % real part
            fseek(fid,obj.global_headerlength+cch*obj.channel_headerlength+...
                (cch-1)*(Nfc*8+Nfc/obj.Nk),'bof');
            fseek(fid,lpos+obj.Nf(dec)*obj.Nsets(dec)*(ik-1)*8+obj.Nf(dec)*obj.Nsets(dec)*4,'cof');
            fseek(fid,(fcs(1)-1)*obj.Nsets(dec)*4,'cof');
            fdch(ich).S(:,:,ik) = fdch(ich).S(:,:,ik)+1i*fread(fid,[obj.Nsets(dec) fcs(2)-fcs(1)+1],'float32')'; % imag part
           
%             fseek(fid,lpos+prod(obj.header.Ndata(dec,1:2))*(ik-1)*8,'cof');
%             fseek(fid,(fcs(1)-1)*obj.header.Ndata(dec,2)*4,'cof');
%             fdch(ich).S(:,:,ik) = fread(fid,[obj.header.Ndata(dec,2) fcs(2)-fcs(1)+1],'float32')'; % real part
%             fseek(fid,obj.header.global_headerlength+cch*obj.header.channel_headerlength+...
%                 (cch-1)*(obj.header.Nfc*8+obj.header.Nfc/obj.header.Nk),'bof');
%             fseek(fid,lpos+prod(obj.header.Ndata(dec,1:2))*(ik-1)*8+prod(obj.header.Ndata(dec,1:2))*4,'cof');
%             fseek(fid,(fcs(1)-1)*obj.header.Ndata(dec,2)*4,'cof');
%             fdch(ich).S(:,:,ik) = fdch(ich).S(:,:,ik)+1i*fread(fid,[obj.header.Ndata(dec,2) fcs(2)-fcs(1)+1],'float32')'; % imag part
        end
        fseek(fid,obj.global_headerlength+cch*obj.channel_headerlength+...
            (cch-1)*(Nfc*8+Nfc/obj.Nk),'bof');
        fseek(fid,lpos+obj.Nf(dec)*obj.Nsets(dec)*obj.Nk*4*2,'cof');
        fseek(fid,(fcs(1)-1)*obj.Nsets(dec)*1,'cof');
    else
        disp('READSPCTRA: don t know which coefs to read!');
    end
end

fclose(fid);
Nch     = numel(fdch);
Nfc     = size(fdch(1).S,1);
if ~isempty(obj.setrange)
    Nsets   = numel(obj.setrange);
else
    Nsets = size(fdch(1).S,2);
    obj.setrange = [1:Nsets];
end
Nk      = obj.Nk;
S       = zeros(Nfc,Nsets,Nk,Nch);
for ich = 1:Nch
    S(:,:,:,ich) = fdch(ich).S(:,obj.setrange,:);
end
end