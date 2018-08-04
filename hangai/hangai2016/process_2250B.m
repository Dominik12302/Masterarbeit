% 
% %% Site 2250B
propath       = {'/syn06/d_harp01/Hangai_2016/'}; % Enter the project path, ie.e. ../../TESTDATA
%propath       = {'E:\hangai_data'};
reftime       = [2016 07 08 00 00 00];
site          = {'4200B'};% '0015' '0024' '0060'};       % name of  recording
emts          = EMTimeSeries(reftime,propath);
emts          = EMTimeSeries(emts,site);
%% convert EDL into ATS format
emts.lsname   = site;
emts.lsrate   = 500;
emts.resmpfreq= 512; % resample to 512 Hz
emts.delay_filter = 0;
% emts.usetime = [2016 07 27 11 0 0 2016 07 27 11 0 5]; 
atsfiles      = emts.atsfiles;
%% load converted SP4 data (stored in propath/proc/spam4/run*') and fft
emts          = EMTimeSeries(reftime,propath);
emts.datapath = {'./proc/spam4/run*'};
emts          = EMTimeSeries(emts,site);
emts.lsname   = site;
emts.lsrate   = 512;
%emts.spdef.Ndec= 6;
%usetimes = {[ 2016 07 08 0 0 0 2016 07 14 0 0 0] [2016 07 14 0 0 0 2016 07 17 0 0 0]  [2016 07 17 0 0 0 2016 07 21 0 0 0]};
%usetimes = { [2016 07 17 10 40 23 2016 07 18 23 59 59]   [2016 07 19 0 0 0 2016 07 20 23 59 59]  [2016 07 21 0 0 0 2016 07 23 1 0 0]};

% for it = 1:numel(usetimes)
%     emts.usetime = usetimes{it};
     afcfiles      = emts.afcfiles;
% end

%% plot spectra
proc            = EMProc(propath);
proc.bandsetup  = 'MT';
proc            = EMProc(proc,site);
proc.lsname     = site;
proc.mindec    = 1;
proc.input      = {'Bx' 'By'};   
proc.output     = {'Ex' 'Ey'};
proc.ref        = {};
proc.bandsetup  = 'MT';
proc.lsrate     = 512;
proc.bsrate     = 0;
proc.rsrate     = 0;
proc.bsname     = {};
proc.lsname     = site; 
% proc.rsname     = {};
% proc.usetime    = [2016 07 23 0 0 0 2016 07 25 0 0 0];           % leave empty: use all avaible data
% procdef.avrange = [4 4];        % averaging domain Nfc x Nsets for smoothing of spectral matrics; this imparts on the coherency estimation, polarization props. etc.
% procdef.bicohthresg = {[0.85 1]};      % threshold fcs for which the coherency is estimated below 0.9    
% proc.procdef    = procdef;
% tfs             = proc.tf;



% horizontal magnetic transfer to 1350B
site = {'1350B' '2250B'};
proc            = EMProc(propath);
proc.bandsetup  = 'MT';
proc            = EMProc(proc,site);
proc.input      = {'Bx' 'By'};   
proc.output     = {'Bx' 'By'};
proc.ref        = {};
proc.bandsetup  = 'MT';
proc.lsrate     = 512;
proc.bsrate     = 512;
proc.rsrate     = 0;
proc.bsname     = {'1350B'};
proc.lsname     = {'2250B'}; 
proc.rsname     = {};
proc.usetime    = [2016 07 23 0 0 0 2016 07 25 0 0 0];           % leave empty: use all avaible data
procdef.avrange = [4 4];        % averaging domain Nfc x Nsets for smoothing of spectral matrics; this imparts on the coherency estimation, polarization props. etc.
procdef.bicohthresg = {[0.85 1]};      % threshold fcs for which the coherency is estimated below 0.9    
proc.procdef    = procdef;
tfs             = proc.tf;




