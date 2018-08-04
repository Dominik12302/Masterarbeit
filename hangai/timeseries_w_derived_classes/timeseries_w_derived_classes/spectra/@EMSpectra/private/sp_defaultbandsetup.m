function bs = sp_defaultbandsetup(hd)   
if hd.sfreq<0, sfreq = -hd.sfreq;
else sfreq = 1/hd.sfreq; end
fd.decimate = hd.decimation;
fd.wlength = hd.windowlength;
fd.Ndec = hd.Ndec;

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
        if sfreqdec  == 524288
            fc = [0:df:sfreqdec/2]; fc = fc(1:((numel(fc)-1)/1+1));
        else
            fc = [0:df:sfreqdec/2]; fc = fc(1:((numel(fc)-1)/1.6+1));
        end
        targetfind = find(targetf<=max(fc) & targetf>=fc(5));
%         if idec<fd.Ndec
%             fcnext = [0:df:sfreqdec/2/fd.decimate(idec+1)]; fcnext = fcnext(1:((numel(fcnext)-1)/4*3+1));
%             targetfind = targetfind(targetf(targetfind)>max(fcnext));
%         end
        for ifi = 1:numel(targetfind)
            fcenter = targetf(targetfind(ifi)); 
%             if fcenter < 30000
            bs.fc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.75) & log2(fc)>(log2(fcenter)-0.75));
%             else
%             bs.fc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.25) & log2(fc)>(log2(fcenter)-0.25));
%             end
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
