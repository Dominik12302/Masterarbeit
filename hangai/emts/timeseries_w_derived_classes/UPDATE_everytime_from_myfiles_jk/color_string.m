function str_out = color_string(str_in,color)
% str_out = color_string(str_in,color)
% returns an html colored string or a cell of them

    if iscell(str_in)        
        str_out = cell(size(str_in));
        for ind = 1 : length(str_in)
            if iscell(color);
                str_out{ind} = color_string(str_in{ind},color{ind});
            else
                str_out{ind} = color_string(str_in{ind},color(ind,:));
            end
        end
    else        
        hex = rgbconv(color);
        str_out = ['<HTML><FONT COLOR="#',hex,'">',str_in,'</FONT></HTML>'];
    end