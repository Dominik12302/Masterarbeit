%% Example EM Time series: plot local and synchronous base sites
propath       = {'G:\RMTMessung31.10.2014'};
reftime       = [2014 10 31 9 30 0];
emts          = EMTimeSeries(reftime,propath);
emts          = EMTimeSeries(emts,{'s04'});
spdef.bandsetup = 'RMT';
spdef.Ndec    = 1;
spdef.decimate= 1;
spdef.wlength = 2^10;
spdef.noverlap= 2^9;
spdef.prew    = -1;
emts.spdef    = spdef;
emts.lsrate   = 524288;
for is = 1:numel(emts.sites)
    emts.lsname   = emts.sites(is);
    afcfiles      = emts.afcfiles;
end

%%
propath       = {'G:\RMTMessung31.10.2014'};
proc            = EMProc(propath);
proc.bandsetup  = 'RMT';
proc.datapath   = {'ADU/meas*'};
proc            = EMProc(proc,{'s04'});
proc.lsrate     = 524288;
proc.lsname     = {'s04'};
proc.bandsetup  = 'RMT';
procdef.avrange = [4 4]; % Nfc x Nwindows NummerFourierKoeff x NummerFensta
procdef.bicohthresg = {[]};  %!!!änderbar!!!
procdef.bicohthrest = {[]};
procdef.bicohthresf = {[0.95 1]};
procdef.reg = 'spectra';

proc.procdef    = procdef;
proc.input      = {'Bx' 'By'};
proc.output     = {'Ex' 'Ey'};
% 
% proc.output     = {'Ex'};
% tfs = proc.tfs;
% plotspectra(proc,'fscale','kHz');
tfs = proc.tf;

