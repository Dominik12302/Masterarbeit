function varargout = display(obj)
if nargout
    
    [p,survey,ext] = fileparts(obj.propath{1});
    str{1} = ([' - Survey details for survey ' survey ' (' obj.propath{1} '):']);
    for is = 1:numel(obj.datapath)
        if is == 1
            str{end+1} = sprintf('   Time series path:   %s',fullfile(obj.tspath{1},'<site>',obj.datapath{is}));
        else
            str{end+1} = sprintf('                       %s',fullfile(obj.tspath{1},'<site>',obj.datapath{is}));
        end
    end
    str{end+1} = sprintf('   Processed data:     %s',fullfile(obj.tspath{1},'<site>',obj.procpath{1}));
    str{end+1} = sprintf('   Spectra:            %s',fullfile(obj.fcpath{1},'<site>'));
    str{end+1} = sprintf('   Reference time:     %s',datestr(obj.reftime));
    str{end+1} = sprintf('   Number of stations: %d',numel(obj.sites));
    str{end+1} = sprintf('   Station names:      ');
    Ns = numel(obj.sites);
    if Ns > 0
        Nlines = floor(Ns/10);
        rest = Ns-Nlines*10;
        id = 0;
        for il = 1:Nlines
            for is = 1:10
                id = id+1;
                str{end} = [str{end} sprintf('%s | ',obj.sites{id})];
            end
%             if rest > 0
%                 str{end+1} = sprintf('\b\b\n\t\t\t\t\t\t ');
%             else
%                 str{end+1} = sprintf('\b\b\n');
%             end
        end
        for is = 1:rest
            id = id+1;
            str{end} = [str{end} sprintf('%s | ',obj.sites{id})];
        end
        %if rest > 0, fprintf('\b\b\b\n'); end
        
        if ~isempty(obj.lsname),
            if ~isempty(obj.lsrates)
            str{end+1} = sprintf('\n>> Local site:         %s',obj.lsname{1});
            tmp = sort(unique(obj.lsrates),'Descend');
            for israte = 1:numel(tmp)
                obj.lsrate = tmp(israte);
                localsite = obj.localsite;
                for is = 1:numel(localsite)
                    str = [str display(localsite{is})];
                end
            end
            else
                str{end+1} = [sprintf(' - Local site:\t\t\t %s',obj.lsname{1}) ' has no data! Please check ...'];
            end   
        end
    end
    varargout = {str};
else
    [p,survey,ext] = fileparts(obj.propath{1});
    disp([' + Survey details for survey ' survey ' (' obj.propath{1} '):']);
    fprintf(1,'   Time series path:');
    for is = 1:numel(obj.datapath)
        if is == 1
            fprintf(1,'\t %s\n',fullfile(obj.tspath{1},'<site>',obj.datapath{is}));
        else
            fprintf(1,'                    \t %s\n',fullfile(obj.tspath{1},'<site>',obj.datapath{is}));
        end
    end
    fprintf(1,'   Processed data:\t\t %s\n',fullfile(obj.tspath{1},'<site>',obj.procpath{1}));
    fprintf(1,'   Spectra:\t\t\t\t %s\n',fullfile(obj.fcpath{1},'<site>'));
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