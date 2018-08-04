% Function designed to work with the ADU class in order to read a .ats
% file to an ADU object from the datafile 'datafile'
%
% CAUTION: The data has to be in integer values (i.e. the measured values
% before they are multiplied by the lsb factor)
function header = ats_read_header(datafile,debuglevel)

%% Open file:
fid     = fopen(datafile,'r');
[pname,fname,ext]=  fileparts(datafile);
header.name =   '';
header.datafile     =   datafile;
if length(fname) == 8
    header.run  = fname(5:6);
    header.band = fname(end);
else
    ind = strfind(fname,'_R');
    header.run      =   fname(ind+2:ind+4);
    ind = strfind(fname,'_BL_');
    header.band     =   fname(ind+4:end-1);
end
header.length   =   fread(fid,1,'int16');       %   Bytes of Header
header.ver      =   fread(fid,1,'int16');       %   Version
header.Nsmp_f  =   fread(fid,1,'int32');       %   Number of Samples in File
header.srate    =   fread(fid,1,'float32');     %   sampling frequency, Hz
header.starttime_sec    =   fread(fid,1,'int32');       %   Start time, seconds since 1970
header.startstr =   datestr(header.starttime_sec/3600/24+datenum('01-JAN-1970 00:00:00'));
header.lsb      =   fread(fid,1,'double');      %   LSB-Value
% RS: added fields
header.iGMTOffset = fread(fid,1,'int32');
header.rOrigSampleFreq = fread(fid,1,'float32');
header.SN_string    =   num2str(fread(fid,1,'int16'),'%03d');       %   ADU serial number
header.adb06    =   num2str(fread(fid,1,'int16'),'%03d');       %   ADB serial number
header.ch_no    =   fread(fid,1,'int8');        %   Channel number
header.bychopper =  fread(fid,1,'int8');
header.chnames  =   [char(fread(fid,2,'uchar'))]';       %   channel type (Hx,Hy,...)
if ~isempty(strfind(header.chnames,'H'))
    header.chnames(1) = 'B'; % (TL) Warum H->B ???
end
tmp = fread(fid,6,'*char');
header.sens_name   =  (tmp)';        %   sensor type (MFS05,EFP05,...)

% CODE4- TO BE removed 
if strfind(header.sens_name,'MFS05'), header.lsb = header.lsb / 800;  end
if strfind(header.sens_name,'MFS06'), header.lsb = header.lsb / 800;  end
if strfind(header.sens_name,'MFS07'), header.lsb = header.lsb / 640;  end
if strfind(header.sens_name,'SHFT02'), header.lsb = header.lsb / 50;  end
if strfind(header.sens_name,'COIL'), header.lsb = header.lsb / 1000;  end
if strfind(header.sens_name,'FGS03'), header.lsb = header.lsb / 0.1;  end

% CODE4+ TO BE replaced by
% header.coil_static = 1;
% if strfind(header.sens_name,'MFS05'), header.coil_static = 800;  end
% if strfind(header.sens_name,'MFS06'), header.coil_static = 800;  end
% if strfind(header.sens_name,'MFS07'), header.coil_static = 640;  end
% if strfind(header.sens_name,'SHFT02'), header.coil_static = 50;  end
% if strfind(header.sens_name,'COIL'), header.coil_static = 1000;  end
% if strfind(header.sens_name,'FGS03'), header.coil_static = 0.1;  end
        
header.sens_sn  =   fread(fid,1,'int16');       %   Sensor serial number
header.x1       =   fread(fid,1,'float32');     %   x1 coordinate of 1. Dipole (m)
header.y1       =   fread(fid,1,'float32');     %   y1 coordinate of 1. Dipole (m)
header.z1       =   fread(fid,1,'float32');     %   z1 coordinate of 1. Dipole (m)
header.x2       =   fread(fid,1,'float32');     %   x2 coordinate of 2. Dipole (m)
header.y2       =   fread(fid,1,'float32');     %   y2 coordinate of 2. Dipole (m)
header.z2       =   fread(fid,1,'float32');     %   z2 coordinate of 2. Dipole (m)
header.dipole   =fread(fid,1,'float32');     %   efield dipole length (m)
header.orient   =fread(fid,1,'float32');      %   efield dipole angle (north = 0???)
if strcmp(header.chnames(1),'E')
    if header.dipole == 0
        header.dipole = abs(header.x1-header.x2);
        if header.dipole == 0
            header.dipole = abs(header.y1-header.y2);
            %disp(['Warning: Replace E dipole length with ' num2str(header.dipol_length) ' m'])
        end
    end
end
if header.dipole<0
    header.dipole = -header.dipole;
    %     header.lsb = -header.lsb;
end
if strcmp(header.chnames,'By')
    if header.orient == 0
        header.orient = 90;
%         disp(['Warning: Replaced By orientation with 90 deg ']);
    end
end
if strcmp(header.chnames,'Ey')
    if header.orient == 0
        header.orient = 90;
%         disp(['Warning: Replaced Ey orientation with 90 deg ']);
    end
end


%RS: added complete ats header fields to enable copying headers
%MTX: Data from selftest
header.rProbeRes = fread(fid,1,'float32');
header.rDCOffset = fread(fid,1,'float32');
header.rPreGain  = fread(fid,1,'float32');
header.rPostGain = fread(fid,1,'float32');

%MTX: Data from status information
header.lat      =   fread(fid,1,'int32');
header.lon      =   fread(fid,1,'int32');
header.alt     =   fread(fid,1,'int32');

header.byLatLongType  = fread(fid,1,'uchar');
header.byAddCoordType = fread(fid,1,'uchar');
header.siRefMedian    = fread(fid,1,'int16');
header.dblXCoord      = fread(fid,1,'float64');
header.dblYCoord      = fread(fid,1,'float64');
header.byGPSStat      = fread(fid,1,'uchar');
header.byGPSAccuracy  = fread(fid,1,'uchar');
header.iUTCOffset     = fread(fid,1,'int16');
header.abySystemType  = [char(fread(fid,12,'uchar'))]';

fclose(fid);
end