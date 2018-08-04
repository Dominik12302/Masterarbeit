function out2 = read_xtr(fn)

fid = fopen(fn,'r');
C = textscan(fid,'%s');
C = C{1};
fclose(fid);

ind = 0;
while ind < numel(C)
    ind = ind + 1;    
    if isequal(C{ind}(1),'[') && isequal(C{ind}(end),']')
        fieldname = C{ind}(2:end-1); 
        if ~isnan(str2double(fieldname(1))); 
            fieldname = ['c',fieldname]; 
        end
        out.(fieldname) = [];
    elseif isequal(C{ind}(1),'''') && isequal(C{ind}(end),'''') && isequal(C{ind}(end-1),'=')
        subfieldname = C{ind}(2:end-2);
        subfieldind = 0;
        n = 1;
        if isfield(out.(fieldname),subfieldname);
            n = size(out.(fieldname).(subfieldname),1) + 1;
        else            
            tmpcell = cell(0);
        end
    else                
        subfieldind = subfieldind + 1;
        % combine fields with spaces, which textscan has
        % misinterpreted as separate, so they'd throw an error (eg. "eval('xx)" )
        % for example '14/07/2015 14:42:24'
        string_ok = false;
        while ~string_ok; 
            try
                tmpcell{n,subfieldind} = eval(C{ind});
                string_ok = true;
            catch
                ind = ind + 1;
                C{ind} = [C{ind-1},' ',C{ind}];
            end
        end       
        out.(fieldname).(subfieldname) = tmpcell;
    end    
end

% assign information to relevant fields:

out2.srate = abs(out.FILE.NAME{4}).^sign(-out.FILE.NAME{4}); % e.g. -500 means 500 Hz, +500 is 500s

% add one sample to the stoptime get duration right:
% [t(sample1 is taken) t(last sample is taken) + 1 dt]
out.FILE.DATE{1} = out.FILE.DATE{1}- 1;
out.FILE.DATE{2} = out.FILE.DATE{2}+1e6-1e6*(floor(out2.srate/out2.srate)/out2.srate);%;seems to be independent of sampling rate ... out2.srate;
out.FILE.DATE{3} = out.FILE.DATE{3}- 1;
out.FILE.DATE{4} = out.FILE.DATE{4};%+1e6-1e6*(floor(out2.srate/out2.srate)/out2.srate);%;seems to be independent of sampling rate ... out2.srate;

out.FILE.DATE{4} = out.FILE.DATE{4};

while out.FILE.DATE{4} >= 1e6; 
    out.FILE.DATE{4} = out.FILE.DATE{4} - 1e6; 
    out.FILE.DATE{3} = out.FILE.DATE{3} + 1;
end


out2.Nsmp = round(( ( out.FILE.DATE{3} + 1e-6*out.FILE.DATE{4} ) ...
            - ( out.FILE.DATE{1} + 1e-6*out.FILE.DATE{2} ) ) * out2.srate);
        
% out.FILE.DATE{1} = out.FILE.DATE{1}-1/out2.srate;
% out.FILE.DATE{3} = out.FILE.DATE{3}-1/out2.srate;

[out2.start, out2.startms] = unixtime2MTtime(out.FILE.DATE{1},out.FILE.DATE{2});
[out2.stop, out2.stopms] = unixtime2MTtime(out.FILE.DATE{3},out.FILE.DATE{4});

out2.lat = str2double(out.SITE.COORDS{2});
out2.lon = str2double(out.SITE.COORDS{3});
out2.alt = str2double(out.SITE.COORDS{4});

out2.chnames = out.CHANNAME.NAME(:,2)';
out2.Nch = size(out.CHANNAME.NAME,1);

for ind = 1 : out2.Nch
    out2.tilt(ind) = 0;
    out2.orient(ind) = out.DATA.CHAN{ind,5};
    out2.dipole(ind) = 0;
    out2.sens_sn{ind} = '';
    out2.factor(ind) = out.DATA.CHAN{ind,7};
    switch out2.chnames{ind}(1)
        case 'B'
            if strcmpi(out2.chnames{ind},'Bz'); 
                out2.tilt(ind) = 90;                
            end
            tmp = num2str(out.DATA.CHAN{ind,4});
            switch tmp(1)
                case '7'
            out2.sens_sn{ind} = (tmp(2:end));
            out2.sens_name{ind} = 'MFS07 ';      
                case '6'
                    
            out2.sens_sn{ind} = (tmp(2:end));
            out2.sens_name{ind} = 'MFS06 '; 
            end
                    
        case 'E'            
            out2.dipole(ind) = out.DATA.CHAN{ind,4};            
            out2.sens_name{ind} = 'AgAgCl';
    end            
end
