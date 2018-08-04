function out = read_inf(filename)

    fid = fopen(filename,'r');
    out = struct;
    while ~feof(fid)
        str = fgetl(fid);
        if isempty(str); continue; end
        if strcmp(str(1),'>');
            fieldname = str(2:17);
            while strcmp(fieldname(end),' ')
                fieldname(end) = [];
            end
            if numel(str) > 18
                out.(fieldname) = str(19:end);
                if ~isnan(str2double(out.(fieldname)));
                    out.(fieldname) = str2double(out.(fieldname));                
                end
            else
                out.(fieldname) = [];
            end
        end
        
    end
    
    fclose(fid);