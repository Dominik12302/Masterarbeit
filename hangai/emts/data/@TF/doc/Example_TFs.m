p = '/Users/mbeck_07/sciebo/projects/Masi/EDI-Files';
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
