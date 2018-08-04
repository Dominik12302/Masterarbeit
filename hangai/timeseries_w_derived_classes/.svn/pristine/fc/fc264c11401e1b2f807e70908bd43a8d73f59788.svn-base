function atsheader = get_atsheader(obj)
% ats header for each channel
if obj.resmpfreq == 0, obj.resmpfreq = obj.srate; end
for ich = 1:numel(obj.usech)
    header = default_atsheader;
    header.sitename =   obj.name;
    fname = [obj.systemSN '_',obj.system(1:3),'_C' num2str(obj.usech(ich),'%02d') '_R' ...
        num2str(obj.run,'%03d') '_T' obj.chnames{obj.usech(ich)} '_BL_' ...
        num2str(obj.resmpfreq,'%d') 'H.ats'];
    header.file     =   fname;
    header.samples  =   obj.Nsmpr;
    header.sfreq    =   obj.resmpfreq;
    start = obj.starttime; start(6) = start(6)+obj.starttimems;
    header.start    =   obj.trsr(1)+etime(obj.reftime,[1970 1 1 0 0 0]);
    header.startstr =   datestr(header.start/3600/24+datenum('01-JAN-1970 00:00:00'));
    header.lsb      =   obj.lsb(ich);
    header.adu06    =   obj.systemSN;                           %   ADU serial number
    header.ch_no    =   obj.usech(ich);                         %   Channel number
    %header.bychopper =  0;
    header.ch_type  =   obj.chnames{obj.usech(ich)};            %   channel type (Hx,Hy,...)
    header.sensor   =   obj.sens_name{obj.usech(ich)};          %   sensor type (MFS05,EFP05,...)
    if strcmp(header.ch_type(1),'H') || strcmp(header.ch_type(1),'B')
        header.sensor_no=   num2str(obj.sens_sn{obj.usech(ich)}(1));     %   Sensor serial number
    else
        header.sensor_no=   '0000';         %   Sensor serial number
    end
    if strcmp(header.ch_type(1),'E')
        header.dipol_length = obj.dipole(obj.usech(ich));       %   efield dipole length (m)
        if strcmp(header.ch_type,'Ex')
            header.x1       =   -header.dipol_length/2;         %   x1 coordinate of 1. Dipole (m)
            header.x2       =   header.dipol_length/2;          %   x2 coordinate of 2. Dipole (m)
        elseif strcmp(header.ch_type,'Ey')
            header.y1       =   -header.dipol_length/2;         %   x1 coordinate of 1. Dipole (m)
            header.y2       =   header.dipol_length/2;          %   x2 coordinate of 2. Dipole (m)
        end
    end
    header.dipol_angle= obj.orient(obj.usech(ich));             %   efield dipole angle (north = 0�)
    header.lat = obj.lat*1000*60*60;
    header.lon = obj.lon*1000*60*60;
    header.elev = 0;
    
    % CODE4- TO BE removed     
    if strfind(header.sensor,'MFS05'), header.lsb = header.lsb * 800;  end
    if strfind(header.sensor,'MFS06'), header.lsb = header.lsb * 800;  end
    if strfind(header.sensor,'MFS07'), header.lsb = header.lsb * 640;  end
    if strfind(header.sensor,'SHFT02'), header.lsb = header.lsb * 50;  end
    if strfind(header.sensor,'COIL'), header.lsb = header.lsb * 1000;  end    
    
    atsheader(ich)  = header;
end
end
function header = default_atsheader
header.sitename =   'sitename';
header.file     =   'nofile.ats';
header.run      =   '00';
header.band     =   '';
header.length   =   1024;       %   Bytes of Header
header.ver      =   1.0;        %   Version
header.samples  =   0;          %   Number of Samples
header.sfreq    =   1;          %   sampling frequency, Hz
header.start    =   0;          %   Start time, seconds since 1970
header.startstr =   datestr(header.start/3600/24+datenum('01-JAN-1970 00:00:00'));
header.lsb      =   1.0;        %   LSB-Value
header.iGMTOffset = 0;
header.rOrigSampleFreq = 0;
header.adu06    =   '001';      %   ADU serial number
header.adb06    =   '001';      %   ADB serial number
header.ch_no    =   1;          %   Channel number
header.bychopper =  0;
header.ch_type  =   '';         %   channel type (Hx,Hy,...)
header.sensor   =   '';         %   sensor type (MFS05,EFP05,...)
header.sensor_no=   '';         %   Sensor serial number
header.x1       =   0;          %   x1 coordinate of 1. Dipole (m)
header.y1       =   0;          %   y1 coordinate of 1. Dipole (m)
header.z1       =   0;          %   z1 coordinate of 1. Dipole (m)
header.x2       =   0;          %   x2 coordinate of 2. Dipole (m)
header.y2       =   0;          %   y2 coordinate of 2. Dipole (m)
header.z2       =   0;          %   z2 coordinate of 2. Dipole (m)
header.dipol_length=0;          %   efield dipole length (m)
header.dipol_angle=0;           %   efield dipole angle (north = 0�)

%RS: added complete ats header fields to enable copying headers
%MTX: Data from selftest
header.rProbeRes = 0;
header.rDCOffset = 0;
header.rPreGain  = 0;
header.rPostGain = 0;

%MTX: Data from status information
header.lat      =   0;
header.lon      =   0;
header.elev     =   0;

header.byLatLongType  = '0';
header.byAddCoordType = '0';
header.siRefMedian    =  0;
header.dblXCoord      = 0;
header.dblYCoord      = 0;
header.byGPSStat      = '0';
header.byGPSAccuracy  = '0';
header.iUTCOffset     = 0;
header.abySystemType  = '';

%MTX: Data from XML-Job specification
header.abySurveyHeaderName = '';
header.abyMeasType         = '';

% MTX: Next three fields will not be supported any more
header.abyLogFileName      = '';
header.abySelfTestResult   = '';
header.abyReserved5        = '';

% MTX: Were the following fields ever used ?
header.siCalFreqs           = 0;
header.siCalEntryLength     = 0;
header.siCalVersion         = 0;
header.siCalStartAddress    = 0;
header.abyLFFilters         = '';
header.abyADU06CalFilename  = '';
header.iADUCalTimeDate      = 0;
header.abySensorCalFilename = '';
header.iSensorCalTimeDate   = 0;
header.rPowerlineFreq1      = 0;
header.rPowerlineFreq2      = 0;
header.abyHFFilters         = '';

% MTX: Unused ?
header.rCSAMTFreq           = 0;
header.siCSAMTBlocks        = 0;
header.siCSAMTStacksPBlock  = 0;
header.iCSAMTBlockLength    = 0;
header.abyADBBoardType      = '';
header.tscComment           = '';
end
