%% reads runtimes from all stations in propath, needs read_xtr.m

function [runtimes] = read_runtimes(propath,reftime)
    %% reading all EDEs
    files = dir([char(propath),'*T']);
    dirStations = [files.isdir];
    stations = files(dirStations);
    clear files dirStations
    sitenumber = 0;
    ede = {};
    runtimes.sitename = ''; 
    for ifold = 1:numel(stations)
        curpath = char(strcat(propath,stations(ifold).name,'\raw\'));
        filesRaw = dir([curpath,'meas*']);
        dirRaw = [filesRaw.isdir];
        folderRaw = filesRaw(dirRaw);
        dirFiles = {};
        % reading runtimes from txt-files (EDE)
        if ~isempty(folderRaw)
            run = 1;
            sitenumber = sitenumber + 1;
            for fi = 1:numel(folderRaw)
                %%% (strfind([runstimes4.sitename],'2025T')-1)\5+1   to
                %%% find out whether the station is already loaded
                dirFiles{fi} = dir([strcat(curpath,folderRaw(fi).name,'\'),'ede*FN*.txt']);
                filepath = strcat(curpath,folderRaw(run).name,'\',dirFiles{run}(end).name);
                ede{sitenumber}{run} = readsoh(filepath);
                runtimes(sitenumber).start{run} = cell2mat(ede{sitenumber}{run}.systemstart);
                runtimes(sitenumber).stop{run} = cell2mat(ede{sitenumber}{run}.filestop);
                runtimes(sitenumber).lat = str2num(ede{sitenumber}{1}.lat)/100;
                runtimes(sitenumber).long = str2num(ede{sitenumber}{1}.long)/100;
                run = run + 1;
            end
            runtimes(sitenumber).sitename = stations(sitenumber).name;
            runtimes(sitenumber).file = filepath;
        end
    end
 
     %% reading all EDLs and SPAMs
    files = [dir([char(propath),'*L']);dir([char(propath),'*B'])];
    dirStations = [files.isdir];
    stations = files(dirStations);
    clear files dirStations
    xtrFiles = {};
    % sitenumber = 0;
    for ifold = 1:numel(stations)
        curpath = char(strcat(propath,stations(ifold).name,'\raw\'));
        filesRaw = dir([curpath]);
        dirRaw = [filesRaw.isdir];
        folderRaw = filesRaw(dirRaw);
        folderRaw(1:2) = [];
        dirFiles = {};
        site = 'None';
        % reading runtimes from xtr-files (EDL / Spam)
        for fi = 1:numel(folderRaw)
            dirFiles{fi} = dir([strcat(curpath,folderRaw(fi).name,'\'),'*.xtr']);
        end
        disp(strcat('Reading folder ',' ',curpath))
        for idir = 1:numel(dirFiles)
            for ifile = 1:numel(dirFiles{idir})
                if (~isempty(dirFiles{idir}))
                    filepath = strcat(curpath,folderRaw(idir).name,'\',dirFiles{idir}(ifile).name);
                    xtrFiles{end+1} = read_xtr(filepath,0);
                    if ~strcmp(xtrFiles{numel(xtrFiles)}.sitename,site) % new station
                        run = 1;
                        sitenumber = sitenumber + 1;
                        runtimes(sitenumber).sitename = stations(ifold).name;
                        site = xtrFiles{numel(xtrFiles)}.sitename;
                        runtimes(sitenumber).start{run} = xtrFiles{numel(xtrFiles)}.start;
                    elseif (etime(xtrFiles{end}.start,xtrFiles{end-1}.stop) ~= 1)  % new run 
                        run = run + 1;
                        runtimes(sitenumber).start{run} = xtrFiles{numel(xtrFiles)}.start;
                    end
                    runtimes(sitenumber).stop{run} = xtrFiles{numel(xtrFiles)}.stop;
                    runtimes(sitenumber).file = filepath;
                    runtimes(sitenumber).lat = xtrFiles{numel(xtrFiles)}.lat;
                    runtimes(sitenumber).long = xtrFiles{numel(xtrFiles)}.lon;
                end
            end
        end
    end
end

 
