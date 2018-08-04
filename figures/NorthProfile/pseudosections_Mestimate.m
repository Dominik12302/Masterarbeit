p           = '/syn06/d_harp01/MasterThesis/case_2000line/2d_inversion/mestimator';
datapath    = {'EDIs_Mest_masked'};
latlim      = [42 52];
lonlim      = [93 105];
%utmzone     = '48';
utmzone     = '47U';
hemisphere  = 'N';
porigin     = [ 47.968213  101.428076]; %2115T point
% porigin     = [ 49.713070  101.998926]; %2920T point
%porigin     = [ 44.374541  100.401661]; 2000 south point
porient     = 15; % rel. to north 
% porient     = 195; % rel. to north
%
disp('loading....')
tfs         = TFs;
tfs.datapath= datapath;
tfs.latlim  = latlim;
tfs.lonlim  = lonlim;
tfs.utmzone = utmzone;
tfs.hemisphere=hemisphere;
tfs.porigin = porigin;
tfs.porient = porient;

tfs         = TFs(tfs,p);   % import all sites
tfs.ylim    = [-15 250];
tfs.Tlim    = [0.005 10000];
tfs.Rlim    = [1 10000];
tfs.Mlim    = [.1 10];
tfs.Plim    = [0 90];
tfs.PTpsilim= [-20 20]; % color range for psi coloring of phase tensor
tfs.PTcond   = 50;
tfs.rotangle = 105; % electromagnetic strike
tfs.dotscale = 2;

%% phase pseudo
h1 = plot_section(tfs,'Phsxy');
set(gcf,'renderer','painter','Color','w');
xlabel('distance [km]','Fontsize',14)
ylabel('log_{10} periods [s]','Fontsize',14)
xlim([-15 215])
set(gca,'Fontsize',13,'XDir','reverse')
h2 = plot_section(tfs,'Phsyx');
set(gcf,'renderer','painter','Color','w');
xlabel('distance [km]','Fontsize',14)
ylabel('log_{10} periods [s]','Fontsize',14)
set(gca,'Fontsize',13,'XDir','reverse')
xlim([-15 215])

%% app. resistivity pseudo
h3 = plot_section(tfs,'Rhoxy');
set(gcf,'renderer','painter','Color','w');
xlabel('distance [km]','Fontsize',14)
ylabel('log_{10} periods [s]','Fontsize',14)
xlim([-15 215])
set(gca,'Fontsize',13,'XDir','reverse')
h4 = plot_section(tfs,'Rhoyx');
set(gcf,'renderer','painter','Color','w');
xlabel('distance [km]','Fontsize',14)
ylabel('log_{10} periods [s]','Fontsize',14)
set(gca,'Fontsize',13,'XDir','reverse')
xlim([-15 215])
disp('plotting done.')


%% export figures
export_fig(h1,'pseudo_phaseXY_Mestimate.png','-painters','-r300','-p0.01')
export_fig(h2,'pseudo_phaseYX_Mestimate.png','-painters','-r300','-p0.01')
export_fig(h3,'pseudo_rhoXY_Mestimate.png','-painters','-r300','-p0.01')
export_fig(h4,'pseudo_rhoYX_Mestimate.png','-painters','-r300','-p0.01')
