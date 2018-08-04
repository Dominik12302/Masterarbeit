function obj = tf_read(obj,fname)
if iszxxfile(fname)
elseif isedifile(fname)
    obj = read_edi(obj,fname);
elseif isidefile(fname)
elseif issifile(fname)
    obj = read_si(obj,fname);
end
if isusefile(fname)
    [path,name,ext] = fileparts(fname);
    usefile = fullfile(path,[name, '.use']);
    fid = fopen(usefile);
    fident  = [];
    for fi = 1:numel(obj.output)
        fident = [fident '%d '];
    end    
    use = fscanf(fid,fident,[fi inf]);
    obj.tfuse = use;
    fclose(fid);
else 
    [path,name,ext] = fileparts(fname);
    usefile = fullfile(path,[name, '.use']);
    fid = fopen(usefile,'w');
    fident  = [];
    for fi = 1:numel(obj.output)
        fident = [fident '%d '];
    end 
    fident = [fident '\n'];
    fprintf(fid,fident,ones(size(squeeze(obj.tf(:,1,:))))');
    fclose(fid);
    obj.tfuse = ones(size(squeeze(obj.tf(:,1,:))));
end


function log = isusefile(fname)
[path,name,ext] = fileparts(fname);
usefile = fullfile(path,[name, '.use']);
log = 0;
if exist(usefile)
    log = 1;
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
files = dir(fullfile(path,'*MTSI.00*'));
log = 0;
for n= 1:length(files)
    if strcmpi(files(n).name,[name ext])
        log = 1;
        break
    end
end
