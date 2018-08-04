function str = add_backspaces(str)    
    tmp = strfind(str,' ');         
    if isempty(tmp); return; end
    for ind = 1 : numel(tmp)        
        str = [str(1:tmp(ind)-1),'\',str(tmp(ind):end)];
        tmp(ind+1:end) = tmp(ind+1:end) + 1;
    end
end
        