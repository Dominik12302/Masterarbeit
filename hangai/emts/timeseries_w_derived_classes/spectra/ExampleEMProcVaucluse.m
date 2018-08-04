%% load some sites into A project 
propath       = {'E:\fieldcourse2014'};
reftime       = [2014 06 02 0 0 0];
proc            = EMProc(propath);
proc.datapath   = {'ADU\meas*'};
proc.input      = {'Bx' 'By'};
proc.output     = {'Ex' 'Ey'};
proc.bandsetup  = 'MT';
proc            = EMProc(proc,{'A03'});
proc.lsrate     = 512;
proc.bsrate     = 512;
%proc.bsname     = {'E03'};
proc.lsname     = {'A03'};
%proc.usetime    = [2014 03 24 0 0 0 2014 03 25 0 0 0];                 % leave empty: use all avaible data
procdef.avrange = [4 20];             % averaging domain Nfc x Nsets for smoothing of spectral matrics; this imparts on the coherency estimation, polarization props. etc.
procdef.bicohthresg = {};      % threshold fcs for which the coherency is estimated below 0.9    
proc.procdef    = procdef;
% compute transfer functions for all data
tfs             = proc.tf;
%% compute transfer functions for a subset of the data 
proc.usetime    = [2014 03 23 23 30 0 2014 03 24 00 00 0];
tf              = proc.tf;
% the plotting function is called inside EMProc, but can be invoked from here as
% well. Note that axes limits, etc. is hardwired in that function
sp_plottf(tf);
%% plot bivariate coherency between Ex at local site and Ex, Ey at base site
% for all fourier coefficients for half an hour at decimation level 4 
proc.usetime    = [];
proc.usedec     = 2;
proc.fcrange    = [];
proc.input      = {'Bx' 'By'};
proc.output     = {'Ex'};
procdef.avrange = [4 30];             % averaging domain Nfc x Nsets for smoothing of spectral matrics; this imparts on the coherency estimation, polarization props. etc.
procdef.bicohthresg = {};      % threshold fcs for which the coherency is estimated below 0.9    
proc.procdef    = procdef;
plotcoh(proc);
%% plot individual transfer functions 
%  at decimation  level 4 
proc            = EMProc(proc,{'E02' 'E03','E05','E06'});
procdef.avrange = [4 4];
procdef.smooth = 'runav';
proc.bsname     = {'E03'};
proc.lsname     = {'E05'};

proc.procdef    = procdef;
proc.usetime    = [2014 03 23 23 30 0 2014 03 24 00 00 0];
% proc.usetime    = [2014 03 23 6 0 0 2014 03 23 10 00 0];
proc.usedec     = 4;
proc.fcrange    = [];
proc.input      = {'Ex' 'Ey'};
proc.output     = {'Ex'};
% tfs = proc.tfs;
plottfs(proc);

%% plot polarization 
% from eigenvalue of the smoothed cross spectral matrix of the INPUT
% channels (basesite!)
proc            = EMProc(proc,{'E02' 'E03','E05','E06'});
procdef.avrange = [10 2];
procdef.smooth = 'runav';
proc.bsname     = {'E03'};
proc.procdef    = procdef;
proc.usetime    = [2014 03 23 23 30 0 2014 03 24 00 00 0];
proc.usedec     = 5;
proc.fcrange    = [];
proc.input      = {'Ex' 'Ey'};
proc.output     = {'Ex'};

% pol = proc.pol;
% this plots degree of polarization and angle using imagesc 
plotpol(proc);

%% this is just to see how the polarization develops in time
% could be instructive to produce maps which show how the polarization
% develops in time for many simultaneous stations
ta = proc.utc;
t = [];
for ia = 1:numel(ta)
    t = [t ta{ia}];
end
dt = etime(datevec(t(2)),datevec(t(1)));
f = proc.f(35);
figure;
axes; 
xlim([-2 2]);
ylim([-2 2]);
hold on;
for isets = 1:size(pol.or,2);
    delete(get(gca,'children'));
    title(['T= ' num2str(1./f,'%.02f') ' - ' datestr(t(isets))]);
    phi = pol.or(35,isets)*pi/180;
    l = (pol.deg(35,isets)-0.5)*2;
    start = [-sin(phi) -cos(phi)]*l;
    stop = [sin(phi) cos(phi)]*l;
    arrow(start,stop,'length',20,'Width',2)
    arrow(stop,start,'length',20,'Width',2);
    pause(dt/20) ; % plot 20 times faster than in real time
end






