%%
% class definition of TF
%
% - calling sequences
%
% obj = TF
%     generates a default transfer function object (which is called 'instance of the class') 
% obj = TFs(fname);

%% MB 2015

classdef TF
    properties
        % definition of properties with default values
        sname           = {'none'};     % name identifier
        rotangle        = 0;            % rotation angle of all stations
        declination     = 0;            % at local site
        elevation       = 0;            % at local site
        % local (output) channels
        lname           = {'none'};     % name of local site
        output          = {'Ex' 'Ey' 'Hz'};
        llatlong        = [];           % lat/long refers to the local output channels
        lrot            = 0;            % rotation angle of local channels (clockwise positive)
        % base (input) channels
        bname           = {'none'};
        input           = {'Hx' 'Hy'};
        blatlong        = [];           % lat/long to the input channels at the base site
        brot            = 0;            % rotation angle of local channels (clockwise positive)
        % original data (unrotated)
        f               = [];           % frequencies
        tf              = [];           % transfer function
        tfse            = [];           % standard deviation
        tfuse           = [];
        debuglevel      = 1;
        % for phase tensor
        PTcond          = 50; 
        % for plotting
        Tlim            = [1e-2 1e+3];  % period limits
        Plim            = [0 90];       % Phase limits
        Rlim            = [10 100000];    % rhoa limits;
    end
    properties (Dependent = true,  SetAccess = private)
        Np
        Ninput
        Noutput
        lxy                             % utm coordinates of local site
        bxy                             % utm coordinates of base site 
        w                               % angular frequency
        T                               % period
        lR                              % horizontal rotation matrix for local (output) channels
        bR                              % horizontal rotation matrix for base (input) channels
        tfrot                           % rotated tf
        tfserot                         % standard deviation in rotated coordinates
        Z
        Zse
        Zused
        rhoa
        phs
        PT                              % phase tensor
        Psi                             % PT parameterization: cf Booker
        Ptheta                          %
        PTab
        PTused                          % logical mask
    end
    methods
        % methods are functions which can operate on objects
        % first method is the constructor method, which allows to set the
        % important properties
        function obj    = TF(varargin)
            if nargin == 2
                if isa(varargin{1},'TF') && exist(varargin{2})
                    obj         = varargin{1}; % Creates TF object from file with values of given TF object
                    if obj.debuglevel, disp([' - Reading file ' varargin{2}]); end
                    obj         = tf_read(obj,varargin{2});
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
        function Np = get.Np(obj)
            Np = numel(obj.f);
        end
        function w = get.w(obj)
            w = 2*pi*obj.f;
        end
        function T = get.T(obj)
            T = 1./obj.f;
        end
        function Z = get.Z(obj)
            tf = obj.tf;
            ex = find(strcmp(obj.output,'Ex'));
            ey = find(strcmp(obj.output,'Ey'));
            hx = find(strcmp(obj.input,'Hx'));
            hy = find(strcmp(obj.input,'Hy'));
            e  = obj.lrot*pi/180;
            h  = obj.brot*pi/180;
            Re = [cos(e) sin(e);-sin(e) cos(e)];
            Rh = [cos(h) sin(h);-sin(h) cos(h)];
            for ip = 1:obj.Np
                Z0 = [tf(ex,hx,ip) tf(ex,hy,ip); tf(ey,hx,ip) tf(ey,hy,ip)];
                Z(:,:,ip) = Re*Z0*Rh';
            end
        end
        function Zse = get.Zse(obj)
            tf = obj.tfse;
            ex = find(strcmp(obj.output,'Ex'));
            ey = find(strcmp(obj.output,'Ey'));
            hx = find(strcmp(obj.input,'Hx'));
            hy = find(strcmp(obj.input,'Hy'));
            e  = obj.lrot*pi/180;
            h  = obj.brot*pi/180;
            Re = [cos(e) sin(e);-sin(e) cos(e)];
            Rh = [cos(h) sin(h);-sin(h) cos(h)];
            for ip = 1:obj.Np
                Z0 = [tf(ex,hx,ip) tf(ex,hy,ip); tf(ey,hx,ip) tf(ey,hy,ip)];
                Zse(:,:,ip) = Re*Z0*Rh';
            end
        end
        function Zused = get.Zused(obj)
            tfuse = obj.tfuse;
            ex = find(strcmp(obj.output,'Ex'));
            ey = find(strcmp(obj.output,'Ey'));
            Zused = {find(tfuse(ex,:)) find(tfuse(ey,:))};
        end
        function PTused = get.PTused(obj)
           tfuse = obj.tfuse;
           ex = find(strcmp(obj.output,'Ex'));
           ey = find(strcmp(obj.output,'Ey'));
           PTused = find(tfuse(ex,:) & tfuse(ey,:)); 
        end
        function PT = get.PT(obj)
            Z   = obj.Z;
            for ip = 1:obj.Np
                Zr = real(Z(:,:,ip));
                [U,s,V]  = svd(Zr);
                if s(2,2)/s(1,1) < 1/obj.PTcond, 
                    s(2,2) = s(2,2)+s(1,1)/obj.PTcond; 
                    Zr = U*s*V'; 
                end
                PT(:,:,ip) = Zr\imag(Z(:,:,ip));
            end 
        end
        function Psi = get.Psi(obj) % Bookers Skew pf the Phase tensor
            PT = obj.PT;
            Psi = squeeze(atan2(PT(1,2,:)-PT(2,1,:),PT(1,1,:)+PT(2,2,:)));
        end
        function Ptheta = get.Ptheta(obj)
            PT = obj.PT;
            Psi = obj.Psi;
            for ip = 1:numel(Psi)
                Ptheta(ip) = fminbnd(@abspw,0,180,optimset('TolX',1e-12,'Display','off'),PT(:,:,ip),Psi(ip))*pi/180;
            end
        end
        function PTab = get.PTab(obj)
            PT  = obj.PT;
            Psi = obj.Psi;
            Ptheta = obj.Ptheta;
            for ip = 1:numel(Psi)
                Rtheta = [cos(Ptheta(ip)) sin(Ptheta(ip)); -sin(Ptheta(ip)) cos(Ptheta(ip))];
                Rpsi   = [cos(Psi(ip)) sin(Psi(ip)); -sin(Psi(ip)) cos(Psi(ip))];
                PTab(:,:,ip) = Rtheta*PT(:,:,ip)*Rtheta'*Rpsi';
            end
        end
        function rhoa = get.rhoa(obj)
            Z   = obj.Z;
            for ip = 1:obj.Np
                rhoa(:,:,ip) = abs(Z(:,:,ip)).^2*obj.T(ip)/5;
            end
        end
        function phs = get.phs(obj)
            Z   = obj.Z;
            for ip = 1:obj.Np
                phs(:,:,ip) = angle(Z(:,:,ip))*180/pi;
            end
        end
        function h = plot_PT(obj)
            h = figure;
            set(h,'Position',[784   987   776   351]);
            hax = axes;
            PT = obj.PT;
            set(gca,'Position',[0.1300    0.1800    0.7250    0.75],'Fontsize',18,'Xscale','log','NextPlot','add',...
                'Ylim',obj.Plim,'Xlim',obj.Tlim,'Box','on', ...
                'YTick',[0 15 30 45 60 75 90]);
            plot(obj.T,180/pi*atan(squeeze(PT(1,1,:))),'or','Markerfacecolor','r','Markersize',8);
            plot(obj.T,180/pi*atan(squeeze(PT(1,2,:))),'om','Markerfacecolor','m','Markersize',5);
            plot(obj.T,180/pi*atan(squeeze(PT(2,1,:))),'og','Markerfacecolor','g','Markersize',5);
            plot(obj.T,180/pi*atan(squeeze(PT(2,2,:))),'ob','Markerfacecolor','b','Markersize',8);
            xlabel('period (s)','Fontsize',18);
            ylabel('phase (deg)','Fontsize',18);
            text(10^log10(min(obj.Tlim)*1.2),80,obj.sname,'Fontsize',22);
            hl = legend({'\phi_x_x','\phi_x_y','\phi_y_x','\phi_y_y'},'Fontsize',18,'Position',[0.8795 0.6083 0.0863 0.3234],'Box','off');
            
            
        end
        function h = plot_PTab(obj)
            h = figure;
            set(h,'Position',[784   987   776   351]);
            hax = axes;
            PT = obj.PTab;
            set(gca,'Position',[0.1300    0.1800    0.7250    0.75],'Fontsize',18,'Xscale','log','NextPlot','add',...
                'Ylim',obj.Plim,'Xlim',obj.Tlim,'Box','on', ...
                'YTick',[0 15 30 45 60 75 90]);
            plot(obj.T,180/pi*atan(squeeze(PT(1,1,:))),'or','Markerfacecolor','r','Markersize',8);
            plot(obj.T,180/pi*atan(squeeze(PT(2,2,:))),'ob','Markerfacecolor','b','Markersize',8);
            xlabel('period (s)','Fontsize',18);
            ylabel('phase (deg)','Fontsize',18);
            text(10^log10(min(obj.Tlim)*1.2),80,obj.sname,'Fontsize',22);
            hl = legend({'\phi_a','\phi_b'},'Fontsize',18,'Position',[0.8795 0.6083 0.0863 0.3234],'Box','off');
        end
        function h = plot_PTellipse(obj)
            h = figure;
            set(h,'Position',[784        1147         776         191]);
            hax = axes;
            PT = obj.PTab;
            set(gca,'Position',[0.1300    0.2700    0.7250    0.65],'Fontsize',18,'Xscale','lin','NextPlot','add',...
                'Ylim',[-1 1],'Xlim',log10(obj.Tlim),'Box','on', ...
                'YTick',[]);
            xlabel('log10 period (s)','Fontsize',18);
            ylabel('','Fontsize',18);
            text(log10(min(obj.Tlim))+0.2,0.7,obj.sname,'Fontsize',22);
            aspectrat = get(gca,'DataAspectRatio');
            axesrat = get(gca,'Position');
            axesrat = axesrat(3:4);
            figurerat = get(gcf,'Position');
            figurerat = figurerat(3:4);
            w = (0:1:360)/180*pi;
            PT = obj.PT;
            Psi = obj.Psi;
            for ip = 1:obj.Np
                ell = PT(:,:,ip)*[cos(w);sin(w)]/15;
                patch(ell(2,:)*aspectrat(1)/aspectrat(2)*axesrat(2)/axesrat(1)*figurerat(2)/figurerat(1)+log10(obj.T(ip)),ell(1,:),Psi(ip)*180/pi);
                
            end
            hc = colorbar;
            hc.Position = [0.8937    0.2723    0.0258    0.6492];
            hc.FontSize = 18;
            hc.YTick = [-30 -20 -10 0 10 20 30];
            caxis([-30 30]);
            colormap(jet);
            title(hc,'\psi (deg)','Position',[16.0104  -30.7028         0])
       end
        function h = plot_rhoaphs(obj)
            h = figure;
            set(h,'Position',[286    88   776   805]);
            hax = axes;
            rhoa = obj.rhoa;
            Xused = obj.Zused{1};
            Yused = obj.Zused{2};
            set(gca,'Position',[0.1300    0.4500    0.7250    0.45],'Fontsize',18,'Xscale','log','Yscale','log','NextPlot','add',...
                'Ylim',obj.Rlim,'Xlim',obj.Tlim,'Box','on');
            plot(obj.T(Xused),(squeeze(rhoa(1,1,Xused))),'om','Markerfacecolor','m','Markersize',5);
            plot(obj.T(Xused),(squeeze(rhoa(1,2,Xused))),'or','Markerfacecolor','r','Markersize',8);
            plot(obj.T(Yused),(squeeze(rhoa(2,1,Yused))),'ob','Markerfacecolor','b','Markersize',8);
            plot(obj.T(Yused),(squeeze(rhoa(2,2,Yused))),'og','Markerfacecolor','g','Markersize',5);
            title(obj.sname,'Fontsize',22);
            ylabel('App. Resistiviy (ohmm)','Fontsize',18);
            hl = legend({'Z_x_x','Z_x_y','Z_y_x','Z_y_y'},'Fontsize',18,'Position',[0.8795 0.6083 0.0863 0.3234],'Box','off');
            
            hax = axes;
            phs = obj.phs;
            
            set(gca,'Position',[0.1300    0.100    0.7250    0.3],'Fontsize',18,'Xscale','log','Yscale','lin','NextPlot','add',...
                'Ylim',obj.Plim,'Xlim',obj.Tlim,'Box','on');
            plot(obj.T(Xused),(squeeze(phs(1,1,Xused))),'om','Markerfacecolor','m','Markersize',5);
            plot(obj.T(Xused),(squeeze(phs(1,2,Xused))),'or','Markerfacecolor','r','Markersize',8);
            plot(obj.T(Yused),(squeeze(phs(2,1,Yused)))+180,'ob','Markerfacecolor','b','Markersize',8);
            plot(obj.T(Yused),(squeeze(phs(2,2,Yused)))+180,'og','Markerfacecolor','g','Markersize',5);
            ylabel('phase (deg)','Fontsize',18);
            xlabel('period (s)','Fontsize',18);
            
        end

    end
end % classdef

