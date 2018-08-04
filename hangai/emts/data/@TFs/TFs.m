%%
% class definition of TFs
%
% - calling sequences
%
% obj = TF
%     generates a default transfer function object (which is called 'instance of the class')
% obj = TFs(fname);

%% MB 2015

classdef TFs
    properties
        % definition of properties with default values
        proname         = {['.' 'filesep']};     % name identifier
        datapath        = {'.'};
        format          = {'*.edi' '*.z??' '*MTSI.00*'};
        
        tf
        usestations     = {'all'};
        % map properties
        latlim          = [];
        lonlim          = [];
        hemisphere      = 'N';
        utmzone         = '';
        % profile/map properties
        porigin         = [];
        porient         = [];
        rotangle        = 0;
        % section limits
        ylim            = [-1 20];
        Tlim            = [0.01 500];
        Rlim            = [1 1000]; % resistivity limits
        Plim            = [0 90];   % phase limits
        % frange
        frange          = [-inf inf]; % use only this frequency range
        % phase tensor, maximum allowable condition number of Z_real
        PTcond          = 100;
    end
    properties (Dependent = true,  SetAccess = private)
        Ns                  % total number of stations
        stations            % all station names
        usedstations        % index of used stations
        llatlong            % geo-crds of used stations
        lxy                 % utm-crds of used stations
        pxy                 % utm-crds of profile origing (porigin)
        stationy            % distance along profile relative to origin
        usedf               % frequencies being used
        Nfused              % number of frequencies used
    end
    methods
        % methods are functions which can operate on objects
        % first method is the constructor method, which allows to set the
        % important properties
        function obj    = TFs(varargin)
            if nargin == 2
                if isa(varargin{1},'TFs') && isdir(varargin{2})
                    obj = varargin{1};
                    obj.proname = varargin(2);
                    for iformat = 1:numel(obj.format)
                        names = dir(fullfile(obj.proname{1},obj.datapath{1},obj.format{iformat}));
                        for ifile = 1:numel(names)
                            tf = TF;
                            obj.tf{ifile} = TF(tf,fullfile(obj.proname{1},obj.datapath{1},names(ifile).name));
                        end
                    end
                else
                    return;
                end
            elseif nargin == 1
                if isdir(varargin{1})     % Creates new TF object from files in given directory with default values
                    
                else
                    return;
                end
                
            end
            
        end
        % get and set methods
        function Ns = get.Ns(obj)
            Ns = numel(obj.tf);
        end
        function stations = get.stations(obj)
            for is = 1:obj.Ns
                stations(is) = obj.tf{is}.sname;
            end
        end
        function usedstations = get.usedstations(obj)
            usedstations = [];
            cont = 1;
            if numel(obj.usestations) == 1
                if strcmp(obj.usestations,'all')
                    usedstations = 1:obj.Ns;
                    cont = 0;
                end
            end
            if cont
                for is = 1:numel(obj.usestations)
                    ind = find(strcmp(obj.stations,obj.usestations{is}));
                    if ~isempty(ind)
                        usedstations = [usedstations ind];
                    end
                end
            end
        end
        function llatlong = get.llatlong(obj)
            used = obj.usedstations;
            for is = 1:numel(used)
                llatlong(:,is) = obj.tf{used(is)}.llatlong;
            end
        end
        function lxy      = get.lxy(obj)
            ll = obj.llatlong;
            if isempty(obj.utmzone) && isempty(obj.latlim)
                disp(' # Warning; utmzone and latlim / lonlim not defined');
                return
            end
            if ~isempty(obj.latlim)
                m_proj('UTM','lat',obj.latlim,'lon',obj.lonlim,'ell','wgs84','hem',obj.hemisphere);
            else
                disp(' #Please set lat/lon lomits');
                %m_proj('UTM','lat',obj.latlim,'lon',obj.lonlim,'ell','wgs84','hem',obj.hemisphere);
                return
            end
            [y,x] = m_ll2xy(ll(2,:),ll(1,:));
            
            lxy = [x;y];
        end
        function pxy      = get.pxy(obj)
            ll = obj.porigin;
            if isempty(obj.utmzone) && isempty(obj.latlim)
                disp(' # Warning; utmzone and latlim / lonlim not defined');
                return
            end
            if ~isempty(obj.latlim)
                m_proj('UTM','lat',obj.latlim,'lon',obj.lonlim,'ell','wgs84','hem',obj.hemisphere);
            else
                disp(' #Please set lat/lon lomits');
                %m_proj('UTM','lat',obj.latlim,'lon',obj.lonlim,'ell','wgs84','hem',obj.hemisphere);
                return
            end
            [y,x] = m_ll2xy(ll(2),ll(1));
            pxy = [x;y];
        end
        function stationy = get.stationy(obj)
            pxy = obj.pxy;
            lxy = obj.lxy;
            for is = 1:size(lxy,2);
                dist =  sqrt((lxy(1,is)-pxy(1)).^2+(lxy(2,is)-pxy(2)).^2);
                ang  = atan2(lxy(2,is)-pxy(2),lxy(1,is)-pxy(1));
                stationy(is) = round(cos(ang)*dist);
            end
            stationy = stationy/1000;
        end
        function usedf = get.usedf(obj)
            usedstations = obj.usedstations;
            f = [];
            for is = 1:numel(obj.usedstations)
                tf = obj.tf{usedstations(is)};
                f  =[f tf.f];
            end
            f = unique(f);
            usedf = f(f<=max(obj.frange) & f>=min(obj.frange));
        end
        function Nfused = get.Nfused(obj)
            Nfused = numel(obj.usedf);
        end
        function write_ModEM(obj,fname)
            fid = fopen(fname,'w+');
            fprintf(fid,'#comment1\n');
            fprintf(fid,'#comment2\n');
            
            fprintf(fid,'> Full Impedance\n');
            fprintf(fid,'> exp(-i\\omega t)\n');
            fprintf(fid,'> [mV/km]/[nT]\n');
            fprintf(fid,'> 0.00\n> 0.000 0.000\n');
            fprintf(fid,'> %d %d\n',obj.Nfused, numel(obj.usedstations));
            usedstations = obj.usedstations;
            lxy = obj.lxy;
            for is = 1:numel(usedstations)
                tf = obj.tf{obj.usedstations(is)};
                f = tf.f;
                xy = round((lxy(:,is)-obj.pxy)/50)*50;
                indf = find(f<=max(obj.frange) & f>=min(obj.frange));
                Z = tf.Z;
                Zse = tf.Zse;
                Zuse = ~tf.Zuse;
                % add error floors
                Zxyse = abs(Z(1,2,:))*0.1/sqrt(2);
                Zyxse = abs(Z(2,1,:))*0.1/sqrt(2);
                Zse(1,1,:) = max(Zse(1,1,:),Zxyse);
                Zse(2,1,:) = max(Zse(2,1,:),Zyxse);
                Zse(1,2,:) = max(Zse(1,2,:),Zxyse);
                Zse(2,2,:) = max(Zse(2,2,:),Zyxse);
                Zse(1,1,Zuse(1,1,:)) = abs(Z(1,2,Zuse(1,1,:)));
                Zse(1,2,Zuse(1,2,:)) = abs(Z(2,1,Zuse(1,2,:)));
                Zse(2,1,Zuse(2,1,:)) = abs(Z(1,2,Zuse(2,1,:)));
                Zse(2,2,Zuse(2,2,:)) = abs(Z(2,1,Zuse(2,2,:)));
                for fi = 1:numel(indf)
                    fprintf(fid,'%.4e %s %.6f %.6f %d %d 0 Zxx %.3e %.3e %.3e\n',1./f(indf(fi)),tf.sname{1},tf.llatlong(2),tf.llatlong(1),xy(1),xy(2),real(Z(1,1,indf(fi))),imag(Z(1,1,indf(fi))),real(Zse(1,1,indf(fi))));
                    fprintf(fid,'%.4e %s %.6f %.6f %d %d 0 Zxy %.3e %.3e %.3e\n',1./f(indf(fi)),tf.sname{1},tf.llatlong(2),tf.llatlong(1),xy(1),xy(2),real(Z(1,2,indf(fi))),imag(Z(1,2,indf(fi))),real(Zse(1,2,indf(fi))));
                    fprintf(fid,'%.4e %s %.6f %.6f %d %d 0 Zyx %.3e %.3e %.3e\n',1./f(indf(fi)),tf.sname{1},tf.llatlong(2),tf.llatlong(1),xy(1),xy(2),real(Z(2,1,indf(fi))),imag(Z(2,1,indf(fi))),real(Zse(2,1,indf(fi))));
                    fprintf(fid,'%.4e %s %.6f %.6f %d %d 0 Zyy %.3e %.3e %.3e\n',1./f(indf(fi)),tf.sname{1},tf.llatlong(2),tf.llatlong(1),xy(1),xy(2),real(Z(2,2,indf(fi))),imag(Z(2,2,indf(fi))),real(Zse(2,2,indf(fi))));
                    
                end
            end
            
            fclose(fid);
            
            
            
        end
        function h = plot_rose(obj,what)
            h = figure;
            set(h,'Position',[ 450   450   657   500]);
            %hax = axes;
            usedstations = obj.usedstations;
            theta = [];
            psi = [];
            for is = 1:numel(usedstations);
                tf = obj.tf{usedstations(is)};
                tf.PTcond = obj.PTcond;
                tf.lrot = obj.rotangle;
                tf.brot = obj.rotangle;
                switch what
                    case 'PT'
                        t = tf.Ptheta;
                        theta   = [theta t];
                        p = tf.Psi;
                        psi = [psi p'];
                end
            end
            switch what
                case 'PT'
                    WindRoseData = WindRose(gca, (theta)'*180/pi, ...
                        abs(psi'*180/pi), [0:10:365], [1.5,4.5,7.5,10.5,13.5], [5 10 15], 'PT ellipse orientation');
            end
        end
        function h = plot_section(obj,what)
            h = figure;
            set(h,'Position',[450         450        900         500]);
            hax = axes;
            %PT = obj.PTab;
            set(gca,'Position',[0.10   0.1   0.8   0.8],'Fontsize',18,'Xscale','lin','NextPlot','add',...
                'Xlim',obj.ylim,'Ylim',log10(obj.Tlim),'Ydir','reverse','Box','on');
            ylabel('log10 period (s)','Fontsize',18);
            xlabel('distance (km)','Fontsize',18);
            aspectrat = get(gca,'DataAspectRatio');
            axesrat = get(gca,'Position');
            axesrat = axesrat(3:4);
            figurerat = get(gcf,'Position');
            figurerat = figurerat(3:4);
            hax = plot(obj.stationy,log10(1./obj.Tlim(2)),'vk','Markersize',9,'Markerfacecolor','k' );
            usedstations = obj.usedstations;
            stationy = obj.stationy;
            for is = 1:numel(usedstations);
                tf = obj.tf{usedstations(is)};
                tf.PTcond = obj.PTcond;
                tf.lrot = obj.rotangle;
                tf.brot = obj.rotangle;
                w = (0:5:360)/180*pi;
                switch what
                    case 'PT'
                        PT = tf.PT;
                        Psi = tf.Psi;
                        for ip = 1:numel(tf.PTused)
                            ell = PT(:,:,tf.PTused(ip))*[cos(w);sin(w)]*2;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+log10(tf.T(tf.PTused(ip))),Psi(tf.PTused(ip))*180/pi,'Edgecolor','none');
                        end
                    case {'PhsXY' 'phsxy' 'Phsxy'}
                        phs = tf.phs;
                        for ip = 1:numel(tf.Zused{1})
                            ell = [cos(w);sin(w)]*3;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+...
                                log10(tf.T(tf.Zused{1}(ip))),phs(1,2,tf.Zused{1}(ip)),'Edgecolor','none');
                        end
                    case {'RhoXY' 'rhoxy' 'Rhoxy'}
                        rhoa = tf.rhoa;
                        for ip = 1:numel(tf.Zused{1})
                            ell = [cos(w);sin(w)]*3;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+...
                                log10(tf.T(tf.Zused{1}(ip))),log10(rhoa(1,2,tf.Zused{1}(ip))),'Edgecolor','none');
                        end
                    case {'PhsYX' 'phsyx' 'Phsyx'}
                        phs = tf.phs;
                        for ip = 1:numel(tf.Zused{1})
                            ell = [cos(w);sin(w)]*3;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+...
                                log10(tf.T(tf.Zused{1}(ip))),180+phs(2,1,tf.Zused{1}(ip)),'Edgecolor','none');
                        end
                    case {'RhoYX' 'rhoyx' 'Rhoyx'}
                        rhoa = tf.rhoa;
                        for ip = 1:numel(tf.Zused{1})
                            ell = [cos(w);sin(w)]*3;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+...
                                log10(tf.T(tf.Zused{1}(ip))),log10(rhoa(2,1,tf.Zused{1}(ip))),'Edgecolor','none');
                        end
                    case {'PTa' 'pta'}
                        phs = tf.PTab;
                        for ip = 1:numel(tf.PTused)
                            ell = [cos(w);sin(w)]*3;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+...
                                log10(tf.T(tf.PTused(ip))),atan(phs(1,1,tf.PTused(ip)))*180/pi,'Edgecolor','none');
                        end
                    case {'PTb' 'ptb'}
                        phs = tf.PTab;
                        for ip = 1:numel(tf.PTused)
                            ell = [cos(w);sin(w)]*3;
                            patch(ell(1,:)+stationy(is), ...
                                ell(2,:)*aspectrat(2)/aspectrat(1)*axesrat(1)/axesrat(2)*figurerat(1)/figurerat(2)+...
                                log10(tf.T(tf.PTused(ip))),atan(phs(2,2,tf.PTused(ip)))*180/pi,'Edgecolor','none');
                        end
                end
                
                text(stationy(is),log10(min(obj.Tlim))-0.1,tf.sname,'Fontsize',12,'Rotation',90);
            end
            hc = colorbar;
            hc.Position = [0.9256    0.2543    0.0151    0.6477];
            hc.FontSize = 18;
            cmap = colormap(jet);
            switch what
                case 'PT'
                    hc.YTick = [-30 -20 -10 0 10 20 30];
                    caxis([-30 30]);
                    title(hc,'\psi','Position',[16.0104  -30.7028 0],'Fontsize',22)
                    
                case {'PhsXY' 'phsxy' 'Phsxy'}
                    hc.YTick = [0 15 30 45 60 75 90];
                    caxis([0 90]);
                    title(hc,'\phi_{xy}','Position',[16.0104  -30.7028 0],'Fontsize',22)
                case {'PhsYX' 'phsyx' 'Phsyx'}
                    hc.YTick = [0 15 30 45 60 75 90];
                    caxis([0 90]);
                    title(hc,'\phi_{yx}','Position',[16.0104  -30.7028 0],'Fontsize',22)
                case {'RhoXY' 'rhoxy' 'Rhoxy'}
                    hc.YTick = [-1 0 1 2 3 4 5];
                    caxis(log10(obj.Rlim));
                    title(hc,'rho^a_{xy}','Position',[16.0104  -30.7028 0],'Fontsize',22)
                    cmap = flipud(cmap);
                case {'RhoYX' 'rhoyx' 'Rhoyx'}
                    hc.YTick = [-1 0 1 2 3 4 5];
                    caxis(log10(obj.Rlim));
                    title(hc,'rho^a_{yx}','Position',[16.0104  -30.7028 0],'Fontsize',22)
                    cmap = flipud(cmap);
                case {'PTa' 'pta'}
                    hc.YTick = [0 15 30 45 60 75 90];
                    caxis([0 90]);
                    title(hc,'\phi_{a}','Position',[16.0104  -30.7028 0],'Fontsize',22)
                case {'PTb' 'ptb'}
                    hc.YTick = [0 15 30 45 60 75 90];
                    caxis([0 90]);
                    title(hc,'\phi_{b}','Position',[16.0104  -30.7028 0],'Fontsize',22)
            end
            colormap(cmap);
        end
        
        function h = plot_sounding(obj,station,what)
            obj.usestations = {station};
            tf = obj.tf{obj.usedstations};
            tf.Plim = obj.Plim;
            tf.Rlim = obj.Rlim;
            tf.Tlim = obj.Tlim;
            tf.PTcond = obj.PTcond;
            tf.lrot = obj.rotangle;
            tf.brot = obj.rotangle;
            switch what
                case {'RhoaPhs', 'rhoaphs'}
                    h = plot_rhoaphs(tf);
                case {'PT'}
                    h = plot_PT(tf);
                case {'PTab'}
                    h = plot_PTab(tf);
                case {'PTellipse'}
                    h = plot_PTellipse(tf);
            end
        end
    end
end % classdef

