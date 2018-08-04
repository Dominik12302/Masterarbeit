%% function for reading EDE header files (by Michael Becken)

function ede = readsoh(fname)
    fid = fopen(fname,'r','b');
    tmp = fgetl(fid); % Ede Nr.
    
    % reading system runtimes
    tmp = fgetl(fid); % System Start time
    time = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]);
    time = [str2double(time(1:2)) str2double(time(3:4)) str2double(time(5:6))];
    tmp = fgetl(fid); % System Start Date
    date = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]);
    date = [str2double(strcat('20',date(5:6))) str2double(date(3:4)) str2double(date(1:2))];
    ede.systemstart = {[date time]};
    tmp = fgetl(fid); % lat
    ede.lat = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]);
    tmp = fgetl(fid); % long
    ede.long = sscanf(tmp(strfind(tmp,':')+1:end),'%s',[1]);
    tmp = fgetl(fid); % delay
    tmp = fgetl(fid); % empty
    tmp = fgetl(fid); % samplerate
    
    % reading file runtimes
    tmp = fgetl(fid); % start time
    time = sscanf(tmp,'%*s %*s %d %d %d',[4])';
    tmp = fgetl(fid); % start date
    date = sscanf(tmp,'%*s %*s %d %d %d',[4])';
    ede.filestart = {[date time]};
    tmp = fgetl(fid); % empty
    tmp = fgetl(fid); % stop time
    time = sscanf(tmp,'%*s %*s %d %d %d',[4])';
    tmp = fgetl(fid); % stop date
    date = sscanf(tmp,'%*s %*s %d %d %d',[4])';
    tmp = date(1);
    date(1) = date(3);
    date(3) = tmp;
    ede.filestop = {[date time]};
    fclose(fid);
end