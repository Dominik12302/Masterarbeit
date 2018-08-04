function sort_ede(station,linkit, convert2ats, varargin)

% sort_ede(station, linkit, convert2ats, ...);
% sort_ede(station, linkit, convert2ats, 'raw_path',...,'proc_path',...);  

[target_sr_rate, raw_path, proc_path] = get_info(varargin,...
    'sample_to',500, ...
    'raw_path', [parvie_path('raw'),filesep,'EDE'], ...
    'proc_path',[parvie_path('proc'),filesep,'EDE']);

if nargin < 2; linkit = false; end
if nargin < 3; convert2ats = false; end
if ~linkit; convert2ats = false; end
if isempty(station);
    nn = dir([raw_path]);
    keep = true(size(nn));
    for ind = 1 : numel(nn);
        if ~nn(ind).isdir || strcmp(nn(ind).name,'.') || strcmp(nn(ind).name,'..')
            keep(ind) = false;
        end
    end
    nn = nn(keep);
    station = {nn.name};
end

    
if iscell(station)
    for ind = 1 : numel(station);
        sort_ede(station{ind},linkit, convert2ats, varargin{:});
    end
    return
end

datapath = [raw_path,filesep,station];
folders = dir([datapath,filesep,'meas*']);

target = [proc_path,filesep,station,filesep,'ts',filesep,'adc',filesep,'EDE'];
if ~exist(target,'dir');
    make_dir_tree(target);
end

for ind = 1 : numel(folders);
    if ~linkit
        disp([datapath,filesep,folders(ind).name,'  ->   ',target,filesep,folders(ind).name])
    else
        if ~exist([target,filesep,folders(ind).name],'file')
            system(['ln -s ',[datapath,filesep,folders(ind).name],' ',[target,filesep,folders(ind).name]]);
        end
    end
end

if convert2ats
    reftime       = [2015 07 24 0 0 0];
    site          = {station};
    emts          = EMTimeSeries(reftime,{proc_path});
    emts          = EMTimeSeries(emts,site);
    emts.usech      = {'Ex','Ey'};
    emts.usetime    = [2015 07 26 0 0 0 2015 08 25 0 0 0];
    emts.lsname     = {station};
    
    % sample to 500 Hz
    if emts.site{1}{1}.srate ~= target_sr_rate
        emts.lsrate = emts.site{1}{1}.srate;
        emts.resmpfreq = target_sr_rate;
    else
        emts.lsrate = target_sr_rate;
    end
    atsfiles      = emts.atsfiles;
end
