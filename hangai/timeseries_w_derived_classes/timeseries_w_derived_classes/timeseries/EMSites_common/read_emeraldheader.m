%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   read data header from emerald file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   MB2005

function [gh,eh,emtype] = read_emeraldheader(xtrfile)

[pname,fname,ext]=  fileparts(xtrfile);
if isemfile(fullfile(pname,strcat(fname,'.RAW')),'RAW')
    %   take into account upper and lower case of file extension
    raw         =   dir(fullfile(pname,strcat(fname,'.RAW')));   
    fid         =   fopen(fullfile(pname,raw.name),'r');
     emtype      =   'RAW';
elseif isemfile(fullfile(pname,strcat(fname,'.SP')),'SP')
    %   take into account upper and lower case of file extension
    raw         =   dir(fullfile(pname,strcat(fname,'.SP')));   
    fid         =   fopen(fullfile(pname,raw.name),'r');
     emtype      =   'SP';
else, fprintf(1,'\nERROR: file %s not found!\n',fullfile(pname,strcat(fname,'.RAW'))); end

% read GENERAL HEADER
%---------------------------------
gh.rec_length   =   fscanf(fid,'%d',1);
gh.file_type    =   fscanf(fid,'%s',1);
gh.word_length  =   fscanf(fid,'%d',1);
gh.version      =   fscanf(fid,'%s',1);
gh.proc_id      =   fscanf(fid,'%s',1);
gh.num_ch       =   fscanf(fid,'%d',1);
gh.total_rec    =   fscanf(fid,'%d',1);
gh.first_EHrec  =   fscanf(fid,'%d',1);
gh.num_event    =   fscanf(fid,'%d',1);
gh.extend       =   fscanf(fid,'%d',1);

% read extended header
if gh.extend ~= 0
    gh.extstring = fscanf(fid,'%s',gh.extend);
end

% read EVENT HEADER
%---------------------------------
record = gh.first_EHrec;
for ir = 1:gh.num_event
    if ~fseek(fid,(record-1)*gh.rec_length,'bof')
        eh(ir).ehtime.start     =   fscanf(fid,'%ld',1);
        eh(ir).ehtime.startms   =   fscanf(fid,'%ld',1);
        eh(ir).ehtime.stop      =   fscanf(fid,'%ld',1);
        eh(ir).ehtime.stopms    =   fscanf(fid,'%ld',1);
        eh(ir).data.cvalue1     =   fscanf(fid,'%lG',1);
        eh(ir).data.cvalue2     =   fscanf(fid,'%lG',1);
        eh(ir).data.cvalue3     =   fscanf(fid,'%lG',1);
        eh(ir).recs.EH_infile   =   fscanf(fid,'%ld',1);
        eh(ir).recs.next_EH     =   fscanf(fid,'%ld',1);
        eh(ir).recs.previous_EH =   fscanf(fid,'%ld',1);
        eh(ir).recs.num_of_data =   fscanf(fid,'%ld',1);
        eh(ir).recs.start_of_data=  fscanf(fid,'%ld',1);
        eh(ir).recs.extended    =   fscanf(fid,'%d', 1);
        if eh(ir).recs.next_EH < gh.total_rec    record  =   eh(ir).recs.next_EH;
        else
            break;
        end
    end
end
fclose(fid);
return