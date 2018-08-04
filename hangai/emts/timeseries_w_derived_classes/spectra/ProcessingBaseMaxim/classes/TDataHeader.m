classdef TDataHeader
    % class for storing data header object
    % 2015 (c) Gary Egbert, Maxim Smirnov
    % Oregon State University, 2015
    
    % some of the properties are redundent and could cleaned later
    % also longer names for variables are preferable
    
    properties
        ArrayName;
        UserMetaData; %  user metadata no specific format, just anything
        NSites; %   Number of sites : integer
        NBands; %  Number of bands : integer
        NchSites %  Number of channels at each site : integer array (NSites)
        Nch      %  Nch = sum(NchSites)
        ih  %   indicies of first channel for each site :integer array (NSites)
        siteInd % "site" (or more generally group) index : integer array
        chInd   %  channel number, within the site
        LatLong % site coordinates: float array in decimal degrees(2,NSites)
        Declination  % site "Declinationination" to support variable local coordinate systems,
        %   as for example when geomagnetic coordinates are used
        XY; % cartesian coordinates (UTM projection) integer array in m (2,NSites)
        orient % Channel azimuths :  real array (2,NSites)
        Channels  % Channel ID's :  character array
        Sites   % Sitestion ID's : cell array
        GeographicCoordinates = false%   by default assume the channel azimuths are in
        %  geomagnetic coordinates until changed explicitly to
        %  geographic; some input formats are alread geographic!
        ZeroTime;
        StartTime;
    end   % properties
    
    properties (Dependent, Hidden)
        %  these properties are required for compatibility.
        %  when possible use new names, otherwise everything should work as before
        
        stcor % site coordinates: integer array (2,NSites)
        sta   % station ID's :  character array
        chid  % Channel ID's :  character array
        decl  % site "declination" to support variable local coordinate systems,
        %   as for example when geomagnetic coordinates are used
    end;
    
    methods
        %***********************************************************************
        %   copies the TDataHeader object to a new handle class object
        function objOut = copy(objIn)
            objOut = TDataHeader;
            objOut.ArrayName = objIn.ArrayName;
            objOut.UserMetaData = objIn.UserMetaData;
            objOut.NSites = objIn.NSites;
            objOut.NBands = objIn.NBands;
            objOut.NchSites = objIn.NchSites;
            objOut.Nch = objIn.Nch;
            objOut.ih  = objIn.ih;
            objOut.siteInd = objIn.siteInd;
            objOut.chInd = objIn.chInd;
            objOut.LatLong = objIn.LatLong;
            objOut.Declination = objIn.Declination;
            objOut.XY = objIn.XY;
            objOut.orient = objIn.orient;
            objOut.Channels  = objIn.Channels;
            objOut.Sites = objIn.Sites;
            objOut.GeographicCoordinates = objIn.GeographicCoordinates;
            objOut.ZeroTime = objIn.ZeroTime;
            objOut.StartTime = objIn.StartTime;
        end
        
        %***********************************************************************
        function ind = findChannel(obj,Site,chID)
            %   Site is a character string giving site ID, chID is a string
            %   (length 6) giving channel ID.   Find index of matching site/channel
            %    in header
            %   Usage:   ind = findChannel(obj,Site,chID)
            siteInd = 0;
            chInd = 0;
            for i = 1:obj.NSites
                if strcmp(obj.Sites{i},Site)
                    siteInd = i;
                    for k = 1:obj.NchSites(siteInd)
                        chIndHd = cellstr(lower(obj.Channels(:,k)'));
                        if strcmpi(chIndHd,cellstr(chID))
                            chInd = k;
                            break
                        end
                    end
                    break
                end
            end
            if siteInd>0 && chInd>0
                inds = find(obj.siteInd==siteInd);
                if ~isempty(inds)
                    j = find(obj.chInd(inds)==chInd);
                    ind = inds(j);
                else
                    ind = [];
                end
            else
                ind = [];
            end
        end
        
        
        %**************************************************************************
        function  obj = SelectChannels(obj,chUse)
            %   modify Header object from input using only channels chUse
            
            maxSiteInd = max(obj.siteInd(chUse));
            nSites = 0;
            for k = 1:maxSiteInd
                ind = find(obj.siteInd(chUse) == k);
                if length(ind)>=1
                    nSites = nSites+1;
                    chInd = obj.chInd(chUse(ind));
                    sitesUse{nSites} = struct('siteInd',k,'ind',chUse(ind),...
                        'chInd',chInd);
                end
            end
            
            SitesUsed = unique(obj.siteInd(chUse));
            obj.NSites = nSites;
            obj.NchSites = zeros(1,nSites);
            obj.siteInd  = [];
            obj.chInd  = [];
            Channels = obj.Channels;
            obj.Channels = [];
            
            k1 = 1;
            for k = 1:nSites
                kk = sitesUse{k}.siteInd;
                jj = sitesUse{k}.ind;
                chInd = sitesUse{k}.chInd - sitesUse{k}.chInd(1)+1;
                obj.NchSites(k)  = length(jj);
                obj.Channels = [obj.Channels Channels(:,jj)];
                ihk = find(Channels(1,jj) == 'H',1);
                if ~isempty(ihk)
                    ih(k)  =  ihk;
                else
                    ih(k) = NaN;
                end
                k2 = k1+obj.NchSites(k)-1;
                obj.siteInd(k1:k2)  = k;
                obj.chInd(k1:k2)  = chInd;
                k1 = k2+1;
            end
            obj.ih = ih +[0 cumsum(obj.NchSites(1:end-1))];
            obj.Nch = sum(obj.NchSites);
            
            obj.LatLong = obj.LatLong(:,SitesUsed);
            temp = obj.Sites;
            obj.Sites  = cell(length(SitesUsed),1);
            for k = 1:length(SitesUsed)
                obj.Sites{k} = temp{SitesUsed(k)};
            end
            try
                obj.Declination = obj.Declination(SitesUsed);
            catch
                obj.Declination = [];
            end
            obj.orient = obj.orient(:,chUse);
            try
                obj.XY = obj.XY(:,SitesUsed);
            catch
                obj.XY = [];
            end
        end
        %**********************************************************************
        function obj = SelectSites(obj,Sites)
            %   only select Sites from the list "Sites"
            %   Sites should be cell array of character strings
            %    (i.e., same format as TDataHeader.Sites)
            
            if ~isempty(Sites) && ~isnumeric(Sites)
                %   find site numbers in list
                use = zeros(obj.Nch,1);
                for k = 1:length(Sites)
                    tf = find(strcmp(Sites{k},obj.Sites));
                    if ~isempty(tf)
                        use(obj.siteInd == tf)=1;
                    end
                end
                chUse = find(use);
                obj = obj.SelectChannels(chUse);
            else
                disp('(WW)  Wrong input to SelectSites');
            end
        end    %  omitSites
        %**************************************************************************
        function obj = Add_LatLong(obj,OBS)
            
            %   adds site coordinates, using cell array of site names/coordinates
            %   matches name in SITES  to obj.sites
            
            for iSites = 1:obj.NSites
                siteNotFound =  1;
                Sites = obj.Sites{iSites};
                for k = 1:length(OBS)
                    if strcmp(OBS{k}.Name,deblank(Sites))
                        siteNotFound =0;
                        lat = OBS{k}.lat;
                        lon = OBS{k}.lon;
                        break
                    end
                end
                if siteNotFound
                    msg = ['Warning: ' Sites ' not found in OBS list'];
                    fprintf(1,'%s',msg)
                else
                    obj.LatLong(1,iSites) =  lat;
                    obj.LatLong(2,iSites)  = lon;
                end
            end
        end
        
        %**********************************************************************
        function  obj = GeogChAzimuth(obj)
            %  change channel azimuths to geographic (i.e., if geogcor = false,
            %    add Declinationination to channel azimuth)
            if ~obj.GeographicCoordinates
                for k = 1:obj.NSites
                    iSite = find(obj.siteInd ==k);
                    iCh = find(lower(obj.Channels(2,iSite))~='z');
                    obj.orient(1,iSite(iCh)) = obj.orient(1,iSite(iCh))+obj.Declination(k);
                end
                obj.GeographicCoordinates = true;
            end
        end;  %GeogChAzimuth
        
        
        % OldNames compatibility functions-------------------------------------
        function obj = set.stcor(obj,val)
            obj.LatLong = val;
        end
        %************************************************************************
        function value = get.stcor(obj)
            value = obj.LatLong;
        end
        %************************************************************************
        function obj = set.sta(obj,val)
            obj.Sites = cellstr(val);
        end
        %************************************************************************
        function value = get.sta(obj)
            value = zeros(3,obj.NSites);
            for k = 1:length(obj.Sites);
                value(:,k) = char(obj.Sites{k});
            end
        end
        %************************************************************************
        function obj = set.chid(obj,val)
            obj.Channels = val;
        end
        %************************************************************************
        function value = get.chid(obj)
            value = obj.Channels;
        end;
        %************************************************************************
        function obj = set.decl(obj,val)
            obj.Declination = val;
        end
        %************************************************************************
        function value = get.decl(obj)
            value = obj.Declination;
        end;
        %************************************************************************
        function  obj = UpdateHeader(obj,chUse)
            error('Use SelectChannels instead of UpdateHeader');
        end
        %************************************************************************
        function  [HdOut,ind]  = merge(HdIn1,HdIn2)
            [ind,sitesOmit] = merge_headers(hd1,hd2)
            warning('Use merge as separate function merge_headers');
        end
        %************************************************************************
        function  [ind,sitesOmit] = compareHeader(hd1,hd2)
            [ind,sitesOmit] = compare_headers(hd1,hd2)
            warning('Use compareHeader as separate function compare_headers');
        end
        %************************************************************************
        function  obj = Add_stcor(obj,OBS)
            obj.Add_LatLong(obj,OBS);
            warning('Use Add_LatLong');
        end
        %************************************************************************
        %Old Names ------------------------------------------------------------------
        
        
        
    end   % methods
    
end  % classdef