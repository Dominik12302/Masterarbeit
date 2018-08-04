function log = isemfile(fname,em)

[path,name,ext] = fileparts(fname);
files = dir(fullfile(path,strcat('*.',em)));
log = 0;
for n= 1: length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end