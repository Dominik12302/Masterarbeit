classdef CalibrationFileBrowser < handle
    properties
        h
        cal_path        
        plotted
    end    
    methods
        function C = CalibrationFileBrowser(caldir)
            
            if nargin < 1; caldir = []; end
            if isempty(caldir); caldir = uigetdir('.','Provide calibration file directory'); end
            C.cal_path = caldir;            
            C.h = C.init_gui_figure;
            
            set(C.h,'closerequestfcn',@(src,evt)close_figure(C,src,evt));
            
            handles = guihandles(C.h);            
            set(handles.response_list,'Callback',@(src,evt)plot_selection(C,src,evt))
            set(handles.title_check1,'Callback',@(src,evt)plot_selection(C,src,evt))
            set(handles.title_check2,'Callback',@(src,evt)plot_selection(C,src,evt))
            set(handles.title_check3,'Callback',@(src,evt)plot_selection(C,src,evt))
        end
        function fl = file_list(C)
            dd = dir(C.cal_path);
            rem = [];
            for ind = 1:numel(dd)
                if dd(ind).isdir; rem = [rem ind]; end
            end
            dd(rem) = [];
            fl = {dd(:).name};
        end
        function plot_selection(C,src,evt)
            handles = guihandles(C.h);            
            str = get(handles.response_list,'string');
            val = get(handles.response_list,'Value');
            selection = str(val);            
            col = lines(numel(selection));
                   
            axh(1) = handles.ax_abs;
            axh(2) = handles.ax_phs;
            axh(3) = handles.ax_re;
            axh(4) = handles.ax_im;
            
            for ia = 1 : numel(axh), set(axh(ia),'Nextplot','replacechildren');end
            
            new_str = cell(1,numel(selection)+1);
            new_str{1} = '<html><b>Selected files</b></html>';
            a_plot_done = false;         
            
            Tmin = Inf; Tmax = -Inf; 
            delete(C.plotted);
            NN = 3; N = NN*4;
            h = zeros(1,numel(selection)*N);
            for ind = 1 : numel(selection)     
                set(handles.text_loading,'string',sprintf('Reading %s ...',selection{ind}));
                drawnow
                [data_real,type,name] = C.get_caldata_real(selection{ind});
                if isempty(data_real)
                    continue;
                end                
                data_theo = C.get_caldata_theorical(type,data_real(:,1));
                
                Tmin = min([1./data_real(:,1);1./data_theo(:,1);Tmin]);
                Tmax = max([1./data_real(:,1);1./data_theo(:,1);Tmax]);
                
                % difference
                if ~isempty(data_real) && ~isempty(data_theo)
                    if get(handles.title_check3,'value');
                        data_diff = data_theo;
                        data_diff(:,4:5) = data_real(:,4:5) - data_theo(:,4:5);
                        data_diff(:,2) = abs(data_diff(:,4)+1i*data_diff(:,5));
                        data_diff(:,3) = 180/pi*angle(data_diff(:,4)+1i*data_diff(:,5));
                        for ia = 1 : numel(axh)                        
                            h(N*(ind-1)+ia+8) = plot(axh(ia),1./data_diff(:,1),data_diff(:,ia+1),'color',col(ind,:),'linestyle','--','marker','none');
                        end                    
                        a_plot_done = true;
                    end
                end
                if a_plot_done;
                    for ia = 1 : numel(axh), set(axh(ia),'Nextplot','add');end
                end
                
                % theoretical
                if ~isempty(data_theo)                    
                    if get(handles.title_check2,'value');
                        for ia = 1 : numel(axh)                        
                            h(N*(ind-1)+ia+4) = plot(axh(ia),1./data_theo(:,1),data_theo(:,ia+1),'color',col(ind,:),'linestyle','-','marker','none');                 
                        end
                        a_plot_done = true;
                    end
                end
                if a_plot_done;
                    for ia = 1 : numel(axh), set(axh(ia),'Nextplot','add');end
                end 
                
                % from file
                if ~isempty(data_real)
                    if get(handles.title_check1,'value');
                        for ia = 1 : numel(axh)
                            h(N*(ind-1)+ia) = plot(axh(ia),1./data_real(:,1),data_real(:,ia+1),'color',col(ind,:),'linestyle',':','marker','.');                        
                        end
                        a_plot_done = true;
                    end
                end             
                if a_plot_done;
                    for ia = 1 : numel(axh), set(axh(ia),'Nextplot','add');end
                end
                                              
                   
                new_str{ind+1} = color_string(str{val(ind)},col(ind,:));
                
                set(handles.text_loading,'string',sprintf('Reading %s done.',selection{ind}));
                drawnow
            end       
            for ia = 1 : numel(axh)
                xlim(axh(ia),[Tmin Tmax]); 
            	set(axh(ia),'Nextplot','replacechildren');
                set(axh(ia),'Xtick',10.^(ceil(log10(Tmin)):floor(log10(Tmax))));
            end            
            
            C.plotted = h(h~=0);
            set(handles.legend,'string',new_str);
            set(handles.text_loading,'string','');
        end
        function data = get_caldata_theorical(C,type,f)
            if isempty(f)
                f = logspace(6,-6,13*7);            
            end
            switch type
                case  {'MFS05','mfs05','005_HF','005_LF','MFS10','mfs10','010_HF','010_LF'}
                    P1 = 1i*f/4;
                    P2 = 1i*f/8192;
                    F = P1./(1+P1).*1./(1+P2);                    
                case {'MFS06','mfs06','006_HF','006_LF'}                    
                    P1 = 1i*f/4;
                    P2 = 1i*f/8192;
                    F = P1./(1+P1).*1./(1+P2);                    
                case {'MFS07','mfs07','007_HF','007_LF'}                    
                    P1 = 1i*f/32;
                    P2 = 1i*f/40000;
                    F = P1./(1+P1).*1./(1+P2);                
                case {'MFS11','mfs11','011_HF','011_LF'}                    
                    P1 = 1i*f/0.7227;
                    P2 = 1i*f/32.45;
                    P3 = 1i*f/45106;
                    P4 = 1i*f/48000;
                    P5 = 1i*f/37589;
                    F = P1./(1+P1).*P2./(1+P2).*1./(1+P3).*1./(1+P4).*1./(1+P5);                
                case {'SHFT02','shft02'}                
                    P1 = 1i*f/300000;
                    F = 1./(1+P1); 
                otherwise
                    F = zeros(0,1); f = zeros(0,1);
            end
            data(:,1)=f; data(:,2) = abs(F); data(:,3) = angle(F)*180/pi; 
            data(:,4)= real(F); data(:,5) = imag(F);
        end
        function [data,type,name] = get_caldata_real(C,fn)
            cal_file = fullfile(C.cal_path,fn);
            
            % here would go a check for the filetype
            if strcmpi(cal_file(end),'X');
                first = strfind(fn,'TYPE-')+5;
                last =  strfind(fn,'-ID-')-1;
                type = fn(first:last);
                
                first = strfind(fn,'-ID-')+4;
                last = strfind(fn,'.RSPX')-1;
                name = num2str(str2double(fn(first:last)));
                
                fprintf('Reading %s ...',cal_file);                
                xmlfile = xml2struct(cal_file);
                fprintf(' done.\n');
                
                staticgain_id = find(strcmp({xmlfile.Children.Name},'StaticGain'));
                staticgain = str2double(xmlfile.Children(staticgain_id).Children.Data);
                data_id = find(strcmp({xmlfile.Children.Name},'ResponseData'));
                Attr = {xmlfile.Children(data_id).Attributes};
                AttrNames = cellfun(@(x){x(:).Name},Attr,'UniformOutput',false);
                freq_id = cellfun(@(x)find(strcmp(x,'Frequency')),AttrNames);
                mag_id = cellfun(@(x)find(strcmp(x,'Magnitude')),AttrNames);
                phase_id = cellfun(@(x)find(strcmp(x,'Phase')),AttrNames);
                data = zeros(numel(freq_id),3);
                for ind2 = 1 : numel(freq_id)
                    values = str2double({Attr{ind2}.Value});
                    data(ind2,:) = values([freq_id(ind2) mag_id(ind2) phase_id(ind2)]);
                end                            
            else
                disp('unknown filetype');
                data = [];
                type = [];
                name = [];
            end
            if ~isempty(data)
                data = flipud(sortrows(data));
                data(:,4) = data(:,2).*cosd(data(:,3));
                data(:,5) = data(:,2).*sind(data(:,3));
            end
        end
        function h = init_gui_figure(C)
                                    
            % defaults
            fs13 = 13; 
            fs14 = 14; 
            fs16 = 16; 
            if ~ismac, 
                fs13 = fs13/(96/72); 
                fs14 = fs14/(96/72); 
                fs16 = fs16/(96/72); 
            end
            fontname = 'Helvetica';
            fontname_monospace = 'Courier';
            
            defaults1 = {'Units','Normalized'};
            defaults2 = {defaults1{:},'Fontsize',fs14,'Fontname',fontname};
            
            h = figure(defaults1{:},'position',[0.1 0.1 0.8 0.8]);
            
            axes('tag','ax_abs',defaults2{:},'position',[0.4 0.55 0.25 0.4],...
                'xscale','log','yscale','log');
            xlabel('Period [s]'); ylabel('Amplitude'); grid on; grid minor;
            
            axes('tag','ax_phs',defaults2{:},'position',[0.7 0.55 0.25 0.4],...
                'xscale','log','yscale','lin');
            xlabel('Period [s]'); ylabel('Phase [^o]'); grid on; grid minor;
            
            axes('tag','ax_re' ,defaults2{:},'position',[0.4 0.07 0.25 0.4],...
                'xscale','log','yscale','lin');
            xlabel('Period [s]'); ylabel(['Real part']); grid on; grid minor;
            
            axes('tag','ax_im' ,defaults2{:},'position',[0.7 0.07 0.25 0.4],...
                'xscale','log','yscale','lin');
            xlabel('Period [s]'); ylabel(['Imaginary part']); grid on; grid minor;
            
            uicontrol('style','text','tag','title_text',defaults2{:},...
                'position',[0.05 0.95 0.28 0.02],'fontweight','bold',...
                'String','Plot selected calibration files');
            
            uicontrol('style','checkbox','tag','title_check1',defaults2{:},...
                'position',[0.05 0.93 0.28 0.02],...
                'String','Dots with dotted line: calibration from file','Value',1);
            
            uicontrol('style','checkbox','tag','title_check2',defaults2{:},...
                'position',[0.05 0.91 0.28 0.02],...
                'String','Solid line: theoretical calibration','Value',1);
            
            uicontrol('style','checkbox','tag','title_check3',defaults2{:},...
                'position',[0.05 0.89 0.28 0.02],...
                'String','Dashed line: difference: file - theoretical','value',1);
            
            uicontrol('style','listbox','tag','response_list',defaults2{:},...
                'position',[0.05 0.22 0.28 0.65],'String',C.file_list,...
                'min',0,'max',2);
            
            uicontrol('style','listbox','tag','legend',defaults2{:},...
                'position',[0.05 0.06 0.28 0.15],'String',{'<html><b>Selected files</b></html>'},...
                'value',1,'hittest','off','selectionhighlight','off');
            
            uicontrol('style','text','tag','text_loading',defaults1{:},'fontsize',8,...
                'position',[0.05 0.03 0.28 0.02],'String','','horizontalalignment','left');
        end
        function close_figure(C,src,evt)
            delete(C.h);
            delete(C);
        end
    end
end