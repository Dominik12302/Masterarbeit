function [fd,bs,ecode] = sp_defaultdecimation(sfreq)

% dyadic sampling frequency?
fd.Ndec = [];
fd.decimate = [];
fd.wlength = [];
fd.noverlap = [];
bs = [];
ecode = 1;
if round(log2(sfreq))==log2(sfreq)
    %  lbase = 2;
    if sfreq == 524288
        fd.Ndec = 1; 
        fd.decimate = [1];
        fd.wlength = [2^12];
        fd.noverlap= [2^11];
    elseif sfreq == 65536
        fd.Ndec = 1; 
        fd.decimate = [1];
        fd.wlength = [2^12];
        fd.noverlap= [2^11];
    elseif sfreq >= 512, 
        fd.Ndec = 10; 
        fd.decimate = [1 4 4 4 4 4 4 4 4 4];
        fd.wlength = [128 128 128 128 128 128 128 128 128 128];
        fd.noverlap= [32 32 32 32 32 32 32 32 64 64];
    elseif sfreq >= 32 
        fd.Ndec = 10; 
        fd.decimate = [1 4 4 4 4 4 4 4 4 4];
        fd.wlength = [128 128 128 128 128 128 128 128 128 128];
        fd.noverlap= [32 32 32 32 32 32 32 64 64 64];
    elseif sfreq >= 2
        fd.Ndec = 8; 
        fd.decimate = [ 1   4   4   4   4  4  4  4];
        fd.wlength = [128 128 128 128 128 64 64 64];
        fd.noverlap= [ 32  32  32  32  32 32 32 32];
%     elseif sfreq >= 32
%         fd.Ndec = 6; 
%         fd.decimate = [1 4 4 4 4 4];
%         fd.wlength = [128 128 128 128 128 128];
%         fd.noverlap= [64 64 64 64 64 64];
    else
        fd.Ndec = 7; 
        fd.decimate = [1 4 4 4 4 4 4];
        fd.wlength = [128 128 128 128 128 128 128];
        fd.noverlap= [32 32 32 32 64 64 64];
    end
    if log2(sfreq)/2==round(log2(sfreq)/2) 
        fd.decimate(2) = 2;
    end
    if sfreq == 524288
        frange = [sfreq/2 sfreq/prod(fd.decimate)/128];
    else
        frange = [sfreq/4 sfreq/prod(fd.decimate)/fd.wlength(end)*4];
    end
    targetf= sort(2.^(log2(min(frange)):0.5:log2(max(frange))),'descend');
    sfreqdec = sfreq;
    for idec = 1:fd.Ndec
        sfreqdec = sfreqdec/fd.decimate(idec);
        df = sfreqdec./fd.wlength(idec);
        fc = [0:df:sfreqdec/2]; fc = fc(1:((numel(fc)-1)/1.6+1));
        targetfind = find(targetf<=max(fc) & targetf>=fc(5));
%         if idec<fd.Ndec
%             fcnext = [0:df:sfreqdec/2/fd.decimate(idec+1)]; fcnext = fcnext(1:((numel(fcnext)-1)/4*3+1));
%             targetfind = targetfind(targetf(targetfind)>max(fcnext));
%         end
        for ifi = 1:numel(targetfind)
            fcenter = targetf(targetfind(ifi)); 
            bs.fc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.25) & log2(fc)>(log2(fcenter)-0.25));
            bs.fcenter{idec}(ifi) = fcenter;
        end
    end
    % remove overlapping coefficients
    for idec = 1:fd.Ndec-1
        ind = find(bs.fcenter{idec}<=bs.fcenter{idec+1}(1));
        bs.fcenter{idec}(ind) = [];
        bs.fc{idec} = bs.fc{idec}(1:ind(1)-1);
    end
    %     delete bands with less than 3 fcs
    ind = [];
    for fi = 1:numel(bs.fc{fd.Ndec})
        if numel(bs.fc{fd.Ndec}{fi})<=2
            ind = [ind fi];
        end
    end
    bs.fc{fd.Ndec}(ind) = [];
    bs.fcenter{fd.Ndec}(ind) = [];
    % the 10-base does not really work
elseif round(log10(sfreq))==log10(sfreq)
    disp(['decimation scheme for sampling with ' num2str(sfreq) ' not really implemented!!!']);
    %  lbase = 2;
    if sfreq == 524288
        fd.Ndec = 1; 
        fd.decimate = [1];
        fd.wlength = [2^12];
        fd.noverlap= [2^11];
    elseif sfreq == 65536
        fd.Ndec = 1; 
        fd.decimate = [1];
        fd.wlength = [2^12];
        fd.noverlap= [2^11];
    elseif sfreq >= 500, 
        fd.Ndec = 6; 
        fd.decimate = [1 4 4 4 4 4 ];
        fd.wlength = [512 512 512  512 512 512];
        fd.noverlap= [256 256 256  256 256 256];
    elseif sfreq >= 32 
        fd.Ndec = 8; 
        fd.decimate = [1 4 4 4 4 4 4 4];
        fd.wlength = [128 128 128 128 128 128 128 128];
        fd.noverlap= [32 32 32 32 32 32 64 64];
    elseif sfreq >= 32
        fd.Ndec = 6; 
        fd.decimate = [1 4 4 4 4 4];
        fd.wlength = [128 128 128 128 128 128];
        fd.noverlap= [64 64 64 64 64 64];
    else
        fd.Ndec = 7; 
        fd.decimate = [1 4 4 4 4 4 4];
        fd.wlength = [128 128 128 128 128 128 128];
        fd.noverlap= [32 32 32 32 64 64 64];
    end
    if log2(sfreq)/2==round(log2(sfreq)/2) 
        fd.decimate(2) = 2;
    end
    if sfreq == 524288
        frange = [sfreq/2 sfreq/prod(fd.decimate)/128];
    else
        frange = [sfreq/4 sfreq/prod(fd.decimate)/fd.wlength(end)*4];
    end
    targetf= sort(2.^(log2(min(frange)):0.5:log2(max(frange))),'descend');
    sfreqdec = sfreq;
    for idec = 1:fd.Ndec
        sfreqdec = sfreqdec/fd.decimate(idec);
        df = sfreqdec./fd.wlength(idec);
        fc = [0:df:sfreqdec/2]; fc = fc(1:((numel(fc)-1)/1.6+1));
        targetfind = find(targetf<=max(fc) & targetf>=fc(5));
%         if idec<fd.Ndec
%             fcnext = [0:df:sfreqdec/2/fd.decimate(idec+1)]; fcnext = fcnext(1:((numel(fcnext)-1)/4*3+1));
%             targetfind = targetfind(targetf(targetfind)>max(fcnext));
%         end
        for ifi = 1:numel(targetfind)
            fcenter = targetf(targetfind(ifi)); 
            bs.fc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.25) & log2(fc)>(log2(fcenter)-0.25));
            bs.fcenter{idec}(ifi) = fcenter;
        end
    end
    % remove overlapping coefficients
    for idec = 1:fd.Ndec-1
        ind = find(bs.fcenter{idec}<=bs.fcenter{idec+1}(1));
        bs.fcenter{idec}(ind) = [];
        bs.fc{idec} = bs.fc{idec}(1:ind(1)-1);
    end
    %     delete bands with less than 3 fcs
    ind = [];
    for fi = 1:numel(bs.fc{fd.Ndec})
        if numel(bs.fc{fd.Ndec}{fi})<=2
            ind = [ind fi];
        end
    end
    bs.fc{fd.Ndec}(ind) = [];
    bs.fcenter{fd.Ndec}(ind) = [];
    % the 10-base does not really work
else 
    ecode = 0;
    disp(['DECIMATE: no scheme available for sampling freq ' num2str(sfreq)]);
end
