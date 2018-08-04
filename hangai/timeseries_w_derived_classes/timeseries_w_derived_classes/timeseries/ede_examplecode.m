%% EDE example code
% clear classes
% fname = {'/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S001_D151113_FN020.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S002_D151113_FN018.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S003_D151113_FN019.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S004_D151113_FN019.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S006_D151113_FN018.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S007_D151113_FN019.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S008_D151113_FN018.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S009_D151113_FN018.txt',
%          '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S010_D151113_FN021.txt'};
p1 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT01-SMT'; % path of files 1
p2 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT02-S8'; % path of files 2
p3 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT03-S6'; % path of files 2
p4 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT04-S5'; % path of files 2
p5 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT06-S4'; % path of files 1
p6 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT07-S7'; % path of files 2
p7 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT08-S3'; % path of files 2
p8 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT09-S2'; % path of files 2
p9 = '/local/Promotion/Messungen/November2013/data/21_11_2013/MTDAT10-S1'; % path of files 2
Files_1=dir(fullfile(p1,'*.txt')); % Files of first station
Files_2=dir(fullfile(p2,'*.txt')); % Files of second station
Files_3=dir(fullfile(p3,'*.txt')); % Files of second station
Files_4=dir(fullfile(p4,'*.txt')); % Files of second station
Files_5=dir(fullfile(p5,'*.txt')); % Files of first station
Files_6=dir(fullfile(p6,'*.txt')); % Files of second station
Files_7=dir(fullfile(p7,'*.txt')); % Files of second station
Files_8=dir(fullfile(p8,'*.txt')); % Files of second station
Files_9=dir(fullfile(p9,'*.txt')); % Files of second station

figure;
% cc=hsv(numel(Files));
cc=hsv(9);
k=1; % Color_index
% for i=130:(numel(Files_1)-1)
for i=numel(Files_1)-3:numel(Files_1)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_1(i).name);
    ede  = EDE(ede,(fullfile(p1,Files_1(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(1,:));
    k=k+1;
    hold on
    clear ede;
end

% for i=132:(numel(Files_2))
for i=numel(Files_2)-3:numel(Files_2)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_2(i).name);
    ede  = EDE(ede,(fullfile(p2,Files_2(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(2,:));
    k=k+1;
    hold on
    clear ede;
end

% for i=132:(numel(Files_2))
for i=numel(Files_3)-3:numel(Files_3)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_3(i).name);
    ede  = EDE(ede,(fullfile(p3,Files_3(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(3,:));
    k=k+1;
    hold on
    clear ede;
end

% for i=132:(numel(Files_2))
for i=numel(Files_4)-3:numel(Files_4)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_4(i).name);
    ede  = EDE(ede,(fullfile(p4,Files_4(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(4,:));
    k=k+1;
    hold on
    clear ede;
end

% for i=132:(numel(Files_2))
for i=numel(Files_5)-9:(numel(Files_5)-1)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_5(i).name);
    ede  = EDE(ede,(fullfile(p5,Files_5(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+29/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(5,:));
    k=k+1;
    hold on
    clear ede;
end
% for i=132:(numel(Files_2))
for i=numel(Files_6)-15:numel(Files_6)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_6(i).name);
    ede  = EDE(ede,(fullfile(p6,Files_6(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+14/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(6,:));
    k=k+1;
    hold on
    clear ede;
end
% for i=132:(numel(Files_2))
for i=numel(Files_7)-3:numel(Files_7)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_7(i).name);
    ede  = EDE(ede,(fullfile(p7,Files_7(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(7,:));
    k=k+1;
    hold on
    clear ede;
end
% for i=132:(numel(Files_2))
for i=numel(Files_8)-3:numel(Files_8)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_8(i).name);
    ede  = EDE(ede,(fullfile(p8,Files_8(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(8,:));
    k=k+1;
    hold on
    clear ede;
end
% for i=132:(numel(Files_2))
for i=numel(Files_9)-3:numel(Files_9)
    ede   = EDE;
    ede.resmplfreq = 10;
    ede.dec = 1;
    ede.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
    fprintf('Processing: %s \n',Files_9(i).name);
    ede  = EDE(ede,(fullfile(p9,Files_9(i).name)));
    ede.usetime(1:6)=ede.starttime+[0 0 0 0 0 5];
    ede.usetime(7:12)=datevec(datenum(ede.starttime)+59/(60*24));
    ede.dipole = [60 60];
    plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:))*1,'color',cc(9,:));
    k=k+1;
    hold on
    clear ede;
end
%% Plot original and resampled data:

% plot(ede.t,ede.data(1,:),'color','r');
% hold on;
% plot(ede.t_r,ede.data_r(1,:)-mean(ede.data_r(1,:)),'color','g');
% hold on
% figure;
% fname = '/local/Promotion/Messungen/November2013/data/tmp/comp/edesoh_S001_D151113_FN020.txt';
% ede2   = EDE;
% ede2.Nch = 2;
% ede2.resmplfreq = 40;
% ede2.dec = 2;
% ede2.usetime = [[2013,11,15,05,56,00] [2013,11,15,06,20,00]];
% ede2   = EDE(ede2,fname);
% plot(ede2.t_r,ede2.data_r(1,:)-mean(ede2.data_r(1,:)),'color','r');
%% ADU data generation:
% [p,f,ext] = fileparts(ede.datafile);
% p = '/local/Promotion/Messungen/November2013/data/tmp/comp/adu_class_test/ts/adc/ADU/meas_2013-11-15_01-54-59';
% dname = ['125_V01_C00_R000_TEx_BL_8H' '.ats'];
% new_datafile = fullfile(p,dname);
% myADU = ADU(ede,1);
% myADU.datafile = new_datafile;
% myADU.write_ats(ede.data_r(1,:)/ede.lsb);
