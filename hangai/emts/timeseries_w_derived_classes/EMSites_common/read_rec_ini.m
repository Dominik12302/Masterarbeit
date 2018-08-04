function out = read_rec_ini(fn)

    fid = fopen(fn);    
    
    ii = 0;
    fieldnames = cell(0);
    fieldvalues = cell(0);
    while ~feof(fid);
        l = fgetl(fid);
        
        if isempty(l);
             continue;
        end
        if strcmp(l(1),';');
            continue;
        end
        if strcmp(l(1),'[');
            continue;
        end
        if isempty(strfind(l,'='))
            continue;
        end

        ii = ii + 1;
        ei = strfind(l,'='); ei = ei(1);
        fieldnames{ii} = l(1:ei-1);
        fieldvalues{ii} = l(1+ei:end);
        if ~isnan(str2double(fieldvalues{ii}));
            fieldvalues{ii} = str2double(fieldvalues{ii});
        end        
    end
    fclose(fid);
    
    fieldmat = [fieldnames(:), fieldvalues(:)]';
    
    out = struct(fieldmat{:});