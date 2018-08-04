classdef TFC_GDE < TFC
    %   class to support reading of FC files in GDE EMTF format
    
    properties
        Files   % cell array containing FC files
        Array   % strucrture containing "directory" of FC files
%        SDMhd   %  SDMheader object ... can replace (or enhance) with 
                %   other header once this is sorted out 
        FCdir = './'    %  root path for FC files
    end


    properties %(access='private')
        lpack = false
        Endian = 'n'
        FractionalOffset = 0.75;
        ZeroTime
        latlonFile
    end
    methods
        function obj = TFC_GDE(arrayFile,FCdir)
            % class constructor ... dummy for now
            if nargin > 0
                obj.ReadArrayCfg(arrayFile)
                if nargin > 1
                    obj.FCdir = FCdir;
                end
            end
            %   test MMT array has "packed" FC files!   (+Written on PC)
            obj.lpack = false;
            obj.LoadFCarray;
            if ~isempty(obj.latlonFile)
                load(obj.latlonFile);
                obj.Header = Add_stcor(obj.Header,OBS);
            end
        end
        %******************************************************************
        function LoadFCarray(obj)
            %  initialize meta-data and "table of  contents" for array files
            obj.NSites = length(obj.Files);
            for j = 1:obj.NSites
                nFCfiles = length(obj.Files{j}.FCfiles);
                obj.Sites{j} = obj.Files{j}.sta;
                for k = 1:nFCfiles
                    cfile = [obj.FCdir obj.Files{j}.FCfiles{k}];
                    FChead = fcOpen(cfile,obj.lpack,obj.Endian);
                    obj.Array{j}(k) = struct('file',cfile,'FChead',FChead);
                end
            end
            obj.Header = TFCHeader(obj.Array,obj.Sites,obj.Bands);
            obj.Header.ZeroTime = obj.ZeroTime;
        end
        %******************************************************************
        function Hd = ExtractSDMheader(obj)
            Hd = obj.SDMhd;
        end
        %******************************************************************
        function LoadFCband(obj,ib)
            FC  = loadArrayRecord(obj.Array,obj.Bands{ib},obj.MaxMiss,obj.lpack);
            %  compute period from info in FC files
            dr  = obj.Array{1}(1).FChead.drs(obj.Bands{ib}.id);
            Twin =  dr*obj.Array{1}(1).FChead.decs(2,obj.Bands{ib}.id);
            obj.T = Twin*2/sum(obj.Bands{ib}.iband);
            %   window length (sec) can also be obtained from FC file headers
            windowLength = obj.Array{1}(1).FChead.decs(2,obj.Bands{ib}.id);
            %  ncht is number of channels, nb is number of adjacent frequencies in
            %   band, nseg is number of segments ... so total number of FCs is
            %   nb*nseg
            [ncht,nb,nseg] = size(FC.X);
            obj.X = reshape(FC.X,[ncht,nb*nseg]);
            obj.SegmentNumber = reshape(ones(nb,1)*FC.setNumbers,1,nb*nseg);
            %   so that Segment # 0 begins at zero time some adjustment of
            %   SegmentNumber is required.   This still needs to be checked
            %   carefully ... this seems to be consistent with
            %   EMTF/T/badToUse.f (i.e., in FC files segment starting at
            %   zeroTIme would be labeled 1)
            obj.SegmentNumber = obj.SegmentNumber-1;
            obj.SegmentLength = Twin/86400;
            %   by default for FC files we assume SegmentOffset is fixed
            %   ...   have to modify after object initialization if this
            %   has changed; information is not available in standard FC
            %   files
            obj.SegmentOffset = obj.SegmentLength*obj.FractionalOffset;
            obj.NSegments = nb*nseg;
            %obj.NChannels = ncht;
            obj.SegmentInd = ones(1,obj.NSegments);   
        end
        %******************************************************************
        function ReadArrayCfg(obj,arrayFile)
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
            nSites = fscanf(fid,'%d\n');
            obj.bandFile = fgetl(fid);
            %  read frequency bands to process from band setup file
            obj.ReadBScfg(obj.bandFile);
            for k = 1:nSites
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
                clear FCfiles;
            end
            obj.ArrayName = deblank(fgetl(fid));
            obj.Files = Files;
            temp = fgetl(fid);
            if temp ~=  -1
                try
                    obj.ZeroTime = sscanf(temp,'%d %d %d %d %d %d\n',6);
                    obj.ZeroTime = obj.ZeroTime'
                    obj.FractionalOffset = fscanf(fid,'%f\n',1);
                    temp = fgetl(fid);
                    if ischar(temp)
                        obj.latlonFile = deblank(temp);
                    else
                        obj.latlonFile = [];
                    end
                catch
                    fprintf(1,'%s','No timing information in array.cfg file')
                    obj.latlonFile = deblank(temp);
                end
            end
        end
    end
    methods (Static)
        function fileName = makeArrayCfg(FCfiles,bandFile,ArrayName,cfgFile)
            %   
            %   USAGE:TFC_GDE.makeArrayCfg(FCfiles,bandFile,ArrayName);
            %           FCfiles is a structure containing for each site the
            %           site name, the number of channels, channel weights,
            %           and a cell array containing the list of FC files 
            %              (one for each run)
            %          cfgFile is optional, defaults to array.cfg
            %    This is a static method that can be used to first create
            %    an array.cfg file which can then be used to create a
            %    TFC_FGDE object; 
           
            if nargin < 4
                cfgFile = 'array.cfg';
            end
            nSitesUse = length(FCfiles);
            fid = fopen(cfgFile,'w');
            fprintf(fid,'%d\n',nSitesUse);
            fprintf(fid,'%s\n',bandFile);
            for k = 1:nSitesUse
                nRuns = length(FCfiles{k}.Files);
                fprintf(fid,'%d %d\n',[nRuns FCfiles{k}.nch]);
                for j = 1:FCfiles{k}.nch-1
                    fprintf(fid,'%6.4f ',FCfiles{k}.wts(j));
                end
                fprintf(fid,'%6.4f\n',FCfiles{k}.wts(FCfiles{k}.nch));
                for iRun = 1:nRuns
                    fprintf(fid,'%s\n',FCfiles{k}.Files{iRun});
                end
                fprintf(fid,'%s\n',FCfiles{k}.sta);
            end
            fprintf(fid,'%s\n',ArrayName);
            fileName=cfgFile;
        end
    end
end