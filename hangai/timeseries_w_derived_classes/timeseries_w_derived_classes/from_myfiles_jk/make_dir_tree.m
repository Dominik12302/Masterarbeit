function make_dir_tree(dirtree)

% make_dir_tree(dirtree)
% creates directory tree (if not given an absolute path, relative to
% current directory).
%
% JK2015

if ~strcmp(dirtree(end),filesep); dirtree = [dirtree,filesep]; end
fs = strfind(dirtree,filesep);

ii = 1;
for ind = 1 : numel(fs) 
    ii2 = fs(ind);
    str{ind} = dirtree(ii:ii2-1);
    ii = ii2 + 1;                
end

pt = [];
for ind = 1 : numel(str);
    if ind == 1;
        pt = [pt, str{ind}];
    else
        pt = [pt, filesep, str{ind}];
    end
    if isempty(strfind(str{ind},':'))
        if ~exist(pt,'dir');
            disp(['creating directory ',pt]);
            [success, message] = mkdir(pt);
            if ~success; disp(message); end
        end
    end
end