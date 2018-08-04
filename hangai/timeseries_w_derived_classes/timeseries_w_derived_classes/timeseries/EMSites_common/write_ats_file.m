% Function designed to work with the ADU class in order to write a .ats
% file from the ADU object 'obj' and the data 'data' to a datafile
% 'obj.datafile'
%
% CAUTION: The data has to be in integer values (i.e. the measured values
% before they are multiplied by the lsb factor)
function write_ats_file(obj,ch,filename,filepath,varargin)

%% Open file:
datafile = fullfile(filepath,filename);
if(exist(datafile,'file'))
    disp('File already exists, pick new File!');
    [FileName,PathName] = uiputfile('*.ats','Select the .ats file to write to');
    datafile = fullfile(PathName,FileName);
end
fprintf('Writing .ats file: %s \n',datafile);

fid     = fopen(datafile,'w');
%% Write obj:
fwrite(fid,zeros(1,obj.length),'int8');
fseek(fid,0,'bof');
fwrite(fid,obj.length,'int16');       %   Bytes of Header
fwrite(fid,obj.ver,'int16');       %   Version
fwrite(fid,obj.Nsmp_r,'int32');       %   Number of Samples -> Change it to Nsmp?
if(obj.resmplfreq > 0)
    fwrite(fid,obj.resmplfreq/obj.dec,'float32');
else
    fwrite(fid,obj.srate/obj.dec,'float32');     %   sampling frequency, Hz
end
% fwrite(fid,obj.starttime_sec,'int32');       %   Start time, seconds since 1970
% fwrite(fid,(datenum(obj.usetime(1:6))-datenum([1970 1 1 0 0 0]))*24*60*60,'int32');       %   Start time, seconds since 1970
fwrite(fid,etime(obj.usetime(1:6),[1970 1 1 0 0 0]),'int32');       %   Start time, seconds since 1970
fwrite(fid,obj.lsb,'double');      %   LSB-Value
fwrite(fid,obj.iGMTOffset,'int32');
fwrite(fid,obj.rOrigSampleFreq,'float32');
fwrite(fid,str2num(obj.SN_string),'int16');
fwrite(fid,str2num(obj.adb06),'int16');
fwrite(fid,obj.ch_no,'int8');        %   Channel number
fwrite(fid,obj.bychopper,'int8');
fwrite(fid,obj.chnames,'uchar');       %   channel type (Hx,Hy,...)
fwrite(fid,obj.sens_name,'uchar');        %   sensor type (MFS05,EFP05,...)
% fwrite(fid,obj.sensor_no,'int16');       %   Sensor serial number
fwrite(fid,0,'int16');       %   Sensor serial number

fwrite(fid,obj.x1,'float32');     %   x1 coordinate of 1. Dipole (m)
fwrite(fid,obj.y1,'float32');     %   y1 coordinate of 1. Dipole (m)
fwrite(fid,obj.z1,'float32');     %   z1 coordinate of 1. Dipole (m)
fwrite(fid,obj.x2,'float32');     %   x2 coordinate of 2. Dipole (m)
fwrite(fid,obj.y2,'float32');     %   y2 coordinate of 2. Dipole (m)
fwrite(fid,obj.z2,'float32');     %   z2 coordinate of 2. Dipole (m)
fwrite(fid,obj.dipole,'float32');     %   efield dipole length (m)
fwrite(fid,obj.orient,'float32');      %   efield dipole angle (north = 0???)

%RS: added complete ats obj fields to enable copying objs
%MTX: Data from selftest
fwrite(fid,obj.rProbeRes,'float32');
fwrite(fid,obj.rDCOffset,'float32');
fwrite(fid,obj.rPreGain,'float32');
fwrite(fid,obj.rPostGain,'float32');

%MTX: Data from status information
fwrite(fid,obj.lat,'int32');
fwrite(fid,obj.lon,'int32');
fwrite(fid,obj.alt,'int32');

fwrite(fid,obj.byLatLongType,'uchar');
fwrite(fid,obj.byAddCoordType,'uchar');
fwrite(fid,obj.siRefMedian,'int16');
fwrite(fid,obj.dblXCoord,'float64');
fwrite(fid,obj.dblYCoord,'float64');
fwrite(fid,obj.byGPSStat,'uchar');
fwrite(fid,obj.byGPSAccuracy,'uchar');
fwrite(fid,obj.iUTCOffset,'int16');
fwrite(fid,obj.abySystemType,'uchar');

%MTX: Data from XML-Job specification
fwrite(fid,obj.abySurveyHeaderName,'uchar');
fwrite(fid,obj.abyMeasType,'uchar');

% MTX: Next three fields will not be supported any more
fwrite(fid,obj.abyLogFileName,'uchar');
fwrite(fid,obj.abySelfTestResult,'uchar');
fwrite(fid,obj.abyReserved5,'uchar');

% MTX: Were the following fields ever used ?
fwrite(fid,obj.siCalFreqs,'int16');
fwrite(fid,obj.siCalEntryLength,'int16');
fwrite(fid,obj.siCalVersion,'int16');
fwrite(fid,obj.siCalStartAddress,'int16');
fwrite(fid,obj.abyLFFilters,'uchar');
fwrite(fid,obj.abyADU06CalFilename,'uchar');
fwrite(fid,obj.iADUCalTimeDate,'int32');
fwrite(fid,obj.abySensorCalFilename,'uchar');
fwrite(fid,obj.iSensorCalTimeDate,'int32');
fwrite(fid,obj.rPowerlineFreq1,'float32');
fwrite(fid,obj.rPowerlineFreq2,'float32');
fwrite(fid,obj.abyHFFilters,'uchar');

% MTX: Unused ?
fwrite(fid,obj.rCSAMTFreq,'float32');
fwrite(fid,obj.siCSAMTBlocks,'int16');
fwrite(fid,obj.siCSAMTStacksPBlock,'int16');
fwrite(fid,obj.iCSAMTBlockLength,'int32');
fwrite(fid,obj.abyADBBoardType,'uchar');
fwrite(fid,obj.tscComment,'uchar');

% Goto data start:
fseek(fid,obj.length,'bof');
%% Write data:
if(numel(varargin) == 1)
    data = varargin{1};
else
    data = obj.data_r(ch,:); % Read data_r
end
data = data*obj.dipole(ch); % Recalculate data from original dipole
data = data/obj.lsb; % Recalculate integere values
fwrite(fid,int32(data),'int32');
%% Close data file:
fclose(fid);
end



%%Old:
% function write_ats_file(obj, data,varargin)
% 
% %% Open file:
% if(numel(varargin)==0)
%     if(exist(obj.datafile,'file'))
%         disp('File already exists, pick new File!');
%         [FileName,PathName] = uiputfile('*.ats','Select the .ats file to write to');
%         obj.datafile = fullfile(PathName,FileName);
%     end
% else
%     obj.datafile = varargin{1};
%     disp(obj.datafile);
% end
% fid     = fopen([obj.datafile],'w');
% %% Write obj:
% fwrite(fid,zeros(1,obj.length),'int8');
% fseek(fid,0,'bof');
% fwrite(fid,obj.length,'int16');       %   Bytes of Header
% fwrite(fid,obj.ver,'int16');       %   Version
% fwrite(fid,obj.Nsmp_r,'int32');       %   Number of Samples -> Change it to Nsmp?
% if(obj.resmplfreq > 0)
%     fwrite(fid,obj.resmplfreq/obj.dec,'float32');
% else
%     fwrite(fid,obj.srate/obj.dec,'float32');     %   sampling frequency, Hz
% end
% % fwrite(fid,obj.starttime_sec,'int32');       %   Start time, seconds since 1970
% fwrite(fid,(datenum(obj.usetime(1:6))-datenum([1970 1 1 0 0 0]))*24*60*60,'int32');       %   Start time, seconds since 1970
% fwrite(fid,obj.lsb,'double');      %   LSB-Value
% fwrite(fid,obj.iGMTOffset,'int32');
% fwrite(fid,obj.rOrigSampleFreq,'float32');
% fwrite(fid,str2num(obj.SN_string),'int16');
% fwrite(fid,str2num(obj.adb06),'int16');
% fwrite(fid,obj.ch_no,'int8');        %   Channel number
% fwrite(fid,obj.bychopper,'int8');
% fwrite(fid,obj.chnames,'uchar');       %   channel type (Hx,Hy,...)
% fwrite(fid,obj.sens_name,'uchar');        %   sensor type (MFS05,EFP05,...)
% % fwrite(fid,obj.sensor_no,'int16');       %   Sensor serial number
% fwrite(fid,0,'int16');       %   Sensor serial number
% 
% fwrite(fid,obj.x1,'float32');     %   x1 coordinate of 1. Dipole (m)
% fwrite(fid,obj.y1,'float32');     %   y1 coordinate of 1. Dipole (m)
% fwrite(fid,obj.z1,'float32');     %   z1 coordinate of 1. Dipole (m)
% fwrite(fid,obj.x2,'float32');     %   x2 coordinate of 2. Dipole (m)
% fwrite(fid,obj.y2,'float32');     %   y2 coordinate of 2. Dipole (m)
% fwrite(fid,obj.z2,'float32');     %   z2 coordinate of 2. Dipole (m)
% fwrite(fid,obj.dipole,'float32');     %   efield dipole length (m)
% fwrite(fid,obj.orient,'float32');      %   efield dipole angle (north = 0???)
% 
% %RS: added complete ats obj fields to enable copying objs
% %MTX: Data from selftest
% fwrite(fid,obj.rProbeRes,'float32');
% fwrite(fid,obj.rDCOffset,'float32');
% fwrite(fid,obj.rPreGain,'float32');
% fwrite(fid,obj.rPostGain,'float32');
% 
% %MTX: Data from status information
% fwrite(fid,obj.lat,'int32');
% fwrite(fid,obj.lon,'int32');
% fwrite(fid,obj.alt,'int32');
% 
% fwrite(fid,obj.byLatLongType,'uchar');
% fwrite(fid,obj.byAddCoordType,'uchar');
% fwrite(fid,obj.siRefMedian,'int16');
% fwrite(fid,obj.dblXCoord,'float64');
% fwrite(fid,obj.dblYCoord,'float64');
% fwrite(fid,obj.byGPSStat,'uchar');
% fwrite(fid,obj.byGPSAccuracy,'uchar');
% fwrite(fid,obj.iUTCOffset,'int16');
% fwrite(fid,obj.abySystemType,'uchar');
% 
% %MTX: Data from XML-Job specification
% fwrite(fid,obj.abySurveyHeaderName,'uchar');
% fwrite(fid,obj.abyMeasType,'uchar');
% 
% % MTX: Next three fields will not be supported any more
% fwrite(fid,obj.abyLogFileName,'uchar');
% fwrite(fid,obj.abySelfTestResult,'uchar');
% fwrite(fid,obj.abyReserved5,'uchar');
% 
% % MTX: Were the following fields ever used ?
% fwrite(fid,obj.siCalFreqs,'int16');
% fwrite(fid,obj.siCalEntryLength,'int16');
% fwrite(fid,obj.siCalVersion,'int16');
% fwrite(fid,obj.siCalStartAddress,'int16');
% fwrite(fid,obj.abyLFFilters,'uchar');
% fwrite(fid,obj.abyADU06CalFilename,'uchar');
% fwrite(fid,obj.iADUCalTimeDate,'int32');
% fwrite(fid,obj.abySensorCalFilename,'uchar');
% fwrite(fid,obj.iSensorCalTimeDate,'int32');
% fwrite(fid,obj.rPowerlineFreq1,'float32');
% fwrite(fid,obj.rPowerlineFreq2,'float32');
% fwrite(fid,obj.abyHFFilters,'uchar');
% 
% % MTX: Unused ?
% fwrite(fid,obj.rCSAMTFreq,'float32');
% fwrite(fid,obj.siCSAMTBlocks,'int16');
% fwrite(fid,obj.siCSAMTStacksPBlock,'int16');
% fwrite(fid,obj.iCSAMTBlockLength,'int32');
% fwrite(fid,obj.abyADBBoardType,'uchar');
% fwrite(fid,obj.tscComment,'uchar');
% 
% % Goto data start:
% fseek(fid,obj.length,'bof');
% %% Write data:
% fwrite(fid,int32(data),'int32');
% 
% %% Close data file:
% fclose(fid);
% end