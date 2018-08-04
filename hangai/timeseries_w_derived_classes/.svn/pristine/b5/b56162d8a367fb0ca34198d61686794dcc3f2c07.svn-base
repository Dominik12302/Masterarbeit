
% 2011 (c) Maxim Smirnov, Gary Egbert,  Oregon State University
%
% TFC the main component containing FCs for all segments and channels/sites
% at one decimation level

classdef TFC < handle
    %
    %
    properties
        Header;   % TDataHeader
        UserData; % cell array with any other user data
        NSegments;    % total number of segments
        NChannels;    % number of channels at each site
        NPeriods;     % periods for each decimation level
        NSites;	      % number of unique sites
        Sites         %   list of site names (these are read from arrayCfg file)
        Data;         % all Fourier Coefficients at each decimation level
        ArrayName;
        T;            % periods in sec
        X;	      % data matrix
        SegmentInd;   % segment indexes
        SiteInd;
        SegmentNumber %   sequence number for segment stored in X
        SegmentLength  %   segment length (in days, for convenient use with datenums)
        SegmentOffset  % interval (days) between segment starts
    end
    properties
        bandFile  %   band setup  file
        Bands     %   decimation levels/frequency bands to process
        nBands
        MaxMiss = inf
    end
    properties (Dependent)
       SegmentTime 
    end
    
    methods
        
        % function obj = TFC(BandFile)
        %   if nargin == 1
        %     obj.ReadBScfg(BandFile);
        %   end
        % end;
        
        
        % get Channel or Segment or all available
        function Y = ExtractFC(H,What,K)
            switch lower(What)
                case 'channel'
                    %  extract all available FCs for channel K
                    ind = find(1-isnan(H.Data(K,:)));
                    Y = H.Data(K,ind)';
                    size(Y)
                case 'segment'
                    %  extract all available FCs for segment K
                    ind = find(1-isnan(H.Data(:,K)));
                    Y = H.Data(ind,K)';
                case 'all'
                    %  extract all available FCs
                    Y = H.Data;
                case 'hd'
                    Y  = TDataHeader();
                    Y.NSites = H.NSites;
                    Y.NDecimation = H.NDecimation;
                    Y.NChSites = H.NChSites;
                    Y.NChannels = H.NChannels;
                    Y.Declination = H.Declination;
                    Y.siteInd = H.siteInd;
                    Y.Lat = H.Lat;
                    Y.Long = H.Long;
                    Y.X = H.X;
                    Y.Y = H.Y;
                    Y.ChAzimuth = H.ChAzimuth;
                    Y.Sites = H.Sites;
                    Y.Channels = H.Channels;
                    Y.StartTime = H.StartTime;
                otherwise
                    % provide something perhaps
            end
        end; %extractFC
        
        % get cleaned Segment or all available
        function CleanFC(H,K,Yc,What)
            switch lower(What)
                case 'channel'
                    ind = find(1-isnan(H.Data(K,:)));
                    H.Data(K, ind) = Yc;
                    
                case 'segment'
                    ind = find(1-isnan(H.Data(:,K)));
                    H.Data(ind, K) = Yc;
                otherwise
                    % provide something perhaps
            end
        end; %cleanFC
        
        
        function DeSpike(obj)
            %  quick despiking algorithm for FC array
            [ncht,nsegs] = size(obj.X);
            for k =  1:ncht
                temp = log10(abs(obj.X(k,:)));
                medX = median(temp(~isnan(temp)));
                ind = temp-medX>1.5;
                obj.X(k,ind)  = NaN;
            end
        end;
        
        function RemoveMissing(obj)
            %  eliminate all segments with any missing channels
            %nMissCh = sum(isnan(FCm.X),2);
            nMissSeg = sum(isnan(obj.X),1);
            %  for now get rid of all segments with any missing data
            %use = find(nMissSeg==0);
            obj.X = obj.X(:,nMissSeg==0);
            obj.NSegments = obj.NSegments-nMissSeg;
        end;
        
        function RemoveEmptyChannels(obj)
            %  eliminate all segments with any missing channels
            %nMissCh = sum(isnan(FCm.X),2);
            nMissSeg = sum(isnan(obj.X),1);
            %  for now get rid of all segments with any missing data
            %use = find(nMissSeg==0);
            obj.X = obj.X(:,nMissSeg==0);
            obj.NSegments = obj.NSegments-nMissSeg;
        end;
        
        
        function ReadBScfg(obj,bsFile)
            
            %   Reads standard "band set up" file, as used by tranmtlr, mmt, etc.
            %   Usage: [iBand]  = readBCcfg(bsFile);
          if exist(bsFile,'file')
            fid = fopen(bsFile,'r');
            obj.nBands = fscanf(fid,'%d',1);
            obj.Bands = cell(obj.nBands,1);
            for k = 1:obj.nBands
                bs = fscanf(fid,'%d',3);
                obj.Bands{k} = struct('id',bs(1),'iband',bs(2:3));
            end
          else
            display(['Can not find band setup file:  ', bsFile]); 
            pause;
          end;    
        end; %readBScfg
        %******************************************************************
        function singleBands(obj)
            %   modify Bands structure to create single frequency bands
            %    obj.Bands has to be set first
            id = zeros(obj.nBands,1);
            ib = zeros(obj.nBands,2);
            for k = 1:obj.nBands
                id(k) = obj.Bands{k}.id;
                ib(k,:) = obj.Bands{k}.iband;
            end
            id1 = min(id); id2 = max(id);
            nd = id2-id1+1;
            nb = zeros(nd,3);
            for k = id1:id2
                nb(k-id1+1,2) = min(ib(id==k,1));
                nb(k-id1+1,3) = max(ib(id==k,2));
                nb(k-id1+1,1) = nb(k-id1+1,3) - nb(k-id1+1,2)+1;
            end
            obj.nBands = sum(nb(:,1));
            obj.Bands = cell(obj.nBands,1);
            kk = 0;
            for k = id1:id2
                for l = nb(k,3):-1:nb(k,2)
                    kk = kk+1;
                    obj.Bands{kk} = struct('id',k,'iband',[l ; l]);
                end
            end
        end        
        
        %******************************************************************
        function [startTime,endTime] = Seg2Time(obj,iSegs)
            %   given range of segments in iSegs = (iSeg1,iSeg2)
            %  compute time of start of first segment, and end of last
            %  Return results as datenums
            if length(iSegs == 1)
                iSegs = [iSegs iSegs];
            end
            zeroTime = datenum(obj.Header.ZeroTime);
            startTime = zeroTime+obj.SegmentNumber(iSegs(1))*...
                obj.SegmentOffset;
            endTime = zeroTime+(obj.SegmentNumber(iSegs(2)))*...
                obj.SegmentOffset+obj.SegmentLength;
        end
        %******************************************************************
        function [iSegs] = Time2Seg(obj,startTime,endTime)
            %   given start and end times (as a datenum) find range of segment
            %   numbers (iSeg1 - iSeg2) that overlap even by a single point)
            %   with these segments
            zeroTime = datenum(obj.Header.ZeroTime);
            segNum1 = floor((startTime-zeroTime)/obj.SegmentOffset);
            segNum2 = ceil((endTime-zeroTime-...
                (obj.SegmentLength-obj.SegmentOffset))/obj.SegmentOffset)-1;
            iSeg1 = find((obj.SegmentNumber>=segNum1&obj.SegmentNumber>0),1,'first');
            iSeg2 = find((obj.SegmentNumber<=segNum2&obj.SegmentNumber>0),1,'last');
            if isempty(iSeg1) || isempty(iSeg2) ||  iSeg2 < iSeg1
                iSegs = [];
            else
                iSegs = [iSeg1 iSeg2];
            end
        end
        
        
        function value = get.SegmentTime(obj)            
            value = obj.Header.StartTime+obj.SegmentNumber*obj.SegmentOffset;
        end;
        
        
        
    end; %methods
    
end
