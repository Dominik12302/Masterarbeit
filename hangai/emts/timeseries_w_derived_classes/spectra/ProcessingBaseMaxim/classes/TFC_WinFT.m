classdef TFC_WinFT < TFC
    %   class to support loading WinFT structures from mat files
    properties
        Files   % cell array containing WinFT mat files
        Array   % cell array containing all WinFT objects
        FCdir = './'    %  root path for WinFT files
        minSpec = 1;   %   this is set to force return of only a single 
                       %  decimation level for each band
    end
    
    methods
        function obj = TFC_WinFT(arrayFile,FCdir)
            % class constructor ... dummy for now
            if nargin > 0
                readArrayWinFT(obj,arrayFile) 
                if nargin > 1
                    obj.FCdir = FCdir;
                end
            end      
        end
        %******************************************************************
        function loadFCarray(obj)
            %  initialize meta-data and load all WinFT objects
            obj.NSites = length(obj.Files);
            for j = 1:obj.NSites
                nFCfiles = length(obj.Files{j}.FCfiles);
                obj.Sites{j} = obj.Files{j}.sta;
                for k = 1:nFCfiles
                    cfile = [obj.FCdir obj.Files{j}.FCfiles{k}];
                    eval(['load ' cfile]);
                    %    wFC seems to have two places to store zero time!
                    %      not good!
                    if isempty(wFC.Header.ZeroTime)
                        wFC.Header.ZeroTime = wFC.zeroTime;
                    end
                    obj.Array{j}(k) = wFC;
                    if k ==  1
                        Hd1 = wFC.Header;
                    else
                        %   compare Hd1 and wFC.Header
                        [ind,sitesOmit] = compareHeader(Hd1,wFC.Header);
                        if ~isempty(sitesOmit) || ind ~= 1
                            error(['runs incompatible in loadFCarray'])
                        end
                    end                   
                end
                if j==1
                    obj.Header = Hd1;
                    obj.Header.ZeroTime = Hd1.ZeroTime;
                else
                    obj.Header = MergeHeader(obj.Header,Hd1);
                end
            end
        end
        %******************************************************************
        function Hd = ExtractSDMheader(obj)
            Hd = obj.Header;
        end
        %******************************************************************
        function LoadFCband(obj,ib)
        %   gets FCs for full array for frequency band ib     
            
            %   obj.minSpec determines how many decimation levels are
            %   retained...   all levels with avg amplitude minSpec decades
            %   below that of the maximum over all bands are discarded.
            
            iBand = findBand(obj.Array{1}(1),obj.Bands{ib}.fBands,obj.minSpec);
            %   iBand provides information about decimation levels and
            %   frequency numbers in the band ... save this for
            %   reconstruction also
            obj.Bands{ib}.iBand = iBand;
            obj.T = mean(1./obj.Bands{ib}.fBands);
            winFTband = cell(obj.NSites,1);
            for k = 1:obj.NSites
                nRuns = length(obj.Files{k}.FCfiles);
                %obj.Sites{k} = obj.Files{k}.sta;
                for j = 1:nRuns
                    winFTband{k}(j) = extractBand(obj.Array{k}(j),iBand);
                end
            end
            %   merge into a single winFT object for this band (all sites)
            temp = mergeWinFT(winFTband);
            Nfc = 0;
            for iDec = 1:temp.NDec
                 [~,nf,nseg] = size(temp.FC{iDec}.X);
                 Nfc = Nfc+nf*nseg;
            end
            obj.X = zeros(temp.NCh,Nfc);
            %   the following is only really coded for the case of 1
            %   decimation level in the band
            obj.SegmentNumber = reshape(ones(nf,1)*temp.FC{1}.segNumber,1,Nfc);
            %   following is needed for consistency with conventions used
            %   for TFC objects: zeroTime is start of segment # 0, but
            %   this would be segment # 1 in winFT.
            obj.SegmentNumber = obj.SegmentNumber-1;
            obj.SegmentLength = temp.dec{1}.decT*temp.win{1}.Npts/86400;
            obj.SegmentOffset = temp.dec{1}.decT*...
                (temp.win{1}.Npts-temp.win{1}.overLap)/86400;
            %  temp.NCh is number of channels, Nfc is total number of FCs
            Nfc = 0;
            for iDec = 1:temp.NDec
                [~,nf,nseg] = size(temp.FC{iDec}.X);
                obj.X(:,Nfc+1:Nfc+nf*nseg) = ...
                    reshape(temp.FC{iDec}.X,temp.NCh,nf*nseg);
                Nfc = Nfc+nf*nseg;
            end
            obj.NSegments = Nfc;
            %obj.NChannels = ncht;
            obj.SegmentInd = ones(1,obj.NSegments);   

        end
        %******************************************************************
        function readArrayWinFT(obj,arrayFile)
            %  reads in standard array.cfg file--i.e., the configuration
            %    file for MMT that gives list of FC files, weights, output name, etc.
            %   Usage: [Files,bandFile,ArrayName]   = readArrayCfg(arrayFile);
            %       Files is cell array of length nsta (number of stations)
            %            each cell contains cell array of file  names for this site
            %            (could be more than one), site name, and channel weights
        %            (array of length nch(ista))
        %       bandFile is name for band-setup file
        %       ArrayName is root for naming output  files
            
            fid = fopen(arrayFile,'r');
            NSites = fscanf(fid,'%d\n');
            obj.bandFile = fgetl(fid);
            %  read frequency bands to process from band setup file ...
            %    here we are expecting to find a matlab file, containing a
            %    list of frequency limits (not the usual decimation and
            %    band limits)
            eval(['load ' obj.bandFile]);
            nBands = length(fBands);
            obj.Bands = cell(nBands,1);
            for ib = 1:nBands
                obj.Bands{ib} = struct('fBands',fBands{ib},'iBand',[]);
            end
            obj.nBands = nBands;
            for k = 1:NSites
                temp = fscanf(fid,'%d',2);
                nfiles  = temp(1);
                nch   = temp(2);
                [wts,count] = fscanf(fid,'%f',nch);
                fgetl(fid);
                for l = 1:nfiles
                    FCfiles{l} = deblank(fgetl(fid));
                end
                sta = deblank(fgetl(fid));
                Files{k} = struct('FCfiles',{FCfiles},'sta',sta,'wts',wts);
            end
            obj.ArrayName = deblank(fgetl(fid));
            obj.Files = Files;
        end
    end
end