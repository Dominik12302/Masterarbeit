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
function [ts] = ts_computespectra(ts,site,index,handles)
h = handles.status_text;

sites   =     get(ts,'sitename');
if strcmp(site,'all'),   site     =     sites; end

for k = 1:length(site)
    
    if any(strcmpi(sites,site(k)))
        s       =   find(strcmpi(sites,site(k)));
        bd      =   ts(s).bd;
        survey_starttime = ts(s).surveytime;
        if ~isempty(index)
            b = index(1); isgm = index(2);
            
            % disp(['SPECTRA: site ' ts(s).sitename]);
            survey_starttime = datenum(survey_starttime);
            % disp(['         -survey starttime is ' datestr(survey_starttime)]);
            sfreq = bd(b).sgm(isgm).sfreq;
            if sfreq < 0, sfreq = abs(sfreq); else sfreq = 1./sfreq; end  %sampling frequency
            % Load default decimation scheme: change
            % in mfiles/default_decimation.m
            % disp('SPECTRA: Load default decimation and band setup layout');
            
            [fd,bs,ecode]=default_decimation(sfreq);
            if ~ecode
            else
                tu = survey_starttime*24*3600; %survey starttime in seconds
                tstart = bd(b).sgm(isgm).starttime*24*3600 + bd(b).sgm(isgm).starttimems*1e-6+bd(b).sgm(isgm).timeshift-tu;
                %                 relative_time_first_sample=(bd(b).sgm(isgm).starttime-survey_starttime)*24*3600 + ...
                %                     bd(b).sgm(isgm).starttimems*1e-6+bd(b).sgm(isgm).timeshift;
                tinf=(bd(b).sgm(isgm).stoptime)*24*3600 + bd(b).sgm(isgm).stoptimems*1e-6+bd(b).sgm(isgm).timeshift-tu;
                % skip the first samples depending on the max . dec. level
                dtmax   = 1/(sfreq/prod(fd.decimate)); % sampling rate at highest declevel(in sec)
                t0      = ceil(tstart/dtmax)*dtmax;   % time of first sample to use
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
                
                fd.Ndec = usedec;
                fd.decimate = fd.decimate(1:usedec);
                fd.wlength = fd.wlength(1:usedec);
                fd.noverlap = fd.noverlap(1:usedec);
                bs.fc  = bs.fc(1:usedec);
                bs.fcenter  = bs.fcenter(1:usedec);
                % write header of afc file
                fname   = bd(b).sgm(isgm).ch(1).file{1};
                [pathstr, name, ext] = fileparts(fname);
                indps = strfind(pathstr,[filesep 'ts' filesep]);
                pathstr = fullfile(pathstr(1:indps),'fd');
                if ~exist(pathstr), mkdir(pathstr); end
                if numel(name)>21
                    name = [name(1:16) name(21:end)];
                    foutname    =   [name '.afc'];
                    indR = strfind(foutname,'_R');
                    foutname(indR+2:indR+4) = num2str(isgm-1,'%03d');
                else
                    name = [name(1:3) '_' name(5:6) '_' name(8)];
                    foutname    =   [name '.afc'];
                end
                
                foutname    =   fullfile(pathstr,foutname);
                fd.name = {foutname};
                set(handles.project,'String',foutname);
                %
                fid = fopen(foutname,'w+');
                global_headerlength = 1024;
                channel_headerlength = 1024;
                fwrite(fid,zeros(1,global_headerlength),'int8');
                
                fseek(fid,0,'bof');
                fwrite(fid,global_headerlength,'int16');
                fwrite(fid,channel_headerlength,'int16');
                fwrite(fid,bd(b).sgm(isgm).nch,'int16');
                fwrite(fid,bd(b).sgm(isgm).sfreq,'int32');
                fwrite(fid,survey_starttime,'float32'); % survey starttime, use datestr to convert
                
                fwrite(fid,fd.Ndec,'int16'); % this is the entire layout
                fwrite(fid,fd.decimate,'int16');
                fwrite(fid,fd.wlength,'int16');
                fwrite(fid,fd.noverlap,'int16');
                header_pos = ftell(fid);
                fseek(fid,global_headerlength,'bof');
                
                % read file
                
                FileInfo{1}    = 'FileInfo';
                FileInfo{2}{1} = ts(s).sitename;
                FileInfo{2}{2} = b;
                FileInfo{2}{3} = isgm;
                
                FileInfo{2}{4} = [tskip+1 bd(b).sgm(isgm).nsamples];
                FileInfo{2}{5} = [1:bd(b).sgm(isgm).nsamples-tskip];
                FileInfo{2}{6} = [tskip+1 bd(b).sgm(isgm).nsamples]-1;
                
                
                Nfc = 0; kd = 1; 
                for ich = 1:bd(b).sgm(isgm).nch
                    fseek(fid,global_headerlength+(ich-1)*channel_headerlength+(ich-1)*(Nfc*8+Nfc/kd),'bof');
                    fwrite(fid,zeros(1,channel_headerlength),'int8');
                    fseek(fid,global_headerlength+(ich-1)*channel_headerlength+(ich-1)*(Nfc*8+Nfc/kd),'bof');
                    % write channel infos
                    fwrite(fid,bd(b).sgm(isgm).ch(ich).name{1}(1:2),'char*1');
                    fwrite(fid,bd(b).sgm(isgm).ch(ich).type{1}(1:2),'char*1');
                    fwrite(fid,numel(bd(b).sgm(isgm).ch(ich).file{1}),'int16');
                    fwrite(fid,bd(b).sgm(isgm).ch(ich).file{1},'char*1');
                    fseek(fid,global_headerlength+ich*channel_headerlength+(ich-1)*(Nfc*8+Nfc/kd),'bof');
                    FileInfo{2}{7}          = ich;
                    set(h,'String',['+Reading time series for channel ' bd(b).sgm(isgm).ch(ich).name{1}]);
                    pause(0.1);
                    %disp(['+Reading time series for channel ' bd(b).sgm(isgm).ch(ich).name{1}]);
                    FileData                = readdata(ts,FileInfo);
                    FileData{2}.PlotSmp{1}  = [];
                    sfreqdec = sfreq;
                    
                    for idec = 1:fd.Ndec
                        sfreqdec = sfreqdec/fd.decimate(idec);
                        df       = sfreqdec/fd.wlength(idec);
                        f        = linspace(df,sfreqdec/2,fd.wlength(idec)/2);
                        set(h,'String',['Decimation level ' num2str(idec) ': decimated Samplingrate @ ' num2str(sfreqdec,'%.3f')]);
                        pause(0.1);
                        windowtype = get(handles.taper,'String');
                        windowtype = windowtype{get(handles.taper,'Value')};
                        switch windowtype
                            case 'hamming'
                                wnd = hamming(fd.wlength(idec),'periodic');
                            case 'hanning'
                                wnd = hann(fd.wlength(idec),'periodic');
                            case 'parzenwin'
                                wnd = parzenwin(fd.wlength(idec));
                            case 'dpss'
                                NW  = eval(get(handles.spectra_NW,'String'));
                                kd   = 1; %max(round(2*NW)-1,1);
                                wnd = dpss(fd.wlength(idec),NW,kd);
                            case 'box (none)'
                                wnd = ones([fd.wlength(idec), 1]);
                        end

                        if fd.decimate(idec) > 1
                            FileData{2}.Data{1} = decimate(FileData{2}.Data{1},fd.decimate(idec),300,'fir');
                        end
                        
                        %% prewhitening
                        prew = get(handles.prewhitening,'String');
                        prew = prew{get(handles.prewhitening,'Value')};
                        switch prew
                            case 'first difference'
                                tmp = diff(FileData{2}.Data{1});
                            otherwise
                                tmp = (FileData{2}.Data{1});
                        end
                        %% delay filter
                        if get(handles.delay,'value')
                            delayfreq = eval(get(handles.delayfreq,'String'));
                            
                            % shift samples
                            for idf = 1:numel(delayfreq)
                            if sfreqdec > delayfreq(idf)
                                shftsamples = sfreqdec/delayfreq(idf);
                                t = 1:numel(tmp);
                                tmp = tmp-interp1(t,tmp,t+shftsamples,'spline');
                                tmp(numel(tmp)-floor(shftsamples):end) = 0;
                            end
                            end
                        end
                        switch get(handles.spectra_method,'Value')
                            case 2
                                [S,F,T] = my_cmtm2(tmp(1,wskip(idec)+1:end),sfreqdec,4,fd.noverlap(idec),fd.wlength(idec));
                            case 1
                                [S,F,T] = spectrogram(tmp(1,wskip(idec)+1:end),wnd,fd.noverlap(idec),fd.wlength(idec),sfreqdec);
                        end
                        kd = size(S,3);
                        F(1) = 1;
                        fac = 2./(sfreqdec*sum(abs(wnd(1:numel(wnd))).^2)); % accounts for the effect of the taper somewhow
                        S = S*sqrt(fac);                        
                        % Undo prewhitening
                        switch prew
                            case 'first difference'
                                for ik = 1:size(S,3)
%                                     S(:,:,ik) = S(:,:,ik)./repmat(1i*2*pi*F,1,size(S,2));
                                end
                        end
                       % scale by sqrt(f)
                       %                                                         if 1
                       %                                                             S = S.*repmat((F),1,size(S,2));
                       %                                                         end
                        F(1) = 0;
                        
                        % calibration
                        cal = interp1(bd(b).sgm(isgm).ch(ich).cal_data(1,:),bd(b).sgm(isgm).ch(ich).cal_data(2,:).* ...
                            exp(1i*bd(b).sgm(isgm).ch(ich).cal_data(3,:)*pi/180),F(1:end));
                        cal(1) = cal(2);
                        
                        % bug fix for nans in metronix calibration
                        % files
                        indnan = find(isnan(cal));
                        if ~isempty(indnan)
                            cal(indnan) =  0.0051 + 0.2000i;
                        end
                        for ik = 1:size(S,3)
                            S(:,:,ik) = S(:,:,ik)./repmat(cal,1,size(S,2));
                        end
                        % magnetics are now in nT, electrics in
                        % mV/km
                        for ik = 1:size(S,3)
                            fwrite(fid,real(S(:,:,ik).'),'float32');
                            fwrite(fid,imag(S(:,:,ik).'),'float32');
                        end
                        fwrite(fid,ones(size(S(:,:,1).')),'uint8');
                        
                        % additional information added to global
                        % header
                        if ich == 1
                            tmp = ftell(fid);
                            fseek(fid,header_pos,'bof');
                            if numel(size(S))==2
                                fwrite(fid,[size(S) 1],'int32'); % size of data in that decimation level
                            else
                                fwrite(fid,size(S),'int32'); % size of data in that decimation level
                            end
                            fwrite(fid,[w1(idec)/dw(idec) size(S,2)],'int32'); % window ids % uncommented this and
%                             fwrite(fid,[w1(idec) size(S,2)],'int32'); % window ids % commented this following wouter
                            fwrite(fid,[T(1) T(end) T(2)-T(1)],'float32'); % window center times
                            fwrite(fid,[F(1) F(end) F(2)-F(1)],'float32'); % frequnecies
                            %fwrite(fid,[first_window last_window last_window-first_window],'float32'); % frequnecies
                            header_pos = ftell(fid);
                            Nfc = numel(S)+Nfc;
                            fseek(fid,tmp,'bof');
                            fdF(idec,:) = [F(1) F(end) F(2)-F(1)];
                            fdT(idec,:) = [T(1) T(end) T(2)-T(1)];
                            fdW(idec,:) = [w1(idec)/dw(idec) size(S,2)]; % uncommented this 
%                            fdW(idec,:) = [w1(idec) size(S,2)]; and commented this following wouter
                        end
                        clear S;
                    end
                    ts(s).bd(b).sgm(isgm).fd.file       = fd.name;
                    ts(s).bd(b).sgm(isgm).fd.Ndec       = fd.Ndec;
                    ts(s).bd(b).sgm(isgm).fd.decimate   = fd.decimate;
                    ts(s).bd(b).sgm(isgm).fd.wlength    = fd.wlength;
                    ts(s).bd(b).sgm(isgm).fd.noverlap   = fd.noverlap;
                    ts(s).bd(b).sgm(isgm).fd.F          = fdF;
                    ts(s).bd(b).sgm(isgm).fd.W          = fdW;
                    ts(s).bd(b).sgm(isgm).fd.T          = fdT;
                    ts(s).bd(b).sgm(isgm).bs            = bs;
                    
                end
                fclose(fid);
                set(handles.project,'String',ts(s).project{1});
            end
        end
    else
        disp(['Warning: site ' site{k} ' not found!']);
    end
end
set(h,'String','ok');


