function log = isxtrfile(fname)

[path,name,ext] = fileparts(fname);
files = dir(fullfile(path,'*.XTR'));
log = 0;
for n= 1: length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end