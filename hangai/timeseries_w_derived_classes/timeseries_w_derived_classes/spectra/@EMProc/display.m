function varargout = display(obj)
if nargout
    %     str{1} = [' + Station details for site ' obj.name ' - run ' obj.run ':'];
    %     str{2} = sprintf('   System:\t\t\t\t %s %s\n',obj.system, obj.systemSN);
    %     str{3} = sprintf('   Latitude:\t\t\t %.6f °\n',obj.lat);
    %     str{4} = sprintf('   Longitude:\t\t\t %.6f °\n',obj.lon);
    %     str{5} = sprintf('   Sampling rate \t\t %d Hz\n',obj.srate);
    %     str{6} = sprintf('   Start or recording: \t %s',obj.starttimestr);
    %     str{7} = sprintf(' + %08.4f ms (1st sample)\n',obj.starttimems);
    %     str{8} = sprintf('   Stop or recording: \t %s',obj.stoptimestr);
    %     str{9} = sprintf(' + %08.4f ms (last sample)\n',obj.stoptimems);
    %     if obj.ppsdelay > 0
    %     str{10} = sprintf('   PPS Delay: \t\t\t %.2f us\n',obj.ppsdelay*1000000);
    %     end
    %     for ich = 1:obj.Nch
    %         if strcmp(obj.chnames{ich},'E')
    %             str{10+ich} = sprintf('   Channel %d, %s dipole %.1f (m)',ich,obj.chanmes{ich},obj.dipole(ich));
    %         elseif strcmp(obj.chnames{ich},'B')
    %             str{10+ich} = sprintf('   Channel %d, %s mag. %.sf (m)',ich,obj.chanmes{ich},obj.dipole(ich));
    %         end
    %     end
    str = '';
    varargout = {str};
else
    [p,survey,ext] = fileparts(obj.propath{1});
    disp([' + Survey details for survey ' survey ' (' obj.propath{1} '):']);
    fprintf(1,'   Spectra path:');
    for is = 1:numel(obj.datapath)
        if is == 1
            fprintf(1,'\t\t %s\n',fullfile('<site>',obj.fcpath{1},obj.datapath{is}));
        else
            fprintf(1,'                    \t %s\n',fullfile('<site>',obj.fcpath{1},obj.datapath{is}));
        end
    end
    fprintf(1,'   Reference time:\t\t %s\n',datestr(obj.reftime));
    fprintf(1,'   Number of stations:\t %d\n',numel(obj.sites));
    fprintf(1,'   Station names:\t\t ');
    Ns = numel(obj.sites);
    if Ns > 0
        Nlines = floor(Ns/10);
        rest = Ns-Nlines*10;
        id = 0;
        for il = 1:Nlines
            for is = 1:10
                id = id+1;
                fprintf(1,'%s | ',obj.sites{id});
            end
            if rest > 0
                fprintf(1,'\b\b\n\t\t\t\t\t\t ');
            else
                fprintf(1,'\b\b\n');
            end
        end
        for is = 1:rest
            id = id+1;
            fprintf(1,'%s | ',obj.sites{id});
        end
        if rest > 0, fprintf(1,'\b\b\b\n'); end
        
        if ~isempty(obj.lsname),
            fprintf(1,' - Local site:\t\t\t %s\n',obj.lsname{1});
            localsite = obj.localsite;
            for is = 1:numel(localsite)
                display(localsite{is});
            end
        end
    end
end