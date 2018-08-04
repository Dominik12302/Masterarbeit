% Function designed to work with the ADU class in order to write a .ats
% file from the ADU object 'obj' and the data 'data' to a datafile
% 'obj.datafile'
%
% CAUTION: The data has to be in integer values (i.e. the measured values
% before they are multiplied by the lsb factor)
function [datafile] = write_ats_header(header, outpath, debuglevel)

%% Open file:
datafile = fullfile(outpath{1},header.file);
if debuglevel, disp([' - open file ' datafile ' ...']); end 
if(exist(datafile,'file'))
    if debuglevel==2, disp(['** Warning: File exists >>  overwriting ...']); end
end
fid     = fopen(datafile,'w+');
%% Write obj:
fwrite(fid,zeros(1,header.length),'int8');
fseek(fid,0,'bof');
fwrite(fid,header.length,           'int16');       %   Bytes of Header
fwrite(fid,header.ver,              'int16');       %   Version
fwrite(fid,header.samples,          'int32');       %   Number of Samples -> Change it to Nsmp?
fwrite(fid,header.sfreq,            'float32');
fwrite(fid,header.start,            'int32');       %   Start time, seconds since 1970
fwrite(fid,header.lsb,              'double');      %   LSB-Value
fwrite(fid,header.iGMTOffset,       'int32');
fwrite(fid,header.rOrigSampleFreq,  'float32');
fwrite(fid,str2num(header.adu06),   'int16');
fwrite(fid,str2num(header.adb06),   'int16');
fwrite(fid,header.ch_no,            'int8');        %   Channel number
fwrite(fid,header.bychopper,        'int8');
% for ic = 1:2
%     if ic > numel(header.ch_type(ic)), s = ' '; else, s = header.ch_type(ic); end
%     fwrite(fid,s,                   'uchar');       %   channel type (Hx,Hy,...)
% end
% for ic = 1:6
%     if ic > numel(header.sensor(ic)), s = ' '; else, s = header.sensor(ic); end
%     fwrite(fid,s,                   'uchar');       %   channel type (Hx,Hy,...)
% end
ns = numel(header.ch_type);
if ns > 2,    str = header.ch_type(1:2);
else str = header.ch_type;
end
fwrite(fid,str,'uchar');  
ns = numel(header.sensor);
if ns > 6, str  = header.sensor(1:6);
else, str = header.sensor;
for is = ns+1:6,  str = [str ' ']; end
end
fwrite(fid,str,'uchar');        %   sensor type (MFS05,EFP05,...)

fwrite(fid,str2num(header.sensor_no),'int16');       %   Sensor serial number
fwrite(fid,header.x1,'float32');     %   x1 coordinate of 1. Dipole (m)
fwrite(fid,header.y1,'float32');     %   y1 coordinate of 1. Dipole (m)
fwrite(fid,header.z1,'float32');     %   z1 coordinate of 1. Dipole (m)
fwrite(fid,header.x2,'float32');     %   x2 coordinate of 2. Dipole (m)
fwrite(fid,header.y2,'float32');     %   y2 coordinate of 2. Dipole (m)
fwrite(fid,header.z2,'float32');     %   z2 coordinate of 2. Dipole (m)
fwrite(fid,header.dipol_length,'float32');     %   efield dipole length (m)
fwrite(fid,header.dipol_angle,'float32');      %   efield dipole angle (north = 0???)

%RS: added complete ats header fields to enable copying headers
%MTX: Data from selftest
fwrite(fid,header.rProbeRes,'float32');
fwrite(fid,header.rDCOffset,'float32');
fwrite(fid,header.rPreGain,'float32');
fwrite(fid,header.rPostGain,'float32');

%MTX: Data from status information
fwrite(fid,header.lat,'int32');
fwrite(fid,header.lon,'int32');
fwrite(fid,header.elev,'int32');

fwrite(fid,header.byLatLongType,'uchar');
fwrite(fid,header.byAddCoordType,'uchar');
fwrite(fid,header.siRefMedian,'int16');
fwrite(fid,header.dblXCoord,'float64');
fwrite(fid,header.dblYCoord,'float64');
fwrite(fid,header.byGPSStat,'uchar');
fwrite(fid,header.byGPSAccuracy,'uchar');
fwrite(fid,header.iUTCOffset,'int16');
fwrite(fid,header.abySystemType,'uchar');

%MTX: Data from XML-Job specification
fwrite(fid,header.abySurveyHeaderName,'uchar');
fwrite(fid,header.abyMeasType,'uchar');

% MTX: Next three fields will not be supported any more
fwrite(fid,header.abyLogFileName,'uchar');
fwrite(fid,header.abySelfTestResult,'uchar');
fwrite(fid,header.abyReserved5,'uchar');

% MTX: Were the following fields ever used ?
fwrite(fid,header.siCalFreqs,'int16');
fwrite(fid,header.siCalEntryLength,'int16');
fwrite(fid,header.siCalVersion,'int16');
fwrite(fid,header.siCalStartAddress,'int16');
fwrite(fid,header.abyLFFilters,'uchar');
fwrite(fid,header.abyADU06CalFilename,'uchar');
fwrite(fid,header.iADUCalTimeDate,'int32');
fwrite(fid,header.abySensorCalFilename,'uchar');
fwrite(fid,header.iSensorCalTimeDate,'int32');
fwrite(fid,header.rPowerlineFreq1,'float32');
fwrite(fid,header.rPowerlineFreq2,'float32');
fwrite(fid,header.abyHFFilters,'uchar');

% MTX: Unused ?
fwrite(fid,header.rCSAMTFreq,'float32');
fwrite(fid,header.siCSAMTBlocks,'int16');
fwrite(fid,header.siCSAMTStacksPBlock,'int16');
fwrite(fid,header.iCSAMTBlockLength,'int32');
fwrite(fid,header.abyADBBoardType,'uchar');
fwrite(fid,header.tscComment,'uchar');
% Goto data start:
fseek(fid,header.length,'bof');
%% Close data file:
fclose(fid);
end


