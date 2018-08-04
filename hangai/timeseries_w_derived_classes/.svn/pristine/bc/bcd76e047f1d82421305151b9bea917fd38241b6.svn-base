%% Example EM Time series: plot local and synchronous base sites
propath       = {'G:\DCtrain'};
reftime       = [2014 03 21 0 0 0];
usetime       = [2014 03 24 12 0 0 2014 03 24 13 0 0];
emts          = EMTimeSeries(reftime,propath);
emts.datapath = {'./adc/EDE/run*' , './adc/ADU/meas*'};
emts          = EMTimeSeries(emts,{'E02' 'E05' 'E06' 'E07' 'E24' 'E25' });
emts.usetime  = usetime;
emts.usech    = {'Ex' 'Ey'};
emts.lsname   = {'E02'};
emts.lsrate   = 512;
emts.bsname   = {'E05' 'E06' 'E07'};
emts.bsrate   = [500 512];
emts.resmpfreq= 10;
plotruntimes(emts,'time','utc');
plot(emts,'time','utc','color','k');

%% Example EM Time series: convert local site data into ats format resampled to 512 Hz
propath       = {'G:\DCtrain'};
reftime       = [2014 03 21 0 0 0];
emts          = EMTimeSeries(reftime,propath);
emts.datapath = {'./adc/EDE/run*'};
emts          = EMTimeSeries(emts,{'E23'}); %ADU E17 E23
emts.usech    = {'Ex' 'Ey'};
emts.lsrate   = 500;
emts.resmpfreq= 512;
for is = 1:numel(emts.sites)
    emts.lsname   = emts.sites(is);
    atsfiles{is}  = emts.atsfiles;
end

%% Example EM Time series: load converted EDE data and compute spectra
propath       = {'G:\DCtrain'};
reftime       = [2014 03 21 0 0 0];
emts          = EMTimeSeries(reftime,propath);
emts.datapath = {'.\proc\EDE\run*'};
emts          = EMTimeSeries(emts,{'A03' 'A07' 'E01' 'E02' 'E03' 'E04' 'E05' 'E06' 'E07' 'E08' 'E09' 'E10' ...
    'E12' 'E13' 'E14' 'E16' 'E18' 'E19' 'E20'  'E21' 'E22' 'E24' 'E25'}); %ADU E17 E23
emts.usech    = {'Ex' 'Ey'};
emts.lsrate   = 512;
spdef.prew    = [-1 -1 -1 -1 -1 -1 -1 -1];
emts.spdef    = spdef;
for is = 1:numel(emts.sites)
    emts.lsname   = emts.sites(is);
    afcfiles      = emts.afcfiles;
end


%% Example EM Time series: load ADU data and compute spectra
propath       = {'G:\DCtrain'};
reftime       = [2014 03 21 0 0 0];
emts          = EMTimeSeries(reftime,propath);
emts.datapath = {'./adc/ADU/meas*'};
emts          = EMTimeSeries(emts,{'E23'});
emts.usech    = {'Ex' 'Ey'};
emts.lsrate   = 512;
usetime = {[2014 3 21 00 00 00 2014 3 24 0 0 0] ...
           [2014 3 24 00 00 00 2014 3 27 0 0 0] ...
           [2014 3 27 00 00 00 2014 3 30 0 0 0] ...
           [2014 3 30 00 00 00 2014 4 02 0 0 0]};
for is = 1:numel(emts.sites)
    for iuse = 4:numel(usetime)
        emts.usetime  = usetime{iuse};
        emts.lsname   = emts.sites(is);
        afcfiles      = emts.afcfiles;
        pause(1)
    end
end

%% plot spectra for A01 and A02
propath       = {'G:\DCtrain'};
proc            = EMProc(propath);
proc.datapath   = {'EDE\run*' 'ADU\meas*'};
proc.input      = {'Ex' 'Ey'};
proc.output     = {'Ex' 'Ey'};
proc.ref        = {};
proc.bandsetup  = 'MT';
proc            = EMProc(proc,{'A06'});
proc.usedec     = 7;
proc.maxdec     = 6;
proc.mindec     = 2;
proc.lsrate     = 512;
proc.bsrate     = 512;
proc.rsrate     = 0;
proc.bsname     = {'A06'};
proc.lsname     = {'A06'};
proc.rsname     = {};
proc.usetime    = [2014 03 28 15 0 0 2014 03 29 15 0 0];                 % leave empty: use all avaible data
procdef.avrange = [4 4];             % averaging domain Nfc x Nsets for smoothing of spectral matrics; this imparts on the coherency estimation, polarization props. etc.
procdef.bicohthresg = {[0.95 1]};      % threshold fcs for which the coherency is estimated below 0.9    
proc.procdef    = procdef;

