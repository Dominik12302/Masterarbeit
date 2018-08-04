%% program to copy data from raw folders to single run folder for processing
clear all
propath = {'E:\hangai_data\north_part1\'};
calpath = ('E:\CALDATA');

 
 %% reading all EDLs and SPAMs
files = [dir([char(propath),'*B'])];
dirStations = [files.isdir];
stations = files(dirStations);
clear files dirStations
xtrFiles = {};
% sitenumber = 0;
for ifold = 1:numel(stations)
    curpath = char(strcat(propath,stations(ifold).name,'\raw\'));
    copypath = char(strcat(propath,stations(ifold).name,'\proc\spam4\run_all\'));
    filesRaw = dir([curpath]);
    dirRaw = [filesRaw.isdir];
    folderRaw = filesRaw(dirRaw);
    folderRaw(1:2) = [];
    for i = 1:numel(folderRaw)
        directory = char(strcat(curpath,folderRaw(i).name,'\'));
        cd(directory);
        command = strcat('xtrx2xtr.exe -c',calpath,' *.xtrx');
        system(command,'-echo');
    end
end

 

 
