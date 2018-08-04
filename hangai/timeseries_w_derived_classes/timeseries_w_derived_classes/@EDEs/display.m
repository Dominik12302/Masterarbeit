function varargout = display(obj)
if nargout
    str{1} = [' - Station details for site ' obj.name ' - run ' obj.run ':'];
    str{2} = sprintf( '   System:             %s %s',obj.system, obj.systemSN);
    str{3} = sprintf( '   Latitude:           %.6f deg',obj.lat);
    str{4} = sprintf( '   Longitude:          %.6f deg',obj.lon);
    str{5} = sprintf( '   Sampling rate:      %d Hz',obj.srate);
    str{6} = [sprintf('   Start or recording: %s',obj.starttimestr) sprintf(' + %08.4f ms (1st sample)',obj.starttimems)];
    str{7} = [sprintf('   Stop or recording:  %s',obj.stoptimestr) sprintf(' + %08.4f ms (last sample)',obj.stoptimems)];
    if obj.ppsdelay > 0 
    str{end+1} = sprintf('   PPS Delay:          %.2f us',obj.ppsdelay*1000000);
    end
    for ich = 1:obj.Nch
        if strfind(obj.chnames{ich},'E')
            str{end+1} = sprintf('   Channel %d:          %s dipole %.1f (m)',ich,obj.chnames{ich},obj.dipole(ich));
        elseif strfind(obj.chnames{ich},'B')
            str{end+1} = sprintf('   Channel %d:          %s %s mag. #%d',ich,obj.chnames{ich},obj.sens_name{ich},obj.sens_sn{ich});
        end
    end
    varargout = {str};
else
    disp([' + Station details for site ' obj.name ' - run ' obj.run ':']);
    fprintf(1,'   System:\t\t\t\t %s %s\n',obj.system, obj.systemSN);
    fprintf(1,'   Latitude:\t\t\t %.6f?\n',obj.lat);
    fprintf(1,'   Longitude:\t\t\t %.6f?\n',obj.lon);
    fprintf(1,'   Sampling rate \t\t %d Hz\n',obj.srate);
    fprintf(1,'   Start or recording: \t %s',obj.starttimestr);
    fprintf(1,' + %08.4f ms (1st sample)\n',obj.starttimems);
    fprintf(1,'   Stop or recording: \t %s',obj.stoptimestr);
    fprintf(1,' + %08.4f ms (last sample)\n',obj.stoptimems);
    if obj.ppsdelay > 0 
    fprintf(1,'   PPS Delay: \t\t\t %.2f us\n',obj.ppsdelay*1000000);
    end
    for ich = 1:obj.Nch
        if strfind(obj.chnames{ich},'E')
            fprintf(1,'   Channel %d:\t\t\t %s dipole %.1f (m)\n',ich,obj.chnames{ich},obj.dipole(ich));
        elseif strfind(obj.chnames{ich},'B')
            fprintf(1,'   Channel %d:          %s %s mag. #%d\n',ich,obj.chnames{ich},obj.sens_name{ich},obj.sens_sn{ich});
        end
    end
    
end