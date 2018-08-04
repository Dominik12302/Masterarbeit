% test_read

xtrfile = 'D:\becken\test_xtr\701s\emerald\_1HBF001.XTR';

[xtr_header]    =   read_xtr(xtrfile);
[gh,eh]         =   read_emeraldheader(xtrfile);

if strcmpi(gh.file_type(1),'B') %   binary data
switch gh.file_type(2)
    case 'C'
        formatstr = '';
    case 'F'
        formatstr = 'float';
    case 'I'
        formatstr = 'integer';
    case 'R'
        formatstr = 'float';
end
formatstr = [formatstr num2str(gh.word_length*8)];

% read some data
[pname,fname,ext]=  fileparts(xtrfile);
raw         =   dir(fullfile(pname,strcat(fname,'.RAW')));
fid         =   fopen(fullfile(pname,raw.name),'r');

fseek(fid,(eh(1).recs.start_of_data-1)*gh.rec_length,'bof');
data    =   fread(fid,[gh.num_ch eh(1).recs.num_of_data ],formatstr);
fclose(fid);
nsmp = 1024
figure(1)
subplot(511)
plot(data(5,(nsmp+1:2*nsmp)))
subplot(512)
plot(data(4,(nsmp+1:2*nsmp)))
subplot(513)
plot(data(3,(nsmp+1:2*nsmp)))
subplot(514)
plot(data(2,(nsmp+1:2*nsmp)))
subplot(515)
plot(data(1,(nsmp+1:2*nsmp)))

end

