function sort_ede(station,linkit, varargin)

% sort_ede(station, linkit, ...);
% sort_ede(station, linkit, 'raw_path',...,'propath',...);  
% 
% 'raw_path_mode',1/2, 1 default, see below
% 'raw_path' optional base path for SPAM4 raw data. Is applied as
%       propath/SITENAME/raw_path/... ('raw_path_mode', 1)
%       OR
%       raw_path/SITENAME/...         ('raw_path_mode', 2)
%       for mode 1, raw_path should be an relative path ('.e.g., 'RAW')
%       for mode 2, raw_path should be an absolute path ('.e.g., '/sadasd/RAW')
%
% optional argument: 'forcecopy' (default: false) to enforce physical copy
%                   even on linux / mac systems
% 
% simplified version of sort_spam4 and for documentation refer to there
% copies/links folders to the location propath/SITENAME/ts/adc/EDE/...
% JK 2015, updated 2017

[raw_path, raw_path_mode, propath, forcecopy] = get_info(varargin,...
    'raw_path','RAW', 'raw_path_mode',1,'propath','D:\DATA_files\DATA\Hangai_2016_testing','forcecopy',false);

if nargin < 2; linkit = false; end
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
        sort_ede(station{ind},linkit, varargin{:});
    end
    return
end

switch raw_path_mode
    case 1
        datapath = [propath,filesep,station,filesep,raw_path];
    case 2
        datapath = [raw_path,filesep,station];
end
folders = dir([datapath,filesep,'meas*']);

target = [propath,filesep,station,filesep,'ts',filesep,'adc',filesep,'EDE'];
if ~exist(target,'dir');
    make_dir_tree(target);
end

for ind = 1 : numel(folders);
    if ~linkit
        disp([datapath,filesep,folders(ind).name,'  ->   ',target,filesep,folders(ind).name])
    else
        if ~exist([target,filesep,folders(ind).name],'file')
            if ~ispc && ~forcecopy
                p1 = add_backspaces([datapath,filesep,folders(ind).name]);
                p2 = add_backspaces([target,filesep,folders(ind).name]);
                system(['ln -s ',p1,' ',p2]);
            else
                disp([datapath,filesep,folders(ind).name,'  ->   ',target,filesep,folders(ind).name])
                fprintf('copying ... ');
                copyfile([datapath,filesep,folders(ind).name],[target,filesep,folders(ind).name]);                
                fprintf('done!\n')
            end            
        end                
    end    
    mtd_files = dir(fullfile([target,filesep,folders(ind).name],'*.mtd'));
    txt_files = dir(fullfile([target,filesep,folders(ind).name],'*.txt'));
    dipole_file = find(~cellfun(@isempty,strfind({txt_files(:).name},'dipol')));
    if isempty(dipole_file);
        msg = ['WARNING!!: no dipole file found!!!'];
        disp(['!!!!!!!!!!!!!!'])
        disp(msg);
        disp(['!!!!!!!!!!!!!!'])
        msgbox(msg);
    elseif numel(dipole_file) > 1;
        msg = ['WARNING!!: ',num2str(numel(dipole_file)),' dipole files found!!!'];
        disp(['!!!!!!!!!!!!!!'])
        disp(msg);
        disp(['!!!!!!!!!!!!!!'])
        msgbox(msg);
    end
    txt_files(dipole_file) = [];
    if numel(txt_files) ~= numel(mtd_files)
        msg = ['WARNING!!: found ',num2str(numel(txt_files)),' TXT-files but ',num2str(numel(mtd_files)),' MTD-files !!!'];
        disp(['!!!!!!!!!!!!!!'])
        disp(msg);
        disp(['!!!!!!!!!!!!!!'])
        msgbox(msg);
    end    
end