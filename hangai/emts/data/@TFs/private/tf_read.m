function obj = tf_read(obj,fname)
if iszxxfile(fname)
elseif isedifile(fname)
    obj = read_edi(obj,fname);
elseif isidefile(fname)
else issifile(fname)
end

function log = iszxxfile(fname)
[path,name,ext] = fileparts(fname);
files = dir(fullfile(path,'*.z??'));
log = 0;
for n= 1:length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end

function log = isedifile(fname)
[path,name,ext] = fileparts(fname);
files = dir(fullfile(path,'*.edi'));
log = 0;
for n= 1:length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end

function log = isidefile(fname)
[path,name,ext] = fileparts(fname);
files = dir(fullfile(path,'*.ide'));
log = 0;
for n= 1:length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end

function log = issifile(fname)
[path,name,ext] = fileparts(fname);
files = dir(fullfile(path,'*.si'));
log = 0;
for n= 1:length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end
