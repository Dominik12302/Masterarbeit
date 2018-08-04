%% EMAPP special, make timeseries nice (1080p required) SUPER AWESOME
emApp = findall(0,'Tag','EMApp');
set(emApp,'units','normalized');
emAppChilds = get(emApp,'children');
tabs = get(emAppChilds(1),'children');
tsTab = tabs(4);
tsTab.BackgroundColor = 'w';
tsTab.ForegroundColor = 'w';
tsAxes = findall(tsTab,'type','axes');
tsLine = findall(tsAxes,'type','line');
tsLine(1).LineWidth = 1;
tsLine(2).LineWidth = tsLine(1).LineWidth;
tsLine(3).LineWidth = tsLine(1).LineWidth;
tsLine(4).LineWidth = tsLine(1).LineWidth;
tsAxes(2).YLim = [-0.05 0.05];
% -c[<top>,<right>,<bottom>,<left>]
defaultSize = get(emApp,'outerposition');
set(emApp,'outerposition',[0 0 1 1]);
export_fig('ts_Kp6_2438B.png','-painters','-r200','-c[600,400,120,1900]');
set(emApp,'outerposition',defaultSize);
