function varargout = TimeIntervalGui(time_in, bg_time, bg_name, varargin)

    % T = TimeIntervalGui([datevec1, datevec2,...]);
    % T = TimeIntervalGui(TimeIntervalArray);
    % T = TimeIntervalGui(TimeIntervalArray,bg_CellOfTimeIntervalArrays);
    % T = TimeIntervalGui(TimeIntervalArray,bg_CellOfTimeIntervalArrays,bg_names,varargin);
    % T = TimeIntervalGui(TimeIntervalArray,[],[],varargin);
    % T = TimeIntervalGui([datevec1, datevec2,...],...
    %       {[bg1_datevec1,bg1_datevec2,... ],...});
    % T = TimeIntervalGui([datevec1, datevec2,...],...
    %       {[bg1_datevec1,bg1_datevec2,... ],...}, bgnames, varargin);
    % T = TimeIntervalGui([datevec1, datevec2,...],[], [], varargin);
    %
    % varargin: 'multi_segment', true/false (default: true)
    %
    % JK2017

    global fs13 fs14 fs16
    fs13 = 13; fs14 = 14; fs16 = 16;
    if ~ismac, fs13 = fs13/(96/72); fs14 = fs14/(96/72); fs16 = fs16/(96/72); end
    h.TimeIntervalGui = figure('units','normalized','position',[0.25 0.3 0.5 0.4],'MenuBar','None','tag','EMApp','Toolbar','none');         
    
    if nargin < 1
        h.TimeIntervals = [];
    else
        h.TimeIntervals = time_in;
    end
    
    if nargin < 2
        h.background_TimeIntervals = [];
    else        
        if isempty(bg_time)
            h.background_TimeIntervals = [];
        elseif iscell(bg_time);            
            h.background_TimeIntervals = bg_time;
        elseif isnumeric(bg_time);
            for ind = 1 : size(bg_time,1)
                h.background_TimeIntervals{1}(ind) = TimeInterval(bg_time(ind,:));
            end
        end
        for ind = 1 : numel(h.background_TimeIntervals)
            if isnumeric(h.background_TimeIntervals{ind});
                h.background_TimeIntervals{ind} = TimeInterval(h.background_TimeInterval{ind});
            end
        end
    end
    
    if nargin < 3        
        h.background_names = cell(size(h.background_TimeIntervals));
        for ind = 1 : numel(h.background_TimeIntervals)
            h.background_names{ind} = {['Site ',num2str(ind)]};
        end              
    else
        if isempty(bg_name)
            h.background_names = cell(0);
        else
            h.background_names = bg_name;
        end
    end            
    
    if isempty(h.TimeIntervals)
        h.TimeIntervals = TimeInterval([1980 10 10 8 0 0 datevec(today)]); 
    elseif iscell(h.TimeIntervals)
        tmp = h.TimeIntervals;
        h = rmfield(h,'TimeIntervals');
        for ind = 1 : numel(tmp)
            h.TimeIntervals(ind) = TimeInterval(tmp{ind});
        end
    elseif isnumeric(h.TimeIntervals)
        tmp = h.TimeIntervals;
        h = rmfield(h,'TimeIntervals');
        for ind = 1 : size(tmp,1)
            h.TimeIntervals(ind) = TimeInterval(tmp(ind,:));
        end
    elseif isa(h.TimeIntervals,'TimeInterval')
    else 
        error('input not supported');
    end 
    h.TimeIntervals = h.TimeIntervals.cleanup;               
    h.OrigTimeIntervals = h.TimeIntervals;
    varargout{1} = h.OrigTimeIntervals;    
    
    h.multi_segment = get_info(varargin,'multi_segment',true);
    if ~h.multi_segment; h.TimeIntervals = h.TimeIntervals.minmax; end
    
    h = init_ui(h);
    h = update_ui_full(h);
    
    guidata(h.TimeIntervalGui,h);
        
    uiwait(h.TimeIntervalGui);
        
    try
        h = guidata(h.TimeIntervalGui);
        varargout{1} = h.OrigTimeIntervals;        
        delete(h.TimeIntervalGui);
    end
    
end

function h = init_ui(h)
    global fs13 fs14 fs16
    
    h.ax  = axes('Position',[0.15 0.85 0.8 0.1]); box on    
    h.ti_patch = h.TimeIntervals.plot(1);
    for ind = 1 : numel(h.background_TimeIntervals)
        h.bg_ti_patch{ind} = h.background_TimeIntervals{ind}.plot(ind+1);
    end
    
    yl = ylim(h.ax);
    
    h.t1 = TimePoint(NaN);
    h.t2 = TimePoint(NaN);
    h.ti = TimeInterval(h.t1,h.t2);
            
    % h.ax_cursor_line = line(h.ax,'xdata',[NaN NaN],'ydata',yl,'zdata',[100 100],'color',[1 0 0],'linewidth',3);
    h.ax_cursor_line = line([NaN NaN],yl);
    set(h.ax_cursor_line,'xdata',[NaN NaN],'ydata',yl,'zdata',[100 100],'color',[1 0 0],'linewidth',3);
    h.ax_cursor_patch = patch([NaN NaN NaN NaN NaN],[yl yl(2) yl(1) yl(1)],1);
    set(h.ax_cursor_patch,'xdata',[NaN NaN NaN NaN NaN],'ydata',[yl yl(2) yl(1) yl(1)],'zdata',[100 100 100 100 100],'facecolor','none','edgecolor',[1 0 0],'linewidth',3);
    
    h.ax_sel_line1 = line([NaN NaN],yl);
    h.ax_sel_line2 = line([NaN NaN],yl);
    h.ax_sel_line1 = set(h.ax_sel_line1,'xdata',[NaN NaN],'ydata',yl,'zdata',[100 100],'color',[0 0 1],'linewidth',3);
    h.ax_sel_line2 = set(h.ax_sel_line2,'xdata',[NaN NaN],'ydata',yl,'zdata',[100 100],'color',[0 1 0],'linewidth',3);
    h.ax_sel_patch = patch([NaN NaN NaN NaN NaN],[yl yl(2) yl(1) yl(1)],1);
    set(h.ax_sel_patch,'xdata',[NaN NaN NaN NaN NaN],'ydata',[yl yl(2) yl(1) yl(1)],'zdata',[100 100 100 100 100],'facecolor','none','edgecolor',[0 1 1]);
    
    set(h.TimeIntervalGui,'windowbuttonmotionfcn',@(o,e)mouse_over_ax(o,e));
    set(h.TimeIntervalGui,'windowbuttonupfcn',@(o,e)mouse_up_ax(o,e));
            
    h.sel1 = uicontrol(h.TimeIntervalGui,'Style','Text','Units','Normalized','String','','Fontsize',fs14,'fontname','courier','backgroundcolor',[0.8 0.8 1]);
    h.sel1.Position = [0.05 0.35 0.3 0.05];
                
    h.dur = uicontrol(h.TimeIntervalGui,'Style','Text','Units','Normalized','String','','Fontsize',fs14,'fontname','courier','backgroundcolor',[0.8 1 1]);
    h.dur.Position = [0.35 0.35 0.3 0.05];
    
    h.sel2 = uicontrol(h.TimeIntervalGui,'Style','Text','Units','Normalized','String','','Fontsize',fs14,'fontname','courier','backgroundcolor',[0.8 1 0.8]);
    h.sel2.Position = [0.65 0.35 0.3 0.05];
    
    tmp = {'yr','mon','d','hr','min','sec','ms'};
    for ind = 1 : 7
        h.incr1_txt(ind) = uicontrol(h.TimeIntervalGui,'Style','Text','Units','Normalized','String',tmp{ind},'Fontsize',fs14,'Fontname','courier');        
        h.incr1_txt(ind).Position = [0.05+(ind-1)*0.0429 0.45 0.042 0.05];
        h.incr1_button_plus(ind) = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','+','Fontsize',fs14,'Fontname','courier','callback',@(src,evt)change_ti(src,evt,1,'+',ind));
        h.incr1_button_plus(ind).Position = [0.05+(ind-1)*0.0429 0.4 0.042 0.05];
        h.incr1_button_minus(ind) = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','-','Fontsize',fs14,'Fontname','courier','callback',@(src,evt)change_ti(src,evt,1,'-',ind));
        h.incr1_button_minus(ind).Position = [0.05+(ind-1)*0.0429 0.3 0.042 0.05];
        
        h.incr2_txt(ind) = uicontrol(h.TimeIntervalGui,'Style','Text','Units','Normalized','String',tmp{ind},'Fontsize',fs14,'Fontname','courier');        
        h.incr2_txt(ind).Position = [0.65+(ind-1)*0.0429 0.45 0.042 0.05];
        h.incr2_button_plus(ind) = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','+','Fontsize',fs14,'Fontname','courier','callback',@(src,evt)change_ti(src,evt,2,'+',ind));
        h.incr2_button_plus(ind).Position = [0.65+(ind-1)*0.0429 0.4 0.042 0.05];
        h.incr2_button_minus(ind) = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','-','Fontsize',fs14,'Fontname','courier','callback',@(src,evt)change_ti(src,evt,2,'-',ind));
        h.incr2_button_minus(ind).Position = [0.65+(ind-1)*0.0429 0.3 0.042 0.05];        
    end
    
    h.ti_list = uicontrol(h.TimeIntervalGui,'Style','Text','Units','Normalized','String','','Fontsize',fs14,'fontname','courier','backgroundcolor',[0.8 0.8 0.8]);
    h.ti_list.Position = [0.05 0.03 0.7 0.23];
    
    h.button_add = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Add','Fontsize',fs14,'fontname','courier','callback',@(src,evt)change_interval(src,evt,'add'));
    h.button_add.Position = [0.35 0.4 0.075 0.1];
    
    h.button_remove = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Remove','Fontsize',fs14,'fontname','courier','callback',@(src,evt)change_interval(src,evt,'remove'));
    h.button_remove.Position = [0.35+0.075 0.4 0.075 0.1];
    
    h.button_keep = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Keep','Fontsize',fs14,'fontname','courier','callback',@(src,evt)change_interval(src,evt,'keep'));
    h.button_keep.Position = [0.35+2*0.075 0.4 0.075 0.1];    
    
    if ~h.multi_segment;
        set(h.button_add,'enable','off');
        set(h.button_remove,'enable','off');
    end
    
    h.button_select = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Select','Fontsize',fs14,'fontname','courier','callback',@(src,evt)change_interval(src,evt,'select'));
    h.button_select.Position = [0.35+3*0.075 0.4 0.075 0.1];    
    
    h.button_done = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Done','Fontsize',fs16,'fontname','courier','callback',@callback_done);    
    h.button_done.Position = [0.85 0.05 0.08 0.1];
        
    h.button_reset = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Reset','Fontsize',fs16,'fontname','courier','callback',@callback_reset);    
    h.button_reset.Position = [0.85 0.15 0.08 0.1];
            
    h.button_cancel = uicontrol(h.TimeIntervalGui,'Style','pushbutton','Units','Normalized','String','Cancel','Fontsize',fs16,'fontname','courier','callback',@callback_cancel);    
    h.button_cancel.Position = [0.77 0.05 0.08 0.1];
        
end

function h = update_ui_full(h)

    h = update_ui_sel(h);
    
    str = cell(1,numel(h.TimeIntervals));
    for ind = 1 : numel(h.TimeIntervals)
        str{ind} = h.TimeIntervals(ind).char;
    end
    set(h.ti_list,'String',str);
    
    prev_ax = gca;
    axes(h.ax);
    
    if ~isempty(h.ti_patch); delete(h.ti_patch); end
    h.ti_patch = h.TimeIntervals.plot(1);
    for ind = 1 : numel(h.background_TimeIntervals)
        h.bg_ti_patch{ind} = h.background_TimeIntervals{ind}.plot(ind+1);
    end
    set(gca,'ytick',1:numel(h.background_TimeIntervals)+1)
    namecell = [{'Selection'},h.background_names{:}];
    n = cellfun(@numel,namecell);
    namestr = repmat(' ',[numel(namecell),max(n)]);
    for ind = 1 : size(namestr,1)
        if n(ind) > 0
            namestr(ind,end-n(ind)+1:end) = namecell{ind};
        end
    end     
    set(gca,'yticklabel',namestr);     
    set(h.ti_patch,'facecolor',[0.2 0.2 0.2]);
    
    set(gca,'xticklabel',datestr(get(gca,'xtick'),31),'xticklabelrotation',45)
    
    axes(prev_ax);    
end

function callback_reset(src,evt)
    h = guidata(src);
    h.TimeIntervals = h.OrigTimeIntervals;
    h = update_ui_full(h);
    guidata(h.TimeIntervalGui,h);
end

function callback_cancel(src,evt)
    h = guidata(src);
    uiresume(h.TimeIntervalGui);
end

function callback_done(src,evt)
    h = guidata(src);
    h.OrigTimeIntervals = h.TimeIntervals;    
    guidata(h.TimeIntervalGui,h);
    uiresume(h.TimeIntervalGui);
end

function h = update_ui_sel(h)
    if isnan(h.t1)
        txt = '';
    else
        txt = h.t1.char;
    end
    set(h.sel1,'string',txt);
    
    if isnan(h.t2)
        txt = '';
    else
        txt = h.t2.char;
    end
    set(h.sel2,'string',txt);
    
    if isnan(h.t1) || isnan(h.t2)
        txt = '';
    else
        txt = h.ti.duration.char;
    end
    set(h.dur,'string',txt);
    set(gca,'xticklabel',datestr(get(gca,'xtick'),31),'xticklabelrotation',45)
    
end

function change_interval(src,evt,mode)
    
    h = guidata(src);
    if isnan(h.t1) || isnan(h.t2); return; end
    
    switch mode
        case 'keep'
            h.TimeIntervals = h.TimeIntervals.keep_interval(h.ti);
        case 'remove'
            h.TimeIntervals = h.TimeIntervals.exclude_interval(h.ti);
        case 'add'
            h.TimeIntervals = [h.TimeIntervals; h.ti];
        case 'select'
            h.TimeIntervals = h.ti;
    end
    h.TimeIntervals = h.TimeIntervals.cleanup;
    
    h = update_ui_full(h);
    
    guidata(h.TimeIntervalGui,h);
end

function change_ti(src,evt,which,pm,ind,incr)
    if nargin < 6; incr = 1; end
    h = guidata(src);

    switch which
        case 1
            old_t = h.t1;
        case 2
            old_t = h.t2;
    end
    
    t_incr = zeros(1,7);
    switch pm
        case '+'
            t_incr(ind) = incr;
        case '-'
            t_incr(ind) = -incr;
    end
    new_t = old_t + t_incr;
    
    
    switch which
        case 1
            h.t1 = new_t;
            set(h.ax_sel_line1,'xdata',[h.t1.mtime h.t1.mtime]);     
        case 2
            h.t2 = new_t;
            set(h.ax_sel_line2,'xdata',[h.t2.mtime h.t2.mtime]);
    end
    set(h.ax_sel_patch,'xdata',[h.t2.mtime h.t2.mtime h.t1.mtime h.t1.mtime h.t2.mtime]);
    h.ti = TimeInterval(h.t1,h.t2);    
    h = update_ui_sel(h);        
    
    guidata(h.TimeIntervalGui,h);
end

function mouse_over_ax(src, evt)
    h = guidata(src);
    C = get (h.ax, 'CurrentPoint');        
    xl = xlim(h.ax);
    yl = ylim(h.ax);
    xd = h.t1.mtime;
    if C(1,1) >= xl(1) && C(1,1) <= xl(2) && C(1,2) >= yl(1) && C(1,2) <= yl(2)        
        if isnan(xd)
            title(h.ax, datestr(C(1,1),31));
            set(h.ax_cursor_line,'xdata',[C(1,1) C(1,1)]);        
            set(h.ax_cursor_patch,'xdata',[NaN NaN NaN NaN NaN]);
        else            
            t1 = TimePoint(datevec(C(1,1)));
            t2 = TimePoint(datevec(xd(1)));            
            ti = TimeInterval(t1,t2);
            ti.cleanup;
            title(h.ax, ti.char);
            set(h.ax_cursor_line,'xdata',[NaN NaN]);
            set(h.ax_cursor_patch,'xdata',[C(1,1) C(1,1) xd xd C(1,1)]);
        end
    else
        title(h.ax,'');
        h.t1 = TimePoint(NaN);
        set(h.ax_cursor_line,'xdata',[NaN NaN]);
        set(h.ax_cursor_patch,'xdata',[NaN NaN NaN NaN NaN]);
    end
end


function mouse_up_ax(src, evt)
    h = guidata(src);
    C = get (h.ax, 'CurrentPoint');        
    xl = xlim(h.ax);
    yl = ylim(h.ax);    
    xd = h.t1.mtime;
    if C(1,1) >= xl(1) && C(1,1) <= xl(2) && C(1,2) >= yl(1) && C(1,2) <= yl(2)
        if isnan(xd)
            title(h.ax, datestr(C(1,1),31));
            set(h.ax_sel_line1,'xdata',[C(1,1) C(1,1)]);     
            h.t1 = TimePoint(datevec(C(1,1)));
            h.t2 = TimePoint(NaN);
        else
            set(h.ax_sel_patch,'xdata',[C(1,1) C(1,1) xd xd C(1,1)]);
            set(h.ax_sel_line2,'xdata',[C(2,1) C(2,1)]);     
            h.t2 = TimePoint(datevec(C(2,1)));
        end
    else
        title(h.ax,'');
        set(h.ax_sel_line1,'xdata',[NaN NaN]);         
        set(h.ax_sel_line2,'xdata',[NaN NaN]);
        set(h.ax_sel_patch,'xdata',[NaN NaN NaN NaN NaN]);
        h.t1 = TimePoint(NaN);
        h.t2 = TimePoint(NaN);
    end
    h.ti = TimeInterval(h.t1,h.t2);
    h = update_ui_sel(h);
    guidata(src,h);
end