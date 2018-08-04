function tf = read_edi(fn)
% tf = read_edi(fn)

    if nargin < 1; [fn, pn] = uigetfile('*.edi'); fn = fullfile(pn,fn); end
    
    if iscell(fn);
        if numel(fn) > 1;
            for ind = 1 : numel(fn);
                tf{ind} = read_edi(fn{ind});
            end
        end
        return;
    end
    
    fid = fopen(fn,'r');
    
    % ignore the stuff at the beginning
    donotcare = true;
    
    % and don't expect numbers
    n_expected = 0;
    
    mode = 'none';
    lat = 0;
    lon = 0;
    
    while ~feof(fid)
        
        line = strtrim(fgetl(fid));                
                
        if isempty(line)
            continue                  
        elseif strcmp(line(1),'L') % looking for lat long
            if numel(line)>5;
                if strcmp(line(1:4),'LAT=')
                   lat = line(5:end);
                elseif strcmp(line(1:5),'LONG=')
                   lon = line(6:end);
                end
            end
        elseif strcmp(line(1),'>'); % found command                        
            if strcmp(line(2),'!'); continue; end
            % if numbers expected, complain
            if n_expected ~= 0
               warning('numbers expected, command found!'); 
            end                
            
            % and here we stop
            if strcmp(line(2:4),'END');
                fclose(fid); clear fid;
                break;
            end
            
            % ignore short commands
            if numel(line)<5;
                continue;
            end                                    
            
            % from now on, it gets interesting
            if strcmp(line(2:5),'FREQ');
                donotcare = false;                
            end                                    
            
            % skip the rest for unimportant stuff
            if donotcare
                continue;
            end
            
            % that's what's coming! (type of numbers)
            sp = strfind(line,' ');
            if ~isempty(sp);
                mode = line(2:sp(1)-1);            
                mode(strfind(mode,'.')) = 'V';
            else
                continue
            end
                
            % how many numbers do we expect? read number after //
            str_pos = strfind(line,'//');
            n_expected = str2double(line(str_pos+2:end));                        
            
            % generate substruct
            tf.(mode) = zeros(1,n_expected);                            
            
        elseif n_expected > 0 && ~donotcare
            
            % get numbers
            numbers = sscanf(line,'%f');
            
            % put numbers in their place
            idx = numel(tf.(mode)) - n_expected + (1 : numel(numbers));
            s = struct('type','()','subs',{{idx}});
            tf.(mode) = subsasgn(tf.(mode), s, numbers);
            
            % reduce expectations
            n_expected = n_expected - numel(numbers);
                                    
            
        end
        
    end
    
    if exist('fid','var')
        fclose(fid);
    end
        
    
    % sort out lat lon
    lat(lat=='+') = [];    
    col = strfind(lat,':');
    if ~isempty(col);
        n1 = lat(1:col(1)-1);
        n2 = lat(1+col(1):col(2)-1);
        n3 = lat(1+col(2):end);
        tf.lat = eval(n1) + 1/60*eval(n2) + 1/3600*eval(n3);
    else
        tf.lat = eval(lat);
    end
    
    lon(lon=='+') = [];    
    col = strfind(lon,':');
    if ~isempty(col);
        n1 = lon(1:col(1)-1);
        n2 = lon(1+col(1):col(2)-1);
        n3 = lon(1+col(2):end);
        tf.lon = eval(n1) + 1/60*eval(n2) + 1/3600*eval(n3);
    else
        tf.lon = eval(lon);
    end
    
    