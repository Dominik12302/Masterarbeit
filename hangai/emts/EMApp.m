function varargout = EMApp(varargin)
global fs13 fs14 fs16 commands
fs13 = 13; fs14 = 14; fs16 = 16; 
if ~ismac, fs13 = fs13/(96/72); fs14 = fs14/(96/72); fs16 = fs16/(96/72); end
commands = cell(0);
h.EMApp = figure('Position',[0 0 1300 700],'MenuBar','None','tag','EMApp','Toolbar','none');
% h.EMApp.ToolBar = 'none';
h.propath         = {pwd};
h.proname         = '';
h.project         = uimenu(h.EMApp,'Label','Project');
h.project_loadini = uimenu(h.project,'Label','Load init file (*.ini) ...',...
    'Callback',@(hObject,eventdata)load_ini_Callback(hObject,eventdata,guidata(h.EMApp)));
h.project_loadpro = uimenu(h.project,'Label','Load project file (*.mat)',...
    'Callback',@(hObject,eventdata)load_Callback(hObject,eventdata,guidata(h.EMApp)));
h.project_savepro = uimenu(h.project,'Label','Save project',...
    'Callback',@(hObject,eventdata)save_Callback(hObject,eventdata,guidata(h.EMApp)),'Separator','on','Accelerator','S');
h.project_saveproas = uimenu(h.project,'Label','Save project as ... (*.mat) ...',...
    'Callback',@(hObject,eventdata)saveas_Callback(hObject,eventdata,guidata(h.EMApp)),'Separator','on');
h.project_exit    = uimenu(h.project,'Label','Close',...
    'Callback',@(hObject,eventdata)close_Callback(hObject,eventdata,guidata(h.EMApp)),'Separator','on','Accelerator','Q');

h.tgroup = uitabgroup('Parent', h.EMApp,'TabLocation', 'top','Visible','off');
h.tab1 = uitab('Parent', h.tgroup, 'Title', 'Import');
h.tab2 = uitab('Parent', h.tgroup, 'Title', 'Site Info');
h.tab3 = uitab('Parent', h.tgroup, 'Title', 'Runtimes');
h.tab4 = uitab('Parent', h.tgroup, 'Title', 'Time series');
h.tab5 = uitab('Parent', h.tgroup, 'Title', 'Spectra');
h.tab6 = uitab('Parent', h.tgroup, 'Title', 'TFs');

h = import_ui(h);
h = siteinfo_ui(h);
h = runtimes_ui(h);
h = timeseries_ui(h);
h = tfs_ui(h);
guidata(h.EMApp,h); % store all handles in h.EMApp

varargout{1} = h;

% load ini file if existing
if nargin
    inifile = varargin{1};
else
    inifile = ['.',filesep,'default.ini'];
end

[PathName,f,e]= fileparts(inifile);
FileName = [f,e];
if exist(inifile,'file')
    if ischar(PathName)
        if isdir(PathName)
            fid = fopen(fullfile(PathName,FileName));
            disp(' ')
            disp(['Reading ',inifile]);
            disp(' ')
            propath = fgetl(fid);
            if isdir(propath)
                h.propath = {propath};
                [p,proname,e] = fileparts(propath);
                h.proname = proname;
                reftime = fscanf(fid,'%d %d %d %d %d %d',[1 6]);
                if ~feof(fid)
                    calpath = fscanf(fid,'%s');
                else
                    calpath = './s';
                end
                h.calpath = {calpath};
                fclose(fid);
                h.reftime = reftime;
                h.tf_TimeIntervals = [];
                set(h.EMApp,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(reftime)]);
                %enable_menu(h,{'save','saveas','edit','display','import'});
                h.emts =  EMTimeSeries(reftime,{propath});
                h.emts.calpath = {calpath};
                h.proc =  EMProc({propath});
                h.proc.bandsetup  = 'MT';
                h.tgroup.Visible = 'on';
                h.tgroup.SelectedTab = h.tab1;
                a=dir(h.emts.propath{1});
                list = {a([a.isdir]).name};
                set(h.import_listbox,'String',list);
                %make_invisible(handles,{'panel_textinfo','panel_ts','panel_runtimes','panel_edit_convert'});
                %make_visible(handles,{'panel_import'});
                %disable_menu(handles,{'project','edit','display','import','load_ini','load'});
                guidata(h.EMApp,h); % store all handles in h.EMApp
            else
                disp(['Error: Project Path ',propath,' given in ' fullfile(PathName,FileName) ' is not a valid directory']);
            end
        end
    end
else
    disp(['Error: INI-file: ' fullfile(PathName,FileName) ' was not found.']);
    disp(['Consider to make copy of your favourite ini-file with name default.ini at the location of EMApp.m/exe']);
end

%guidata(h.EMApp,h);
end
%% UI CONTROLS
% tab1: IMPORT
function h = import_ui(h)
global fs13 fs14 fs16
% Listbox with site names
h.import_listbox = uicontrol(h.tab1,'Style','listbox',...
    'String',{'<none>'},'Value',1,'Units','normalized','Fontsize',fs14,'Min',0,'Max',2);
h.import_listbox.Position = [0.05 0.20 0.15 0.75];
h.import_listbox_title = uicontrol(h.tab1,'Style','Text',...
    'String',{'Multi-select sites to import:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.import_listbox_title.Position = [0.05 0.96 0.15 0.02];
h.import_listbox_title.HorizontalAlignment = 'left';

% Path filters
h.import_pfilters_title = uicontrol(h.tab1,'Style','Text', ...
    'String',{'Import time series or fourier coefficients. Data are assumed to be organized in  EM archive structure. Raw time series are either *.ats, *.raw/*.xtr or *.mtd data. Proc time series are converted and/or resampled raw time seriees and always in *.ats format . .'},...
    'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.import_pfilters_title.Position = [0.225 0.92 0.70 0.06];
h.import_pfilters_title.HorizontalAlignment = 'left';

% organise files
h.import_raw = uicontrol(h.tab1,'Style','Checkbox','String','Time series as measured (./RAW/...)','Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','bold','Enable','inactive','Tooltipstr','Files are moved from <site>/RAW/... to <site>/ts/ads/.... Also runs xtrx2xtr.exe if needed.');
h.import_raw.Position = [0.225 0.88 0.45 0.03];
h.import_raw_cleanfiles = uicontrol(h.tab1,'Style','Checkbox','String',{'Clean adc folder before organising files'},'Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','Tooltipstr','delete any existing /ts/adc/...');
h.import_raw_cleanfiles.Position = [0.43 0.836 0.3 0.05];
h.import_raw_linkfiles = uicontrol(h.tab1,'Style','Checkbox','String',{'Link files (instead of copy)'},'Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','Tooltipstr','only on unix/linux/mac systems');
h.import_raw_linkfiles.Position = [0.43 0.803  0.3 0.05];
if ispc; set(h.import_raw_linkfiles,'enable','off','value',0); end
h.import_raw_lsrate = uicontrol(h.tab1,'Style','Edit','String','0','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Only select this sampling rate (0 means automatic selection)');
h.import_raw_lsrate.Position = [0.325 0.845 0.05 0.03];
h.import_raw_lsrate_text1 = uicontrol(h.tab1,'Style','Text','String','Select:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Only select this sampling rate (0 means automatic selection)');
h.import_raw_lsrate_text1.Position = [0.242 0.845 0.07 0.03];
h.import_raw_lsrate_text2 = uicontrol(h.tab1,'Style','Text','String','Hz','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Only select this sampling rate (0 means automatic selection)');
h.import_raw_lsrate_text2.Position = [0.378 0.845 0.02 0.03];
h.import_raw_organise = uicontrol(h.tab1,'Style','Pushbutton','String',{'Organise files (in adc folder)'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[1 1 0.7],'Fontweight','bold','Callback',@(hObject,eventdata)raw_organise_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_raw_organise.Position = [0.662 0.82 0.2 0.05];

%adc filters
h.import_ts_adc = uicontrol(h.tab1,'Style','Checkbox','String','Raw time series(./ts/adc/...)','Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','bold','Enable','inactive');
h.import_ts_adc.Position = [0.225 0.79 0.45 0.03];
h.import_ts_adc_filt_text1 = uicontrol(h.tab1,'Style','Text','String','Input Paths:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_ts_adc_filt_text1.Position = [0.242 0.75 0.1 0.03];
h.import_ts_adc_filt_text2 = uicontrol(h.tab1,'Style','Text','String','Output Paths:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_ts_adc_filt_text2.Position = [0.242 0.71 0.1 0.03];
h.import_adc_filter = uicontrol(h.tab1,'Style','Edit','String','./adc/EDE/meas* ./adc/spam4/run* ./adc/ADU/meas* ./adc/EDL/run*','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_adc_filter.Position = [0.325 0.75 0.4 0.03];
h.export_proc_filter = uicontrol(h.tab1,'Style','Edit','String',{'./proc'},'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.export_proc_filter.Position = [0.325 0.71 0.1 0.03];
% channel order
h.import_chorder = uicontrol(h.tab1,'Style','Edit','String','','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','renumber channel order; must match # of channels. Ex. change ch1 and ch2: 2 1 3 4 5');
h.import_chorder.Position = [0.325 0.67 0.1 0.03];
h.import_chorder_text1 = uicontrol(h.tab1,'Style','Text','String','Channel order:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','renumber channel order; must match # of channels. Ex. change ch1 and ch2: 2 1 3 4 5');
h.import_chorder_text1.Position = [0.242 0.67 0.08 0.03];
% premultiply
h.import_premult = uicontrol(h.tab1,'Style','Edit','String','','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','channels will be multiplied with factors; match # of channels. Ex. Flip polarity of ch2: 1 -1 1 1 1');
h.import_premult.Position = [0.51 0.67 0.1 0.03];
h.import_premult_text1 = uicontrol(h.tab1,'Style','Text','String','Pre-multipy:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','channels will be multiplied with factors; match # of channels. Ex. Flip polarity of ch2: 1 -1 1 1 1');
h.import_premult_text1.Position = [0.442 0.67 0.06 0.03];
% resample lsrate to resmpfrq
h.import_lsrate = uicontrol(h.tab1,'Style','Edit','String','0','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Use recordings at this sampling rate');
h.import_lsrate.Position = [0.325 0.63 0.05 0.03];
h.import_lsrate_text1 = uicontrol(h.tab1,'Style','Text','String','Resample:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Use recordings at this sampling rate');
h.import_lsrate_text1.Position = [0.242 0.63 0.07 0.03];
h.import_lsrate_text2 = uicontrol(h.tab1,'Style','Text','String','Hz runs','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Use recordings at this sampling rate');
h.import_lsrate_text2.Position = [0.378 0.63 0.08 0.03];
% resamplefreq
h.import_resmpfrq = uicontrol(h.tab1,'Style','Edit','String','0','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','resample to this sampling rate; 0 means no resampling');
h.import_resmpfrq.Position = [0.51 0.63 0.05 0.03];
h.import_resmpfrq_text1 = uicontrol(h.tab1,'Style','Text','String','to:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','resample to this sampling rate; 0 means no resampling');
h.import_resmpfrq_text1.Position = [0.489 0.63 0.02 0.03];
h.import_resmpfrq_text2 = uicontrol(h.tab1,'Style','Text','String','Hz','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','resample to this sampling rate; 0 means no resampling');
h.import_resmpfrq_text2.Position = [0.553 0.63 0.08 0.03];
% Import adc buttons
h.import_import = uicontrol(h.tab1,'Style','Pushbutton','String',{'Import'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[0.7 1 0.7],'Fontweight','bold','Callback',@(hObject,eventdata)import_import_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_import.Position = [0.242 0.49 0.2 0.05];
h.import_import_convert = uicontrol(h.tab1,'Style','Pushbutton','String',{'Import & Resample'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[1 0.7 0.7],'Fontweight','bold','Callback',@(hObject,eventdata)import_import_convert_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_import_convert.Position = [0.452 0.49 0.2 0.05];
h.import_import_convert_fc = uicontrol(h.tab1,'Style','Pushbutton','String',{'Import & Resample & FFT'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[0.7 0.7 1],'Fontweight','bold','Callback',@(hObject,eventdata)import_import_convert_fc_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_import_convert_fc.Position = [0.662 0.52 0.2 0.05];
h.import_import_convert_fc_no_proc = uicontrol(h.tab1,'Style','Pushbutton','String',{'as above but skip writing Proc'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[0.7 0.7 1],'Fontweight','bold','Callback',@(hObject,eventdata)import_import_convert_fc_no_proc_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_import_convert_fc_no_proc.Position = [0.662 0.46 0.2 0.05];
h.import_import_cleanproc = uicontrol(h.tab1,'Style','Checkbox','String',{'Clean proc and fc directories before resampling/fft'},'Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal',...
    'Tooltipstr','Tic to delete all files in <site>/proc/... and <site>/fc/...');
h.import_import_cleanproc.Position = [0.242 0.57 0.3 0.05];
h.import_import_breakfiles = uicontrol(h.tab1,'Style','Checkbox','String',{'Break files every two days before resampling'},'Value',0,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','enable','inactive',...
    'Tooltipstr','Tic to split files every second midnight.');
h.import_import_breakfiles.Position = [0.55 0.57 0.3 0.05];


% proc filters
h.import_ts_proc = uicontrol(h.tab1,'Style','Checkbox','String','Proc time series(./ts/proc/...)','Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','bold','Enable','inactive');
h.import_ts_proc.Position = [0.225 0.43 0.46 0.03];
h.import_ts_proc_filt_text1 = uicontrol(h.tab1,'Style','Text','String','Input Paths:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_ts_proc_filt_text1.Position = [0.242 0.38 0.1 0.03];
h.import_proc_filter = uicontrol(h.tab1,'Style','Edit','String','./proc/EDE/meas* ./proc/spam4/run* ./proc/ADU/meas* ./proc/EDL/run*','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_proc_filter.Position = [0.325 0.38 0.43 0.03];
h.import_proc_lsrate = uicontrol(h.tab1,'Style','Edit','String','0','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Use recordings at this sampling rate');
h.import_proc_lsrate.Position = [0.325 0.34 0.05 0.03];
h.import_proc_lsrate_text1 = uicontrol(h.tab1,'Style','Text','String','Spl. rate:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Use recordings at this sampling rate');
h.import_proc_lsrate_text1.Position = [0.242 0.34 0.07 0.03];
h.import_proc_lsrate_text2 = uicontrol(h.tab1,'Style','Text','String','Hz (fft runs at this rate)','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left',...
    'Tooltipstr','Use recordings at this sampling rate');
h.import_proc_lsrate_text2.Position = [0.378 0.34 0.15 0.03];
h.import_import_cleanfc = uicontrol(h.tab1,'Style','Checkbox','String',{'Clean fc directory before fft'},'Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal',...
    'Tooltipstr','Tic to delete all files in <site>/fc/...');
h.import_import_cleanfc.Position = [0.242 0.29 0.2 0.05];
% Import proc button
h.import_importproc = uicontrol(h.tab1,'Style','Pushbutton','String',{'Import'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[1 .7 0.7],'Fontweight','bold','Callback',@(hObject,eventdata)import_import_proc_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_importproc.Position = [0.242 0.23 0.2 0.05];
h.import_importproc = uicontrol(h.tab1,'Style','Pushbutton','String',{'Import & FFT'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[0.7 0.7 1],'Fontweight','bold','Callback',@(hObject,eventdata)import_import_proc_fc_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_importproc.Position = [0.452 0.23 0.2 0.05];


% fc filters
h.import_fc = uicontrol(h.tab1,'Style','Checkbox','String','Fourier coefficients(./fc/...)','Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','bold','Enable','inactive');
h.import_fc.Position = [0.225 0.15 0.45 0.03];
h.import_fc_filt_text1 = uicontrol(h.tab1,'Style','Text','String','Input Paths:','Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_fc_filt_text1.Position = [0.242 0.12 0.1 0.03];
h.import_fc_filter = uicontrol(h.tab1,'Style','Edit','String',{'./fc'},'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','HorizontalAlignment','left');
h.import_fc_filter.Position = [0.325 0.12 0.4 0.03];
% Import fc button
h.import_importfc = uicontrol(h.tab1,'Style','Pushbutton','String',{'Import'},'Value',1,'Units','normalized',...
    'Fontsize',fs16,'Backgroundcolor',[0.7 0.7 1],'Fontweight','bold','Callback',@(hObject,eventdata)import_importfc_Callback(hObject,eventdata,guidata(h.EMApp)));
h.import_importfc.Position = [0.242 0.05 0.2 0.05];

h.import_write_skript = uicontrol(h.tab1,'Style','Checkbox','String','Write skripts','Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','Enable','on','Tooltipstr','Create an m-file to reproduce any action that is more than just ''import''/ i.e. writes something to disk.');
h.import_write_skript.Position = [0.05 0.15 0.15 0.03];
h.import_keep_skript = uicontrol(h.tab1,'Style','Checkbox','String','Keep previous skripts','Value',0,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','Enable','on','Tooltipstr','When a skript becomes obselete, rename it and keep it.');
h.import_keep_skript.Position = [0.05 0.12 0.15 0.03];
h.import_show_skript = uicontrol(h.tab1,'Style','Checkbox','String','Show generated skripts','Value',0,'Units','normalized',...
    'Fontsize',fs14,'Fontweight','normal','Enable','on','Tooltipstr','Shows generated skript in the command window.');
h.import_show_skript.Position = [0.05 0.09 0.15 0.03];

end
% tab2: SITEINFO
function h = siteinfo_ui(h)
global fs13 fs14 fs16
% Listbox with site names
h.text_sitelist = uicontrol(h.tab2,'Style','listbox',...
    'String',{'<none>'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Callback',@(hObject,eventdata)text_sitelist_Callback(hObject,eventdata,guidata(h.EMApp)));
h.text_sitelist.Position = [0.05 0.05 0.15 0.85];
h.text_sitelist_title = uicontrol(h.tab2,'Style','Text',...
    'String',{'Select Site:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.text_sitelist_title.Position = [0.05 0.91 0.15 0.02];
h.text_sitelist_title.HorizontalAlignment = 'left';
% text with info
h.textinfo = uicontrol(h.tab2,'Style','listbox',...
    'String',{'<none>'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1);
h.textinfo.Position = [0.225 0.05 0.65 0.85];
h.textinfo_title = uicontrol(h.tab2,'Style','Text',...
    'String',{'Survey information:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.textinfo_title.Position = [0.225 0.91 0.15 0.02];
h.textinfo_title.HorizontalAlignment = 'left';

end
% tab3: RUNTIMES
function h = runtimes_ui(h)
global fs13 fs14 fs16
% Listbox with sampling rates
h.srates_for_runtimes = uicontrol(h.tab3,'Style','listbox',...
    'String','0','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',2,...
    'Callback',@(hObject,eventdata)srates_for_runtimes_Callback(hObject,eventdata,guidata(h.EMApp)));
h.srates_for_runtimes.Position = [0.05 0.7 0.1 0.2];
h.srates_for_runtimes_title = uicontrol(h.tab3,'Style','Text',...
    'String',{'Sampling rate:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.srates_for_runtimes_title.Position = [0.05 0.91 0.1 0.03];
h.srates_for_runtimes_title.HorizontalAlignment = 'left';

% Listbox with systems
h.runtimes_systems = uicontrol(h.tab3,'Style','listbox',...
    'String',{'ADU' 'EDE' 'SPAM' 'EDL' 'MTU' 'OTHER'},'Value',2,'Min',0,'Max',4,'Units','normalized',...
    'Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,'Enable','off',...
    'Callback',@(hObject,eventdata)systems_for_runtimes_Callback(hObject,eventdata,guidata(h.EMApp)));
h.runtimes_systems.Position = [0.05 0.4 0.1 0.2];
h.runtimes_systems_title = uicontrol(h.tab3,'Style','Text',...
    'String',{'System:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.runtimes_systems_title.Position = [0.05 0.61 0.1 0.03];
h.runtimes_systems_title.HorizontalAlignment = 'left';

% popupmenu Nsites
h.runtimes_Nsites = uicontrol(h.tab3,'Style','popupmenu',...
    'String',{'10' '15' '20'  '25'  '30'  '35'  '40'  '45'  '50'  '55'  '60'},'Value',2,'Units','normalized',...
    'Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,'Enable','on',...
    'Callback',@(hObject,eventdata)runtimes_Nsites_Callback(hObject,eventdata,guidata(h.EMApp)));
h.runtimes_Nsites.Position = [0.05 0.15 0.1 0.03];
h.runtimes_Nsites_title = uicontrol(h.tab3,'Style','Text',...
    'String',{'# of sites:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.runtimes_Nsites_title.Position = [0.05 0.18 0.1 0.03];
h.runtimes_Nsites_title.HorizontalAlignment = 'left';

% popupmenu time axes
h.runtimes_tax = uicontrol(h.tab3,'Style','popupmenu',...
    'String',{'utc' 'relative d' 'relative h'  'relative s'},'Value',1,'Units','normalized',...
    'Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,'Enable','on',...
    'Callback',@(hObject,eventdata)runtimes_tax_Callback(hObject,eventdata,guidata(h.EMApp)));
h.runtimes_tax.Position = [0.05 0.07 0.1 0.03];
h.runtimes_tax_title = uicontrol(h.tab3,'Style','Text',...
    'String',{'Axis format:'},'Value',1,'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.runtimes_tax_title.Position = [0.05 0.1 0.1 0.03];
h.runtimes_tax_title.HorizontalAlignment = 'left';

% axes
h.ax_runtimes = axes('parent',h.tab3,'Fontsize',fs14,'Fontname','Helvetica');
h.ax_runtimes.Position = [0.2 0.2 0.75 0.7];
end
% tab4: TIMESERIES
function h = timeseries_ui(h)
global fs13 fs14 fs16
% Listbox with site names rates
h.ts_lsname = uicontrol(h.tab4,'Style','Popupmenu',...
    'String','<none>','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Callback',@(hObject,eventdata)ts_lsname_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_lsname.Position = [0.03 0.88 0.1 0.03];
h.ts_lsname_title = uicontrol(h.tab4,'Style','Text',...
    'String',{'Local site:'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_lsname_title.Position = [0.033 0.912 0.1 0.03];
h.ts_lsname_title.HorizontalAlignment = 'left';
% Listbox with local sampling rates
h.ts_lsrate = uicontrol(h.tab4,'Style','Popupmenu',...
    'String','0','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Callback',@(hObject,eventdata)ts_lsrate_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_lsrate.Position = [0.05 0.83 0.08 0.03];
h.ts_lsrate_title1 = uicontrol(h.tab4,'Style','Text',...
    'String',{'@'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_lsrate_title1.Position = [0.035 0.83 0.01 0.03];
h.ts_lsrate_title1.HorizontalAlignment = 'left';
h.ts_lsrate_title2 = uicontrol(h.tab4,'Style','Text',...
    'String',{'Hz'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_lsrate_title2.Position = [0.13 0.83 0.02 0.03];
h.ts_lsrate_title2.HorizontalAlignment = 'left';
% Text edit with channel selections
h.ts_usech = uicontrol(h.tab4,'Style','edit',...
    'String','Ex Ey Bx By Bz','Units','normalized','Fontsize',fs14,'Fontname','Courier',...
    'Callback',@(hObject,eventdata)ts_usech_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_usech.Position = [0.03 0.775 0.1 0.035];

% Text edit with timing information
h.usetime_from = uicontrol(h.tab4,'Style','edit',...
    'String','yy mm dd hh mm ss','Units','normalized','Fontsize',fs14,'Fontname','Courier');%,...
    %'Callback',@(hObject,eventdata)tf_time_Callback(hObject,eventdata,guidata(h.EMApp)));
h.usetime_from.Position = [0.25 0.95 0.15 0.035];
h.usetime_from_title = uicontrol(h.tab4,'Style','Text',...
    'String',{'From'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.usetime_from_title.Position = [0.2 0.95 0.05 0.03];
h.usetime_from_title.HorizontalAlignment = 'center';
h.usetime_to = uicontrol(h.tab4,'Style','edit',...
    'String','yy mm dd hh mm ss','Units','normalized','Fontsize',fs14,'Fontname','Courier');%,...
    %'Callback',@(hObject,eventdata)tf_time_Callback(hObject,eventdata,guidata(h.EMApp)));
h.usetime_to.Position = [0.42 0.95 0.15 0.035];
h.usetime_to_title = uicontrol(h.tab4,'Style','Text',...
    'String',{'to'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.usetime_to_title.Position = [0.4 0.95 0.02 0.03];
h.usetime_to_title.HorizontalAlignment = 'center';
% plot button
% Text edit with timing information
h.ts_refresh = uicontrol(h.tab4,'Style','pushbutton',...
    'String','Plot','Units','normalized','Fontsize',fs16,'Fontname','Helvetica','Fontweight','bold',...
    'BackgroundColor',[.7 1 0.7],...
    'Callback',@(hObject,eventdata)ts_refresh_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_refresh.Position = [0.65 0.95 0.1 0.04];
h.ts_refresh_title = uicontrol(h.tab4,'Style','Text',...
    'String',{'>>>'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_refresh_title.Position = [0.57 0.95 0.03 0.03];
h.ts_refresh_title.HorizontalAlignment = 'center';
% axes for time series
h.axes_ch1 = axes('parent',h.tab4,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_ch1.Position = [0.2 0.75 0.75 0.15];
h.axes_ch2 = axes('parent',h.tab4,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_ch2.Position = [0.2 0.58 0.75 0.15];
h.axes_ch3 = axes('parent',h.tab4,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_ch3.Position = [0.2 0.41 0.75 0.15];
h.axes_ch4 = axes('parent',h.tab4,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_ch4.Position = [0.2 0.24 0.75 0.15];
h.axes_ch5 = axes('parent',h.tab4,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_ch5.Position = [0.2 0.07 0.75 0.15];
h.ts_leg = axes('parent',h.tab4,'Fontsize',fs14,'Fontname','Helvetica','tag','ts_leg');
h.ts_leg.Position = [0.2 0.025 0.75 0.037];
% Resampling freq
h.ts_resmp = uicontrol(h.tab4,'Style','Radiobutton',...
    'String','Resample to:','Units','normalized','Fontsize',fs14,'Fontname','Helvetica','Fontweight','bold',...
    'Callback',@(hObject,eventdata)ts_resmp_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_resmp.Position = [0.03 0.7 0.1 0.035];
h.ts_resmpfreq = uicontrol(h.tab4,'Style','Edit',...
    'String','512','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Callback',@(hObject,eventdata)ts_resmpfreq_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_resmpfreq.Position = [0.05 0.66 0.075 0.03];
h.ts_resmpfreq_title1 = uicontrol(h.tab4,'Style','Text',...
    'String',{'@'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_resmpfreq_title1.Position = [0.035 0.66 0.01 0.03];
h.ts_resmpfreq_title1.HorizontalAlignment = 'left';
h.ts_resmpfreq_title2 = uicontrol(h.tab4,'Style','Text',...
    'String',{'Hz'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_resmpfreq_title2.Position = [0.13 0.66 0.02 0.03];
h.ts_resmpfreq_title2.HorizontalAlignment = 'left';

h.ts_tshift = uicontrol(h.tab4,'Style','Edit',...
    'String','0','Units','normalized','Fontsize',fs14,'Fontname','Courier',...
    'Callback',@(hObject,eventdata)ts_refresh_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_tshift.Position = [0.05 0.56 0.075 0.03];
h.ts_tshift_title1 = uicontrol(h.tab4,'Style','Radiobutton','Value',0,'Fontweight','bold',...
    'String','Time shift (s)','Units','normalized','Fontsize',fs14);
h.ts_tshift_title1.Position = [0.03 0.6 0.1 0.03];
h.ts_tshift_title2 = uicontrol(h.tab4,'Style','Text',...
    'String',{'s'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_tshift_title2.Position = [0.13 0.56 0.02 0.03];
h.ts_tshift_title2.HorizontalAlignment = 'left';

% base sites
h.ts_basesites = uicontrol(h.tab4,'Style','Checkbox',...
    'String','Base sites:','Units','normalized','Fontsize',fs14,'Fontname','Helvetica','Fontweight','bold',...
    'Callback',@(hObject,eventdata)ts_basesites_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_basesites.Position = [0.03 0.5 0.1 0.035];
h.ts_bsnames = uicontrol(h.tab4,'Style','Listbox',...
    'String','<none>','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',2,...
    'Callback',@(hObject,eventdata)ts_bsnames_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_bsnames.Position = [0.03 0.2 0.1 0.29];
h.ts_bsrates = uicontrol(h.tab4,'Style','Edit',...
    'String','512 500 50 2','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Callback',@(hObject,eventdata)ts_bsrates_Callback(hObject,eventdata,guidata(h.EMApp)));
h.ts_bsrates.Position = [0.05 0.15 0.075 0.03];
h.ts_bsrates_title1 = uicontrol(h.tab4,'Style','Text',...
    'String',{'@'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_bsrates_title1.Position = [0.035 0.15 0.01 0.03];
h.ts_bsrates_title1.HorizontalAlignment = 'left';
h.ts_bsrates_title2= uicontrol(h.tab4,'Style','Text',...
    'String',{'Hz'},'Units','normalized','Fontsize',fs14,'Fontweight','bold');
h.ts_bsrates_title2.Position = [0.13 0.15 0.02 0.03];
h.ts_bsrates_title2.HorizontalAlignment = 'left';


end
% tab6: TFs
function h = tfs_ui(h)
global fs13 fs14 fs16
%local site
% Listbox with site names rates
h.tf_lsname = uicontrol(h.tab6,'Style','Popupmenu',...
    'String','<none>','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Tooltipstr','Local Site (left hand side of tf equation)');
h.tf_lsname.Position = [0.033 0.88 0.12 0.03];
h.tf_lsname_title = uicontrol(h.tab6,'Style','Checkbox',...
    'String',{'Local site:'},'Units','normalized','Fontsize',fs14,'Fontweight','bold','Value',1,...
    'enable','inactive',...
    'Tooltipstr','Local Site (left hand side of tf equation)');
h.tf_lsname_title.Position = [0.020 0.92 0.1 0.03];
h.tf_lsname_title.HorizontalAlignment = 'left';
% Text edit with channel selections
h.tf_output = uicontrol(h.tab6,'Style','edit',...
    'String','Ex Ey Bz','Units','normalized','Fontsize',fs14,'Fontname','Courier',...
    'Tooltipstr','output channels (left hand side of tf equation)');
h.tf_output.Position = [0.036 0.83 0.1 0.035];
% base site
% Listbox with site names rates
h.tf_bsname = uicontrol(h.tab6,'Style','Popupmenu',...
    'String','<none>','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1,...
    'Tooltipstr','output channels (left hand side of tf equation)');
h.tf_bsname.Position = [0.033 0.73 0.12 0.03];
h.tf_bsname_title = uicontrol(h.tab6,'Style','Checkbox',...
    'String',{'Base site:'},'Units','normalized','Fontsize',fs14,'Fontweight','bold','Value',1,'enable','on',...
    'Tooltipstr','tic for intersation tf estimate using this base site (right hand side of tf equation)');
h.tf_bsname_title.Position = [0.020 0.77 0.1 0.03];
h.tf_bsname_title.HorizontalAlignment = 'left';
% Text edit with channel selections
h.tf_input = uicontrol(h.tab6,'Style','edit',...
    'String','Bx By','Units','normalized','Fontsize',fs14,'Fontname','Courier',...
    'Tooltipstr','input channels (right hand side of tf equation, either from the base site, if ticked, or from the local site)');
h.tf_input.Position = [0.036 0.68 0.1 0.035];

% ref site
% Listbox with site names rates
h.tf_rsname = uicontrol(h.tab6,'Style','Popupmenu',...
    'String','<none>','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1);
h.tf_rsname.Position = [0.033 0.58 0.12 0.03];
h.tf_rsname_title = uicontrol(h.tab6,'Style','Checkbox',...
    'String',{'Reference:'},'Units','normalized','Fontsize',fs14,'Fontweight','bold','Value',0,'enable','on');
h.tf_rsname_title.Position = [0.020 0.62 0.1 0.03];
h.tf_rsname_title.HorizontalAlignment = 'left';
% Text edit with channel selections
h.tf_refch = uicontrol(h.tab6,'Style','edit',...
    'String','Bx By','Units','normalized','Fontsize',fs14,'Fontname','Courier');
h.tf_refch.Position = [0.036 0.53 0.1 0.035];
% Settings
h.tf_settings = uicontrol(h.tab6,'Style','Text',...
    'String','+  Settings:','Units','normalized','Fontsize',fs14,'Fontname','Helvetica','Fontweight','bold');
h.tf_settings.Position = [0.02 0.46 0.1 0.035];
h.tf_settings.HorizontalAlignment = 'left';
% sampling rate
h.tf_srate = uicontrol(h.tab6,'Style','Popupmenu',...
    'String','32','Value',1,'Units','normalized','Fontsize',fs14,'Fontname','Courier','Min',0,'Max',1);
h.tf_srate.Position = [0.033 0.39 0.12 0.03];
h.tf_srate_title = uicontrol(h.tab6,'Style','Text',...
    'String',{'Sampling rate:'},'Units','normalized','Fontsize',fs14,'Fontweight','normal','Value',0,'enable','on');
h.tf_srate_title.Position = [0.034 0.42 0.1 0.03];
h.tf_srate_title.HorizontalAlignment = 'left';
% Text edit with mindec maxdec selections
h.tf_mindec = uicontrol(h.tab6,'Style','Edit',...
    'String','1','Units','normalized','Fontsize',fs14,'Fontname','Courier');
h.tf_mindec.Position = [0.033 0.30 0.04 0.035];
h.tf_maxdec = uicontrol(h.tab6,'Style','Edit',...
    'String','10','Units','normalized','Fontsize',fs14,'Fontname','Courier');
h.tf_maxdec.Position = [0.081 0.30 0.04 0.035];
h.tf_mindec_text = uicontrol(h.tab6,'Style','Text',...
    'String','Mindec  /  Maxdec','Units','normalized','Fontsize',fs14,'Fontname','Helvetica');
h.tf_mindec_text.Position = [0.032 0.34 0.1 0.035];
h.tf_mindec_text.HorizontalAlignment = 'left';
% Cojerency threshold
h.tf_coh = uicontrol(h.tab6,'Style','Edit',...
    'String','0 1','Units','normalized','Fontsize',fs14,'Fontname','Courier');
h.tf_coh.Position = [0.033 0.21 0.088 0.035];
h.tf_coh_text = uicontrol(h.tab6,'Style','Text',...
    'String','Coherency thres.','Units','normalized','Fontsize',fs14,'Fontname','Helvetica');
h.tf_coh_text.Position = [0.032 0.25 0.1 0.035];
h.tf_coh_text.HorizontalAlignment = 'left';

% TF estimate
h.tf_estimate = uicontrol(h.tab6,'Style','pushbutton',...
    'String','Estimate','Units','normalized','Fontsize',fs16,'Fontname','Helvetica','Fontweight','bold','BackgroundColor',[0.7 1 0.7],...
    'Callback',@(hObject,eventdata)tf_estimate_Callback(hObject,eventdata,guidata(h.EMApp)));
h.tf_estimate.Position = [0.02 0.05 0.13 0.07];

% TF use usetime;
h.tf_use_usetime = uicontrol(h.tab6,'Style','Checkbox','Value',0,...
    'String','Process time interval(s):','Units','normalized','Fontsize',fs14,'Fontname','Helvetica',...
    'Callback',@(hObject,eventdata)tf_time_Callback(hObject,eventdata,guidata(h.EMApp)));
h.tf_use_usetime.Position = [0.020 0.15 0.18 0.03];
h.tf_use_usetime.HorizontalAlignment = 'left';

h.tf_usetime_intervals_pushbutton = uicontrol(h.tab6,'Style','Pushbutton','String','',...
    'Units','normalized','Fontsize',fs14,...
    'Callback',@(hObject,eventdata)tf_time_interval_Callback(hObject,eventdata,guidata(h.EMApp)),'enable','off');
h.tf_usetime_intervals_pushbutton.Position = [0.25 0.14 0.7 0.05];

% axes for tfs
h.axes_tf1 = axes('parent',h.tab6,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_tf1.Position = [0.2 0.75 0.75 0.15];
h.axes_tf2 = axes('parent',h.tab6,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_tf2.Position = [0.2 0.58 0.75 0.15];
h.axes_tf3 = axes('parent',h.tab6,'Fontsize',fs14,'Fontname','Helvetica');
h.axes_tf3.Position = [0.2 0.41 0.75 0.15];

end
%% Callbacks
% Project Menu callbacks
function load_ini_Callback(hObject, eventdata, handles)
[FileName,PathName,FilterIndex] = uigetfile('*.ini','Load ini file',handles.propath{1});
if ischar(PathName)
    if isdir(PathName)
        fid = fopen(fullfile(PathName,FileName));
        propath = fgetl(fid);
        if isdir(propath)
            handles.propath = {propath};
            [p,proname,e] = fileparts(propath);
            handles.proname = proname;
            reftime = fscanf(fid,'%d %d %d %d %d %d',[1 6]);
            if ~feof(fid)
                calpath = fscanf(fid,'%s');
            else
                calpath = './s';
            end
            handles.calpath = {calpath};
            fclose(fid);
            handles.reftime = reftime;
            handles.tf_TimeIntervals = [];
            set(handles.EMApp,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(reftime)]);
            %enable_menu(handles,{'save','saveas','edit','display','import'});
            handles.emts =  EMTimeSeries(reftime,{propath});
            handles.emts.calpath = {calpath};
            handles.proc =  EMProc({propath});
            handles.proc.bandsetup  = 'MT';
            handles.tgroup.Visible = 'on';
            handles.tgroup.SelectedTab = handles.tab1;
            a=dir(handles.emts.propath{1});
            list = {a([a.isdir]).name};
            set(handles.import_listbox,'String',list);
            %make_invisible(handles,{'panel_textinfo','panel_ts','panel_runtimes','panel_edit_convert'});
            %make_visible(handles,{'panel_import'});
            %disable_menu(handles,{'project','edit','display','import','load_ini','load'});
            guidata(handles.EMApp,handles); % store all handles in h.EMApp
        else
            disp(['Error: Project Path ',propath,' given in ' fullfile(PathName,FileName) ' is not a valid directory']);
            fclose(fid);
        end
    end
end
end

function load_Callback(hObject, eventdata, handles)
[proname,propath,FilterIndex] = uigetfile('*.mat','Load EMTimeSeries project:');
if ischar(proname)
    load(fullfile(propath,proname));
    if isvarname('emts')
        if isa(emts,'EMTimeSeries')
            handles.propath = {fullfile(propath)};
            [p,proname,e]   = fileparts(proname);
            handles.proname = proname;
            handles.emts    = emts;
            % save(fullfile(handles.propath{1},handles.proname),'emts'); % JK: why???
            set(handles.EMApp,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(emts.reftime)]);
            %enable_menu(handles,{'save','saveas','edit','display','import'});
            update_ui(hObject,eventdata,handles);
            handles.tgroup.Visible = 'on';
            handles.tgroup.SelectedTab = handles.tab2;
            a=dir(handles.emts.propath{1});
            list = {a([a.isdir]).name};
            set(handles.import_listbox,'String',list);
            %make_invisible(handles,{'panel_import','panel_ts','panel_runtimes','panel_edit_convert'});
            %enable_menu(handles,{'project','edit','display','import'});
            %disp_text_Callback(hObject, eventdata, handles);
            guidata(handles.EMApp,handles); % store all handles in h.EMApp
        end
    end
    if isvarname('proc')
        if isa(emts,'EMProc')
            handles.proc    = proc;
            update_ui(hObject,eventdata,handles);
            guidata(handles.EMApp,handles); % store all handles in h.EMApp
        end
    end
    disp('Done!')
end
end

function save_Callback(hObject, eventdata, handles)
emts = handles.emts;
proc = handles.proc;
save(fullfile(handles.propath,handles.proname),'emts','proc');
disp('Done!')
end

function saveas_Callback(hObject, eventdata, handles)
pw = pwd;
cd(handles.propath);
[proname,propath,FilterIndex] = uiputfile('*.mat','Save Project as: ',[handles.proname '.mat']);
if ischar(proname)
    handles.propath = fullfile(propath);
    [p,proname,e] = fileparts(proname);
    handles.proname = proname;
    emts = handles.emts;
    save(fullfile(handles.propath,handles.proname),'emts');
    set(handles.EMApp,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(emts.reftime)]);
    guidata(handles.EMApp,handles); % store all handles in h.EMApp
end
cd(pw);
end

function close_Callback(hObject, eventdata, handles)
close(gcf);
end

function raw_organise_Callback(hObject, eventdata, handles)
global commands
commands = cell(0);
organise_files(handles);
% write skript
title_str = '% Skript to organize files from ./RAW/ folder to ./ts/adc/ folder';
write_skript(handles, commands, 'make_adc', title_str);
commands = cell(0);
disp('Done!');
end

% Import data callbacks
function import_import_Callback(hObject, eventdata, handles)
handles = import(handles,'adc');
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
disp('Done!')
end

function import_import_convert_Callback(hObject, eventdata, handles)
global commands
commands = cell(0);
handles = import(handles,'adc','resample',true);
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
% write skript
title_str = '% Skript to convert sites from ./ts/adc/ to ./ts/proc/';
write_skript(handles,commands,'adc_make_proc', title_str);
commands = cell(0);
disp('Done!')
end

function import_import_convert_fc_Callback(hObject, eventdata, handles)
global commands
commands = cell(0);
handles = import(handles,'adc','resample',true,'fc',true);
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
% write skript
title_str = '% Skript to convert sites from ./ts/adc/ to ./ts/proc/ and to write ./fc';
write_skript(handles, commands, 'adc_make_proc_fc', title_str);
commands = cell(0);
disp('Done!')
end

function import_import_convert_fc_no_proc_Callback(hObject, eventdata, handles)
global commands
commands = cell(0);
handles = import(handles,'adc','resample',true,'fc',true,'write_proc',false);
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
% write skript
title_str = '% Skript to import sites from ./ts/adc/ and to write ./fc';
write_skript(handles, commands,'adc_make_fc', title_str);
commands = cell(0);
disp('Done!')
end

function import_import_proc_Callback(hObject, eventdata, handles)
handles = import(handles,'proc');
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
disp('Done!')
end

function import_import_proc_fc_Callback(hObject, eventdata, handles)
global commands
commands = cell(0);
handles = import(handles,'proc','fc',true);
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
% write skript
title_str = '% Skript to import sites from ./ts/proc/ and to write ./fc';
write_skript(handles, commands, 'proc_make_fc', title_str);
commands = cell(0);
disp('Done!')
end

function import_importfc_Callback(hObject, eventdata, handles)
str = get(handles.import_listbox,'String');
val = get(handles.import_listbox,'Value');
selection = str(val);
handles.emts = handles.emts.remove_site(selection);
handles.proc = handles.proc.remove_site(selection);
handles.proc            = EMProc(handles.proc,selection);
handles.tgroup.SelectedTab = handles.tab6;
update_ui(hObject,eventdata,handles);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
disp('Done!')
end

%callbacks Display site info text
function text_sitelist_Callback(hObject, eventdata, handles)
str = get(handles.text_sitelist,'String');
val = get(handles.text_sitelist,'Value');
handles.emts.lsname = str(val);
%handles.emts.lsrate = 512;
str = display(handles.emts);
set(handles.text_sitelist,'String',handles.emts.sites);
set(handles.textinfo,'String',str);
guidata(handles.EMApp,handles); % store all handles in h.EMApp
end

% Runtimes callbacks
function srates_for_runtimes_Callback(hObject, eventdata, handles)
update_runtimes(handles);
end
function systems_for_runtimes_Callback(hObject, eventdata, handles)
update_runtimes(handles);
end
function runtimes_tax_Callback(hObject, eventdata, handles)
update_runtimes(handles);
end
function runtimes_Nsites_Callback(hObject, eventdata, handles)
update_runtimes(handles);
end

% Timeseries Callbacks
function tf_time_Callback(hObject, eventdata, handles)
if get(handles.tf_use_usetime,'Value')==1;
    set(handles.tf_usetime_intervals_pushbutton,'enable','on');
else
    set(handles.tf_usetime_intervals_pushbutton,'enable','off');
end
update_ui(hObject,eventdata,handles);
end

function tf_time_interval_Callback(hObject,eventdata,handles)
runtime_cell = handles.proc.runtimes(:);
name_cell = handles.proc.snames;
[bg_name,b,c] = unique(name_cell);
bg = cell(1,numel(bg_name));
for ind = 1 : numel(bg_name);
    tmp_cell = runtime_cell(c==ind);
    for ind2 = 1 : numel(tmp_cell)
        bg{ind}(ind2) = TimeInterval(tmp_cell{ind2});
    end
end
handles.tf_TimeIntervals = TimeIntervalGui(handles.tf_TimeIntervals,bg,bg_name,'multi_segment',false);
ti_char = ['<html>'];
for ind = 1 : numel(handles.tf_TimeIntervals);
    ti_char = [ti_char,handles.tf_TimeIntervals(ind).char];
    if ind < numel(handles.tf_TimeIntervals)
        ti_char = [ti_char,'<br>'];
    end
end
ti_char = [ti_char,'</html>'];
set(handles.tf_usetime_intervals_pushbutton,'String',ti_char);
guidata(hObject,handles);
end

function ts_nextwindow_Callback(hObject, eventdata, handles)
end

function ts_prevwindow_Callback(hObject, eventdata, handles)
end

function ts_refresh_Callback(hObject, eventdata, handles)
lsnames = get(handles.ts_lsname,'String');
val     = get(handles.ts_lsname,'Value');
handles.emts.lsname = lsnames(val);
lsrates = sort(unique(handles.emts.lsrates),'descend');
lsrate  = str2num(get(handles.ts_lsrate,'String'));
lsrate = lsrate(get(handles.ts_lsrate,'Value'));
usech = textscan(get(handles.ts_usech,'String'),'%s');
handles.emts.lsrate = lsrate;
handles.emts.usech  = usech{1}';
if get(handles.ts_resmp,'Value')
    set(handles.ts_resmpfreq,'Enable','on');
    handles.emts.resmpfreq = str2num(get(handles.ts_resmpfreq,'String'));
else
    set(handles.ts_resmpfreq,'Enable','on');
    handles.emts.resmpfreq = 0;
end
starttime = str2num(get(handles.usetime_from,'String'));
stoptime  = str2num(get(handles.usetime_to,'String'));
if numel(starttime) == 6 && numel(stoptime) == 6
    handles.emts.usetime  = [starttime stoptime] ;
end
% JK not sure why Micha commented this:
%handles.emts.resmpfreq = str2num(get(handles.ts_resmpfreq,'String'));
handles = plot_ts(handles,hObject);
guidata(hObject, handles);
end

function ts_tax_Callback(hObject, eventdata, handles)
end

function ts_lsname_Callback(hObject, eventdata, handles)
lsnames = get(handles.ts_lsname,'String');
val     = get(handles.ts_lsname,'Value');
handles.emts.lsname = lsnames(val);
% update local sampling rate lis, but keep old value if possible
lsrates = sort(unique(handles.emts.lsrates),'descend');
lsrate  = str2num(get(handles.ts_lsrate,'String'));
lsrate = lsrate(get(handles.ts_lsrate,'Value'));
val   = find(lsrates == lsrate);
if isempty(val), val = 1; end
set(handles.ts_lsrate,'String',lsrates,'Value',val);
handles.emts.lsrate = lsrates(val);
% lsrate  = str2num(get(handles.ts_lsrate,'String'));
% handles.emts.lsrate = lsrate(val);
guidata(hObject,handles);
end

function ts_lsrate_Callback(hObject, eventdata, handles)
lsrate  = str2num(get(handles.ts_lsrate,'String'));
val     = get(handles.ts_lsrate,'Value');
handles.emts.lsrate = lsrate(val);
guidata(hObject,handles);
end

function ts_usech_Callback(hObject, eventdata, handles)
usech = textscan(get(handles.ts_usech,'String'),'%s');
handles.emts.usech  = usech{1}';
guidata(hObject,handles);
end

function ts_resmp_Callback(hObject, eventdata, handles)
if get(handles.ts_resmp,'Value')
    set(handles.ts_resmpfreq,'Enable','on');
    handles.emts.resmpfreq = str2num(get(handles.ts_resmpfreq,'String'));
else
    set(handles.ts_resmpfreq,'Enable','on');
    handles.emts.resmpfreq = 0;
end
guidata(hObject,handles);
end

function ts_resmpfreq_Callback(hObject, eventdata, handles)
handles.emts.resmpfreq = str2num(get(handles.ts_resmpfreq,'String'));
guidata(hObject,handles);
end

function ts_bsnames_Callback(hObject, eventdata, handles)
bsnames =  get(handles.ts_bsnames,'String');
val     =  get(handles.ts_bsnames,'Value');
handles.emts.bsname = bsnames(val)';
guidata(hObject,handles);
end

function ts_bsrates_Callback(hObject, eventdata, handles)
handles.emts.bsrate = str2num(get(handles.ts_bsrates,'String'));
guidata(hObject,handles);
end

function ts_basesites_Callback(hObject, eventdata, handles)
if get(handles.ts_basesites,'Value');
    bsnames =  get(handles.ts_bsnames,'String');
    val     =  get(handles.ts_bsnames,'Value');
    handles.emts.bsname = bsnames(val)';
    handles.emts.bsrate = str2num(get(handles.ts_bsrates,'String'));
    set(handles.ts_bsnames,'Enable','on');
else
    handles.emts.bsname = {};
    handles.emts.bsrate = [];
    set(handles.ts_bsnames,'Enable','off');
end
guidata(hObject,handles);
end

% processing callback
function tf_estimate_Callback(hObject, eventdata, handles)
global commands
commands = cell(0);
commands{end+1} = ['proc = EMProc({''',handles.propath{1},'''});'];

lsname = get(handles.tf_lsname,'String');
handles.proc.lsname = lsname(get(handles.tf_lsname,'Value'));
output = textscan(get(handles.tf_output,'String'),'%s');
input = textscan(get(handles.tf_input,'String'),'%s');
ref = textscan(get(handles.tf_refch,'String'),'%s');
srate = str2double(get(handles.tf_srate,'String'));
srate = srate(get(handles.tf_srate,'Value'));
handles.proc.lsrate = srate;
handles.proc.output = output{1}';
handles.proc.input = input{1}';

if get(handles.tf_bsname_title,'Value')
    bsname = get(handles.tf_bsname,'String');
    handles.proc.bsname = bsname(get(handles.tf_bsname,'Value'));
    handles.proc.bsrate = srate;
else
    bsname = {};
    handles.proc.bsname = bsname;
    handles.proc.bsrate = 0;
end

if get(handles.tf_rsname_title,'Value')
    rsname = get(handles.tf_rsname,'String');
    handles.proc.rsname = rsname(get(handles.tf_rsname,'Value'));
    handles.proc.ref = ref{1}';
    handles.proc.rsrate = srate;
else
    rsname = {};
    handles.proc.rsname = rsname;
    handles.proc.ref = {};
    handles.proc.rsrate = 0;
end
handles.proc.bandsetup = 'MT';

all_sites = unique([lsname,bsname,rsname]);
commands{end+1} = ['proc = EMProc(proc,',strcell2evalstr(all_sites),');'];
commands{end+1} = 'proc.bandsetup = ''MT'';';
commands{end+1} = [];
commands{end+1} = ['proc.lsname = ',strcell2evalstr(handles.proc.lsname),';'];
commands{end+1} = ['proc.lsrate = ',num2str(handles.proc.lsrate),';'];
commands{end+1} = [];
commands{end+1} = ['proc.bsname = ',strcell2evalstr(handles.proc.bsname),';'];
commands{end+1} = ['proc.bsrate = ',num2str(handles.proc.bsrate),';'];
commands{end+1} = [];
commands{end+1} = ['proc.rsname = ',strcell2evalstr(handles.proc.rsname),';'];
commands{end+1} = ['proc.ref = ',strcell2evalstr(handles.proc.ref),';'];
commands{end+1} = ['proc.rsrate = ',num2str(handles.proc.rsrate),';'];
commands{end+1} = [];
commands{end+1} = ['proc.output = ',strcell2evalstr(handles.proc.output),';'];
commands{end+1} = ['proc.input  = ',strcell2evalstr(handles.proc.input),';'];
commands{end+1} = [];
use_usetime = get(handles.tf_use_usetime,'Value');
if use_usetime
    handles.proc.usetime = handles.tf_TimeIntervals.vec;    
    disp(['Using time interval:    ',handles.tf_TimeIntervals.char]);        
else
    handles.proc.usetime = [];
end
commands{end+1} = ['proc.usetime = [',num2str(handles.proc.usetime),'];'];   
handles.proc.mindec = str2num(get(handles.tf_mindec,'String'));
handles.proc.maxdec = str2num(get(handles.tf_maxdec,'String'));
commands{end+1} = ['proc.mindec = [',num2str(handles.proc.mindec),'];'];   
commands{end+1} = ['proc.maxdec = [',num2str(handles.proc.maxdec),'];'];   
commands{end+1} = [];
procdef.avrange = [4 4];
commands{end+1} = ['procdef.avrange = [4 4];'];
cohthres = get(handles.tf_coh,'String');
if ~isempty(cohthres)
    cohthres = str2num(cohthres);
    procdef.bicohthresg = {cohthres};
    commands{end+1} = ['procdef.bicohthresg = {[',num2str(cohthres),']};'];
else
    procdef.bicohthresg = {[]};
    commands{end+1} = ['procdef.bicohthresg = {[]};'];    
end
handles.proc.procdef = procdef;
commands{end+1} = 'proc.procdef = procdef;';

tfs = handles.proc.tf;
commands{end+1} = [];
commands{end+1} = 'tfs = proc.tf;';

% write skript
title_str = '% Skript to process spectra in ./fc and write results to ./tf';
write_skript(handles, commands, 'fc_make_tf', title_str);
commands = cell(0);
disp('Done!')
end

% % UPDATE UIs
function update_ui(hObject,eventdata,handles)

lsname = handles.emts.lsname;
lsrate = handles.emts.lsrate;

% % update textinfo after import
sites   = handles.emts.sites;
procsites   = handles.proc.sites;
ls      = get(handles.text_sitelist,'String');
val     = get(handles.text_sitelist,'Value');
if isempty(ls); ls = {'<none>'}; end
if isempty(val); val = 1; end
if iscell(ls), if val>numel(ls); val = numel(ls); end, ls = ls{val}; end
if ~isempty(sites) % probably only proc data
    if any(strcmp(sites,ls))
        ind = find(strcmp(sites,ls));
        set(handles.text_sitelist,'String',sites);
        set(handles.text_sitelist,'Value',ind);
        handles.emts.lsname = sites(ind);
    else
        set(handles.text_sitelist,'String',sites);
        set(handles.text_sitelist,'Value',1);
        handles.emts.lsname = sites(1);
    end
    str = display(handles.emts);
    set(handles.textinfo,'String',str);
    % % update runtimesplot
    srates  = sort(unique([handles.emts.srates{:}]),'descend');
    csrates = str2num(get(handles.srates_for_runtimes,'String'));
    val     = get(handles.srates_for_runtimes,'Value');
    newval  = [];
    if ~isempty(csrates)
        for ival = 1:numel(val)
            if any(srates==csrates(val(ival)))
                newval = [newval find(srates == csrates(val(ival)))];
            end
        end
    end
    if isempty(newval), newval = numel(srates); end
    set(handles.srates_for_runtimes,'String',srates,'Value',newval);
    update_runtimes(handles);
    % % update time series panel
    % update local sitename list, but keep old value if possible
    if isempty(lsname), lsname = handles.emts.lsname; handles.emts.lsrate = min(handles.emts.lsrates); lsrate = handles.emts.lsrate; end
    val    = find(strcmp(sites,lsname{1}));
    if isempty(val), val = 1; end
    set(handles.ts_lsname,'String',sites,'Value',val);
    handles.emts.lsname = sites(val);
    % update local sampling rate lis, but keep old value if possible
    lsrates = sort(unique(handles.emts.lsrates),'descend');
    val   = find(lsrates == lsrate);
    if isempty(val), val = 1; end
    set(handles.ts_lsrate,'String',lsrates,'Value',val);
    handles.emts.lsrate = lsrates(val);
    % update base site list
    bsnames = handles.emts.bsname;
    val = [];
    if ~isempty(bsnames)
        for ival = 1:numel(bsnames)
            if any(strcmp(sites,bsnames{ival}))
                val = [val find(strcmp(sites,bsnames{ival}))];
            end
        end
    end
    if isempty(val), val = 1; set(handles.ts_basesites,'Value',0);
    else set(handles.ts_basesites,'Value',1); end
    set(handles.ts_bsnames,'String',sites,'Value',val);
    ts_basesites_Callback(hObject, eventdata, handles);
    % usetime
    st = handles.emts.stimes;
    if isempty(handles.emts.usetime) && isempty(st)
        str1 = [num2str(handles.emts.reftime(1),'%04d') ' ' ...
            num2str(handles.emts.reftime(2),'%02d') ' ' ...
            num2str(handles.emts.reftime(3),'%02d') ' ' ...
            num2str(handles.emts.reftime(4),'%02d') ' ' ...
            num2str(handles.emts.reftime(5),'%02d') ' ' ...
            num2str(handles.emts.reftime(6),'%02d')];
        set(handles.usetime_from,'String', str1);
        str2 = [num2str(handles.emts.reftime(1),'%04d') ' ' ...
            num2str(handles.emts.reftime(2),'%02d') ' ' ...
            num2str(handles.emts.reftime(3),'%02d') ' ' ...
            num2str(handles.emts.reftime(4),'%02d') ' ' ...
            num2str(handles.emts.reftime(5),'%02d') ' ' ...
            num2str(handles.emts.reftime(6)+1,'%02d')];
        set(handles.usetime_to,'String', str2);
        starttime = str2num(str1);
        stoptime  = str2num(str2);
        handles.emts.usetime  = [starttime stoptime] ;
    elseif isempty(handles.emts.usetime) && ~isempty(st)
        ii = 0;
        for ind = 1 : numel(st);
            for ind2 = 1 : numel(st{ind});
                ii = ii+ 1;
                T(ii) = TimeInterval(st{ind}{ind2});
            end;
        end
        vec = T.minmax.vec;
        str1 = [num2str(vec(1),'%04d') ' ' ...
            num2str(vec(2),'%02d') ' ' ...
            num2str(vec(3),'%02d') ' ' ...
            num2str(vec(4),'%02d') ' ' ...
            num2str(vec(5),'%02d') ' ' ...
            num2str(vec(6),'%02d')];
        set(handles.usetime_from,'String', str1);
        str2 = [num2str(vec(7),'%04d') ' ' ...
            num2str(vec(8),'%02d') ' ' ...
            num2str(vec(9),'%02d') ' ' ...
            num2str(vec(10),'%02d') ' ' ...
            num2str(vec(11),'%02d') ' ' ...
            num2str(vec(12),'%02d')];
        set(handles.usetime_to,'String', str2);
        starttime = str2num(str1);
        stoptime  = str2num(str2);
        handles.emts.usetime  = [starttime stoptime] ;
    else str1 = [num2str(handles.emts.usetime(1),'%04d') ' ' ...
            num2str(handles.emts.usetime(2),'%02d') ' ' ...
            num2str(handles.emts.usetime(3),'%02d') ' ' ...
            num2str(handles.emts.usetime(4),'%02d') ' ' ...
            num2str(handles.emts.usetime(5),'%02d') ' ' ...
            num2str(handles.emts.usetime(6),'%02d')];
        set(handles.usetime_from,'String', str1);
        str2 = [num2str(handles.emts.usetime(7),'%04d') ' ' ...
            num2str(handles.emts.usetime(8),'%02d') ' ' ...
            num2str(handles.emts.usetime(9),'%02d') ' ' ...
            num2str(handles.emts.usetime(10),'%02d') ' ' ...
            num2str(handles.emts.usetime(11),'%02d') ' ' ...
            num2str(handles.emts.usetime(12),'%02d')];
        set(handles.usetime_to,'String', str2);
    end
    
    % resampling rate
    if handles.emts.resmpfreq
        set(handles.ts_resmpfreq,'String',num2str(handles.emts.resmpfreq),'Enable','on');
        set(handles.ts_resmp,'Value',1);
    else
        set(handles.ts_resmpfreq,'String',num2str(handles.emts.resmpfreq),'Enable','off');
        set(handles.ts_resmp,'Value',0);
    end
end

% time intervals
st = handles.proc.runtimes;
if isempty(handles.tf_TimeIntervals)
    if ~isempty(handles.emts.usetime)
        handles.tf_TimeIntervals = TimeInterval(handles.emts.usetime);
    elseif ~isempty(st)
        for ind = 1 : numel(st);
            T(ind) = TimeInterval(st{ind});
        end
        handles.tf_TimeIntervals = T.minmax;
    else
        handles.tf_TimeIntervals = TimeInterval([handles.reftime handles.reftime]+[0 0 0 0 0 0 0 0 0 0 0 1]);
    end
end
if all(handles.tf_TimeIntervals(1).vec == [handles.reftime handles.reftime]+[0 0 0 0 0 0 0 0 0 0 0 1]) && ~isempty(st)
    T = [];
    for ind = 1 : numel(st);
        T = [T; TimeInterval(st{ind})];
    end
    handles.tf_TimeIntervals = T.minmax;
end

ti_char = ['<html>'];
for ind = 1 : numel(handles.tf_TimeIntervals);
    ti_char = [ti_char,handles.tf_TimeIntervals(ind).char];
    if ind < numel(handles.tf_TimeIntervals)
        ti_char = [ti_char,'<br>'];
    end
end
ti_char = [ti_char,'</html>'];
set(handles.tf_usetime_intervals_pushbutton,'String',ti_char);

% if only FC was imported
if isempty(sites) && ~isempty(procsites)
    % % update runtimesplot
    srates  = sort(unique([handles.proc.srates{:}]),'descend');
    csrates = str2num(get(handles.srates_for_runtimes,'String'));
    val     = get(handles.srates_for_runtimes,'Value');
    newval  = [];
    if ~isempty(csrates)
        for ival = 1:numel(val)
            if any(srates==csrates(val(ival)))
                newval = [newval find(srates == csrates(val(ival)))];
            end
        end
    end
    if isempty(newval), newval = numel(srates); end
    set(handles.srates_for_runtimes,'String',srates,'Value',newval);
    update_runtimes(handles);
end

% % update tfs panel
%tf_lsname
lsname = handles.proc.lsname;
lsrate = handles.proc.lsrate;
bsname = handles.proc.bsname;
bsrate = handles.proc.bsrate;
rsname = handles.proc.rsname;
rsrate = handles.proc.rsrate;

sites  = handles.proc.sites;
% populate tf_lsname
ls      = get(handles.tf_lsname,'String');
val     = get(handles.tf_lsname,'Value');
if ~isempty(sites)
    if iscell(ls), ls = ls{val}; end
    if any(strcmp(sites,ls))
        ind = find(strcmp(sites,ls));
        set(handles.tf_lsname,'String',sites);
        set(handles.tf_lsname,'Value',ind);
        handles.proc.lsname = sites(ind);
    else
        set(handles.tf_lsname,'String',sites);
        set(handles.tf_lsname,'Value',1);
        handles.proc.lsname = sites(1);
    end
    
    % populate tf_bsname
    ls      = get(handles.tf_bsname,'String');
    val     = get(handles.tf_bsname,'Value');
    if iscell(ls), ls = ls{val}; end
    if any(strcmp(sites,ls))
        ind = find(strcmp(sites,ls));
        set(handles.tf_bsname,'String',sites);
        set(handles.tf_bsname,'Value',ind);
        handles.proc.bsname = sites(ind);
    else
        set(handles.tf_bsname,'String',sites);
        set(handles.tf_bsname,'Value',1);
        handles.proc.bsname = sites(1);
    end
    
    % populate tf_rsname
    ls      = get(handles.tf_rsname,'String');
    val     = get(handles.tf_rsname,'Value');
    if iscell(ls), ls = ls{val}; end
    if any(strcmp(sites,ls))
        ind = find(strcmp(sites,ls));
        set(handles.tf_rsname,'String',sites);
        set(handles.tf_rsname,'Value',ind);
        handles.proc.rsname = sites(ind);
    else
        set(handles.tf_rsname,'String',sites);
        set(handles.tf_rsname,'Value',1);
        handles.proc.rsname = sites(1);
    end
    
    if isempty(lsname), lsname = handles.proc.lsname; handles.proc.lsrate = min(handles.proc.lsrates); lsrate = handles.proc.lsrate; end
    val    = find(strcmp(sites,lsname{1}));
    if isempty(val), val = 1; end
    set(handles.tf_lsname,'String',sites,'Value',val);
    handles.proc.lsname = sites(val);
    % update local sampling rate lis, but keep old value if possible
    lsrates = sort(unique(handles.proc.lsrates),'descend');
    val   = find(lsrates == lsrate);
    if isempty(val), val = 1; end
    set(handles.tf_srate,'String',lsrates,'Value',val);
    handles.proc.lsrate = lsrates(val);
    handles.proc.bsrate = lsrates(val);
    handles.proc.rsrate = lsrates(val);
end
guidata(handles.EMApp,handles); % store all handles in h.EMApp

end

% % update runtimes
function update_runtimes(handles)
srates = get(handles.srates_for_runtimes,'String');
srates = str2num(srates);
val    = get(handles.srates_for_runtimes,'Value');
systems= get(handles.runtimes_systems,'String');
val2   = get(handles.runtimes_systems,'Value');
time   = get(handles.runtimes_tax,'String');
val3   = get(handles.runtimes_tax,'Value');
Nsites   = (get(handles.runtimes_Nsites,'String'));
val4   = get(handles.runtimes_Nsites,'Value');
delete(get(handles.ax_runtimes,'Children'));
set(handles.ax_runtimes,'Nextplot','replace');
if ~isempty(handles.emts.site)
    plotruntimes(handles.emts,'time',time{val3},'axes',handles.ax_runtimes, ...
        'srates',srates(val),'systems',systems(val2),'Nsites',str2num(Nsites{val4}));
elseif ~isempty(handles.proc.site)
    % try to use proc if emts did not yield runtimes
    plotruntimes(handles.proc,'time',time{val3},'axes',handles.ax_runtimes, ...
        'srates',srates(val),'systems',systems(val2),'Nsites',str2num(Nsites{val4}));
end
end

% % plot time series
function handles = plot_ts(handles,hObject)
Nch = numel(handles.emts.usech);
ax = [handles.axes_ch1 handles.axes_ch2 handles.axes_ch3 handles.axes_ch4 handles.axes_ch5];
for iax = 1:numel(ax)
    delete(findall(gcf,'Tag','ts_ylabel'));
    delete(get(ax(iax),'Children'));
    delete(get(handles.ts_leg,'Children'));
    set(ax(iax),'Visible','off');
end
% time shift in seconds
if get(handles.ts_tshift_title1,'value')
    tshift = str2double(get(handles.ts_tshift,'string'))/86400;
else
    tshift = 0;
end
plot(handles.emts,'time','utc','units','mV','color','k','axes',ax(1:Nch),'newplot',1,'tshift',tshift);
end

function organise_files(handles,site)

global commands

if nargin < 2;
    str = get(handles.import_listbox,'String');
    val = get(handles.import_listbox,'Value');
    site = str(val);
    if get(handles.import_raw_cleanfiles,'Value')    
        for ind = 1 : numel(site)
            adcdir = {fullfile(handles.emts.propath{1},site{ind},handles.emts.tspath{1},'./adc')};
            if isdir(adcdir{1});
                islink = false;
                if ~ispc
                    % should not really happen ever that the adc file is a
                    % link, but if ever it really is, better to make sure so
                    % its contents can't be deleted.
                    islink = ~system(['test -L ',add_backspaces(adcdir{1})]); % returns zero if a link
                end
                if islink
                    fprintf('removing link %s ...',adcdir{1});
                    delete(adcdir{1});            
                    fprintf('done.\n');
                    commands{end+1} = '% remove pre-existing ./ts/adc/  folder (symbolic link)';
                    commands{end+1} = ['delete(''',adcdir{1},''');'];
                    commands{end+1} = [];
                else
                    fprintf('deleting directory %s ...',adcdir{1});
                    c = rmdir(adcdir{1},'s');
                    fprintf(' done.\n');
                    commands{end+1} = '% delete pre-existing ./ts/adc folder';
                    commands{end+1} = ['c = rmdir(''',adcdir{1},''',''s'');'];
                    commands{end+1} = [];
                end
            end
        end
    end
    organise_files(handles,site);
    return
elseif iscell(site)    
    for ind = 1 : numel(site)
        organise_files(handles,site{ind});
    end
    return
end

srate = str2double(get(handles.import_raw_lsrate,'string'));
forcecopy = ~get(handles.import_raw_linkfiles,'value');
propath = handles.propath{1};
calpath = handles.calpath{1};

commands{end+1} = '% create ./ts/adc file structure';
D = scandir(fullfile(propath,site),'*');
mtd = cell2mat(cellfun(@(x)strfind(x,'.mtd'),{D(:).name},'UniformOutput',false));
txt = cell2mat(cellfun(@(x)strfind(x,'.txt'),{D(:).name},'UniformOutput',false));
xtr = cell2mat(cellfun(@(x)strfind(x,'.XTR'),{D(:).name},'UniformOutput',false));
raw = cell2mat(cellfun(@(x)strfind(x,'.RAW'),{D(:).name},'UniformOutput',false));
    
if any(mtd) && any(txt)
    disp(['Site ',site,' identified as EDE system (*.mtd and *.txt-files found)']);
    if ~ (srate==0)
        % detect sampling rate(s)
        D2 = scandir(fullfile(propath,site),'*.txt');
        % ignore dipole files
        dipole_files = ~cellfun(@isempty,strfind({D2.name},'dipol'));
        D2(dipole_files) = [];
        srates = zeros(1,numel(D2));
        for ind = 1 : numel(D2);
            fid = fopen(fullfile(D2(ind).location,D2(ind).name),'r');
            C = textscan(fid,'%s');
            fclose(fid);
            fullfile(D2(ind).location,D2(ind).name)
            srates(ind) = str2double(C{1}{find(strcmp(C{1},'SAMPLERATE'))+2});
        end
        srates = unique(srates);
        if ~any(srates==srate*ones(size(srates)))
            msgbox(['Problem: Found sampling rates: ',cellfun(@num2str,num2cell(srates),'UniformOutput',false)])
            return
        end
    end
    sort_ede(site,1,'propath',propath,'forcecopy',forcecopy);    
    
    commands{end+1} = ['sort_ede(''',site,''',1,''propath'',''',propath,''',''forcecopy'',',num2str(forcecopy),');'];
elseif any(xtr) && any(raw)
    disp(['Site ',site,' identified as SP4 system (*.XTR(X) and *.RAW-files found)']);
    
    % detect sampling rate(s)
    D2 = scandir(fullfile(propath,site),'*.XTR');
    srates = zeros(1,numel(D2));
    for ind = 1 : numel(D2);
        fid = fopen(fullfile(D2(ind).location,D2(ind).name),'r');
        lookfor = '[FILE]';
        nextone = false;
        while ~feof(fid)
            l = strtrim(fgetl(fid));
            if numel(l) >= numel(lookfor);
                if nextone
                    tmp = strfind(l,' ');
                    srates(ind) = str2double(l(tmp(end)+1:end));
                    break;
                end
                if ~isempty(strfind(l,lookfor));
                    nextone = true;
                end
            end
        end
        if srates(ind) < 0
            srates(ind) = -srates(ind);
        else
            srates(ind) = 1/srates(ind);
        end
        fclose(fid);
    end
    srates = unique(srates);
    if ~all(srates==srate) && numel(srates) == 1 && srate ~=0
        msgbox({'Problem: Found sampling rates: ',cellfun(@num2str,srates),' but not ',num2str(srate)})
        return
    elseif ~all(srates==srate) && numel(srates)>1
        [sel,srate_ind] = choicedlg([cellfun(@num2str,num2cell(srates),'UniformOutput',false),'all'],'title','Choose a frequency');
        if ~isempty(srate_ind)
            if srate_ind <= numel(srates)
                srate = srates(srate_ind);
            else % all selected
                srate = srates;
            end
        else
            return
        end
    end
    sort_spam4(site,0,1,'propath',propath,'calpath',calpath,'samplerate',srate,'forcecopy',forcecopy);
        
    commands{end+1} = ['sort_spam4(''',site,''',0,1,''propath'',''',propath,''',''calpath'',''',calpath,''',''samplerate'',',num2str(srate),',''forcecopy'',',num2str(forcecopy),');'];
else
    % ADUs need to be implemented
    disp(['Site ',site,' could not be identified as any valid system']);
end
commands{end+1} = [];
end

function handles = import(handles,mode,varargin)

[resample, write_proc, fc] = get_info(varargin,'resample',false,'write_proc',true,'fc',false);

str = get(handles.import_listbox,'String');
val = get(handles.import_listbox,'Value');
lssites = str(val);

global commands

% only emts commands are recorded.
% initialization command, instead of using old emts
switch mode
    case 'adc'
        commands{end+1} = '% Import data from ./ts/adc/';
    case 'proc'
        commands{end+1} = '% Import data from ./ts/proc/';
end
commands{end+1} = ['emts = EMTimeSeries([',num2str(handles.reftime),'],{''',handles.propath{1},'''});'];

handles.emts = handles.emts.remove_site(lssites);
handles.proc = handles.proc.remove_site(lssites);

% choose where the files are to come from
switch mode
    case 'adc'
        pt = textscan(get(handles.import_adc_filter,'String'),'%s');
        chorder_str = get(handles.import_chorder,'String');
        chorder = str2num(chorder_str);
        premult_str = get(handles.import_premult,'String');
        premult = str2num(premult_str);
        handles.emts.chorder = chorder;
        handles.emts.premult = premult;
        
        if ~isempty(chorder_str)
            commands{end+1} = ['emts.chorder = ',chorder_str,';'];
        else
            commands{end+1} = 'emts.chorder = [];';
        end
        if ~isempty(premult_str)
            commands{end+1} = ['emts.premult = ',premult_str,';'];
        else
            commands{end+1} = 'emts.premult = [];';
        end
    case 'proc'
        pt = textscan(get(handles.import_proc_filter,'String'),'%s');
        
        % in this case, resampling is assumed already being done!
        resample = false;
end
% import data
handles.emts.datapath = pt{1}';
handles.emts = EMTimeSeries(handles.emts,lssites);

commands{end+1} = ['emts.datapath = ',strcell2evalstr(pt{1}'),';'];
commands{end+1} = ['emts = EMTimeSeries(emts,',strcell2evalstr(lssites),');'];
commands{end+1} = [];

% if no data, don't do more, otherwise
if ~isempty(handles.emts.sites)
    % display data
    handles.tgroup.SelectedTab = handles.tab2;
    
    % target frequency
    switch mode
        case 'adc'
            lsrate = str2num(get(handles.import_lsrate,'String'));
        case 'proc'
            lsrate = str2num(get(handles.import_proc_lsrate,'String'));
    end
    
    if resample || fc
        % get all relevant sampling rates, and match it to the user choice
        % required for: resample and fc
        allsrates = [];
        for ind = 1 : numel(lssites)
            site_idx = find(strcmp(handles.emts.sites,lssites{ind}));
            for ind2 = 1 : numel(handles.emts.site{site_idx})
                allsrates = [allsrates, handles.emts.site{site_idx}{ind2}.srate];
            end
        end
        allsrates = unique(allsrates);
        % lsrate 0, if found more than 1, choose (only one possible)
        % elseif lsrate 0 found only one, choose the one which is there
        % elseif lsrate ~0, take the frequency selected if there, or don't
        % do anything if it's not there
        if lsrate == 0 && numel(allsrates) > 1
            [~,srate_ind] = choicedlg(cellfun(@num2str,num2cell(allsrates),'UniformOutput',false),'title','Which frequency?');
            if ~isempty(srate_ind);
                lsrate = allsrates(srate_ind);
            else
                return
            end
        elseif lsrate == 0 && numel(allsrates) == 1
            lsrate = allsrates;
        elseif lsrate > 0
            if ~any(allsrates == lsrate);
                return
            end
        end
    end
    
    resmpfreq = 0;
    if resample
        resmpfreq = str2num(get(handles.import_resmpfrq,'String'));                        
        if resmpfreq == lsrate; resmpfreq = 0; end
        handles.emts.resmpfreq = resmpfreq;
        
        if resmpfreq == 0 || resmpfreq == lsrate
            commands{end+1} = '% No resampling';            
        else
            commands{end+1} = ['% Resampling from ',num2str(lsrate),' Hz to ',num2str(resmpfreq),' Hz'];
        end
        commands{end+1} = ['emts.resmpfreq = ',num2str(resmpfreq),';'];
        
        for is = 1:numel(lssites) % JK 1:
            handles.emts.lsname = lssites(is);
            handles.emts.lsrate = lsrate;            
            commands{end+1} = ['emts.lsname = {''',lssites{is},'''};'];
            commands{end+1} = ['emts.lsrate = ',num2str(lsrate),';'];            
            % clean proc dir
            if get(handles.import_import_cleanproc,'Value')
                procdir = {fullfile(handles.emts.propath{1},handles.emts.lsname{1},handles.emts.tspath{1},handles.emts.procpath{1})};
                fprintf('deleting %s ...',procdir{1});
                c = rmdir(procdir{1},'s');
                fprintf(' done.\n');                                
                commands{end+1} = '% delete pre-existing ./ts/proc/';
                commands{end+1} = ['c = rmdir(''',procdir{1},''',''s'');'];
            end
            if write_proc
                if resmpfreq == 0;
                    commands{end+1} = ['% Write ./ts/proc/ at ',num2str(lsrate),' Hz (same sampling frequency as ./ts/adc/)'];            
                else
                    commands{end+1} = ['% Write ./ts/proc/ at ',num2str(lsrate),' Hz'];
                end
                runtimes = [];
                if get(handles.import_import_breakfiles,'Value') % break files
                    reftime = datenum(handles.emts.reftime);
                    localsites = handles.emts.localsite;
                    for il = 1:numel(localsites)
                        startstop(il,:) = [datenum(handles.emts.localsite{1}.starttime) datenum(handles.emts.localsite{1}.stoptime)];
                        tmp1 = reftime:2:datenum(handles.emts.localsite{il}.starttime);
                        tmp2 = reftime:2:(datenum(handles.emts.localsite{il}.stoptime)+2);
                        runtimedays(il,:) = [tmp1(end) tmp2(end)];
                    end
                    runtimes = [min(runtimedays(:,1)):2:max(runtimedays(:,2))];
                end
                if isempty(runtimes) % do not break files
                    handles.emts.usetime = [];
                    atsfiles = handles.emts.atsfiles;
                    
                    commands{end+1} = 'atsfiles = emts.atsfiles;';
                else % break files
                    commands{end+1} = '% in 2 day intervals';
                    for ir = 1:(numel(runtimes)-1)
                        handles.emts.usetime = [datevec(runtimes(ir)) datevec(runtimes(ir+1))];
                        atsfiles = handles.emts.atsfiles;
                                                
                        commands{end+1} = ['emts.usetime = [',num2str([datevec(runtimes(ir)) datevec(runtimes(ir+1))]),'];'];
                        commands{end+1} = 'atsfiles = emts.atsfiles;';
                    end
                    handles.emts.usetime = [];
                    commands{end+1} = ['emts.usetime = [];'];
                end
                handles.emts.chorder = [];
                handles.emts.premult = [];
                
                commands{end+1} = 'emts.chorder = [];';
                commands{end+1} = 'emts.premult = [];';
                commands{end+1} = [];
                
                handles = import(handles,'proc');
            end
        end
    end
    if fc
        commands{end+1} = [];        
        commands{end+1} = '% Spectrum calculation (saved to ./fc/)';        
        
        switch mode
            case 'adc'
                clean_fc = get(handles.import_import_cleanproc,'Value');
            case 'proc'
                clean_fc = get(handles.import_import_cleanfc,'Value');
        end
        % now write spectra
        if resmpfreq == 0;
            handles.emts.lsrate = lsrate;
        else
            handles.emts.lsrate = resmpfreq;
        end
        commands{end+1} = ['emts.lsrate = ',num2str(handles.emts.lsrate),';'];
        
        for is = 1:numel(lssites) % JK 1:
            handles.emts.lsname = lssites(is);
            commands{end+1} = ['emts.lsname = {''',lssites{is},'''};'];
            
            % clean fc dir
            if clean_fc
                fcdir = {fullfile(handles.emts.propath{1},handles.emts.lsname{1},handles.emts.fcpath{1})};
                fprintf('deleting %s ...',fcdir{1});
                c = rmdir(fcdir{1},'s');
                fprintf(' done.\n');
                commands{end+1} = '% delete pre-existing ./fc/ folder';
                commands{end+1} = ['c = rmdir(''',fcdir{1},''',''s'');'];
            end       
            commands{end+1} = '% Write spectra to ./fc/';                    
            handles.emts.usetime = [];                        
            afcfiles = handles.emts.afcfiles;            
            commands{end+1} = 'emts.usetime = [];';
            commands{end+1} = 'afcfiles = emts.afcfiles;';
        end
        handles.proc            = EMProc(handles.proc,lssites);
        % display spectra
        handles.tgroup.SelectedTab = handles.tab5;
    end
    handles.emts.chorder = [];
    handles.emts.premult = [];
    commands{end+1} = 'emts.chorder = [];';
    commands{end+1} = 'emts.premult = [];';
    commands{end+1} = [];    
else
    handles.emts.chorder = [];
    handles.emts.premult = [];
    commands{end+1} = 'emts.chorder = [];';
    commands{end+1} = 'emts.premult = [];';
    commands{end+1} = [];    
end
handles.emts.resmpfreq = 0;
commands{end+1} = 'emts.resmpfreq = 0;';
commands{end+1} = [];
end


function write_skript(handles, commands, fileroot, title_str)

    if ~get(handles.import_write_skript,'Value'); return; end
    % scripts are of the form site1_site2_..._siteN_start_make_xxx_xxx_target.m

    str = get(handles.import_listbox,'String');
    val = get(handles.import_listbox,'Value');
    sitenames = str(val);
    
    header_lines{1} = title_str;    
    header_lines{2} = '% created by EMApp.m';
    header_lines{3} = ['% ',datestr(now)];
    for ind = 1 : numel(sitenames); header_lines{end+1} = ['% ',sitenames{ind}]; end
    header_lines{end+1} = [];
    
    % skripts are related in a chain:
    % make_adc -> adc_make -> proc_make -> fc_make
    % with the starting points
    starting_points = {'raw','adc', 'proc','fc'};
    % and the targets
    target_points   = {'adc','proc','fc',  'tf'};
    % when making a new skript (subchain), keep only scripts that start
    % earlier than the one we are trying to make    
    start = fileroot(1:strfind(fileroot,'make')-2);
    if isempty(start); start = 'raw'; end    
    target = fileroot(strfind(fileroot,'make')+5:end);
    target = target(find(target=='_',1,'last')+1:end);
            
    % find all scripts in propath that match site selection
    skripts = dir(fullfile(handles.propath{1},'*.m'));
    disregard = true(size(skripts));
    for ind = 1 : numel(skripts)        
        
        % is it an EMApp skript?
        fid = fopen(fullfile(handles.propath{1},skripts(ind).name),'r'); 
        l1 = []; if  ~feof(fid); l1 = fgetl(fid); end
        l2 = []; if  ~feof(fid); l2 = fgetl(fid); end
        l3 = []; if  ~feof(fid); l3 = fgetl(fid); end        
        fclose(fid);                        
        if ~strcmp(l2,header_lines{2});            
            % not an EMApp skript, can be omitted
            disregard(ind) = true; 
            continue
        end
        if ~isempty(l3); skript_time = datestr(datenum(l3(3:end)),31); end
            
        % parse file name
        [~,sn,~] = fileparts(skripts(ind).name);
        cut_here = strfind(sn,'_');
        strcell = cell(1,numel(cut_here)+1);
        last = -1;
        for ind2 = 1 : numel(cut_here)
            first = last + 2; last = cut_here(ind2)-1;
            strcell{ind2} = sn(first:last);
        end
        strcell{numel(cut_here)+1} = sn(last+2:end);            
        make_idx = find(strcmp(strcell,'make'));
        
        % find starting point
        skript_start = []; if make_idx > 1; skript_start = strcell{make_idx-1}; end
        if isempty(skript_start); skript_start = 'raw'; end
            
        % identify sites
        strcell = strcell(make_idx+1:end);
        is_site = true(size(strcell));  % site names or ids      
        is_siteid = false(size(strcell));% only site ids        
        site_ids = {'ls','bs','rs'};        
        sites_for_id = cell(1,numel(site_ids)+1); % last category is for unId sites
        for ind2 = 1 : numel(sites_for_id); sites_for_id{ind2} = cell(0); end
        next_id = numel(sites_for_id);
        for ind2 = 1 : numel(strcell)            
            for ind3 = 1 : numel(target_points)
                if strcmp(strcell{ind2},target_points{ind3})
                    is_site(ind2) = false;
                end
            end            
            for ind3 = 1 : numel(site_ids)                
                if strcmp(strcell{ind2},site_ids{ind3});
                    is_siteid(ind2) = true;     
                    next_id = ind3;
                end
            end    
            if is_site(ind2) && ~is_siteid(ind2)
                sites_for_id{next_id}{end+1} = strcell{ind2};
            end
        end                                                                    
        skript_sites = strcell(is_site & ~is_siteid);        
        
        % find target point
        strcell(is_site) = [];
        skript_target = strcell{end};        
        
        % which of the in the filename sites are relevenant
        is_relevant = false(size(skript_sites));
        for ind2 = 1 : numel(skript_sites)
            for ind3 = 1 : numel(sitenames)
                if strcmp(skript_sites{ind2},sitenames{ind3});
                    is_relevant(ind2) = true;
                    continue
                end
            end
        end
        
        % which of the sites looked for where found
        has_sites = false(size(sitenames));
        for ind2 = 1 : numel(sitenames)
            for ind3 = 1 : numel(skript_sites)
                if strcmp(skript_sites{ind3},sitenames{ind2});
                    has_sites(ind2) = true;
                    continue
                end
            end
        end
        
        switch target
            case 'tf' % these one we only overwrite!(no reason to delete them)
            otherwise
                % delete those
                if all(is_relevant) && all(has_sites); 
                    % where the start is later or same
                    if find(strcmp(starting_points,skript_start)) >= find(strcmp(starting_points,start))
                        disregard(ind) = false;                     
                    end
                end
        end
        
    end                    
    skripts(disregard) = [];
    for ind = 1 : numel(skripts);
        skriptname = fullfile(handles.propath{1}, skripts(ind).name);
        if ~get(handles.import_keep_skript,'Value')
            delete(skriptname);
            disp(['Deleting ',skriptname]);
        else
            new_sn = [skriptname,'_',skript_time];
            disp([skriptname,' exists, moving to ',new_sn]);
            movefile(skriptname,new_sn);            
        end
    end
    
    fn = fileroot; 
    for ind = 1 : numel(sitenames); 
        fn = [fn, '_',sitenames{ind}];         
    end
    fn = [fn,'.m'];
    fn = fullfile(handles.propath{1}, fn);                    
    
    if exist(fn,'file');
        if ~get(handles.import_keep_skript,'Value')
            disp([fn,' exists, overwriting']);
            delete(fn);
        else
            new_fn = [fn,'_',skript_time];
            disp([fn,' exists, moving to ',newfilename]);
            movefile(fn,new_fn);
        end
    end            
    
    fid = fopen(fn,'w');
    for ind = 1 : numel(header_lines)
        fprintf(fid,'%s\n',header_lines{ind});
    end
    for ind = 1 : numel(commands)
        fprintf(fid,'%s\n',commands{ind});
    end
    fclose(fid);
    disp([fn,' written.']);
    
    if get(handles.import_show_skript,'Value');
        disp(' ');
        disp(' ');
        disp(['v------------------------ ',fn,' ------------------------v'])
        disp(' ');
        type(fn);
        disp(' ');
        disp(['^------------------------ ',fn,' ------------------------^'])
        disp(' ');
        disp(' ');
    end
end