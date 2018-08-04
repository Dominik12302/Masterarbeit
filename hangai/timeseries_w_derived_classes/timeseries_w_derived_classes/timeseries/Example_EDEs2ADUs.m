%% load synchronous recordings of ADU and ede and plot the time series resampled to 8 Hz
% adu data from site A02
usetime     = [2014 03 22 00 00 00 2014 03 22 12 00 00]; % we look at 12 hours, from midnight to noon
reftime     = [2014 03 21 00 00 00];                     % for plotting, we choose this as a reference time
pathname    = 'D:\DCtrain\A02\ts\adc\ADU\meas_2014-03-21_11-26-00';
adu         = ADUs;
adu.name    = 'A02';
adu.run     = '001';
adu.debuglevel = 1;
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to plot
adu.usech   = [1 2];                    % we just want to plot the first two channels
adu.reftime = reftime;     
adu.resmpfreq = 8;                      % to resample to 8 Hz
hax         = plot(adu,'time','relative h','units','physical','factor',[1 -1]);
%% ede data from site A02
pathname    = 'D:\data\EDE_NoiseTest_09072014\E01\ts\adc\EDE\meas_2014-07-08_08-21-14'
usetime     = [2014 07 8 8 30 00 2014 07 8 9 0 00]; % we look at 12 hours, from midnight to noon
reftime     = [2014 07 8 8 30 00];

% pathname    = 'D:\data\EDE_NoiseTest_09072014\E01\ts\adc\EDE\meas_2014-07-08_09-55-56';
% usetime     = [2014 07 8 10 00 00 2014 07 8 10 30 00]; % we look at 12 hours, from midnight to noon
% reftime     = [2014 07 8 10 00 00];
 
% pathname    = 'D:\data\EDE_NoiseTest_09072014\E01\ts\adc\EDE\meas_2014-07-08_12-17-56';
% usetime     = [2014 07 8 12 30 00 2014 07 8 13 00 00]; % we look at 12 hours, from midnight to noon
% reftime     = [2014 07 8 12 30 00];
pathname    = 'D:\data\EDE_NoiseTest_09072014\E01\ts\adc\EDE\meas_2014-08-21_08-48-44';
usetime     = [2014 08 21 9 30 00 2014 08 21 11 30 00]; % we look at 12 hours, from midnight to noon
reftime     = [2014 08 21 9 30 00];

ede         = EDEs;

ede.name    = 'E01';
ede.run     = '001';
ede.debuglevel = 1;
ede         = EDEs(ede,pathname);
ede.usesmp  = get_usesmp(ede,usetime);
ede.usech   = [1 2];
ede.reftime = reftime;
ede.resmpfreq = 500;
hax         = plot(ede,'time','relative h','units','mV','elim',[-.05 .05] );
ede.resmpfreq = 1;
hax         = plot(ede,'time','relative h','units','mV','elim',[-.05 .05],'axes',hax(1:2),'color','r');

%% convert ede files into ats files, resampled to 512 Hz
% unless otherwise specified in the field (cell) ede.atsoutdir 
% ats files are written to the data directory ede.source;
reftime     = [2014 03 21 00 00 00];
pathname    = 'D:\DCtrain\A02\ts\adc\EDE\run2';
ede         = EDEs;
ede.name    = 'A02';
ede.run     = '002';
ede.debuglevel = 1;                 % set this t two, if you want to see some more messages
ede         = EDEs(ede,pathname);
ede.usesmp  = [1 ede.Nsmp];         % use all samples, but first and last samples will omitted to make sure that we start (and stop) at a full second
ede.usech   = [1 2];                % output the two channels
ede.reftime = reftime;              % not very relevant for this
ede.resmpfreq = 512;                % can be anything >= 1 (Hz)
ede.atsoutdir  = {'D:\DCtrain\A02\ts\proc\EDE\run2'};
atsfiles    = ede.atsfile;          % returns the ats filenames
  
%% load the adu data and the converted ede data into an adu class and compare with the true adu data
% adu data from site A02
usetime     = [2014 03 22 00 00 00 2014 03 22 00 00 01]; % we look at 1 sec, at midnight
reftime     = [2014 03 22 00 00 00];
pathname    = 'D:\DCtrain\A02\ts\adc\ADU\meas_2014-03-21_11-26-00';
adu         = ADUs;
adu.name    = 'A02';
adu.run     = '001';
adu.debuglevel = 1;
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to plot
adu.usech   = [1 2 3 4];                    % we just want to plot the first two channels
adu.reftime = reftime;                  % for plotting, we choose this as a reference time
hax         = plot(adu,'time','relative s','units','mV','elim',[-100 100],'factor',[1 -1 10 10]);

% converted ede data
pathname    = 'D:\DCtrain\A02\ts\proc\EDE\run2';
adu         = ADUs;
adu.name    = 'A02';
adu.run     = '002';
adu.debuglevel = 1;
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to plot

adu.usech   = [1 2];                    % we just want to plot the first two channels
adu.reftime = reftime;                  % for plotting, we choose this as a reference time
hax         = plot(adu,'time','relative s','units','mV','axes',hax(1:2),'color','r');

%% compute spectra for the unconverted ede data
usetime     = [2014 03 21 00 00 00 2014 03 24 00 00 00]; % we look at 3 days, but the actual recording is shorter
reftime     = [2014 03 21 00 00 00];                     % for spectral computation, we choose this as a reference time

pathname    = 'D:\DCtrain\A02\ts\adc\EDE\run2';
ede         = EDEs;
ede.name    = 'A02';
ede.run     = '003';
ede         = EDEs(ede,pathname);
ede.usesmp  = get_usesmp(ede,usetime);  % this returns the samples to transform
ede.usech   = [1 2];                    % we just want to use the first two channels
ede.resmpfreq=512;

sp          = EMSpectra;                % Initilaize an EMSpectra object
sp.reftime  = reftime;                  % this is the reftime which will overwrite the reftime property in the adu object
sp.source   = {'D:\DCtrain\A02\fd'};    % Here the spectra will be stored
sp          = EMSpectra(sp,ede);        % This triggers the spectrogram computation

%% compute spectra for the converted ede data
usetime     = [2014 03 21 00 00 00 2014 03 24 00 00 00]; % we look at 3 days, but the actual recording is shorter
reftime     = [2014 03 21 00 00 00];                     % for spectral computation, we choose this as a reference time

pathname    = 'D:\DCtrain\A02\ts\proc\EDE\run2';
adu         = ADUs;
adu.name    = 'A02';
adu.run     = '002';
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to transform
adu.usech   = [1 2];                    % we just want to use the first two channels

sp          = EMSpectra;                % Initilaize an EMSpectra object
sp.reftime  = reftime;                  % this is the reftime which will overwrite the reftime property in the adu object
sp.source   = {'D:\DCtrain\A02\fd'};    % Here the spectra will be stored
sp          = EMSpectra(sp,adu);        % This triggers the spectrogram computation

%% compute spectra for the adu data
reftime     = [2014 03 21 00 00 00];    % same reftime as above
pathname    = 'D:\DCtrain\A02\ts\adc\ADU\meas_2014-03-21_11-26-00';
adu         = ADUs;
adu.name    = 'A02';
adu.run     = '001';
adu         = ADUs(adu,pathname);
adu.usesmp  = [1 adu.Nsmp];  % this returns the samples to plot
sp          = EMSpectra;
sp.source   = {'D:\DCtrain\A02\fd'};
sp.reftime  = reftime;
sp          = EMSpectra(sp,adu);

%% plot ede and adu spectra

filename = 'D:\DCtrain\A02\fd\EDE001_R002_ExEy_512H_T20140321-000000.afc';
spe = EMSpectra(filename); 
spe.output = {'Ex' 'Ey'};
spe.usedec = 6;

filename = 'D:\DCtrain\A02\fd\ADU07e346_R001_ExEyBxBy_512H_T20140321-000000.afc';
spa = EMSpectra(filename); 
spa.output = {'Ex' 'Ey'};
spa.usedec = 6;

[a,b,c]=intersect(spa.wr,spe.wr);
spa.setrange = b;
spe.setrange = c;

spa.fcrange  = [4 65];
spe.fcrange  = [4 65];

plot(spa,'channel','Ex','time','utc','clim',[-10 -2],'frequency','Hz');
plot(spe,'channel','Ex','time','utc','clim',[-10 -2],'frequency','Hz');
plot(spa,'channel','Ey','time','utc','clim',[-10 -2],'frequency','Hz');
plot(spe,'channel','Ey','time','utc','clim',[-10 -2],'frequency','Hz');


