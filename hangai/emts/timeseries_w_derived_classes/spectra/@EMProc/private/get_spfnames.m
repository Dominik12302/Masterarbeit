function spfiles = get_spfnames(obj,sname)
spfiles = [];
for id = 1:numel(obj.datapath)
    p0 = fileparts(fullfile(obj.propath{1},sname,obj.fcpath{1},obj.datapath{id},'.\'));
    if isdir(p0)
        if ~isempty(dir(fullfile(p,'*.afc')))
            tmp = dir(fullfile(p,'*.afc'));
            for iafc = 1:numel(tmp)
                spfiles = [spfiles {fullfile(p0,tmp.name)}];
            end
        end
    else
        lsdirs = dir(p0);
        for is = 1:numel(lsdirs)
            p = fullfile(fileparts(fileparts(...
                fullfile(obj.propath{1},sname,obj.fcpath{1},obj.datapath{id},'.\'))), ...
                lsdirs(is).name);
            if isdir(p)
                if ~isempty(dir(fullfile(p,'*.afc')))
                    tmp = dir(fullfile(p,'*.afc'));
                    for iafc = 1:numel(tmp)
                        spfiles = [spfiles {fullfile(p,tmp.name)}];
                    end
                end
            end
        end
    end
end
end