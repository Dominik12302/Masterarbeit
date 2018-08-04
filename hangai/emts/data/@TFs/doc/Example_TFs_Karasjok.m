p           = 'F:\Hangai.2016';
datapath    = {'edi'};
%usestations = {'all'};
latlim      = [44 49];
lonlim      = [98 102];
utmzone     = '48';
hemisphere  = 'T';
porigin     = [45+31.361/60 100+41.063/60 ];
porient     = 15;
%
tfs         = TFs;
tfs.datapath= datapath;
tfs.latlim  = latlim;
tfs.lonlim  = lonlim;
tfs.utmzone = utmzone;
tfs.hemisphere=hemisphere;
tfs.porigin = porigin;
tfs.porient = porient;

tfs         = TFs(tfs,p);
%%
tfs.ylim = [-10 410];
tfs.Tlim = [0.005 10000];
tfs.PTcond = 100;
usestations = {'2250B-2250B'};
tfs.usestations = usestations;
%tfs.usestations = {'all'};
tfs.rotangle = 0;
%plot_sounding(tfs,'N21E-N01A','rhoaphs');
plot_section(tfs,'PT');
plot_section(tfs,'phsxy');
plot_rose(tfs,'PT');
%%
fname = 'test.dat';
write_ModEM(tfs,fname);