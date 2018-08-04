function [lat, lon] = read_gps_file(fn)

    % READ MTU GPS FILE

    fid = fopen(fn,'r');   
    % jump over first 2 lines
    fgetl(fid);
    fgetl(fid);
    l = fgetl(fid);
    fclose (fid);
    
    
    % find delimiters
    pl = strfind(l,'+');
    sc = strfind(l,';');
    
    lat = str2double([l(pl(1)+(1:2)),'.',l(pl(1)+3:pl(2)-1)]);
    lon = str2double([l(pl(2)+(1:3)),'.',l(pl(2)+4:sc(1)-1)]);
    
    