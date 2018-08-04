% read spectra header from *.afc file
function [sp] = sp_readheaderafc_tmp(fname)
fid                 = fopen(fname);
sp.global_headerlength = fread(fid,1,'int16');
sp.channel_headerlength= fread(fid,1,'int16');
Ns = fread(fid,1,'int16');
sp.name                = fread(fid,[1 Ns],'uint8=>char');
Ns = fread(fid,1,'int16');
sp.run                = fread(fid,[1 Ns],'uint8=>char');
sp.lat                = fread(fid,1,'float32');
sp.lon                = fread(fid,1,'float32');
sp.alt                = fread(fid,1,'float32');
sp.Nch                 = fread(fid,1,'int16');

% JK: HERE WE DO A DIRTY TRICK!
% int32 have range of [-2^31, 2^31-1]
% thus the negative range is used here to store fractional
% sampling rates
%
% see: help code_double_as_neg_int
% and  help code_double_as_neg_int_inverse
%
% original
% sp.srate               = fread(fid,1,'int32');
% modified
sp.srate               = code_double_as_neg_int_inverse(fread(fid,1,'int32'),32);

%sp.reftime             = datevec(fread(fid,1,'float32')); % survey starttime, use datestr to convert
sp.reftime             = fread(fid,[1 6],'int16'); % survey starttime, use datestr to convert
sp.Ndec                = fread(fid,1,'int16');
sp.decimate            = fread(fid,[1 sp.Ndec],'int16');
sp.wlength             = fread(fid,[1 sp.Ndec],'int16');
sp.noverlap            = fread(fid,[1 sp.Ndec],'int16');
sp.prew                = fread(fid,[1 sp.Ndec],'int16');
sp.window              = fread(fid,[1 4],'uint8=>char');
sp.Nk                  = fread(fid,1,'int16');
sp.timebandwidth       = fread(fid,1,'int16');
Ns                     = fread(fid,1,'int16');
sp.tssource            = {fread(fid,[1 Ns],'uint8=>char')};
for idec = 1:sp.Ndec
    Ndata = fread(fid,[1 3],'int32');   % 3rd dim is the number of slepian seqs.
    sp.Nf(idec)            = Ndata(1);
    sp.Nsets(idec)         = Ndata(2);
    %sp.Nk            = sp.Ndata(idec,3);
    sp.W(idec,:)     = fread(fid,[1 2],'int32');
    sp.T(idec,:)     = fread(fid,[1 3],'float32');
    sp.F(idec,:)     = fread(fid,[1 3],'float32');
end
fseek(fid,sp.global_headerlength,'bof');
Nfc = sum(sp.Nfc);
for ich = 1:sp.Nch
    fseek(fid,(ich-1)*sp.channel_headerlength+sp.global_headerlength+(ich-1)*(Nfc*8+Nfc/sp.Nk),'bof');
    sp.chnames{ich} = fread(fid,[1 2],'uint8=>char');
    sp.chtypes{ich} = fread(fid,[1 2],'uint8=>char');
    %     tmp = fread(fid,1,'int16');
    %     sp.tsfiles{ich} = fread(fid,[1 tmp],'uint8=>char');
end
fclose(fid);
end