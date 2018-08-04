%% load synchronous recordings of ADU and ede and plot the time series resampled to 8 Hz
% adu data from site A02
usetime     = [2014 03 22 00 00 00 2014 03 22 12 00 00]; % we look at 12 hours, from midnight to noon
reftime     = [2014 03 22 00 00 00];                     % for plotting, we choose this as a reference time
pathname    = 'D:\DCtrain\A02\ts\adc\ADU\meas_2014-03-21_11-26-00';
adu         = ADUs;
adu.name    = 'A02';
adu.debuglevel = 1;
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to plot
adu.usech   = [1 2];                    % we just want to plot the first two channels
adu.reftime = reftime;     
adu.resmpfreq = 8;                      % to resample to 8 Hz
hax         = plot(adu,'time','relative h','units','mV','elim',[-10 10],'factor',[1 -1]);
% ede data from site A02
pathname    = 'D:\DCtrain\A02\ts\adc\EDE\run2';
ede         = EDEs;
ede.name    = 'A02';
ede.run     = '002';
ede.debuglevel = 1;
ede         = EDEs(ede,pathname);
ede.usesmp  = get_usesmp(ede,usetime);
ede.usech   = [1 2];
ede.reftime = reftime;
ede.resmpfreq = 8;
hax         = plot(ede,'time','relative h','units','mV','axes',hax);

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
atsfiles    = ede.atsfile;          % returns the ats filenames
  
%% load the converted ede data into an adu class and compare with the true adu data
% adu data from site A02
usetime     = [2014 03 22 00 00 00 2014 03 22 00 00 01]; % we look at 1 sec, at midnight
reftime     = [2014 03 22 00 00 00];
pathname    = 'D:\DCtrain\A02\ts\adc\ADU\meas_2014-03-21_11-26-00';
adu         = ADUs;
adu.name    = 'A02';
adu.debuglevel = 1;
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to plot
adu.usech   = [1 2];                    % we just want to plot the first two channels
adu.reftime = reftime;                  % for plotting, we choose this as a reference time
hax         = plot(adu,'time','relative s','units','mV','elim',[-100 100],'factor',[1 -1]);

% converted ede data
pathname    = 'D:\DCtrain\A02\ts\adc\EDE\run2';
adu         = ADUs;
adu.name    = 'A02';
adu.debuglevel = 1;
adu         = ADUs(adu,pathname);
adu.usesmp  = get_usesmp(adu,usetime);  % this returns the samples to plot
adu.usech   = [1 2];                    % we just want to plot the first two channels
adu.reftime = reftime;                  % for plotting, we choose this as a reference time
hax         = plot(adu,'time','relative s','units','mV','axes',hax);
