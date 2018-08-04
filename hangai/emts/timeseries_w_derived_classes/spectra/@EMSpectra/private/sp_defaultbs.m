function obj = sp_defaultbs(obj)
% sfreq = obj.srate;
% % dyadic sampling frequency?
% fd.Ndec = [];
% fd.decimate = [];
% fd.wlength = [];
% fd.noverlap = [];
% if round(log2(sfreq))==log2(sfreq)
%     %  lbase = 2;
%     if sfreq == 524288
%         fd.Ndec = 1;
%         fd.decimate = [1];
%         fd.wlength = [2^12];
%         fd.noverlap= [2^11];
%     elseif sfreq == 65536
%         fd.Ndec = 1;
%         fd.decimate = [1];
%         fd.wlength = [2^12];
%         fd.noverlap= [2^11];
%     elseif sfreq >= 512,
%         fd.Ndec = 9;
%         fd.decimate = [1 4 4 4 4 4 4 4 4 4];
%         fd.wlength = [128 128 128 128 128 128 128 128 128 128];
%         fd.noverlap= [32 32 32 32 32 32 32 32 64 64];
%     elseif sfreq >= 32
%         fd.Ndec = 10;
%         fd.decimate = [1 4 4 4 4 4 4 4 4 4];
%         fd.wlength = [128 128 128 128 128 128 128 128 128 128];
%         fd.noverlap= [32 32 32 32 32 32 32 64 64 64];
%     elseif sfreq >= 2
%         fd.Ndec = 7;
%         fd.decimate = [ 1   4   4   4   4  4  4  4];
%         fd.wlength = [128 128 128 128  64 64 64 64];
%         fd.noverlap= [ 32  32  32  32  32 32 32 32];
%         %     elseif sfreq >= 32
%         %         fd.Ndec = 6;
%         %         fd.decimate = [1 4 4 4 4 4];
%         %         fd.wlength = [128 128 128 128 128 128];
%         %         fd.noverlap= [64 64 64 64 64 64];
%     else
%         fd.Ndec = 7;
%         fd.decimate = [1 4 4 4 4 4 4];
%         fd.wlength = [128 128 128 128 128 128 128];
%         fd.noverlap= [32 32 32 32 64 64 64];
%     end
%     
%     obj.Ndec = fd.Ndec;
%     obj.wlength = fd.wlength;
%     obj.noverlap = fd.noverlap;
%     obj.decimate = fd.decimate;
% end
switch obj.bandsetup
    case 'MT2'
        
        frange = [obj.srate/4 obj.srate/prod(obj.decimate)/obj.wlength(end)*4];
        targetf= sort(2.^(log2(min(frange)):0.5:log2(max(frange))),'descend');
        for idec = 1:obj.Ndec
            df = obj.sratedec(idec)./obj.wlength(idec);
            fc = [0:df:obj.sratedec(idec)/3];
            targetfind = find(targetf<=max(fc) & targetf>=fc(5));
            for ifi = 1:numel(targetfind)
                fcenter = targetf(targetfind(ifi));
                obj.bsfc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.25) & log2(fc)>(log2(fcenter)-0.25));
                if fcenter == 64
                    obj.bsfc{idec}{ifi} = obj.bsfc{idec}{ifi}(2:end);
                end
                if fcenter > 45 && fcenter < 46
                    obj.bsfc{idec}{ifi} = obj.bsfc{idec}{ifi}([1 2]);
                end
                if fcenter > 90 && fcenter < 100
                    obj.bsfc{idec}{ifi} = obj.bsfc{idec}{ifi}([1:min(4,end)]);
                end
                
                
                obj.bsfcenter{idec}(ifi) = fcenter;
            end
        end
        
        
    case 'MT'
        frange = [obj.srate/4 obj.srate/prod(obj.decimate)/obj.wlength(end)*4];
        targetf= sort(2.^(log2(min(frange)):0.5:log2(max(frange))),'descend');
        for idec = 1:obj.Ndec
            df = obj.sratedec(idec)/obj.wlength(idec);
            fc = 0:df:obj.sratedec(idec)/2; fc = fc(1:ceil(((numel(fc)-1)/1.6+1)));
            targetfind = find(targetf<=max(fc) & targetf>=fc(5));
            for ifi = 1:numel(targetfind)
                fcenter = targetf(targetfind(ifi));
                obj.bsfc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.25) & log2(fc)>(log2(fcenter)-0.25));
                %                 if fcenter == 64
                %                      obj.bsfc{idec}{ifi} = obj.bsfc{idec}{ifi}(2:end);
                %                  end
                if fcenter > 45 && fcenter < 46
                    obj.bsfc{idec}{ifi} = obj.bsfc{idec}{ifi}([1 2]);
                end
                %                  if fcenter > 90 && fcenter < 100
                %                      obj.bsfc{idec}{ifi} = obj.bsfc{idec}{ifi}([1:min(4,end)]);
                %                  end
                
                
                obj.bsfcenter{idec}(ifi) = fcenter;
            end
        end
        % remove overlapping coefficients
        for idec = 1:obj.Ndec-1
            ind = find(obj.bsfcenter{idec}<=obj.bsfcenter{idec+1}(1));
            obj.bsfcenter{idec}(ind) = [];
            obj.bsfc{idec} = obj.bsfc{idec}(1:ind(1)-1);
        end
        %     delete bands with less than 3 fcs
        ind = [];
        for fi = 1:numel(obj.bsfc{obj.Ndec})
            if numel(obj.bsfc{obj.Ndec}{fi})<=2
                ind = [ind fi];
            end
        end
        obj.bsfc{obj.Ndec}(ind) = [];
        obj.bsfcenter{obj.Ndec}(ind) = [];
    case 'RMT'
        
        frange = [obj.srate/2 obj.srate/prod(obj.decimate)/128];
        targetf= sort(2.^(log2(min(frange)):0.5:log2(max(frange))),'descend');
        for idec = 1:obj.Ndec
            df = obj.sratedec(idec)./obj.wlength(idec);
            fc = [0:df:obj.sratedec(idec)/2]; fc = fc(1:((numel(fc)-1)/1+1));
            targetfind = find(targetf<=max(fc) & targetf>=fc(5));
            for ifi = 1:numel(targetfind)
                fcenter = targetf(targetfind(ifi));
                if fcenter > 15000
                    obj.bsfc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.5) & log2(fc)>(log2(fcenter)-0.5));
                else
                    obj.bsfc{idec}{ifi} = find(log2(fc)<(log2(fcenter)+0.5) & log2(fc)>(log2(fcenter)-0.5));
                end
                obj.bsfcenter{idec}(ifi) = fcenter;
            end
        end
        % remove overlapping coefficients
        for idec = 1:obj.Ndec-1
            ind = find(obj.bsfcenter{idec}<=obj.bsfcenter{idec+1}(1));
            obj.bsfcenter{idec}(ind) = [];
            obj.bsfc{idec} = obj.bsfc{idec}(1:ind(1)-1);
        end
        %     delete bands with less than 3 fcs
        ind = [];
        for fi = 1:numel(obj.bsfc{obj.Ndec})
            if numel(obj.bsfc{obj.Ndec}{fi})<=2
                ind = [ind fi];
            end
        end
        obj.bsfc{obj.Ndec}(ind) = [];
        obj.bsfcenter{obj.Ndec}(ind) = [];
end