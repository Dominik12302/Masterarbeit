function log = iszxxfile(fname)

[path,name,ext,ver] = fileparts(fname);
files = dir(strcat(path,'\*.z??'));
log = 0;
for n= 1:length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end

return