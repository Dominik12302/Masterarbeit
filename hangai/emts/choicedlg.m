function varargout = choicedlg(choices,varargin)

% [choice, choice_idx] = choicedlg({'choice 1','choice 2', 'choice 3', ...},
%                 'default',default_choice, 'title',title_string);
%
% opens a dialogbox that awaits that the user chooses one of the choices
% given in the cell "choices". If the box is closed by the 'x',
% the default choice will be returned, which if not otherwise specified, is
% is empty.
%
% The 'title' argument allows to specify a line to prompt the user.
%
% JK2017

    global fs13 fs14 fs16
    fs13 = 13; fs14 = 14; fs16 = 16;
    if ~ismac, fs13 = fs13/(96/72); fs14 = fs14/(96/72); fs16 = fs16/(96/72); end    
    h.choice_gui = figure('units','normalized','position',[0.35 0.4 0.3 0.2],'MenuBar','None','Toolbar','none','name','selection dialogue');
    h.title_string = get_info(varargin,'title','Make a choice!');
    if nargin < 1
        h.choices = {'A','B','C'};
    else
        h.choices = choices;
    end
    h.N = numel(h.choices);
    h.default_choice = get_info(varargin,'default',[]);
    h.current_choice = h.default_choice;    
    varargout{2} = h.default_choice; 
    if ~isempty(h.default_choice)
        varargout{1} = h.choices{h.default_choice};
    else
        varargout{1} = [];
    end
    
    h = init(h);        
    guidata(h.choice_gui,h);        
    uiwait(h.choice_gui);
        
    try
        h = guidata(h.choice_gui);
        varargout{2} = h.current_choice;
        if ~isempty(h.current_choice)
            varargout{1} = h.choices{h.current_choice};
        else
            varargout{1} = [];
        end
        delete(h.choice_gui);
    end
    
end


function h = init(h)
    global fs13 fs14 fs16

    h.title_text = uicontrol(h.choice_gui,'Style','Text','String',h.title_string,'Units','normalized',...
        'Fontsize',fs16,'Fontweight','bold','HorizontalAlignment','center');
    h.title_text.Position = [0.25 0.8 0.5 0.1]; 
    H.button = cell(1,h.N);
    for ind = 1 : h.N        
        h.button{ind} = uicontrol(h.choice_gui,'Style','Pushbutton','String',h.choices{ind},'Value',1,'Units','normalized',...
        'Fontsize',fs16,'Backgroundcolor',[0.7 0.7 0.7],'Fontweight','bold','Callback',@(h,e)choice_callback(h,e,ind));
        h.button{ind}.Position = [0.1 + 0.8/h.N*(ind-1) 0.2 0.8/h.N 0.4];        
    end
end

function choice_callback(src, evt, choice)
    handles = guidata(src);
    handles.current_choice = choice;
    guidata(handles.choice_gui,handles);
    uiresume(handles.choice_gui);
end