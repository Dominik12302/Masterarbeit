function varargout = EM_ts(varargin)
% EM_TS MATLAB code for EM_ts.fig
%      EM_TS, by itself, creates a new EM_TS or raises the existing
%      singleton*.
%
%      H = EM_TS returns the handle to a new EM_TS or the handle to
%      the existing singleton*.
%
%      EM_TS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EM_TS.M with the given input arguments.
%
%      EM_TS('Property','Value',...) creates a new EM_TS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EM_ts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EM_ts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EM_ts

% Last Modified by GUIDE v2.5 01-Oct-2014 17:16:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EM_ts_OpeningFcn, ...
                   'gui_OutputFcn',  @EM_ts_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EM_ts is made visible.
function EM_ts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EM_ts (see VARARGIN)
% Choose default command line output for EM_ts
handles.output = hObject;
% Update handles structure
handles.propath = pwd;
handles.proname = [];
handles.reftime = [];
handles.emts    = [];
handles.proc    = [];
guidata(hObject, handles);
% UIWAIT makes EM_ts wait for user response (see UIRESUME)
% uiwait(handles.EMTimeSeriesGUI);


% --- Outputs from this function are returned to the command line.
function varargout = EM_ts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%% some helper functions
function enable_menu(handles, to_enable)
for il = 1:numel(to_enable)
    set(eval(['handles.' to_enable{il}]),'Enable','on');
end
function disable_menu(handles, to_disable)
for il = 1:numel(to_disable)
    set(eval(['handles.' to_disable{il}]),'Enable','off');
end
function make_visible(handles, panels)
for il = 1:numel(panels)
    set(eval(['handles.' panels{il}]),'Visible','on');
end
function make_invisible(handles, panels)
for il = 1:numel(panels)
    set(eval(['handles.' panels{il}]),'Visible','off');
end
function tick_dispmenu(handles,items)
for il = 1:numel(items)
    set(eval(['handles.' items{il}]),'checked','on');
end
function untick_dispmenu(handles,items)
for il = 1:numel(items)
    set(eval(['handles.' items{il}]),'checked','off');
end
function update_ui(hObject,eventdata,handles)
lsname = handles.emts.lsname;
lsrate = handles.emts.lsrate;
%% update textinfo after import
sites   = handles.emts.sites;
ls      = get(handles.text_sitelist,'String');
val     = get(handles.text_sitelist,'Value');
if iscell(ls), ls = ls{val}; end
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
%% update runtimesplot
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
%% update time series panel
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
if isempty(handles.emts.usetime)
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
else str1 = [num2str(handles.emts.usetime(1),'%04d') ' ' ...
    num2str(handles.emts.usetime(2),'%02d') ' ' ...
    num2str(handles.emts.usetime(3),'%02d') ' ' ...
    num2str(handles.emts.usetime(4),'%02d') ' ' ...
    num2str(handles.emts.usetime(5),'%02d') ' ' ...
    num2str(handles.emts.usetime(6),'%02d')];
set(handles.usetime_from,'String', str1);
str2 = [num2str(handles.emts.usetime(1),'%04d') ' ' ...
    num2str(handles.emts.usetime(2),'%02d') ' ' ...
    num2str(handles.emts.usetime(3),'%02d') ' ' ...
    num2str(handles.emts.usetime(4),'%02d') ' ' ...
    num2str(handles.emts.usetime(5),'%02d') ' ' ...
    num2str(handles.emts.usetime(6)+1,'%02d')];
set(handles.usetime_to,'String', str2);
end
% resmpling rate
if handles.emts.resmpfreq
    set(handles.ts_resmpfreq,'String',num2str(handles.emts.resmpfreq),'Enable','on');
    set(handles.ts_resmp,'Value',1);
else
    set(handles.ts_resmpfreq,'String',num2str(handles.emts.resmpfreq),'Enable','off');
    set(handles.ts_resmp,'Value',0);
end
%% update conversion/resampling panel
set(handles.conv_sitelist,'String',sites);
set(handles.conv_srate,'String',srates);
% times
set(handles.conv_to,'String', str2);
set(handles.conv_from,'String', str1);

guidata(hObject,handles);
%% menus
function project_Callback(hObject, eventdata, handles)
function load_ini_Callback(hObject, eventdata, handles)
[FileName,PathName,FilterIndex] = uigetfile('*.ini','Load ini file',handles.propath);
if ischar(PathName)
    if isdir(PathName)
        fid = fopen(fullfile(PathName,FileName));
        propath = fgetl(fid);
        if isdir(propath)
            handles.propath = {propath};
            [p,proname,e] = fileparts(propath);
            handles.proname = proname;
            reftime = fscanf(fid,'%d %d %d %d %d %d',[1 6]);
            fclose(fid);
            handles.reftime = reftime;
            set(handles.EMTimeSeriesGUI,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(reftime)]);
            enable_menu(handles,{'save','saveas','edit','display','import'});
            handles.emts =  EMTimeSeries(reftime,{propath});
            guidata(hObject, handles);            
        else
            disp(['Error: Project Path given in ' fullfile(PathName,FileName) ' is not a valid directory']);
            fclose(fid);
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
            save(fullfile(handles.propath{1},handles.proname),'emts');
            set(handles.EMTimeSeriesGUI,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(emts.reftime)]);
            enable_menu(handles,{'save','saveas','edit','display','import'});
            update_ui(hObject,eventdata,handles);
            make_invisible(handles,{'panel_import','panel_ts','panel_runtimes','panel_edit_convert'});
            enable_menu(handles,{'project','edit','display','import'});
            disp_text_Callback(hObject, eventdata, handles);
            guidata(hObject,handles);
        end
    end
end
function save_Callback(hObject, eventdata, handles)
emts = handles.emts;
save(fullfile(handles.propath{1},handles.proname),'emts');
function saveas_Callback(hObject, eventdata, handles)
pw = pwd;
cd(handles.propath{1});
[proname,propath,FilterIndex] = uiputfile('*.mat','Save Project as: ',[handles.proname '.mat']);
if ischar(proname)
handles.propath = {fullfile(propath)};
[p,proname,e] = fileparts(proname);
handles.proname = proname;
emts = handles.emts;
save(fullfile(handles.propath{1},handles.proname),'emts');
set(handles.EMTimeSeriesGUI,'Name',['Project: ' fullfile(propath,[proname,'.mat']) '- reftime is ' datestr(emts.reftime)]);
guidata(hObject,handles);
end
cd(pw);
function close_Callback(hObject, eventdata, handles)
function edit_Callback(hObject, eventdata, handles)
function edit_starttime_Callback(hObject, eventdata, handles)
function edit_convert_Callback(hObject, eventdata, handles)
make_invisible(handles,{'panel_textinfo','panel_ts','panel_runtimes' 'panel_import'});
make_visible(handles,{'panel_edit_convert'});
disable_menu(handles,{'project','edit','display','import'});

function import_Callback(hObject, eventdata, handles)
function import_emarchive_Callback(hObject, eventdata, handles)
% populate listbox
a=dir(handles.emts.propath{1});
list = {a([a.isdir]).name};
set(handles.import_listbox,'String',list);
make_invisible(handles,{'panel_textinfo','panel_ts','panel_runtimes','panel_edit_convert'});
make_visible(handles,{'panel_import'});
disable_menu(handles,{'project','edit','display','import','load_ini','load'});
function display_Callback(hObject, eventdata, handles)
function disp_text_Callback(hObject, eventdata, handles)
untick_dispmenu(handles,{'disp_runtimes','disp_ts','disp_spectra'});
tick_dispmenu(handles,{'disp_text'});
make_invisible(handles, {'panel_import','panel_ts','panel_runtimes'});
make_visible(handles, {'panel_textinfo'});
function disp_runtimes_Callback(hObject, eventdata, handles)
untick_dispmenu(handles,{'disp_text','disp_ts','disp_spectra'});
tick_dispmenu(handles,{'disp_runtimes'});
make_invisible(handles, {'panel_import','panel_ts','panel_textinfo'});
make_visible(handles, {'panel_runtimes'});
function disp_ts_Callback(hObject, eventdata, handles)
untick_dispmenu(handles,{'disp_text','disp_runtimes','disp_spectra'});
tick_dispmenu(handles,{'disp_ts'});
make_invisible(handles, {'panel_import','panel_runtimes','panel_textinfo'});
make_visible(handles, {'panel_ts'});
function disp_spectra_Callback(hObject, eventdata, handles)


%% Import data, called from menu import -> EM archive
function import_ts_Callback(hObject, eventdata, handles)
if get(handles.import_ts,'Value')
    set(handles.import_adc_filter,'Enable','on');
    set(handles.import_proc_filter,'Enable','on');
else
    set(handles.import_adc_filter,'Enable','off');
    set(handles.import_proc_filter,'Enable','off');
end
function import_fc_Callback(hObject, eventdata, handles)
function import_adc_filter_Callback(hObject, eventdata, handles)
pt = textscan(get(handles.import_adc_filter,'String'),'%s');
handles.emts.datapath = pt{1}';
guidata(hObject,handles);
function import_adc_filter_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function import_proc_filter_Callback(hObject, eventdata, handles)
function import_proc_filter_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function import_fc_filter_Callback(hObject, eventdata, handles)
function import_fc_filter_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function import_listbox_Callback(hObject, eventdata, handles)
function import_listbox_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function import_cancel_Callback(hObject, eventdata, handles)
make_invisible(handles,{'panel_import'});
enable_menu(handles,{'project','edit','display','import'});
function import_import_Callback(hObject, eventdata, handles)
str = get(handles.import_listbox,'String');
val = get(handles.import_listbox,'Value');
pt = textscan(get(handles.import_adc_filter,'String'),'%s');
handles.emts.datapath = pt{1}';
handles.emts = EMTimeSeries(handles.emts,str(val));
if ~isempty(handles.emts.sites)
%    handles.emts.lsname = handles.emts.sites(1);
    guidata(hObject, handles);
    update_ui(hObject,eventdata,handles);
    make_invisible(handles,{'panel_import','panel_ts','panel_runtimes'});
    enable_menu(handles,{'project','edit','display','import'});
    disp_text_Callback(hObject, eventdata, handles);
end
%% Display text info
function text_sitelist_Callback(hObject, eventdata, handles)
str = get(handles.text_sitelist,'String');
val = get(handles.text_sitelist,'Value');
handles.emts.lsname = str(val);
%handles.emts.lsrate = 512;
str = display(handles.emts);
set(handles.text_sitelist,'String',handles.emts.sites);
set(handles.textinfo,'String',str);
guidata(hObject, handles);
function text_sitelist_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% runtimes plot
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
plotruntimes(handles.emts,'time',time{val3},'axes',handles.ax_runtimes, ...
    'srates',srates(val),'systems',systems(val2),'Nsites',str2num(Nsites{val4}));
function srates_for_runtimes_Callback(hObject, eventdata, handles)
update_runtimes(handles);
function srates_for_runtimes_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function runtimes_tax_Callback(hObject, eventdata, handles)
update_runtimes(handles);
function runtimes_tax_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function runtimes_Nsites_Callback(hObject, eventdata, handles)
update_runtimes(handles);
function runtimes_Nsites_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function runtimes_systems_Callback(hObject, eventdata, handles)
update_runtimes(handles);
function runtimes_systems_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% plot time series
function handles = plot_ts(handles,hObject)
Nch = numel(handles.emts.usech);
ax = [handles.axes_ch1 handles.axes_ch2 handles.axes_ch3 handles.axes_ch4 handles.axes_ch5];
for iax = 1:numel(ax)
    delete(findall(gcf,'Tag','ts_ylabel'));
    delete(get(ax(iax),'Children'));
    delete(get(handles.ts_leg,'Children'));
    set(ax(iax),'Visible','off');
end
plot(handles.emts,'time','utc','color','k','axes',ax(1:Nch),'newplot',1);
function usetime_from_Callback(hObject, eventdata, handles)
starttime = str2num(get(handles.usetime_from,'String'));
stoptime  = str2num(get(handles.usetime_to,'String'));
if numel(starttime) == 6 && numel(stoptime) == 6
    handles.emts.usetime  = [starttime stoptime] ;
end
guidata(hObject,handles);
function usetime_from_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function usetime_to_Callback(hObject, eventdata, handles)
starttime = str2num(get(handles.usetime_from,'String'));
stoptime  = str2num(get(handles.usetime_to,'String'));
if numel(starttime) == 6 && numel(stoptime) == 6
    handles.emts.usetime  = [starttime stoptime] ;
end
guidata(hObject,handles);
function usetime_to_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ts_nextwindow_Callback(hObject, eventdata, handles)
function ts_prevwindow_Callback(hObject, eventdata, handles)
function ts_refresh_Callback(hObject, eventdata, handles)
handles = plot_ts(handles,hObject);
guidata(hObject, handles);
function ts_tax_Callback(hObject, eventdata, handles)
function ts_tax_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
function ts_lsname_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ts_lsrate_Callback(hObject, eventdata, handles)
lsrate  = str2num(get(handles.ts_lsrate,'String')); 
val     = get(handles.ts_lsrate,'Value');
handles.emts.lsrate = lsrate(val);
guidata(hObject,handles);
function ts_lsrate_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ts_usech_Callback(hObject, eventdata, handles)
usech = textscan(get(handles.ts_usech,'String'),'%s');
handles.emts.usech  = usech{1}';
guidata(hObject,handles);
function ts_usech_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
function ts_resmpfreq_Callback(hObject, eventdata, handles)
handles.emts.resmpfreq = str2num(get(handles.ts_resmpfreq,'String'));
guidata(hObject,handles);
function ts_resmpfreq_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ts_bsnames_Callback(hObject, eventdata, handles)
bsnames =  get(handles.ts_bsnames,'String');
val     =  get(handles.ts_bsnames,'Value');
handles.emts.bsname = bsnames(val)';
guidata(hObject,handles);
function ts_bsnames_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ts_bsrates_Callback(hObject, eventdata, handles)
handles.emts.bsrate = str2num(get(handles.ts_bsrates,'String'));
guidata(hObject,handles);
function ts_bsrates_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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

%% Resampling and conversion


function conv_sitelist_Callback(hObject, eventdata, handles)
function conv_sitelist_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_from_Callback(hObject, eventdata, handles)
function conv_from_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_to_Callback(hObject, eventdata, handles)
function conv_to_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_conv_Callback(hObject, eventdata, handles)
snames =  get(handles.conv_sitelist,'String');
val     = get(handles.conv_sitelist,'Value');
snames  = snames(val)';
handles.emts.resmpfreq = str2num(get(handles.ts_resmpfreq,'String'));
usech = textscan(get(handles.ts_usech,'String'),'%s');
handles.emts.usech  = usech{1}';
usetime = {[]};
if get(handles.conv_usetime,'Value');
starttime = str2num(get(handles.conv_from,'String'));
stoptime  = str2num(get(handles.conv_to,'String'));
if numel(starttime) == 6 && numel(stoptime) == 6
    usetime  = {[starttime stoptime]};
end
end
if get(handles.conv_usetimec,'Value');
% starttime = str2num(get(handles.conv_from,'String'));
% stoptime  = str2num(get(handles.conv_to,'String'));
% if numel(starttime) == 6 && numel(stoptime) == 6
%     usetime  = {[starttime stoptime]};
% end
end
if get(handles.conv_resmp,'Value');
    handles.emts.resmpfreq = str2num(get(handles.conv_resmpfreq,'String'));
else
    handles.emts.resmpfreq = 0;
end
set(handles.panel_statusbar,'Backgroundcolor',[0 0.3 1]);
pause(0.1);
for is = 1:numel(snames)
    handles.emts.lsname = snames(is);
    for it = 1:numel(usetime)
        handles.emts.usetime = usetime{it};
        atsfiles  = handles.emts.atsfiles;
        
    end
end
set(handles.panel_statusbar,'Backgroundcolor',0.941+[0 0 0]);
function conv_resmp_Callback(hObject, eventdata, handles)
if get(handles.conv_resmp,'Value')
    set(handles.conv_resmpfreq,'Enable','on');
else
    set(handles.conv_resmpfreq,'Enable','off');
end
function conv_resmpfreq_Callback(hObject, eventdata, handles)
function conv_resmpfreq_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_srate_Callback(hObject, eventdata, handles)
function conv_srate_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_usech_Callback(hObject, eventdata, handles)
function conv_usech_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_usetimec_Callback(hObject, eventdata, handles)
function conv_usetime_cell_Callback(hObject, eventdata, handles)
function conv_usetime_cell_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_cancel_Callback(hObject, eventdata, handles)
make_invisible(handles,{'panel_edit_convert'});
enable_menu(handles,{'project','edit','display','import'});
if strcmp(get(handles.disp_text,'Checked'),'on')
    make_visible(handles, {'panel_textinfo'});
elseif strcmp(get(handles.disp_runtimes,'Checked'),'on')
    make_visible(handles, {'panel_runtimes'});
elseif strcmp(get(handles.disp_ts,'Checked'),'on')
    make_visible(handles, {'panel_ts'});
elseif strcmp(get(handles.disp_spectra,'Checked'),'on')
    make_visible(handles, {'panel_spectra'});
end
function convert_textinfo_Callback(hObject, eventdata, handles)
function convert_textinfo_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function conv_import_Callback(hObject, eventdata, handles)


function conv_usetime_Callback(hObject, eventdata, handles)
if get(handles.conv_usetime,'Value')
    set(handles.conv_to,'Enable','on');
    set(handles.conv_from,'Enable','on');
else
    set(handles.conv_to,'Enable','off');
    set(handles.conv_from,'Enable','off');
end
