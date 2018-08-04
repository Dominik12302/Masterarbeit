%% Example EM Time series: plot local and synchronous base sites
propath       = {'G:\DCtrain'};
reftime       = [2014 03 21 0 0 0];
usetime       = [2014 03 24 12 0 0 2014 03 24 13 0 0];
emts          = EMTimeSeries(reftime,propath);
emts          = EMTimeSeries(emts,{'A04' 'E02' 'E03' 'E05' 'E06' 'E07' 'E08' 'E09' 'E10'});
emts.usetime  = usetime;
emts.usech    = {'Ex' 'Ey'};
emts.lsname   = {'A04'};
emts.lsrate   = 512;
emts.bsname   = {'E02' 'E05' 'E06' 'E07'};
emts.bsrate   = [500 512];
emts.resmpfreq= 10;
plotruntimes(emts,'time','utc');
% plot(emts,'time','utc','color','k');

%% Example EM Time series: convert local site data into ats format resampled to 512 Hz
propath       = {'E:\DCtrain'};
reftime       = [2014 03 21 0 0 0];
usetime       = [2014 03 23 6 0 0 2014 03 24 6 0 0]; 
emts          = EMTimeSeries(reftime,propath);
emts          = EMTimeSeries(emts,{'E02' 'E03' 'E05' 'E06' 'E07' 'E08' 'E09' 'E10'});
emts.usech    = {'Ex' 'Ey'};
%emts.usetime  = usetime;
emts.lsrate   = 500;
emts.resmpfreq= 512;
for is = 1:numel(emts.sites)
    emts.lsname   = emts.sites(is);
    atsfiles{is}  = emts.atsfiles;
end

%% Example EM Time series: load converted EDE data and compute spectra
propath       = {'E:\fieldcourse2014'};
reftime       = [2014 06 02 0 0 0];
emts          = EMTimeSeries(reftime,propath);
emts.datapath = {'./adc/ADU/meas*' };
emts          = EMTimeSeries(emts,{'A03'});
emts.usech    = {'Ex' 'Ey' 'Bx' 'By'};
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
emts          = EMTimeSeries(emts,{'A04'});
emts.usech    = {'Ex' 'Ey' 'Bx' 'By'};
emts.lsrate   = 512;
usetime = {[2014 3 21 00 00 00 2014 3 24 0 0 0] ...
           [2014 3 24 00 00 00 2014 3 27 0 0 0] ...
           [2014 3 27 00 00 00 2014 3 30 0 0 0] ...
           [2014 3 30 00 00 00 2014 4 02 0 0 0]};
for is = 1:numel(emts.sites)
    for iuse = 1:numel(usetime)
        emts.usetime  = usetime{iuse};
        emts.lsname   = emts.sites(is);
        afcfiles      = emts.afcfiles;
        pause(5)
    end
end

%% plot spectra for A01 and A02
sp_1 = EMSpectra('E:\fieldcourse2014\A03\fc\ADU\meas_2014-06-03_10-50-00\125_ADU_R001_TExEyBxBy_512H_I20140603-105000_20140604-105000_Z20140602-000000.afc');
sp_2 = EMSpectra('E:\fieldcourse2014\A03\fc\ADU\meas_2014-06-03_10-50-00\125_ADU_R001_TExEyBxBy_512H_I20140603-105000_20140604-105000_Z20140602-000000.afc');
sp_1.output = {'Ex' 'Ey'};
sp_1.usedec = 2;
sp_2.output = {'Bx' 'By'};
sp_2.usedec = 2;
[a,b,c]=intersect(sp_1.wr,sp_2.wr);
sp_1.setrange = b;
sp_2.setrange = c;
sp_1.fcrange  = [4 65];
sp_2.fcrange  = [4 65];
plot(sp_1,'channel','Ex','time','utc','frequency','Hz');
plot(sp_1,'channel','Ey','time','utc','frequency','Hz');
plot(sp_2,'channel','Bx','time','utc','frequency','Hz');
plot(sp_2,'channel','By','time','utc','frequency','Hz');