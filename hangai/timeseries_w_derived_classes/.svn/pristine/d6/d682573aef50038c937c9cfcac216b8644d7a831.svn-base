function varargout = disp(obj)
if nargout
%     str{1} = [' + Station details for site ' obj.name ' - run ' obj.run ':'];
%     str{2} = sprintf('   System:\t\t\t\t %s %s\n',obj.system, obj.systemSN);
%     str{3} = sprintf('   Latitude:\t\t\t %.6f �\n',obj.lat);
%     str{4} = sprintf('   Longitude:\t\t\t %.6f �\n',obj.lon);
%     str{5} = sprintf('   Sampling rate \t\t %d Hz\n',obj.srate);
%     str{6} = sprintf('   Start or recording: \t %s',obj.starttimestr);
%     str{7} = sprintf(' + %08.4f ms (1st sample)\n',obj.starttimems);
%     str{8} = sprintf('   Stop or recording: \t %s',obj.stoptimestr);
%     str{9} = sprintf(' + %08.4f ms (last sample)\n',obj.stoptimems);
%     for ich = 1:obj.Nch
%         if strcmp(obj.chnames{ich},'E')
%             str{10+ich} = sprintf('   Channel %d, %s dipole %.1f (m)',ich,obj.chanmes{ich},obj.dipole(ich));
%         elseif strcmp(obj.chnames{ich},'B')
%             str{10+ich} = sprintf('   Channel %d, %s mag. %.sf (m)',ich,obj.chanmes{ich},obj.dipole(ich));
%         end
%     end
    str = {''};
    varargout = {str};
else
    disp([' + Station details for site ' obj.name ' - run ' obj.run ':']);
    fprintf(1,'   Latitude:\t\t\t %.6f�\n',obj.lat);
    fprintf(1,'   Longitude:\t\t\t %.6f�\n',obj.lon);
    fprintf(1,'   Sampling rate:\t\t %d Hz\n',obj.srate);
    fprintf(1,'   First | last window:  %s | %s\n',datestr(obj.utc(1),0),datestr(obj.utc(end),0));
    fprintf(1,'   Reference time: \t\t %s\n',datestr(obj.reftime,0));
    
    fprintf(1,'   %d channels: \t\t\t ',obj.Nch);
    for ich = 1:obj.Nch
        fprintf(1,'%s, ',obj.chnames{ich});
        
    end
    fprintf(1,'\b\b\n');
    fprintf(1,'   %d decimation levels:\t ',obj.Ndec);
    for idec = 1:obj.Ndec
        if obj.sratedec(idec) > 1
            fprintf(1,'%d Hz | ',obj.sratedec(idec));
        else
            fprintf(1,'%d sec | ',1/obj.sratedec(idec));
        end
    end
    fprintf(1,'\b\b\b\n');
    
end