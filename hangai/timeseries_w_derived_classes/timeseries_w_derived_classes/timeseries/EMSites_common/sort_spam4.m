function [xtr_freq, tot_time, n] = sort_spam4(station_folder,plotit,linkit,varargin)
    
    % search Spam4 folder and sort files into a new directory hierarchy as
    % required by emts
    %
    % sort_spam(station_folder, plotit, linkit)
    % sort_spam(station_folder, plotit, linkit,'raw_path',...,'proc_path',...)    
    % 
    % - read station from 
    %   fullfile(raw_path, station_folder)
    % where station_folder and raw_path are described below.
    %
    % - then make directories and link files to 
    %	proc_pathFFFF/SITENAME/ts/adc/spam4/runX
    % where proc_path is described below, FFFF is the frequency 
    % (if several are detected, multiple paths are created),
    % SITENAME is the name of the station folder
    % runX is the Xth folder of data
    % identified as continuous (as is determined from headers)
    %
    % station_folder: (relative) folder name for data of a station, or cell
    %                 of multiple stations.            ,
    %           if station_folder is empty, search all rawpath for folders
    %           (see below)
    %        
    % linkit (default: false) print operations to be done, but do not link! 1: actally carry out
    %           symbolic linking, but skip printing.     
    %    
    % plotit (default: true) shows the detected continuous runs in a
    %           runtime plot
    %
    % 'raw_path' optional base path for SPAM4 raw data. Default set at
    % beginning of function
    %
    % 'proc_path' optional target path for SPAM4 data ready for processing,
    % default set at beggining of function.
    %
    % JK 2015
    
    raw_path = [parvie_path('raw'),filesep,'Spam4',filesep,'data',filesep,'ParvieEM'];
    proc_path = [parvie_path('proc'),filesep,'Spam4',filesep,'data',filesep,'ParvieEM'];

    if nargin < 1;  station_folder = []; end
    if isempty(station_folder); tmp = dir([parvie_path('raw'),filesep,'Spam4',filesep,'data',filesep,'ParvieEM',filesep,'0*',filesep]); for ind = 1 : numel(tmp); station_folder{ind} = tmp(ind).name; end; end
    if nargin < 2; plotit = true; end
    if nargin < 3; linkit = false; end    
    n = get_info(varargin,'n',0);
    if iscell(station_folder);
        for ind = 1 : numel(station_folder);
            [xtr_freq, tmp, n] = sort_spam4(station_folder{ind},plotit,linkit,'n',n,varargin{:});
            if exist('tot_time','var');
                tot_time(end+1) = tmp;
            else
                tot_time(1) = tmp;
            end
        end
        return
    end    

    [raw_path, proc_path] = get_info(varargin,'raw_path',raw_path,'proc_path',proc_path);
    
    meas_dirs = dir([raw_path,filesep,station_folder,filesep,'ts',filesep,'adc',filesep,'spam4',filesep,'20*']);
        
    for ind = 1 : numel(meas_dirs)
        tmp = dir([raw_path,filesep,station_folder,filesep,'ts',filesep,'adc',filesep,'spam4',filesep,meas_dirs(ind).name,filesep,'*.XTR']);
        for ind2 = 1 : numel(tmp)
            tmp(ind2).base_dir = [raw_path,filesep,station_folder,filesep,'ts',filesep,'adc',filesep,'spam4',filesep,meas_dirs(ind).name];
        end
        if ~isempty(tmp)
            if ~exist('xtr_files','var')
                xtr_files = tmp;
            else            
                xtr_files = [xtr_files; tmp];
            end
        end
    end        
    
    start = zeros(1,numel(xtr_files));
    for ind = 1 : numel(xtr_files)
        fid = fopen([xtr_files(ind).base_dir,filesep,xtr_files(ind).name],'r');
        C = textscan(fid,'%s'); C = C{1};
        fclose(fid);
        [tf, which_name] = cell_contains(C, '[FILE]');
        C(1:which_name) = [];        
        [tf, which_name] = cell_contains(C, '''NAME=''');
        which_freq = which_name + 4;
        f = abs(str2double(C{which_freq})).^(-sign(str2double(C{which_freq})));
        xtr_files(ind).freq = f;
        [tf, which_name] = cell_contains(C, '''DATE=''');
        which_start = which_name + 1;
        which_start_ms = which_name + 2;
        which_stop = which_name + 3;
        which_stop_ms = which_name + 4;        
        xtr_files(ind).start = str2double(C{which_start});
        xtr_files(ind).startms = str2double(C{which_start_ms});
        xtr_files(ind).finish = str2double(C{which_stop});
        xtr_files(ind).finishms = str2double(C{which_stop_ms});
        start(ind) = xtr_files(ind).start;
        xtr_files(ind).run = [];
    end
    idx = sortrows([start(:), (1:numel(start))']);
    xtr_files = xtr_files(idx(:,2));        
    
    freq = zeros(1,numel(xtr_files));
    for ind = 1 : numel(xtr_files)        
        freq(ind) = xtr_files(ind).freq;
    end
    
    ufreq = unique(freq);    
    for ind = 1 : numel(ufreq);
        xtr_freq{ind} = xtr_files(freq == ufreq(ind));
    end
    
    for ind = 1 : numel(xtr_freq)
        run = 1;        
        stru = xtr_freq{ind};
        for ind2 = 1 : numel(stru)            
            if ind2 > 1 
                if abs( ufreq(ind).*((stru(ind2).start - stru(ind2-1).finish) + 1e-6*(stru(ind2).startms - stru(ind2-1).finishms) )  - 1 ) > 0.5
                    % disp( ufreq(ind).*(stru(ind2).start - stru(ind2-1).finish) + (ufreq(ind)*1e-6)*(stru(ind2).startms - stru(ind2-1).finishms) - 1 );
                    run = run + 1;
                end
            end
            stru(ind2).run = run;
        end
        xtr_freq{ind} = stru;
    end
    
    nold = n; mint = Inf; maxt = -Inf;
    for ind = 1 : numel(xtr_freq)
        f = xtr_freq{ind}(1).freq;
        stru = xtr_freq{ind};           
        
        tot_time.name = station_folder;
        tot_time.f = f;
        tot_time.start = xtr_freq{1}(1).start;
        tot_time.stop = xtr_freq{1}(end).finish;
        
        runs = zeros(1,numel(stru));
        for ind2 = 1 : numel(stru)
            runs(ind2) = stru(ind2).run;
        end
        uruns = unique(runs);
                
        for ind2 = 1 : numel(uruns)
            n = n + 1;
            first = find(runs == uruns(ind2),1,'first');
            last = find(runs == uruns(ind2),1,'last');
            s1 = stru(first).start; s1ms = stru(first).startms;                                    
            s2 = stru(last).finish; s2ms = stru(last).finishms;
            if s2 == 0;                               
                tmp = dir([xtr_freq{ind}(last-1).base_dir,filesep,xtr_freq{ind}(last-1).name(1:end-3),'RAW']); Nsmp = (tmp.bytes - 200)/5;
                s2 = s1 + Nsmp/xtr_freq{ind}(last-1).freq;
                s2ms = round((s2 - floor(s2))*1e6);
                s2 = floor(s2);
            end
            [start, startms] = unixtime2MTtime(s1,s1ms);
            [finish, finishms] = unixtime2MTtime(s2,s2ms);
            disp([station_folder,' - ',num2str(f),' Hz: run ',num2str(uruns(ind2)),' start: ',datestr(start),' ',num2str(startms),' ms, stop: ',datestr(finish),' ',num2str(finishms),' ms.']);                        
            if plotit                  
                t1 = datenum(start)  + startms/86400/1000; t2 = datenum(finish) + finishms/86400/1000;
                if t1<mint; mint = t1; end
                if t2>maxt; maxt = t2; end
                patch([t1, t2, t2, t1, t1],[n n n+1 n+1 n]-1/2, f);
                hold on;
                set(gca,'xticklabel',datestr(get(gca,'xtick')'));
            end
            target_path = [proc_path,num2str(xtr_freq{ind}(first).freq),filesep,station_folder,filesep,'ts',filesep,'adc',filesep,'spam4',filesep,'run',num2str(uruns(ind2))];
            
            for ind3 = first:last
                xtr_file_name = [xtr_freq{ind}(ind3).base_dir,filesep,xtr_freq{ind}(ind3).name];
                raw_file_name = [xtr_freq{ind}(ind3).base_dir,filesep,xtr_freq{ind}(ind3).name(1:end-3),'RAW'];
                xtr_target_name = [target_path,filesep,xtr_freq{ind}(ind3).name];
                raw_target_name = [target_path,filesep,xtr_freq{ind}(ind3).name(1:end-3),'RAW'];
            
                if linkit
                    if ~exist(target_path,'dir'); make_dir_tree(target_path); end                    
                    system(['ln -fs ',add_backspaces(xtr_file_name),' ',add_backspaces(xtr_target_name)]);
                    system(['ln -fs ',add_backspaces(raw_file_name),' ',add_backspaces(raw_target_name)]);                    
                elseif link
                    disp([xtr_file_name,' -> ',xtr_target_name]);
                    disp([raw_file_name,' -> ',raw_target_name]);
                end
                
            end
            
        end        
    end
    if plotit
        hold on;
        dt = (maxt-mint).*1e-3;
        dn = (nold - n).*1e-3;
        plot([mint-dt maxt+dt maxt+dt mint-dt  mint-dt],[nold+1/2-dn nold+1/2-dn n+1/2+dn n+1/2+dn nold+1/2-dn],'r-');
%         text( (mint + maxt - 100*dt)/2 , (nold + n + 1 - 100*dn)/2,station_folder,'fontsize',16,'color','r');
        text( mint - 1, (nold + n + 1 - 100*dn)/2,station_folder,'fontsize',16,'color','r');
    end
        
end

        
        
        
        
            
            
            
    
    
    
    


    
    

    