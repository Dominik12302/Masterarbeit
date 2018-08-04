function obj = proc_import(obj,sites)
for is = 1:numel(sites)
    site = sites{is};
    % obj.sites(is) = sites(is); % is now a dependent property! JK
    % check directory for ede or adu runs
    id = 0;
    for ip = 1:numel(obj.datapath)
        fcpath = fullfile(obj.propath{1},site,obj.fcpath{1},obj.datapath{ip});
        [runs]  = dir(fcpath);
        for ir = 1:numel(runs)
            if runs(ir).isdir
                % search for *.afc files
                ind  = strfind(fcpath,filesep);
                runpath = fullfile(fcpath(1:ind(end)),runs(ir).name);
                if ~isempty(dir(fullfile(runpath,'*.afc'))) % is afc dir
                    tmp = dir(fullfile(runpath,'*.afc'));
                    for iafc = 1:numel(tmp)
                        id = id+1;
                        sp = EMSpectra;
                        sp.debuglevel = obj.debuglevel;
                        sp.bandsetup  = obj.bandsetup;
                        sp.output     = obj.output;
                        sp.input      = obj.input;
                        obj.site{is}{id} = EMSpectra(sp,fullfile(runpath,tmp(iafc).name));
                        obj.reftime   = obj.site{is}{id}.reftime; % here need to check if this is alwas the same reftime
                    end
                end                
            end
        end
    end
end