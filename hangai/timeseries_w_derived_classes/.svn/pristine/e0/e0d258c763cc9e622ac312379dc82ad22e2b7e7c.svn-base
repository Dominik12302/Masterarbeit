 %******************************************************************
        function [Omitted,t0,dt] = testBr(BRm,FCm)
        %   this returns a full array, one entry for each possible
        %   segment/channel with value of 0 if there is no data, 1 if there
        %   is unmarked (good?) data and -1 if data has been marked in the
        %   BR object.  t0 is time in days and dt offset between segments,
        %   also in days.   To get date of segment #j, use
        %   datevec(t0+(j-1)*dt)
            Xbefore = FCm.X;
            crap = isnan(Xbefore);
            omitBadSegments(FCm,BRm);
            temp = isnan(FCm.X)& ~isnan(Xbefore);
            temp = temp+1/2*crap;
            ind = FCm.SegmentNumber-FCm.SegmentNumber(1) + 1;
            nSeg = ind(end);
            [nch,~] =size(Xbefore);
            Omitted = zeros(nch,nSeg);
            Omitted(:,ind) = 1-2*temp;
            %   segoffset in days
            dt = FCm.SegmentOffset;
            d0 = datenum(BRm(1).refTime);
            t0 = d0+FCm.SegmentNumber(1)*dt;
        end