function cell_out = remove_info(cell_in, varargin)
% use for removing property value pairs in/to a sth like varargin
% example: 
% varargin_new = remove_info(varargin,'param1name','param2name',...)
%
% if the property is not found, nothing happens
% it is assumed to that paramvalue immediately follows
% 'paramname' in varargin
% JK
               
        
    keep = true(size(cell_in));
    for ind = 1 : length(varargin)
        [doesit, where] = cell_contains(cell_in, varargin{ind});        
        if doesit
            keep(where:where+1) = false;
        end
    end
    cell_out = cell_in(keep);