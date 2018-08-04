%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   read data from xtrfile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   MB2005

function [xtr] = read_xtr(xtrfile)

fid             =   fopen(xtrfile,'r');
[pname,fname,ext]=fileparts(xtrfile);

%   read TITLE section
%----------------------------------
[pos] = keyword('[TITLE]',fid); fseek(fid,pos,'bof');   section.title = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.title = [section.title {cline}];    else    break,  end
end
header.title.author     = keyindex(section.title,'''AUTHOR=''',{'%s'},1);
header.title.version    = keyindex(section.title,'''VERSION=''',{'%s' '%f'},[3 1]);
header.title.date       = keyindex(section.title,'''DATE=''',{'%s'},1);
header.title.comment    = keyindex(section.title,'''COMMENT=''',{'%s'},1);

%   read STATUS section
%----------------------------------
[pos] = keyword('[STATUS]',fid); fseek(fid,pos,'bof');   section.status = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.status = [section.status {cline}];    else    break,  end
end
header.status.status     = keyindex(section.status,'''STATUS=''',{'%s'},1);

%   read Project section
%----------------------------------
[pos] = keyword('[PROJECT]',fid); fseek(fid,pos,'bof');   section.project = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.project = [section.project {cline}];    else    break,  end
end
header.project.name     = keyindex(section.project,'''NAME=''',{'%s' '%s'},[1 1]);
header.project.comment     = keyindex(section.project,'''COMMENT=''',{'%s'},1);

%   read FILE section
%----------------------------------
[pos] = keyword('[FILE]',fid); fseek(fid,pos,'bof');   section.file = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.file = [section.file {cline}];    else    break,  end
end
header.file.name     = keyindex(section.file,'''NAME=''',{'%s' '%d' '%f'},[1 2 1]);
header.file.band     = keyindex(section.file,'''FREQBAND=''',{'%s' '%g' '%s'},[1 2 1]);
header.file.date     = keyindex(section.file,'''DATE=''',{'%d'},4);
if header.file.band{1}{2}(1)==-125 &&  header.file.name{1}{3}==-500
    header.file.band{1}{2}(1) = -200;
end

%   read CHANNAME section
%----------------------------------
[pos] = keyword('[CHANNAME]',fid); fseek(fid,pos,'bof');   section.channel = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.channel = [section.channel {cline}];    else    break,  end
end
header.channel.no     = keyindex(section.channel,'''ITEMS=''',{'%d'},1);
header.channel.name = keyindex(section.channel,'''NAME=''',{'%d' '%s' '%s'},[1 1 1]);
if length(header.channel.name) ~= header.channel.no{1}{1}
    fprintf(1,'\nWarning: in xtr-file (section CHANNAME) %s\n number of entries NAME not equal value of ITEMS\n proceeding ...\n',xtrfile)
end
    
%   read SITE section
%----------------------------------
[pos] = keyword('[SITE]',fid); fseek(fid,pos,'bof');   section.site = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.site = [section.site {cline}];    else    break,  end
end
header.site.no      = keyindex(section.site,'''ITEMS=''',{'%d'},1);
header.site.name    = keyindex(section.site,'''NAME=''',{'%d' '%s' '%d' '%d'},[1 1 1 1]);
if length(header.site.name) ~= header.site.no{1}{1}
    fprintf(1,'\nWarning: in xtr-file: (section SITE) %s\n number of entries NAME not equal value of ITEMS\n proceeding ...\n',xtrfile)
end
header.site.crd = keyindex(section.site,'''COORDS=''',{'%d' '%s' '%s' '%f'},[1 1 1 1]);
if length(header.site.crd) ~= header.site.no{1}{1}
    fprintf(1,'\nWarning: in xtr-file: (section SITE) %s\n number of entries COORDS not equal value of ITEMS\n proceeding ...\n',xtrfile)
end

%   read DATA section
%----------------------------------
[pos] = keyword('[DATA]',fid); fseek(fid,pos,'bof');   section.data = {};
while 1 
    cline = fgetl(fid); if ~isempty(cline), section.data = [section.data {cline}];    else    break,  end
end

header.data.no     = keyindex(section.data,'''ITEMS=''',{'%d'},1);
header.data.chan = keyindex(section.data,'''CHAN=''',{'%d' '%f' '%f' '%d'},[3 3 1 1]);
if length(header.data.chan) ~= header.data.no{1}{1}
    fprintf(1,'\nWarning: in xtr-file: (section DATA) %s\n number of entries CHAN not equal value of ITEMS\n proceeding ...\n',xtrfile)
end

%   read CALIBRATION sections
%----------------------------------
header.dev.category ={}; header.dev.module ={};
for k = 1:header.data.no{1}{1} % no of channels in file
    
    % JK: 
    % Old:
    
    % assume three modules (hardwired)
    % for m = 1:3        
    
    % New:
    % detect number of modules on the fly
    m = 0;
    while 1        
        m = m + 1;
        
        string = ['[' num2str(2000000+header.data.chan{k}{1}(1)*1000+m) ']'];
        [pos, notfound] = keyword(string,fid); fseek(fid,pos,'bof');
        
        % JK stop if there are no further modules
        if notfound; break; end
        
        section.dev = {};
        while 1
            cline = fgetl(fid); 
            if ~isempty(cline) 
                if cline~=-1 
                    section.dev = [section.dev {cline}];    
                else
                    break
                end
            else
                break 
            end
        end
%        header.dev.category{k}{m}     = keyindex(section.dev,'''CATEGORY=''',{'%s' '%d' '%s'},[1 1 1]);
        header.dev.module{k}{m}      = keyindex(section.dev,'''MODULE=''',{'%s' '%d' '%s'},[1 1 1]);    
    end
end
%...

fclose(fid);

%------------------------------------------------------------------------
%   now read header structure
%------------------------------------------------------------------------

%xtr =   struct(MT_xtr);

tmp = header.site.name{1}{2}; [a] = strfind(tmp,''''); 
if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.site.name{1}{2} = tmp(2:end-1); end, end
xtr.sitename =   header.site.name{1}{2};

tmp = header.file.name{1}{1}; [a] = strfind(tmp,''''); 
if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.file.name{1}{1} = tmp(2:end-1); end, end
xtr.file     =   fullfile(pname,header.file.name{1}{1});

xtr.run      =   num2str(header.file.name{1}{2}(1));
xtr.events   =   header.file.name{1}{2}(2);
tmp = header.file.band{1}{1}; [a] = strfind(tmp,''''); 
if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.file.band{1}{1} = tmp(2:end-1); end, end
xtr.band     =   header.file.band{1}{1};

xtr.ver      =   0.0;        %   Version
xtr.sfreq    =   header.file.name{1}{3};          %   sampling frequency, Hz negative, sec positive
xtr.lowpass  =   header.file.band{1}{2}(1);          %   Frequency band
xtr.highpass =   header.file.band{1}{2}(2);          %   Frequency band

date1970 = datenum('01-JAN-1970 00:00:00');
xtr.start    =   header.file.date{1}{1}(1);          %   Start time, seconds since 1970
xtr.startms  =   header.file.date{1}{1}(2)/1000;
xtr.startstr =   datestr(xtr.start/3600/24 + date1970);
xtr.start   =    datevec(xtr.start/3600/24 + date1970);
xtr.stop    =    header.file.date{1}{1}(3);          %   Stop  time, seconds since 1970
%TEMP correction for wrong stop time from seed2em
% if strfind(xtrfile,'edl')
%     xtr.stop = xtr.stop + 3600;
% end
xtr.stopms  =    header.file.date{1}{1}(4)/1000;
xtr.stopstr =    datestr(xtr.stop/3600/24 + date1970);
xtr.stop   =     datevec(xtr.stop/3600/24 + date1970);

% shift starttime by one sample into past
nshft = 1;% run2, s07: 23 shift samples
srate = abs(xtr.sfreq)^(-sign(xtr.sfreq));
dt = nshft/srate*1000; % shift time in ms
startms = xtr.startms-dt;
start = xtr.start;
while startms < 0
    startms = startms+1e3;
    start(6) = start(6)-1;
end
while startms >= 1e3
    startms = startms-1e3;
    start(6) = start(6)+1;
end
start = datevec(datenum(start));

stopms = xtr.stopms-dt;
stop = xtr.stop;
while stopms < 0
    stopms = stopms+1e3;
    stop(6) = stop(6)-1;
end
while stopms >= 1e3
    stopms = stopms-1e3;
    stop(6) = stop(6)+1;
end
stop = datevec(datenum(stop));
xtr.start = start; xtr.startms = startms;
xtr.stop = stop; xtr.stopms = stopms;

for k = 1:header.data.no{1}{1} %channels
    xtr.scaling(k) =   header.data.chan{k}{3};         %
    xtr.res1(k)    =   {'001'};       %
    xtr.res2(k)    =   {'001'};       %   ADB serial number
    xtr.ch_no(k)   =   header.data.chan{k}{1}(3);           %   Channel number
    chind          =   header.data.chan{k}{1}(3);
    tmp = header.channel.name{chind}{2}; [a] = strfind(tmp,''''); 
    if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.channel.name{chind}{2} = tmp(2:end-1); end, end
    xtr.ch_type(k) =   header.channel.name{chind}(2);          %   channel type (Hx,Hy,...)
    
    % JK skip channels 'Na'
    if strcmp(xtr.ch_type(k),'Na');
        continue;
    end
    
    
    % JK
    % hardcoded before change:
    modn = 3;    
    % however, it can happen that the sensor box does not appear in the XTR file. 
    % Then modn will not be 3 but two. It seems to be safer to always take
    % the last module found:    
    modn = numel(header.dev.module{chind});
        
    
       
    tmp = header.dev.module{chind}{modn}{1}{1};  [a] = strfind(tmp,''''); 
    if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.dev.module{chind}{modn}{1}{1} = tmp(2:end-1); end, end
    xtr.sens(k)     =   header.dev.module{chind}{modn}{1}(1);         %   sensor type (MFS05,EFP05,...)
    xtr.sens_no(k) = {num2str(header.dev.module{chind}{modn}{1}{2})};
    xtr.sens_orient(k)  =   header.data.chan{k}{2}(2);
    xtr.sens_tilt(k)    =   header.data.chan{k}{2}(3);
    if strcmpi(xtr.ch_type(k),'Ex') || strcmpi(xtr.ch_type(k),'Ey')
        xtr.dipol_length(k) =   header.data.chan{k}{2}(1);      %   efield dipole length (m)
    else
        xtr.dipol_length(k) =  0;
    end
end
deg = 0; min = 0; sec = 0;
tmp = header.site.crd{1}{2}; [a] = strfind(tmp,''''); 
if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.site.crd{1}{2} = tmp(2:end-1); end, end
tmp = header.site.crd{1}{2}; [a] = strfind(tmp,':'); 
if ~isempty(tmp)
    lat = str2double(tmp);
%     deg = str2double(tmp(1:a(1)-1));
%     min = sign(deg)*str2double(tmp(a(1)+1:a(2)-1));
%     sec = sign(deg)*str2double(tmp(a(2)+1:end));
end
xtr.lat      =   lat; %deg+min/60+sec/3600;
deg = 0; min = 0; sec = 0;
tmp = header.site.crd{1}{3}; [a] = strfind(tmp,''''); 
if ~isempty(a) , if a(1) == 1 && a(2) == length(tmp) , header.site.crd{1}{3} = tmp(2:end-1); end, end
tmp = header.site.crd{1}{3}; [a] = strfind(tmp,':'); 
if ~isempty(tmp)
    lon = str2double(tmp);
%     min = sign(deg)*str2double(tmp(a(1)+1:a(2)-1));
%     sec = sign(deg)*str2double(tmp(a(2)+1:end));
end
xtr.lon      =   lon; %deg+min/60+sec/3600;
xtr.elev     =   header.site.crd{1}{4};

[gh,eh,emtype]         =   read_emeraldheader(xtrfile);
[p,r,e]=fileparts(xtr.file);
xtr.file    =   fullfile(p,[r '.' emtype]);

if gh.num_event > 1
%     button = questdlg('More than one event in raw-file! I don''t know what will happen now.','Warning','Proceed','Abort','Proceed');
disp('Warning: More than one event header in file');
end
xtr.samples  =   eh(1).recs.num_of_data;          %   Number of Samples

xtr.gh = {gh};
xtr.eh = {eh};


return

%------------------------------------------------------------------------
%   internal function to extract section with name <key> in file <fid>
%------------------------------------------------------------------------

function [pos, notfound] = keyword(key,fid)

fseek(fid,0,'bof');
while isempty(strfind(fgetl(fid),key)) && ~feof(fid),  end
pos = ftell(fid);

% JK return if not found
notfound = false;
if feof(fid); notfound = true; end

return

%--------------------------------------------------------------------------
%   internal function to extract entry with key_index <keyindex>  in section
%   <cline> (string); cline is scanned with format <form> of dimension <nm>
%--------------------------------------------------------------------------

function data = keyindex(cline,key_ind,form,nm)
l = 0;
data = [];
for k=1:length(cline)
    if ~isempty(strfind(cline{k},key_ind)) 
        next = 0;
        l = l+1;
        for f = 1:length(form)
            [tmp,count,err,nex] = sscanf(cline{k}(length(key_ind)+2+next:end-1),form{f},nm(f));
            next = nex+next;
            data{l}{f} = tmp;
        end
    end
end
if isempty(data)  
    l = l+1;
    for f = 1:length(form)
        tmp = [];
        for ff = 1:nm(f)
            switch form{f}
                case '%s'
                    tmp = [tmp '0'];
                case '%d'
                    tmp = [tmp 0];
                case '%f'
                    tmp = [tmp 0.0];
                case '%g'
                    tmp = [tmp 0.0];
            end
        end
        data{l}{f} = tmp;
    end
end
return