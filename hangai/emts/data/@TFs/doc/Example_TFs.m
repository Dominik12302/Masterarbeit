p           = '/Users/mbeck_07/sciebo/projects/Masi';
datapath    = {'EDI-files'};
%usestations = {'all'};
latlim      = [69 71];
lonlim      = [22 25];
utmzone     = '35';
hemisphere  = 'N';
porigin     = [23.401580555555554  69.443444444444452];
porient     = 90;
%%
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
usestations = {'o14e-o03a_dec1' 'o13e-o03a_coh0.9_dec1' 'o12u-o03a_dec1_512H' 'o11e-o03a_dec1' ...
    'o10e-o03a_coh0.9_dec1' 'o09e-o03a_dec1' 'o08e-o03a_dec1' 'o15e-o03a_dec1' 'o05e-o03a_dec1' ...
    'o04e-o03a_dec1' 'o02e-o03a_coh0.9_dec1' 'o03a_coh0.8_dec1' 'o01e-o03a_coh0.9_dec1'};

tfs.usestations = usestations;
%tfs.usestations = {'all'};


plot_PTsection(tfs);
plot_RPsection(tfs);
%%
d = dir(fullfile(p,'*.edi'));
for id = 1:numel(d)
    fname = fullfile(p,d(id).name );
    [p,n,ext]=fileparts(fname);
    tfs   = TFs;
    tfs   = TFs(tfs,fname);
    tfs.lrot = 0;
    tfs.brot = 0;
    plot_PT(tfs)
    set(gcf,'color','w')
    export_fig(fullfile(p,[n '_PT.png']))
    close(gcf)
    plot_PTab(tfs)
    set(gcf,'color','w')
    export_fig(fullfile(p,[n '_PTab.png']))
    close(gcf)
    plot_PTellipse(tfs);
    set(gcf,'color','w')
    export_fig(fullfile(p,[n '_PTellipse.png']))
    close(gcf)
    plot_rhoaphs(tfs);
    set(gcf,'color','w')
    export_fig(fullfile(p,[n '_rhoa_phs.png']))
    close(gcf)
end
%%
fname = '/Users/mbeck_07/sciebo/projects/Masi/EDI-Files/w24a_coh0.8_dec1.edi';

[p,n,ext]=fileparts(fname);
tfs   = TFs;
tfs   = TFs(tfs,fname);
tfs.lrot = 0;
tfs.brot = 90;
tfs.output = {'Hz'  'Ex'  'Ey'};
tfs.input = {'Hx'  'Hy'};
plot_PT(tfs)
plot_PTab(tfs)
plot_PTellipse(tfs);
plot_rhoaphs(tfs);
%%
Z = tfs.Z;

for ip = 1:tfs.Np
    Zdet(ip) = abs(det(Z(:,:,ip)))*tfs.T(ip)/5;
end
