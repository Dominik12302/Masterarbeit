function D = scandir(pathname, pattern)

% D = scandir(pathname, pattern)
%
% applies D = dir(fullfile(pathname,pattern));
% recursively to all subdirectories
% JK2015

if isempty(pathname); pathname = '.'; end

D = dir(fullfile(pathname,pattern));
[D(:).location] = deal([]);

for ind = 1 : numel(D)
    D(ind).location = pathname;
end

dirs = dir(pathname);
for ind = 1 : numel(dirs)
    if strcmp(dirs(ind).name,'.') || strcmp(dirs(ind).name,'..')
        continue;
    elseif dirs(ind).isdir
            D = cat(1,D,scandir(fullfile(pathname,dirs(ind).name),pattern));
    end
end