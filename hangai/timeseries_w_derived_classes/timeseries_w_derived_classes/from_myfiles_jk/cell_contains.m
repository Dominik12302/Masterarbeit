function [tf, which] = cell_contains(cellin,stringin,mode,n)
    % tf = cell_contains(compare_cell,to_this)
    % tf = cell_contains(to_this,compare_cell)
    % [tf, which] = cell_contains(...)
    % 
    % if any cell is equal to_this (numeric or string)
    % return true
    % otherwise return false
    % 
    % which: index of first occurence.
    %
    % 120512 simplified, now using isequal, instead of char by char
    % comparison, can thus be used for (probably) anything
    %
    % tf = cell_contains(compare_cell,to_this, mode, n)
    %
    % mode can be 'first' or 'last', and n is the number.
    % default is 'first', 1
    %
    % similiar to find(...)
    %
    % no capitalization checking for strings! ( {'AaA'} contains 'aAa' );
    %
    % JK

    if ~iscell(cellin) && iscell(stringin)
        tmps = stringin; clear stringin
        tmpc = cellin; clear cellin
        stringin = tmpc;
        cellin = tmps;
    end
    
    if ~iscell(cellin)
            tmp = cellin; clear cellin;
            cellin = {tmp};        
    end
    

    tf = false;
    which = [];
    for ind = 1 : numel(cellin)
        if length(cellin{ind}) == length(stringin)
            if ischar(cellin{ind}) && ischar(stringin)
                if strcmpi(cellin{ind},stringin); % no capitalization checking for strings
                    tf = true;
                    which = [which ind];             
                end
            else                            
                if isequal(cellin{ind},stringin);
                    tf = true;
                    which = [which ind];             
                end
            end
        end
    end
    
    if nargin < 4; n = 1; end
    if nargin < 3; mode = 'first'; end
    
    if length(which) > n;
        switch mode
            case 'first'            
                which = which(1:n);
            case 'last'
                which = which(end-n+1:end);
        end
    end
    
    
% old code: 120512    
%     tf = false;
%     which = [];
%     for ind = 1 : numel(cellin)
%         if isnumeric(stringin) && isnumeric(cellin{ind})
%             if length(cellin{ind}) == length(stringin)
%                 for ind2 = 1:length(cellin{ind})
%                     if cellin{ind}(ind2) == stringin(ind2);
%                         tf = true;
%                         which = ind;
%                         if ind2==length(cellin{ind})
%                             return                        
%                         end          
%                     else
%                         tf = false;
%                         which = [];
%                     end
%                 end                                 
%             end
%     
%     tf = false;
%     which = [];
%     for ind = 1 : numel(cellin)
%         if isnumeric(stringin) && isnumeric(cellin{ind})
%             if length(cellin{ind}) == length(stringin)
%                 for ind2 = 1:length(cellin{ind})
%                     if cellin{ind}(ind2) == stringin(ind2);
%                         tf = true;
%                         which = ind;
%                         if ind2==length(cellin{ind})
%                             return                        
%                         end          
%                     else
%                         tf = false;
%                         which = [];
%                     end
%                 end
%             end
%         elseif ischar(stringin) && (ischar(cellin{ind}))
%             if size(cellin{ind},1) == size(stringin,1)
%                 for ind2 = 1:size(cellin{ind},1)
%                     if strcmp(cellin{ind}(ind2,:),stringin(ind2,:));
%                         tf = true;
%                         which = ind;
%                         if ind2==size(cellin{ind},1)
%                             return                        
%                         end        
%                     else
%                         tf = false;
%                         which = [];
%                     end                
%                 end
%             end
%         end
%     end