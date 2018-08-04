function log = isemfile(fname)

[path,name,ext,ver] = fileparts(fname);
files = dir(fullfile(path,'*.RAW'));
log = 0;
for n= 1: length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end