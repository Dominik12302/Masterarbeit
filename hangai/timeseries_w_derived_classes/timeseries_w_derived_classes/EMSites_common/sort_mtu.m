function sort_mtu(station_folder,linkit,mode,varargin)

    % search MTU folder and sort data files into a new directory hierarchy as
    % required by emts
    %
    % sort_mtu(station_folder, linkit, mode)
    % sort_mtu(station_folder, linkit, mode,'raw_path',...,'proc_path',...)
    % sort_mtu(station_folder, linkit, mode,'raw_path',...,'proc_path',...,'N',...)
    % 
    % - read station from 
    %   fullfile(raw_path, station_folder)
    % where station_folder and raw_path are described below.
    %
    % - then make directories and link files to 
    %	proc_path/{LF_data,HF_data}/SITENAME/ts/adc/MTU/runX
    % where proc_path is described below, LF_data/HF_data depends on
    % "mode" setting, see below, SITENAME is extracted from the first 3
    % characters of the filename strings, runX is the Xth folder of data
    % identified as continuous (assumed on a (max.) file length of N
    % minutes)
    %
    % station_folder: (relative) folder name for data of a station, or cell
    %                 of multiple stations.            ,
    %           if station_folder is empty, search all rawpath for folders
    %           (see below)
    %        
    % linkit (default: false) print operations to be done, but do not link! 1: actally carry out
    %           symbolic linking, but skip printing.
    % 
    % mode: 'LF' read mseed2 data (default). 'HF' read mseed data. write to
    %        corresponding path 'LF_data' or 'HF_data', see above.
    %
    % 'raw_path' optional base path for MTU raw data. Default set at
    % beginning of function
    %
    % 'proc_path' optional target path for MTU data ready for processing,
    % default set at beggining of function.
    %
    % 'N' assumed file length in minutes, default set below (20 minutes typically)
    %
    % JK 2015
    %
    % NOTE: sometimes when filenames are odd, a few short runs are created.
    % This could either be because the device was restarted a few times in
    % the field, or because something is still not working in this script
    
    
    raw_path = '/giant/MTgroup/Data/Scandinavia/MTMasi_SofiesData/MTMasi_UU';
    proc_path = '/ddfs/user/data/k/kammj/TMP_MTMasi_UU_proc';        
    N = 20;
    
    if nargin < 1; station_folder = []; end    
    if isempty(station_folder); tmp = dir('/giant/MTgroup/Data/Scandinavia/MTMasi_SofiesData/MTMasi_UU');
        for ind = 1 : numel(tmp); station_folder{ind} = tmp(ind).name; end; 
        rem = []; 
        for ind = 1 : numel(tmp); 
            if strcmp(station_folder{ind},'.') || strcmp(station_folder{ind},'..')
                rem = [rem, ind]; 
            end
        end
        station_folder(rem) = [];
            
    end    
    if nargin < 2; linkit = false; end    
    if nargin < 3; mode = 'LF'; end
    if iscell(station_folder);
        for ind = 1 : numel(station_folder);
            sort_mtu(station_folder{ind},linkit,mode,varargin{:});            
        end
        return
    end   
    
    [raw_path, proc_path, N] = get_info(varargin,'raw_path',raw_path,'proc_path',proc_path,'N',N);
    
    switch mode
        case 'LF'
            all_mseed  = scandir([raw_path,filesep,station_folder],'*.mseed2');
            all_mseed().tint = [];
        case 'HF'
            all_mseed  = scandir([raw_path,filesep,station_folder],'*.mseed');
            all_mseed().tint = [];
    end
    
    site_name = all_mseed(1).name(1:3);
    for ind = 1 : numel(all_mseed)
        if ~strcmp(all_mseed(ind).name(1:3),site_name)
            error('inconsistent site naming');
        end
        all_mseed(ind).tint = str2double(all_mseed(ind).name(4:15));        
    end
    
    tintmat = zeros(numel(all_mseed),1);
    dates = zeros(numel(all_mseed),1);
    for ind = 1 : numel(tintmat)
        % assuming N minute files
        tintmat(ind) = all_mseed(ind).tint;        
        dates(ind) = round(N*3600*datenum(str2double(all_mseed(ind).name(4:5))+2000,...
            str2double(all_mseed(ind).name(6:7)),...
            str2double(all_mseed(ind).name(8:9)),...
            str2double(all_mseed(ind).name(10:11)),...
            str2double(all_mseed(ind).name(12:13)),...
            str2double(all_mseed(ind).name(14:15))))./1000;
    end    
    [tintmat, order] = sort(tintmat);
    all_mseed = all_mseed(order);           
    
    all_mseed().run = [];
    run = 1; oldtime = dates(1);
    for ind = 1 : numel(tintmat)
        
        % if is not an integer, start a new run (unless its the same as
        % before
        if ~isint(dates(ind)) && oldtime - dates(ind) ~=0
            run = run + 1;
        end
        % is an integer but gap is too large, start a new run
        if isint(dates(ind)) && oldtime - dates(ind) > 1
            run = run + 1;
        end
        
        all_mseed(ind).run = run;
        oldtime = dates(ind);
    end
        
    for ind = 1 : numel(all_mseed)
        source_path = [all_mseed(ind).location];
        target_path = [proc_path,filesep,mode,'_data',filesep,site_name,filesep,'ts',filesep,'adc',filesep,'MTU',filesep,'run',num2str(all_mseed(ind).run)];

        msd_file_name = [source_path,filesep,all_mseed(ind).name];
        msd_target_name = [target_path,filesep,all_mseed(ind).name];
        
         if linkit
            if ~exist(target_path,'dir'); make_dir_tree(target_path); end
            system(['ln -fs ',add_backspaces(msd_file_name),' ',add_backspaces(msd_target_name)]);            
         else
            disp([msd_file_name,' -> ',msd_target_name]);            
         end                
    end
        
    hdr  = scandir([raw_path,filesep,station_folder],'configuration.inf');    
    hdr_file_name = [hdr(1).location,filesep,hdr(1).name];
    
    for ind2 =  1 : run
        target_path = [proc_path,filesep,mode,'_data',filesep,site_name,filesep,'ts',filesep,'adc',filesep,'MTU',filesep,'run',num2str(ind2)];
        
        hdr_target_name = [target_path,filesep,hdr(1).name];
        
        if linkit
            if ~exist(target_path,'dir'); make_dir_tree(target_path); end
            system(['ln -fs ',add_backspaces(hdr_file_name),' ',add_backspaces(hdr_target_name)]);
        else
            disp([hdr_file_name,' -> ',hdr_target_name]);
        end
    end
    
    gps  = scandir([raw_path,filesep,station_folder],'*.gps');
    for ind = 1 : numel(gps);
        
        source_path = [gps(ind).location];
        gps_file_name = [source_path,filesep,gps(ind).name];
        
        for ind2 =  1 : run
            target_path = [proc_path,filesep,mode,'_data',filesep,site_name,filesep,'ts',filesep,'adc',filesep,'MTU',filesep,'run',num2str(ind2)];
            
            gps_target_name = [target_path,filesep,gps(ind).name];
        
            if linkit
                if ~exist(target_path,'dir'); make_dir_tree(target_path); end
                system(['ln -fs ',add_backspaces(gps_file_name),' ',add_backspaces(gps_target_name)]);            
            else
                disp([gps_file_name,' -> ',gps_target_name]);            
            end
         end
         
    end
    
    ini  = scandir([raw_path,filesep,station_folder],'recorder.ini');
    for ind = 1 : numel(ini);
        
        source_path = [ini(ind).location];
        ini_file_name = [source_path,filesep,ini(ind).name];
        
        for ind2 =  1 : run
            target_path = [proc_path,filesep,mode,'_data',filesep,site_name,filesep,'ts',filesep,'adc',filesep,'MTU',filesep,'run',num2str(ind2)];
            
            ini_target_name = [target_path,filesep,ini(ind).name];
        
            if linkit
                if ~exist(target_path,'dir'); make_dir_tree(target_path); end
                system(['ln -fs ',add_backspaces(ini_file_name),' ',add_backspaces(ini_target_name)]);            
            else
                disp([ini_file_name,' -> ',ini_target_name]);            
            end
         end
         
    end