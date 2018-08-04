%% program to plot runtimes from all stations in project folder
clear all;
reftime = [2016 07 13 02 00 00];


propath = {'E:\hangai_data\HANGAI_PHASE2_CENTER_data_archive\'};

[runtimes1] = read_runtimes(propath,reftime);

propath = {'E:\hangai_data\south_part2\'};

[runtimes2] = read_runtimes(propath,reftime);

propath = {'/var/run/media/d_harp01/TOSHIBA EXT/hangai_data/south_part1/'};

[runtimes3] = read_runtimes(propath,reftime);

propath = {'E:\hangai_data\north_part1\'};

[runtimes4] = read_runtimes(propath,reftime);

propath = {'E:\hangai_data\center_part1\'};

[runtimes5] = read_runtimes(propath,reftime);


runtimes = [runtimes1,runtimes2,runtimes3,runtimes4,runtimes5];


%% concatenate multiple stations

for i = 1:numel(runtimes)
    check{i} = strfind([runtimes(:).sitename],runtimes(i).sitename);
end

multiple = {};
for i = 1:numel(check)
    if (numel(cell2mat(check(i))) > 1)
        multiple(end+1) = {(cell2mat(check(i))-1)/5 + 1};
    end
end
multiple = multiple(1:numel(multiple)/2);


del = [];
for i = 1:numel(multiple)
    index = cell2mat(multiple(i));
    for j = 2:numel(index)
        runtimes(index(1)).start = [runtimes(index(1)).start, runtimes(index(j)).start];
        runtimes(index(1)).stop = [runtimes(index(1)).stop, runtimes(index(j)).stop];
        del(end+1) = index(j);
    end
end

del = sort(del);

for i = numel(del):-1:1
    runtimes(del(i)) = [];
end







save runtimes runtimes;