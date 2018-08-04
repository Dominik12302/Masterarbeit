%
function [ts] = sp_writemask(ts,site,index,ch,dec,use,varargin)
if isempty(varargin)
    fcrange = [];
else
    fcrange = varargin{1};
end

b = index;
sites   =     get(ts,'sitename');
if strcmp(site,'all'),   site     =     sites; end

TimeShift   =   [];

for k = 1:length(site)
    if any(strcmpi(sites,site(k)))
        s       =   find(strcmpi(sites,site(k)));
        bd      =   ts(s).bd;
        if isempty(b)
            for ibd = 1:length(bd)
                for isgm = 1:length(bd(ibd).sgm)
                        if bd(ibd).sgm(isgm).sfreq > 0 ,  sfreq   =   1./bd(ibd).sgm(isgm).sfreq; else sfreq   =   -bd(ibd).sgm(isgm).sfreq; end
                end
            end
        else
            ibd = b(1); isgm = b(2);
            if bd(ibd).sgm(isgm).sfreq > 0 ,  sfreq   =   1./bd(ibd).sgm(isgm).sfreq; else sfreq   =   -bd(ibd).sgm(isgm).sfreq; end
            chs = [bd(ibd).sgm(isgm).ch.name];
            chmap = [];
            for ich = 1:numel(ch)
                tmp = find(strcmp(chs,ch{ich})); 
                if ~isempty(tmp)
                chmap = [chmap tmp];
                else
                    disp(['WARNING from READSPECTRA: channel ' ch{ich} ' not found']);
                end
            end
            afcfile = bd(ibd).sgm(isgm).fd.file{1};
            writefile(afcfile,chmap,dec,use,fcrange);

        end
    else
        disp(['Warning: site ' site{k} ' not found!']);
    end
end
end
function writefile(fname,ch,dec,use,fcrange)

fid = fopen(fname,'r+');
global_headerlength = fread(fid,1,'int16');
channel_headerlength = fread(fid,1,'int16');
Nch = fread(fid,1,'int16');
sfreq = fread(fid,1,'int32');
survey_starttime = fread(fid,1,'float32'); % survey starttime, use datestr to convert
Ndec = fread(fid,1,'int16');
decimation = fread(fid,[1 Ndec],'int16');
windowlength = fread(fid,[1 Ndec],'int16');
noverlap = fread(fid,[1 Ndec],'int16');
Nfc = 0;
for idec = 1:Ndec
    Ndata(idec,:) = fread(fid,[1 3],'int32');
    Nfc = Nfc + prod(Ndata(idec,:));
    k             = Ndata(idec,3);
    Nwins(idec,:) = fread(fid,[1 2],'int32');
    T(idec,:) = fread(fid,[1 3],'float32');
    F(idec,:) = fread(fid,[1 3],'float32');
end

% fseek(fid,global_headerlength,'bof');
% fdch.S = [];
% fdch.use = [];
% lpos = sum(prod(Ndata(1:dec-1,:),2))*9;
lpos = sum(prod(Ndata(1:dec-1,:),2))*8+sum(prod(Ndata(1:dec-1,1:2),2));

for ich = 1:numel(ch)
    cch = ch(ich);
    % read requested data
    fseek(fid,global_headerlength+cch*channel_headerlength+(cch-1)*(Nfc*8+Nfc/k),'bof');
    fseek(fid,lpos,'cof');
    fseek(fid,prod(Ndata(dec,:,:))*2*4,'cof');
    if ~isempty(fcrange)
        fseek(fid,Nwins(dec,2)*min(fcrange-1),'cof');
        fwrite(fid,[use{ich}]','uint8');
    else
        fwrite(fid,[zeros(1,size(use{ich},2));use{ich}]','uint8'); %% add zeros for dc component??
    end
end;


fclose(fid);
end