% computes spectra and write to *.afc file
%
% Usage: [ts] = MT_ts(ts,'RuntimeOverlap',{<site>,<filter>,<Intervall>})
%
% site   = {'all'}                  consideres all sites in ts
% site   = {'001' '003' '551' '...'} explicitly defines sites to be
%                                    considered
% filter = [sfreq lowpass highpass] defines the recording band;
% filter = []                       all recording bands are considered.
% Intervall=[start stop] defines the time intervall is in times since 1970;
%
% Note :Filter frequencies are given in Hz ( value < 0) or sec (value > 0).
% 	Example 1. [-2 2 0] corresponds to 2 Hz sampling rate, filtered
% 	with a lowpass filter, which has its upper corner frequency at 0.5Hz = 2s.
% 	Example 2. [-32 -8 -4] corresponds to 32 Hz sampling rate, filtered
% 	with a narrow band-pass with corner freqeuncies 8Hz and 4Hz.
%
% FORMAT of afc files
% BOF global header of length <headerlength>
% 1 x int16     global_headerlength
% 1 x int16     channel_headerlength
% 1 x int16     Nch
% 1 x float32   sfreq
% 1 x float32   global starttime of survey, use datestr to convert
% 1 x int16     Ndec
% Ndec x int16  decimation factors
% Ndec x int16  window lengths
% Ndec x int16  noverlapsdecimation factors
% the following block Ndec times, one for each decimation level
% 2 x int32     size of data in 1st decimation level
% 2 x int32     window ids
% 3 x float32   window center times
% 3 x float32   frequencies
% Each channels has its own headerblock, with the first header block
% beginning at global_headerlength(+1) bytes, and the following header
% blocks beginning at
% fseek(fid,global_headerlength+(ich-1)*channel_headerlength+(ich-1)*Nfc*9,
% 'bof'), and Nfc being the total number of Fcs, summed over all decimation
% levels. This number multiplies by 9 byte, four for each real and imaginary part,
% and 1 byte for a binary mask
%
function [obj] = sp_computespectra(obj,ts)

% use the time window as defined by ts.usesmp; make sure before that the
% desired sample range is defined here

% also use the resampled data for the decimation scheme, rather than the
% data at the original sampling frequency
if ts.resmpfreq > 0, 
    ts.resmpfreq = ts.srate;
end

firstsmp = ts.rsmpr; lastsmp  = firstsmp(end); firstsmp = firstsmp(1);
win(1)   = firstsmp/(obj.wlength(1)-obj.noverlap(1));
% we need to know the 

% calculate number of possible decimation levels
idecuse     = 0;
for idec = 1:obj.Ndec
    Nsmp = Nsmp/obj.decimate(idec);
    wlength     = obj.wlength(idec)-obj.noverlap(idec);
    if Nsmp/wlength > 20 % keep at least ~20 windows
       idecuse = 1+idecuse;
    else break; end
end
obj.Ndec        = idecuse;
obj.decimate    = obj.decimate(1:idecuse);
obj.noverlap    = obj.noverlap(1:idecuse);

% at the lowest 
for idec = 1:obj.Ndec
    sfreqdec   = sfreqdec/obj.decimate(idec);
    dw(idec)   = (obj.wlength(idec)-obj.noverlap(idec))/sfreqdec; % length of windows in sec
    w1(idec)   = ceil(t0/dw(idec))*dw(idec);          % time of first sample of first window in sec
    wskip(idec)= round((w1(idec)-t0)*sfreqdec);       % samples to skip after decimation
    winf(idec) = floor(tinf/dw(idec))*dw(idec);
    if (winf(idec)-w1(idec))/dw(idec) > 10 % keep at least 10 windows
        usedec = usedec +1;
    end
end


dtmax   = 1/(obj.sfreq/prod(obj.decimate));  % sampling rate at highest declevel(in sec)

tu      = obj.reftime*24*3600; %survey starttime in seconds
tstart  = bd(b).sgm(isgm).starttime*24*3600 + bd(b).sgm(isgm).starttimems*1e-6+bd(b).sgm(isgm).timeshift-tu;
%                 relative_time_first_sample=(bd(b).sgm(isgm).starttime-survey_starttime)*24*3600 + ...
%                     bd(b).sgm(isgm).starttimems*1e-6+bd(b).sgm(isgm).timeshift;
tinf=(bd(b).sgm(isgm).stoptime)*24*3600 + bd(b).sgm(isgm).stoptimems*1e-6+bd(b).sgm(isgm).timeshift-tu;
% skip the first samples depending on the max . dec. level
dtmax   = 1/(sfreq/prod(fd.decimate));  % sampling rate at highest declevel(in sec)
t0      = ceil(tstart/dtmax)*dtmax;     % time of first sample to use
tskip   = round((t0-tstart)*sfreq);     % samples to skip from file

% calculate number of possible decimation levels for this
% file
sfreqdec = sfreq;
usedec = 0;
for idec = 1:fd.Ndec
    sfreqdec   = sfreqdec/fd.decimate(idec);
    dw(idec)   = (fd.wlength(idec)-fd.noverlap(idec))/sfreqdec; % length of windows in sec
    w1(idec)   = ceil(t0/dw(idec))*dw(idec);          % time of first sample of first window in sec
    wskip(idec)= round((w1(idec)-t0)*sfreqdec);       % samples to skip after decimation
    winf(idec) = floor(tinf/dw(idec))*dw(idec);
    %                     if first_sample_in_file == 0
    %                         first_window               = first_window+1;
    %                         first_sample_in_file       = fd.wlength(idec)-fd.noverlap(idec);
    %                     end
    %                     last_window         = floor(relative_time_last_sample/(fd.wlength(idec)-fd.noverlap(idec))*sfreqdec);
    %                     last_sample_in_file = round((last_window-1)*(fd.wlength(idec)-fd.noverlap(idec))-relative_time_first_sample_to_use*sfreqdec);
    if (winf(idec)-w1(idec))/dw(idec) > 10 % keep at least 10 windows
        usedec = usedec +1;
    end
end

