% compute spectrogramm and write to disc

function obj = sp_writeafc(obj,ts)

obj.tssource = ts.source;
obj.name     = ts.name;
obj.run      = ts.run;
obj.lat      = ts.lat;
obj.lon      = ts.lon;
obj.alt      = ts.alt;
obj.Nch      = numel(ts.usech);
obj.chnames  = ts.chnames(ts.usech);
obj.chtypes  = ts.chnames(ts.usech);
obj.sens_name= ts.sens_name(ts.usech);
obj.sens_sn  = ts.sens_sn(ts.usech);

if ts.resmpfreq == 0, ts.resmpfreq = ts.srate; end
obj.srate = ts.srate;

if obj.srate >= 1, srate = [num2str(round(obj.srate)) 'H'];
else srate = [num2str(round(1./obj.srate)) 'S'];
end

% outputfilename, make output directory if necessary and possible
fname = [ts.system ts.systemSN '_R' obj.run '_' [obj.chnames{ts.usech}] '_' srate ...
    '_T' num2str(obj.reftime(1),'%04d')  num2str(obj.reftime(2),'%02d')  num2str(obj.reftime(3),'%02d') '-' ...
    num2str(obj.reftime(4),'%02d') num2str(obj.reftime(5),'%02d') num2str(obj.reftime(6),'%02d') '.afc'];
if isdir(obj.source{1})
    obj.source = {fullfile(obj.source{1},fname)};
elseif isdir(fullfile(obj.source{1},'..'))
    if obj.debuglevel == 1, disp([' - creating directory ' obj.source{1} ' ...']); end
    mkdir(obj.source{1});
    obj.source = {fullfile(obj.source{1},fname)};
else
    disp(['** Error: Target directory ' obj.source ' does not exist']);
    return;
end

%% make sure, we use the reftime defined in the EMspectra obj.
ts.reftime  = obj.reftime;
% extract the sample range of the data relative to
% reftime; Note that we do not use all samples as
% the default but only the samples given by ts.usesmpr
% (corresponding to the time interval ts.usetime)
obj.srate   = ts.resmpfreq;

smp1        = ts.rsmpr; 
smp2        = smp1(end); 
smp1        = smp1(1);
smprange    = [smp1 smp2];
% calculate number of possible decimation levels
% such that at least 10 windows remain at the
% largest decimation level. Do this only roughly,
% because I ignore the overlap between the windows,
% and do not test how many windows really fit given
% that we will have to cut off some samples when
% using the global time axis
Nsmp            = diff(smprange)+1;
ind             = find(Nsmp./(obj.wlength.*cumprod(obj.decimate))>10);
obj.Ndec        = numel(ind);
obj.decimate    = obj.decimate(ind);
obj.wlength     = obj.wlength(ind);
obj.noverlap    = obj.noverlap(ind);
obj.prew        = obj.prew(ind);
% ok, now we should be able to determine the actual
% sample range being used for each decimation level. We do
% this by considering the number of samples at the
% original sampling rate, required to form windows
% of length wlength at each decimation level at the
% decimated sampling rate.

% iwin+1 is the counter of the first window to
% use relative to reftime
win1      = ceil((smprange(1)-1)./((obj.wlength-obj.noverlap).*cumprod(obj.decimate)));
% ismp+1 is the first sample to use relative to reftime
smp1      = win1.*((obj.wlength-obj.noverlap).*cumprod(obj.decimate));
% win2+1 is the last window to use, relative to
% reftime
win2      = floor((smprange(2)-obj.wlength.*cumprod(obj.decimate))./((obj.wlength-obj.noverlap).*cumprod(obj.decimate)));
% smp2 is the last sample to use, relative to reftime
smp2      = win2.*((obj.wlength-obj.noverlap).*cumprod(obj.decimate))+obj.wlength.*cumprod(obj.decimate);
% now we know that we have to read samples
% [smp1+1:smp2] relative to reftime, if the data were resampled. This
% corresponds to a different set of samples of the
% original data. So, we must recalculate the usesmp
% property of the time series object
% we will have a problem, if the first window does
% not start at a full second, and if the last
% window does not end at a full second

% let us recalculate the usetime and usesmp
% properties for each decimation level
for idec = 1:obj.Ndec
    usetime   = [obj.reftime obj.reftime];
    usetime(6)  = usetime(6)+smp1(idec)/obj.srate;
    usetime(12) = usetime(12)+ceil(smp2(idec)/obj.srate);
    usetimedec(idec,:)= [datevec(datenum(usetime(1:6))) datevec(datenum(usetime(7:12)))];
    usesmpdec(idec,:) = get_usesmp(ts,usetimedec(idec,:));
    if idec > 1
        if usesmpdec(idec,1) < usesmpdec(idec-1,1) % go one window further
            usesmpdec(idec,1) = usesmpdec(idec,1)+(obj.wlength(idec)-obj.noverlap(idec))*prod(obj.decimate(1:idec));
            win1(idec) = win1(idec+1);
        end
    end
end
obj.W = [win1+1; win2+1]';
% before decimating, we have to skip this ampount
% of samples
smpskip   = diff(usesmpdec(:,1))./cumprod(obj.decimate(1:end-1))';
ts.usesmp = [usesmpdec(1,1)  max(usesmpdec(:,2))];
usech     = ts.usech;
if obj.debuglevel == 1, disp([' - creating spectra file ' obj.source{1} ' ...']); end
% write general header
fid = fopen(obj.source{1},'w+');
fwrite(fid,zeros(1,obj.global_headerlength),'int8');
fseek(fid,0,'bof');
fwrite(fid,obj.global_headerlength,'int16');
fwrite(fid,obj.channel_headerlength,'int16');
Ns = numel(obj.name);
fwrite(fid,Ns,'int16');
fwrite(fid,obj.name,'char*1');
Ns = numel(obj.run);
fwrite(fid,Ns,'int16');
fwrite(fid,obj.run,'char*1');
fwrite(fid,obj.lat,'float32');
fwrite(fid,obj.lon,'float32');
fwrite(fid,obj.alt,'float32');
fwrite(fid,obj.Nch,'int16');
fwrite(fid,obj.srate,'int32');
fwrite(fid,datenum(obj.reftime),'float32'); % reference time in datenum format, use datestr to convert
fwrite(fid,obj.Ndec,'int16'); % this is the entire layout
fwrite(fid,obj.decimate,'int16');
fwrite(fid,obj.wlength,'int16');
fwrite(fid,obj.noverlap,'int16');
fwrite(fid,obj.prew,'int16');
fwrite(fid,obj.window(1:4),'char*1');
fwrite(fid,obj.Nk,'int16');
fwrite(fid,obj.timebandwidth,'int16');
Ns = numel(obj.tssource{1});
fwrite(fid,Ns,'int16');
fwrite(fid,obj.tssource{1},'char*1');
header_pos = ftell(fid);
Nfc = 0;
for ich = 1:numel(usech)
    if obj.debuglevel == 1, disp([' + Channel ' obj.chnames{ich}]); end
    fseek(fid,obj.global_headerlength+(ich-1)*obj.channel_headerlength+(ich-1)*(Nfc*8+Nfc/obj.Nk),'bof');
    fwrite(fid,zeros(1,obj.channel_headerlength),'int8');
    fseek(fid,obj.global_headerlength+(ich-1)*obj.channel_headerlength+(ich-1)*(Nfc*8+Nfc/obj.Nk),'bof');
    % write channel infos
    fwrite(fid,obj.chnames{ich}(1:2),'char*1');
    fwrite(fid,obj.chtypes{ich}(1:2),'char*1');
    % write additional staff here like calibration
    % data etc.
    % ...
    fseek(fid,obj.global_headerlength+ich*obj.channel_headerlength+(ich-1)*(Nfc*8+Nfc/obj.Nk),'bof');
    ts.usech = usech(ich);
    data = ts.dataphys;
    f = 1;
    for idec = 1:obj.Ndec      
        if obj.decimate(idec)>1
            if obj.sratedec(idec) >= 1, srd = [num2str(obj.sratedec(idec)) ' Hz']; 
            else srd = [num2str(1./obj.sratedec(idec)) ' sec']; end
            if obj.debuglevel == 1, 
                if f, fprintf(1,' - decimating to '); f=0; end
                fprintf(1,[srd ' / ' ]); 
                if idec == obj.Ndec, fprintf(1,'\b\b\n'); end; 
            end
            data = decimate(data(smpskip(idec-1)+1:end),obj.decimate(idec),300,'fir'); %#ok<*CPROP>
        end
        switch obj.window
            case 'hamming'
                wnd = hamming(obj.wlength(idec),'periodic');
            case 'hanning'
                wnd = hann(obj.wlength(idec),'periodic');
            case 'parzenwin'
                wnd = parzenwin(obj.wlength(idec));
            case 'dpss'
                wnd = dpss(obj.wlength(idec),obj.timebandwidth,obj.Nk);
            case 'rectangular'
                wnd = ones([obj.wlength(idec), 1]);
        end
        shftmethod = 'spectrogram';
        switch shftmethod
            case 'multitaper'
                [S,F,T] = my_cmtm2(tmp(1,wskip(idec)+1:end),sfreqdec,4,fd.noverlap(idec),fd.wlength(idec));
            case 'spectrogram'
                [S,F,T] = spectrogram(data,wnd,obj.noverlap(idec),obj.wlength(idec),obj.sratedec(idec));
        end
        T0              = win1(idec)*(obj.wlength(idec)-obj.noverlap(idec))./obj.sratedec(idec);
        T1              = T(1)+T0;
        T2              = T(end)+T0;
        dT              = T(2)-T(1);     % seconds since reftime
        obj.W(idec,:)   = obj.W(idec,1)+[1 numel(T)];
        obj.T(idec,:)   = [T1 T2 dT];
        obj.F(idec,:)   = [F(1) F(end) F(2)-F(1)];
        obj.Nsets(idec) = numel(T);
        obj.Nf(idec)    = numel(F);
        k               = size(S,3);
        F(1)            = 1;
        fac             = 2./(obj.sratedec(idec)*sum(abs(wnd(1:numel(wnd))).^2)); % accounts for the effect of the taper somewhow
        S               = S*sqrt(fac);
        F(1) = 0;
        % magnetics are now in nT, electrics in
        % mV/km
        for ik = 1:size(S,3)
            fwrite(fid,real(S(:,:,ik).'),'float32');
            fwrite(fid,imag(S(:,:,ik).'),'float32');
        end
        fwrite(fid,ones(size(S(:,:,1).')),'uint8');
        % additional information added to global
        % header
        obj.Nsets(idec) = size(S,2);
        obj.Nf(idec)    = size(S,1);
        %         obj.Nk(idec)    = size(S,3);
        if ich == 1
            tmp = ftell(fid);
            fseek(fid,header_pos,'bof');
            if numel(size(S))==2
                fwrite(fid,[size(S) 1],'int32'); % size of data in that decimation level
            else
                fwrite(fid,size(S),'int32'); % size of data in that decimation level
            end
            fwrite(fid,[obj.W(idec,1) obj.W(idec,2)],'int32');   % window ids % uncommented this and
            fwrite(fid,[obj.T(idec,1) obj.T(idec,2) obj.T(idec,3)],'float32'); % central time of window with respect to reftime, and time increment,
            fwrite(fid,[obj.F(idec,1) obj.F(idec,2) obj.F(idec,3)],'float32'); % frequnecies
            %fwrite(fid,[first_window last_window last_window-first_window],'float32'); % frequnecies
            header_pos = ftell(fid);
            Nfc = numel(S)+Nfc;
            fseek(fid,tmp,'bof');
        end
        clear S;
        
    end
end
fclose(fid);