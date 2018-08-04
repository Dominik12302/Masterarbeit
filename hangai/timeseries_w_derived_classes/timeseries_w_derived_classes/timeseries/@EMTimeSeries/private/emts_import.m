function [obj] = emts_import(obj,sites)
nobj = EMTimeSeries(obj.reftime,obj.propath);
for is = 1:numel(sites)
    site = sites{is};
    
    % JK 20160112
    % no longer required as obj.sites is now a dependent property:
    % nobj.sites(is) = sites(is);
    
    % check directory for ede, adu. spam4 or mtu runs
    id = 0;
    for ip = 1:numel(obj.datapath)
        tspath = fullfile(obj.propath{1},site,obj.tspath{1},obj.datapath{ip});
        [runs]  = dir(tspath);
        % remove . and .. directories
        rem = false(size(runs));
        for ind = 1 : numel(runs) 
            if isequal(runs(ind).name,'.') || isequal(runs(ind).name,'..')
                rem(ind) = true;
            end
        end
        runs(rem) = [];
        for ir = 1:numel(runs)
           if runs(ir).isdir
               % search for *.ats files
               ind  = strfind(tspath,filesep);
               runpath = fullfile(tspath(1:ind(end)),runs(ir).name);
               if ~isempty(dir(fullfile(runpath,'*.ats'))) % is ats dir
                   id = id+1;
                   adu              = ADUs;
                   adu.name         = site;
                   adu.run          = num2str(ir,'%03d');
                   adu.debuglevel   = obj.debuglevel;
                   adu.reftime      = obj.reftime;
                   nobj.site{is}{id} = ADUs(adu,runpath);
                   if ~isempty(obj.premult)
                       disp(' - Adding premult factors to ADU channels.');
                       nobj.site{is}{id}.premult = obj.premult;
                   end
                   if ~isempty(obj.chorder)
                       if numel(obj.chorder) == nobj.site{is}{id}.Nch
                           disp(' - Changing channel order of ADU channels.');
                           nobj.site{is}{id}.chnames = nobj.site{is}{id}.chnames(obj.chorder);
                           nobj.site{is}{id}.dipole = nobj.site{is}{id}.dipole(obj.chorder);
                           nobj.site{is}{id}.orient = nobj.site{is}{id}.orient(obj.chorder);
                           nobj.site{is}{id}.tilt = nobj.site{is}{id}.tilt(obj.chorder);
                           nobj.site{is}{id}.sens_sn = nobj.site{is}{id}.sens_sn(obj.chorder);
                           nobj.site{is}{id}.sens_name = nobj.site{is}{id}.sens_name(obj.chorder);
                           nobj.site{is}{id}.lsb = nobj.site{is}{id}.lsb(obj.chorder);
                       else
                           disp(' - Warning: tried to change ADU channel order, but #No of channels does not match');
                       end
                   end
               end
               if ~isempty(dir(fullfile(runpath,'*.mtd'))) % is ede dir.
                   id = id+1;
                   ede              = EDEs;
                   ede.name         = site;
                   ede.run          = num2str(ir,'%03d');
                   ede.debuglevel   = obj.debuglevel;
                   ede.reftime      = obj.reftime;
                   nobj.site{is}{id} = EDEs(ede,runpath);
                   if ~isempty(obj.premult)
                       disp(' - Adding premult factors to EDE channels.');
                       nobj.site{is}{id}.premult = obj.premult;
                   end
                   if ~isempty(obj.chorder)
                       if numel(obj.chorder) == nobj.site{is}{id}.Nch
                           disp(' - Changing channel order of EDE channels.');
                           nobj.site{is}{id}.chnames = nobj.site{is}{id}.chnames(obj.chorder);
                           nobj.site{is}{id}.dipole = nobj.site{is}{id}.dipole(obj.chorder);
%                            nobj.site{is}{id}.lsb = nobj.site{is}{id}.lsb(obj.chorder);
                       else
                           disp(' - Warning: tried to change EDE channel order, but #No of channels does not match');
                       end
                   end
               end
               if (~isempty(dir(fullfile(runpath,'*.raw'))) || ~isempty(dir(fullfile(runpath,'*.RAW'))))% is spam4 dir.
                   id               = id+1;
                   spam              = SPAM4s;
                   spam.name         = site;
                   spam.run          = num2str(ir,'%03d');
                   spam.debuglevel   = obj.debuglevel;
                   spam.reftime      = obj.reftime;
                   nobj.site{is}{id} = SPAM4s(spam,runpath);
                   if ~isempty(obj.premult)
                       disp(' - Adding premult factors to SPAM4 channels.');
                       nobj.site{is}{id}.premult = obj.premult;
                   end
                   if ~isempty(obj.chorder)
                       if numel(obj.chorder) == nobj.site{is}{id}.Nch
                           disp(' - Changing channel order of SPAM4 channels.');
                           nobj.site{is}{id}.chnames = nobj.site{is}{id}.chnames(obj.chorder);
                           nobj.site{is}{id}.dipole = nobj.site{is}{id}.dipole(obj.chorder);
                           nobj.site{is}{id}.orient = nobj.site{is}{id}.orient(obj.chorder);
                           nobj.site{is}{id}.tilt = nobj.site{is}{id}.tilt(obj.chorder);
                           nobj.site{is}{id}.sens_sn = nobj.site{is}{id}.sens_sn(obj.chorder);
                           nobj.site{is}{id}.sens_name = nobj.site{is}{id}.sens_name(obj.chorder);
                           nobj.site{is}{id}.lsb = nobj.site{is}{id}.lsb(obj.chorder);
                       else
                           disp(' - Warning: tried to change SPAM4 channel order, but #No of channels does not match');
                       end
                   end
               end
               if (~isempty(dir(fullfile(runpath,'*.inf'))) || ~isempty(scandir(runpath,'*.mseed')))% is mtu2000 dir.
                   id               = id+1;
                   mtu              = MTUs;
                   mtu.name         = site;
                   mtu.run          = num2str(ir,'%03d');
                   mtu.debuglevel   = obj.debuglevel;
                   mtu.reftime      = obj.reftime;
                   nobj.site{is}{id} = MTUs(mtu,runpath);
                   if ~isempty(obj.premult)
                       disp(' - Adding premult factors to MTU channels.');
                       nobj.site{is}{id}.premult = obj.premult;
                   end
                   if ~isempty(obj.chorder)
                       if numel(obj.chorder) == nobj.site{is}{id}.Nch
                           disp(' - Changing channel order of SPAM4 channels.');
                           nobj.site{is}{id}.chnames = nobj.site{is}{id}.chnames(obj.chorder);
                           nobj.site{is}{id}.dipole = nobj.site{is}{id}.dipole(obj.chorder);
                           nobj.site{is}{id}.orient = nobj.site{is}{id}.orient(obj.chorder);
                           nobj.site{is}{id}.tilt = nobj.site{is}{id}.tilt(obj.chorder);
                           nobj.site{is}{id}.sens_sn = nobj.site{is}{id}.sens_sn(obj.chorder);
                           nobj.site{is}{id}.sens_name = nobj.site{is}{id}.sens_name(obj.chorder);
                           nobj.site{is}{id}.lsb = nobj.site{is}{id}.lsb(obj.chorder);
                       else
                           disp(' - Warning: tried to change MTU channel order, but #No of channels does not match');
                       end
                   end
               end
           end
        end
    end
end
% clean empty sites
keep = []; del = [];
if ~isempty(nobj.site)
for is = 1:numel(nobj.sites)
    if ~isempty(nobj.site{is})
        keep = [keep is];
    else
        del = [del is];
    end
end
if  ~isempty(del), msgbox([{'Found no data for station(s):'} nobj.sites(del)],'Warning:','warn'); end
nobj.site  = nobj.site(keep);
% JK 20160112
% no longer required, see above
% nobj.sites = nobj.sites(keep);

% % merge with existing sites;
oldsites = obj.sites;
newsites = nobj.sites;

if isempty(obj.site)
    obj = nobj;
else
    for is = 1:numel(sites)    
        if any(strcmp(oldsites,newsites{is}))
            obj.site(find(strcmp(oldsites,newsites{is})))=nobj.site(is);
        else
            obj.site(end+1) = nobj.site(is);  
            
            % JK 20160112
            % obj.sites(end+1) = nobj.sites(is);
        end
    end
    [a,ind] = sort(obj.sites);
    
    % JK 20160112
    % obj.sites = obj.sites(ind);
    
    obj.site = obj.site(ind);
end
else
msgbox([{'Found no data for station(s):'} nobj.sites],'Warning:','warn'); 
end

% obj.sites(is) = sites(is);
% obj.site) = site;