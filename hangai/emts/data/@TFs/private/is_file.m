function log = is_file(fname)
files = dir(fname);
log = 0;
if ~isempty(files) , log = 1; end