function omitBadSegments(FCm,BRm)
%   given a TFC object FCm, with data loaded for a band (i.e., X and
%   corresponding SegmentNumber fields are set) and an array of BR objects
%   containing lists of times to omit for some channels, set corresponding
%   valuies of X to NaN (i.e., mark as missing)

    %   loop over array of BR objects
    for k = 1:length(BRm)
        d0 = datenum(BRm(k).refTime);
        %  loop over array of channels within the BR objecg
        for j = 1:BRm(k).NCh
            %  find the corresponding channel index in the FCM.X array
            Site = BRm(k).markedSegs{j}.Site;
            ChID = BRm(k).markedSegs{j}.ChID;
            ind = findChannel(FCm.Header,Site,ChID);
            if ~isempty(ind)
                % loop over marked segments for this channel
                for l = 1:BRm(k).markedSegs{j}.NSeg
                    %  for each segment:
                    %   convert marked segment start, end times to datenum
                    s = d0+BRm(k).markedSegs{j}.Segs(l,1)*BRm(k).dt/86400;
                    e = d0+BRm(k).markedSegs{j}.Segs(l,2)*BRm(k).dt/86400;
                    %  convert segment start-end to range of segment numbers
                    [iSegs] = Time2Seg(FCm,s,e);
                    %   set corresponding channel/segments of FCm.X array to NaN
                    if length(iSegs==2)
                        FCm.X(ind,iSegs(1):iSegs(2)) = NaN;
                    end
                end
            end
        end
    end
end % omitBadSegments