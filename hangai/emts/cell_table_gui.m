function cell_out = cell_table_gui(cell_in,varargin)

    global fs13 fs14 fs16
    fs13 = 13; fs14 = 14; fs16 = 16;
    if ~ismac, fs13 = fs13/(96/72); fs14 = fs14/(96/72); fs16 = fs16/(96/72); end    
    h.cell_gui = figure('units','normalized','position',[0.35 0.4 0.3 0.2],'MenuBar','None','Toolbar','none','name','');

    h.N = size(cell_in,1);
    h.M = size(cell_in,2);
    
    h.cell_in = cell_in;    
    h.cell_current = cell_in;
    cell_out = cell_in;
    
    [h.title_string, h.block_col, h.block_row] = get_info(varargin,'title','Modify table','block_col',[],'block_row',[]);    
    
    h = init(h);
    guidata(h.cell_gui,h);
    uiwait(h.cell_gui)
    
    try
        h = guidata(h.cell_gui);
        cell_out = h.cell_current;        
        delete(h.cell_gui);
    end
end


function h = init(h)
    global fs13 fs14 fs16

    h.title_text = uicontrol(h.cell_gui,'Style','Text','String',h.title_string,'Units','normalized',...
        'Fontsize',fs16,'Fontweight','bold','HorizontalAlignment','center');
    h.title_text.Position = [0.25 0.8 0.5 0.1]; 
    
end