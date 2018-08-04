function cell_out = replace_info(cell_in, varargin)
% use for changing and adding property value pairs in/to a sth like varargin
% example: 
% varargin_new = replace_info(varargin,'param1name',newparam1value,
%           'param2name',newparam2value,...)
%
% if the property is not found, it is added at the end.
% it is assumed to that paramvalue immediately follows
% 'paramname' in varargin


    if mod(length(varargin),2); 
        disp('give property and value in pairs'); 
        return
    end
            
    props = varargin(1:2:end);
    value = varargin(2:2:end);
    
    cell_out = cell_in;
    for ind = 1 : length(props);
        [doesit, where] = cell_contains(cell_in, props{ind});
        if doesit
            cell_out{where+1} = value{ind};
        else
            cell_out{end+1} = props{ind};
            cell_out{end+1} = value{ind};
        end
    end