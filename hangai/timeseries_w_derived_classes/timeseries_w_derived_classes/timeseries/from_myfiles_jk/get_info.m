function varargout = get_info(cell_in, varargin)
% use for extracting input arguments from a cell like varargin
% example: 
% [param1, param2...] = get_info(varargin,'param1name',defaultparam1value,
%           'param2name',defaultparam2value,...)
%
% if the parameter is not found, the defaultvalue is given. 
% it is assumed to that paramvalue immediately follows
% 'paramname' in varargin
% multiple keywords given using {'param1name','alternateparam1name'}.
% in any case, multiple finds return the first valid alternative found
%JK

    if mod(length(varargin),2); 
        disp('give property and default value in pairs'); 
        return
    end
    
    props = varargin(1:2:end);
    defaults = varargin(2:2:end);
    
    for ind = length(props) : - 1: 1
        if iscell(props{ind})
            for ind2 = numel(props{ind}) : -1 : 1
                [doesit, where] = cell_contains(cell_in,props{ind}{ind2});
            end
        else
            [doesit, where] = cell_contains(cell_in,props{ind});
        end
        if doesit
            varargout{ind} = cell_in{where+1};
        else
            varargout{ind} = defaults{ind};
        end
    end