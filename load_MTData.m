%% load data from SPAM and EDE, save components to matrix in Matlab


propath       = {'/syn06/d_harp01/Hangai_2016/'}; % project path



site = {'1350B' '2250B'};
proc            = EMProc(propath);
proc.bandsetup  = 'MT';
proc            = EMProc(proc,site);
proc.input      = {'Ex'};   
proc.output     = {'Bx' 'By'};
proc.ref        = {};
proc.bandsetup  = 'MT';
proc.lsrate     = 512;
proc.bsrate     = 512;
proc.rsrate     = 0;
proc.bsname     = {'1350B'};
proc.lsname     = {'1350B'}; 
proc.rsname     = {};
proc.usetime    = [2016 07 23 0 0 0 2016 07 23 0 0 1];           % leave empty: use all avaible data
procdef.avrange = [4 4];        % averaging domain Nfc x Nsets for smoothing of spectral matrics; this imparts on the coherency estimation, polarization props. etc.
procdef.bicohthresg = {};      % threshold fcs for which the coherency is estimated below 0.9    
proc.procdef    = procdef;
% robproc         = EMRobustProcessing(proc.X,proc.Y);
proc.tf
a = robproc.XmN;
b = robproc.YmN;
% tfs             = proc.tf;

