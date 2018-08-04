function fh = sp_plottf(tf,tit)
if isempty(tf.tf); return; end

%% error bars for ap. res and e-tfs are 2 times the standard deviation
col = {'r','b','m','g'};
sym = {'o','o','o','o'};
plt.rho = [1 30000];
plt.phs = [0 90];
%plt.phs = [-180 90];
%plt.phs = [-180 -90];
plt.hz = [-.5 .5];
plt.per = [1e-3 1e+4];
% plt.per = [1e-2 1e3];
if ~tf.nper
    fh = [];
else
    fh = figure;
    set(gcf,'Position',[ 770    64   627   743]);    
    izii = 0;
    izij = 0;
    iiv  = 0;
    it   = 1;
    itii = 0;
    itij = 0;
    ieii = 0;
    ieij = 0;            
    
    if (  (any(strcmp(tf.lchname,'Ex'))  ) ...
       && (any(strcmp(tf.bchname,'Bx'))||any(strcmp(tf.bchname,'Hx')))  ) ...
    || (  (any(strcmp(tf.lchname,'Ey'))  ) ...
       && (any(strcmp(tf.bchname,'By'))||any(strcmp(tf.bchname,'Hy')))  )
        izii = 1;
    end
    if (  (any(strcmp(tf.lchname,'Ey'))  ) ...
       && (any(strcmp(tf.bchname,'Bx'))||any(strcmp(tf.bchname,'Hx')))  ) ...
    || (  (any(strcmp(tf.lchname,'Ex'))  ) ...
       && (any(strcmp(tf.bchname,'By'))||any(strcmp(tf.bchname,'Hy')))  )
        izij = 1;
    end
    if any(strcmp(tf.lchname,'Ex')) && any(strcmp(tf.bchname,'Ey')) ...
       || any(strcmp(tf.lchname,'Ey')) && any(strcmp(tf.bchname,'Ex'));
        ieij = 1;
    end
    if any(strcmp(tf.lchname,'Ex')) && any(strcmp(tf.bchname,'Ex')) ...
       || any(strcmp(tf.lchname,'Ey')) && any(strcmp(tf.bchname,'Ey'));
        ieii = 1;
    end
    if (  (any(strcmp(tf.lchname,'Bx'))||any(strcmp(tf.lchname,'Hx'))) ...
       && (any(strcmp(tf.bchname,'Bx'))||any(strcmp(tf.bchname,'Hx')))  ) ...
    || (  (any(strcmp(tf.lchname,'By'))||any(strcmp(tf.lchname,'Hy'))) ...
       && (any(strcmp(tf.bchname,'By'))||any(strcmp(tf.bchname,'Hy')))  )
        itii = 1;
    end
    if (  (any(strcmp(tf.lchname,'Bx'))||any(strcmp(tf.lchname,'Hx'))) ...
       && (any(strcmp(tf.bchname,'By'))||any(strcmp(tf.bchname,'Hy')))  ) ...
    || (  (any(strcmp(tf.lchname,'By'))||any(strcmp(tf.lchname,'Hy'))) ...
       && (any(strcmp(tf.bchname,'Bx'))||any(strcmp(tf.bchname,'Hx')))  )
        itij = 1;
    end
    if (  (any(strcmp(tf.lchname,'Bz'))||any(strcmp(tf.lchname,'Hz'))) ...
       && (any(strcmp(tf.bchname,'By'))||any(strcmp(tf.bchname,'Hy')))  ) ...
    || (  (any(strcmp(tf.lchname,'Bz'))||any(strcmp(tf.lchname,'Hz'))) ...
       && (any(strcmp(tf.bchname,'Bx'))||any(strcmp(tf.bchname,'Hx')))  )
        if it == 1; it = 1; else it = 0; end
        if iiv == 1; iiv = 1; else iiv = 0; end
    else
        it = 0; iiv = 0;
    end
    
%     
%     if ~(any(strcmp(tf.lchname,'Hz')) | any(strcmp(tf.lchname,'Bz'))) ,  iiv=0; it = 0; end
%     if ~(any(strcmp(tf.lchname,'Ex')) | any(strcmp(tf.lchname,'Ey'))) ,  izii=0; izij = 0; end
    if izii | izij
        %   find Ex/Ey data
        %         loc    = get(st(ist),'loc');   loc = loc{1};
        if any(strcmp(tf.lchname,'Ex')) ,  index   =   find(strcmp(tf.lchname,'Ex')); end
        if any(strcmp(tf.lchname,'Ey')) ,  indey   =   find(strcmp(tf.lchname,'Ey')); end

        chid    = tf.lchid(index)-2;
        tfxx   = squeeze(tf.tf(chid,1,:));
        tfxy   = squeeze(tf.tf(chid,2,:));
        tfxx_se= squeeze(tf.tf_se(chid,1,:));
        tfxy_se= squeeze(tf.tf_se(chid,2,:));
        
        tfxper = tf.periods;

        chid    = tf.lchid(indey)-2;
        tfyx   = squeeze(tf.tf(chid,1,:));
        tfyy   = squeeze(tf.tf(chid,2,:));
        tfyx_se= squeeze(tf.tf_se(chid,1,:));
        tfyy_se= squeeze(tf.tf_se(chid,2,:));
        
        tfyper  = tf.periods;
        
        axes_rhoa = axes;
        set(axes_rhoa,'Position',[  0.1300    0.5580    0.7    0.3881],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
            'TickDir','out','GridLineStyle','-', ...
            'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5],'XTicklabel',[], ...
            'Yscale','log','YMinorGrid','off','YMinorTick','off','YTick',10.^[-6 -3 -2 -1 0 1 2 3 4 5], ...
            'Nextplot','add','Visible','on');
        grid on;
        title(tit,'Fontsize',14);
        ylim(plt.rho);    xlim(plt.per);
        h = ylabel('App. Resistivity (ohm-m)','Fontsize',14,'Fontname','helvetica');
        labpos = get(h,'Position');
        set(h,'Position',[10.^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);
        if izii
            rho.xx  = abs(tfxx).^2.*tfxper/5;
            rho.yy  = abs(tfyy).^2.*tfyper/5;
            rho.xx_se = real(2*tfxx_se/5.*rho.xx.*tfxper);
            rho.yy_se = real(2*tfyy_se/5.*rho.yy.*tfyper);
            % error bars
            loglog([tfxper tfxper]',[rho.xx+rho.xx_se  rho.xx-rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper tfyper]',[rho.yy+rho.yy_se  rho.yy-rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xx+rho.xx_se rho.xx+rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xx-rho.xx_se rho.xx-rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yy+rho.yy_se rho.yy+rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yy-rho.yy_se rho.yy-rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            % data points
            loglog(tfxper,rho.xx, ...
                sym{3},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            loglog(tfyper,rho.yy, ...
                sym{4},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
        end
        if izij
            rho.xy  = abs(tfxy).^2.*tfxper/5;
            rho.yx  = abs(tfyx).^2.*tfyper/5;
            rho.xy_se = real(2*tfxy_se/5.*rho.xy.*tfxper);
            rho.yx_se = real(2*tfyx_se/5.*rho.yx.*tfyper);

            % error bars
            loglog([tfxper tfxper]',[rho.xy+rho.xy_se   rho.xy-rho.xy_se]','-k');
            loglog([tfyper tfyper]',[rho.yx+rho.yx_se   rho.yx-rho.yx_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xy+rho.xy_se rho.xy+rho.xy_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xy-rho.xy_se rho.xy-rho.xy_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yx+rho.yx_se rho.yx+rho.yx_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yx-rho.yx_se rho.yx-rho.yx_se]','-k');
            % data points
            loglog(tfxper,rho.xy, ...
                sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            loglog(tfyper,rho.yx, ...
                sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
        end
        %     legend
        if izii & izij
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.6 log10(max(plt.rho))-0.6 log10(max(plt.rho))-0.04], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.17],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            text(10^(log10(min(plt.per))+0.35+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.17],'Zxx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.17],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            text(10^(log10(min(plt.per))+1.0+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.17],'Zxy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.2+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.43],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
            text(10^(log10(min(plt.per))+0.35+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.43],'Zyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.43],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
            text(10^(log10(min(plt.per))+1.0+log10(max(plt.per))-0),10.^[log10(max(plt.rho))-0.43],'Zyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        elseif izij
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2+log10(max(plt.per))-1),10.^[log10(max(plt.rho))-0.17],sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            text(10^(log10(min(plt.per))+0.35+log10(max(plt.per))-1),10.^[log10(max(plt.rho))-0.17],'Zxy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85+log10(max(plt.per))-1),10.^[log10(max(plt.rho))-0.17],sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
            text(10^(log10(min(plt.per))+1.0+log10(max(plt.per))-1),10.^[log10(max(plt.rho))-0.17],'Zyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        elseif izii
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),10.^[log10(max(plt.rho))-0.17],sym{3},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            text(10^(log10(min(plt.per))+0.35),10.^[log10(max(plt.rho))-0.17],'Zxx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),10.^[log10(max(plt.rho))-0.17],sym{4},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
            text(10^(log10(min(plt.per))+1.0),10.^[log10(max(plt.rho))-0.17],'Zyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        end

        axes_phs= axes;
        %     if get(handles.holdon,'Value')  ==    1
        %     set(gca,'NextPlot','add');
        %     else
        %         delete(get(gca,'Children'));
        %     end
        set(axes_phs,'position',[ 0.1300    0.2732    0.7     0.2664],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
            'TickDir','out','GridLineStyle','-', ...
            'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5],'XTicklabel',[],...
            'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[0 15 30 45 60 75 90],'YTicklabel',{'0 ' '15 ' '30 ' '45 ' ' 60 ' '75 ' '90 '}, ...
            'Nextplot','add','Visible','on');
        if ~(iiv | it)
            set(gca,'XTicklabel',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5]);
            xlabel('Periods (s)','Fontsize',14,'Fontname','Helvetica');
        end
        grid on;
        ylim(plt.phs);    xlim(plt.per);
        h = ylabel('Phase (deg)','Fontsize',14,'Fontname','Helvetica');
        labpos = get(h,'Position');
        set(h,'Position',[10^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);

        if izii
            phs.xx  = angle(tfxx)*180/pi+180;
            phs.yy  = angle(tfyy)*180/pi;
            phs.xx_se = real(180./(pi*abs(tfxx)).*(tfxx_se));
            phs.yy_se = real(180./(pi*abs(tfyy)).*(tfyy_se));
            % error bars
            loglog([tfxper tfxper]',[phs.xx+phs.xx_se  phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper tfyper]',[phs.yy+phs.yy_se  phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xx+phs.xx_se phs.xx+phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xx-phs.xx_se phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yy+phs.yy_se phs.yy+phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yy-phs.yy_se phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            % data points
            loglog(tfxper,phs.xx, ...
                sym{3},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            loglog(tfyper,phs.yy, ...
                sym{4},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
        end

        if izij
            phs.xy  = angle(tfxy)*180/pi+180;
            phs.yx  = angle(tfyx)*180/pi;
            for k1 = 1:length(phs.xy)
                if phs.xy(k1) > 180
                    phs.xy(k1) = phs.xy(k1)-360;
                elseif phs.xy(k1) < -180
                    phs.xy(k1) = phs.xy(k1)+360;
                end
                if phs.yx(k1) > 180
                    phs.yx(k1) = phs.yx(k1)-360;
                elseif phs.xy(k1) < -180
                    phs.yx(k1) = phs.yx(k1)+360;
                end
            end
            phs.xy_se = real(180./(pi*abs(tfxy)).*(tfxy_se));
            phs.yx_se = real(180./(pi*abs(tfyx)).*(tfyx_se));
            % error bars
            loglog([tfxper tfxper]',[phs.xy+phs.xy_se   phs.xy-phs.xy_se]','-k');
            loglog([tfyper tfyper]',[phs.yx+phs.yx_se   phs.yx-phs.yx_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xy+phs.xy_se phs.xy+phs.xy_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xy-phs.xy_se phs.xy-phs.xy_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yx+phs.yx_se phs.yx+phs.yx_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yx-phs.yx_se phs.yx-phs.yx_se]','-k');
            % data points
            loglog(tfxper,phs.xy, ...
                sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            loglog(tfyper,phs.yx, ...
                sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
        end

    end
    %% horizontal magnetic transfer functions
    if any(strcmp(tf.lchname,'Bx'))
    else itii = 0; itij = 0;
    end
    if any(strcmp(tf.lchname,'By'))
    else itii = 0; itij = 0;
    end
    if ~ (itii | itij)
        %         axes(handles.axes_tii); set(gca,'Visible','off'); delete(get(gca,'Children'));
        %         axes(handles.axes_tij); set(gca,'Visible','off'); delete(get(gca,'Children'));
    elseif itii | itij
        %  plot horizontal magnetic transfer function
        %  find Ex data
        if any(strcmp(tf.lchname,'Bx'))     ,  index   =   find(strcmp(tf.lchname,'Bx'));
        end
        if any(strcmp(tf.lchname,'By'))     ,  indey   =   find(strcmp(tf.lchname,'By'));
        end
        chid    = tf.lchid(index)-2;
        tfxx   = squeeze(tf.tf(chid,1,:));
        tfxy   = squeeze(tf.tf(chid,2,:));
        tfxx_se= squeeze(tf.tf_se(chid,1,:));
        tfxy_se= squeeze(tf.tf_se(chid,2,:));
        
        tfxper = tf.periods;

        chid    = tf.lchid(indey)-2;
        tfyx   = squeeze(tf.tf(chid,1,:));
        tfyy   = squeeze(tf.tf(chid,2,:));
        tfyx_se= squeeze(tf.tf_se(chid,1,:));
        tfyy_se= squeeze(tf.tf_se(chid,2,:));
        
        tfyper  = tf.periods;
        
        axes_rhoa = axes;
        grid on;
        set(axes_rhoa,'Position',[  0.1300    0.5580    0.7    0.3881],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',12,'Fontweight','bold','Linewidth',1, ...
            'TickDir','out','GridLineStyle','-', ...
            'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5],'XTicklabel',[], ...
            'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[-1 0 1 2], ...
            'Nextplot','add','Visible','on');
        
        ylim([-1 2]);    xlim(plt.per);
        h = ylabel('Real part','Fontsize',14,'Fontname','helvetica');
        labpos = get(h,'Position');
        set(h,'Position',[10.^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);
        if itii
            rho.xx  = real(tfxx);
            rho.yy  = real(tfyy);
            rho.xx_se = real(tfxx_se);
            rho.yy_se = real(tfyy_se);
            % error bars
            loglog([tfxper tfxper]',[rho.xx+rho.xx_se  rho.xx-rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper tfyper]',[rho.yy+rho.yy_se  rho.yy-rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xx+rho.xx_se rho.xx+rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xx-rho.xx_se rho.xx-rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yy+rho.yy_se rho.yy+rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yy-rho.yy_se rho.yy-rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            % data points
            loglog(tfxper,rho.xx, ...
                sym{3},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            loglog(tfyper,rho.yy, ...
                sym{4},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
        end
        if itij
            rho.xy  = real(tfxy);
            rho.yx  = real(tfyx);
            rho.xy_se = real(tfxy_se);
            rho.yx_se = real(tfyx_se);

            % error bars
            loglog([tfxper tfxper]',[rho.xy+rho.xy_se   rho.xy-rho.xy_se]','-k');
            loglog([tfyper tfyper]',[rho.yx+rho.yx_se   rho.yx-rho.yx_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xy+rho.xy_se rho.xy+rho.xy_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xy-rho.xy_se rho.xy-rho.xy_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yx+rho.yx_se rho.yx+rho.yx_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yx-rho.yx_se rho.yx-rho.yx_se]','-k');
            % data points
            loglog(tfxper,rho.xy, ...
                sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            loglog(tfyper,rho.yx, ...
                sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
        end
        %     legend
        if itii & itij
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                [max(plt.rho)-0.06 max(plt.rho)-0.6 max(plt.rho)-0.6 max(plt.rho)-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),[(max(plt.rho))-0.17],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            text(10^(log10(min(plt.per))+0.35),[(max(plt.rho))-0.17],'Bxx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),[(max(plt.rho))-0.17],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            text(10^(log10(min(plt.per))+1.0),[(max(plt.rho))-0.17],'Bxy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.2),[(max(plt.rho))-0.43],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
            text(10^(log10(min(plt.per))+0.35),[(max(plt.rho))-0.43],'Byx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),[(max(plt.rho))-0.43],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
            text(10^(log10(min(plt.per))+1.0),[(max(plt.rho))-0.43],'Byy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        elseif itij
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),10.^[log10(max(plt.rho))-0.17],sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            text(10^(log10(min(plt.per))+0.35),10.^[log10(max(plt.rho))-0.17],'Bxy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),10.^[log10(max(plt.rho))-0.17],sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
            text(10^(log10(min(plt.per))+1.0),10.^[log10(max(plt.rho))-0.17],'Byx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        elseif itii
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),10.^[log10(max(plt.rho))-0.17],sym{3},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            text(10^(log10(min(plt.per))+0.35),10.^[log10(max(plt.rho))-0.17],'Bxx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),10.^[log10(max(plt.rho))-0.17],sym{4},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
            text(10^(log10(min(plt.per))+1.0),10.^[log10(max(plt.rho))-0.17],'Byy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        end

        axes_phs= axes;
        %     if get(handles.holdon,'Value')  ==    1
        %     set(gca,'NextPlot','add');
        %     else
        %         delete(get(gca,'Children'));
        %     end
        grid on;
        set(axes_phs,'position',[ 0.1300    0.2732    0.7     0.2664],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',12,'Fontweight','bold','Linewidth',1, ...
            'TickDir','out','GridLineStyle','-', ...
            'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5],'XTicklabel',[],...
            'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[-1 0 1],'YTicklabel',{'-1' '0 ' '1 '}, ...
            'Nextplot','add','Visible','on');
        if ~(iiv | it)
            set(gca,'XTicklabel',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5]);
            xlabel('Periods (s)','Fontsize',14,'Fontname','Helvetica');
        end
        
        ylim([-1 1]);    xlim(plt.per);
        h = ylabel('imag. part','Fontsize',14,'Fontname','Helvetica');
        labpos = get(h,'Position');
        set(h,'Position',[10^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);

        if itii
            phs.xx  = imag(tfxx);
            phs.yy  = imag(tfyy);
            phs.xx_se = real(tfxx_se);
            phs.yy_se = real(tfyy_se);
            % error bars
            loglog([tfxper tfxper]',[phs.xx+phs.xx_se  phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper tfyper]',[phs.yy+phs.yy_se  phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xx+phs.xx_se phs.xx+phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xx-phs.xx_se phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yy+phs.yy_se phs.yy+phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yy-phs.yy_se phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            % data points
            loglog(tfxper,phs.xx, ...
                sym{3},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            loglog(tfyper,phs.yy, ...
                sym{4},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
        end

        if itij
            phs.xy  = imag(tfxy);
            phs.yx  = imag(tfyx);
            %             for k1 = 1:length(phs.xy)
            %                 if phs.xy(k1) > 180
            %                     phs.xy(k1) = phs.xy(k1)-360;
            %                 elseif phs.xy(k1) < -180
            %                     phs.xy(k1) = phs.xy(k1)+360;
            %                 end
            %                 if phs.yx(k1) > 180
            %                     phs.yx(k1) = phs.yx(k1)-360;
            %                 elseif phs.xy(k1) < -180
            %                     phs.yx(k1) = phs.yx(k1)+360;
            %                 end
            %             end
            phs.xy_se = real(tfxy_se);
            phs.yx_se = real(tfyx_se);
            % error bars
            loglog([tfxper tfxper]',[phs.xy+phs.xy_se   phs.xy-phs.xy_se]','-k');
            loglog([tfyper tfyper]',[phs.yx+phs.yx_se   phs.yx-phs.yx_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xy+phs.xy_se phs.xy+phs.xy_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xy-phs.xy_se phs.xy-phs.xy_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yx+phs.yx_se phs.yx+phs.yx_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yx-phs.yx_se phs.yx-phs.yx_se]','-k');
            % data points
            loglog(tfxper,phs.xy, ...
                sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            loglog(tfyper,phs.yx, ...
                sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
        end
    end
%     if any(strcmp(tf.lchname,'Hx'))
%     elseif any(strcmp(tf.lchname,'Bx'))
%     else itii = 0; itij = 0;
%     end
%     if any(strcmp(tf.lchname,'Hy'))
%     elseif any(strcmp(tf.lchname,'By'))
%     else itii = 0; itij = 0;
%     end
%     if ~ (itii | itij)
%         %         axes(handles.axes_tii); set(gca,'Visible','off'); delete(get(gca,'Children'));
%         %         axes(handles.axes_tij); set(gca,'Visible','off'); delete(get(gca,'Children'));
%     elseif itii | itij
%         %  plot horizontal magnetic transfer function
%         %  find Hx data
%         if any(strcmp(tf.lchname,'Hx'))     ,  indbx   =   find(strcmp(tf.lchname,'Hx'));
%         elseif any(strcmp(tf.lchname,'Bx')) ,  indbx   =   find(strcmp(tf.lchname,'Bx'));
%         end
%         if any(strcmp(tf.lchname,'Hy'))     ,  indby   =   find(strcmp(tf.lchname,'Hy'));
%         elseif any(strcmp(tf.lchname,'By')) ,  indby   =   find(strcmp(tf.lchname,'By'));
%         end
%         chid   = tf.lchid(indbx)-2;
%         data = tf;
%         tf.xx   = squeeze(data.tf(chid,1,:));
%         tf.xy   = squeeze(data.tf(chid,2,:));
%         tf.xx_se= squeeze(data.tf_se(chid,1,:));
%         tf.xy_se= squeeze(data.tf_se(chid,2,:));
%         %          tf.smooth= data.smooth;
%         tf.smooth = [];
%         use = data.use{chid};
%         tf.per = data.periods;
%         tf.xx   = tf.xx(use);     tf.xy   = tf.xy(use);
%         tf.xx_se= tf.xx_se(use);  tf.xy_se= tf.xy_se(use);
%         tf.per = tf.per(use)';
% 
%         chid   = tf.lchid(indby)-2;
%         tf.yx   = squeeze(data.tf(chid,1,:));
%         tf.yy   = squeeze(data.tf(chid,2,:));
%         tf.yx_se= squeeze(data.tf_se(chid,1,:));
%         tf.yy_se= squeeze(data.tf_se(chid,2,:));
%         use = data.use{chid};
%         tf.per = data.periods;
%         tf.yx   = tf.yx(use);     tf.yy   = tf.yy(use);
%         tf.yx_se= tf.yx_se(use);  tf.yy_se= tf.yy_se(use);
%         tf.per = tf.per(use)';
% 
%         axes(handles.axes_tii);
%         delete(get(gca,'Children'));
%         %     end
%         set(gca,'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
%             'TickDir','out','GridLineStyle','-', ...
%             'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5], ... %,'Xcolor',[0.8 0.8 0.8], ...
%             'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]-1, ... % 'Ycolor',[0.8 0.8 0.8], ...
%             'YTickLabel',{'1.0' '-0.8' '-0.6' '-0.4' '-0.2' '0.0' '0.2' '0.4' '0.6' '0.8' '1.0' '1.2' '1.4'}, ...
%             'Nextplot','add','Visible','on');
%         grid on;
%         plt.tii =   [-1 1];
%         ylim(plt.tii);    xlim(plt.per);
%         if itii
%             h   =   ylabel('htf','Fontsize',14,'Fontname','Helvetica');
%             labpos = get(h,'Position');
%             set(h,'Position',[10.^(log10(min(plt.per))-0.3) labpos(2),labpos(3)]);
%             tf.xx_se = sqrt(tf.xx_se); tf.yy_se = sqrt(tf.yy_se);
%             loglog([tf.per tf.per]',imag([tf.xx+i*tf.xx_se  tf.xx-i*tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per tf.per]',+real([tf.xx+tf.xx_se  tf.xx-tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.xx+i*tf.xx_se tf.xx+i*tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.xx-i*tf.xx_se tf.xx-i*tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.xx+tf.xx_se tf.xx+tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.xx-tf.xx_se tf.xx-tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per tf.per]',imag([tf.yy+i*tf.yy_se  tf.yy-i*tf.yy_se])','-k');
%             loglog([tf.per tf.per]',+real([tf.yy+tf.yy_se  tf.yy-tf.yy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.yy+i*tf.yy_se tf.yy+i*tf.yy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.yy-i*tf.yy_se tf.yy-i*tf.yy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.yy+tf.yy_se tf.yy+tf.yy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.yy-tf.yy_se tf.yy-tf.yy_se])','-k');
%             % data points
%             semilogx(tf.per,imag(tf.xx), ...
%                 'o','MarkerSize',4,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%             semilogx(tf.per,+real(tf.xx), ...
%                 'o','MarkerSize',4,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             semilogx(tf.per,imag(tf.yy), ...
%                 'o','MarkerSize',5,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
%             semilogx(tf.per,+real(tf.yy), ...
%                 'o','MarkerSize',5,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
%             %   legend
%             
%             if smoot
%                 if ~isempty(tf.smooth)
%                     if ~isempty(find(strcmp({tf.smooth{:,1}},'Hx')))
%                         ind = find(strcmp({tf.smooth{:,1}},'Hx'));
%                         tmp = tf.smooth(ind,:);
%                         if ~isempty(tmp{4})
%                             mtf.xxs = (tmp{3});
%                             loglog(tmp{2}(tmp{5}),real(mtf.xxs(tmp{5})),'-','Color',col{3});
%                             loglog(tmp{2}(tmp{5}),imag(mtf.xxs(tmp{5})),'-','Color',col{4});
%                         end
%                     end
%                     if ~isempty(find(strcmp({tf.smooth{:,1}},'Hy')))
%                         ind = find(strcmp({tf.smooth{:,1}},'Hy'));
%                         tmp = tf.smooth(ind,:);
%                         if ~isempty(tmp{3})
%                             mtf.yys = (tmp{4});
%                             loglog(tmp{2}(tmp{5}),real(mtf.yys(tmp{5})),'-','Color',col{1});
%                             loglog(tmp{2}(tmp{5}),imag(mtf.yys(tmp{5})),'-','Color',col{2});
%                         end
%                     end
%                 end
%             end
%             
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 [max(plt.tii)-0.02 max(plt.tii)-0.13 max(plt.tii)-0.13 max(plt.tii)-0.02], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
%             plot(10^(log10(min(plt.per))+0.2),[max(plt.tii)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor','k');
%             text(10^(log10(min(plt.per))+0.35),[max(plt.tii)-0.07],'Tyyr','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             plot(10^(log10(min(plt.per))+0.85),[max(plt.tii)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor','k');
%             text(10^(log10(min(plt.per))+1.0),[max(plt.tii)-0.07],'Tyyi','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 [min(plt.tii)+0.02 min(plt.tii)+0.13 min(plt.tii)+0.13 min(plt.tii)+0.02], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
%             plot(10^(log10(min(plt.per))+0.2),[min(plt.tii)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             text(10^(log10(min(plt.per))+0.35),[min(plt.tii)+0.07],'Txxr','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             plot(10^(log10(min(plt.per))+0.85),[min(plt.tii)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%             text(10^(log10(min(plt.per))+1.0),[min(plt.tii)+0.07],'Txxi','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%         end
%         axes(handles.axes_tij);
%         delete(get(gca,'Children'));
%         %     end
%         set(gca,'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
%             'TickDir','out','GridLineStyle','-', ...
%             'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5], ... %,'Xcolor',[0.8 0.8 0.8], ...
%             'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]-1, ... % 'Ycolor',[0.8 0.8 0.8], ...
%             'YTickLabel',{'1.0' '-0.8' '-0.6' '-0.4' '-0.2' '0.0' '0.2' '0.4' '0.6' '0.8' '1.0'  '1.2' '1.4'}, ...
%             'Nextplot','add','Visible','on');
%         grid on;
%         plt.tij =   [-1 1];
%         ylim(plt.tij);    xlim(plt.per);
%         if itij
%             h   =   ylabel('htf','Fontsize',14,'Fontname','Helvetica');
%             labpos = get(h,'Position');
%             set(h,'Position',[10.^(log10(min(plt.per))-0.3) labpos(2),labpos(3)]);
%             tf.yx_se = sqrt(tf.yx_se); tf.xy_se = sqrt(tf.xy_se);
%             loglog([tf.per tf.per]',imag([tf.yx+i*tf.yx_se  tf.yx-i*tf.yx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per tf.per]',real([tf.yx+tf.yx_se  tf.yx-tf.yx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.yx+i*tf.yx_se tf.yx+i*tf.yx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.yx-i*tf.yx_se tf.yx-i*tf.yx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.yx+tf.yx_se tf.yx+tf.yx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.yx-tf.yx_se tf.yx-tf.yx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per tf.per]',imag([tf.xy+i*tf.xy_se  tf.xy-i*tf.xy_se])','-k');
%             loglog([tf.per tf.per]',real([tf.xy+tf.xy_se  tf.xy-tf.xy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.xy+i*tf.xy_se tf.xy+i*tf.xy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 imag([tf.xy-i*tf.xy_se tf.xy-i*tf.xy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.xy+tf.xy_se tf.xy+tf.xy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 real([tf.xy-tf.xy_se tf.xy-tf.xy_se])','-k');
%             % data points
%             semilogx(tf.per,imag(tf.yx), ...
%                 'o','MarkerSize',4,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%             semilogx(tf.per,real(tf.yx), ...
%                 'o','MarkerSize',4,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             semilogx(tf.per,imag(tf.xy), ...
%                 'o','MarkerSize',5,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
%             semilogx(tf.per,real(tf.xy), ...
%                 'o','MarkerSize',5,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
%             %   legend
%             if smoot
%                 if ~isempty(tf.smooth)
%                     if ~isempty(find(strcmp({tf.smooth{:,1}},'Hx')))
%                         ind = find(strcmp({tf.smooth{:,1}},'Hx'));
%                         tmp = tf.smooth(ind,:);
%                         if ~isempty(tmp{4})
%                             mtf.xys = (tmp{4});
%                             loglog(tmp{2}(tmp{5}),real(mtf.xys(tmp{5})),'-','Color',col{3});
%                             loglog(tmp{2}(tmp{5}),imag(mtf.xys(tmp{5})),'-','Color',col{4});
%                         end
%                     end
%                     if ~isempty(find(strcmp({tf.smooth{:,1}},'Hy')))
%                         ind = find(strcmp({tf.smooth{:,1}},'Hy'));
%                         tmp = tf.smooth(ind,:);
%                         if ~isempty(tmp{3})
%                             mtf.yxs = (tmp{3});
%                             loglog(tmp{2}(tmp{5}),real(mtf.yxs(tmp{5})),'-','Color',col{1});
%                             loglog(tmp{2}(tmp{5}),imag(mtf.yxs(tmp{5})),'-','Color',col{2});
%                         end
%                     end
%                 end
%             end
%             
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 [max(plt.tij)-0.02 max(plt.tij)-0.13 max(plt.tij)-0.13 max(plt.tij)-0.02], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
%             plot(10^(log10(min(plt.per))+0.2),[max(plt.tij)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor','k');
%             text(10^(log10(min(plt.per))+0.35),[max(plt.tij)-0.07],'Tyxr','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             plot(10^(log10(min(plt.per))+0.85),[max(plt.tij)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor','k');
%             text(10^(log10(min(plt.per))+1.0),[max(plt.tij)-0.07],'Tyxi','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 [min(plt.tij)+0.02 min(plt.tij)+0.13 min(plt.tij)+0.13 min(plt.tij)+0.02], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
%             plot(10^(log10(min(plt.per))+0.2),[min(plt.tij)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             text(10^(log10(min(plt.per))+0.35),[min(plt.tij)+0.07],'Txyr','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             plot(10^(log10(min(plt.per))+0.85),[min(plt.tij)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%             text(10^(log10(min(plt.per))+1.0),[min(plt.tij)+0.07],'Txyi','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%         end
%     end
    %%
     %% horizontal electric transfer functions
    if any(strcmp(tf.lchname,'Ex'))
    else ieii = 0; ieij = 0;
    end
    if any(strcmp(tf.lchname,'Ey'))
    else ieii = 0; ieij = 0;
    end
    if ~ (ieii | ieij)
        %         axes(handles.axes_tii); set(gca,'Visible','off'); delete(get(gca,'Children'));
        %         axes(handles.axes_tij); set(gca,'Visible','off'); delete(get(gca,'Children'));
    elseif ieii | ieij
        %  plot horizontal magnetic transfer function
        %  find Ex data
        if any(strcmp(tf.lchname,'Ex'))     ,  index   =   find(strcmp(tf.lchname,'Ex'));
        end
        if any(strcmp(tf.lchname,'Ey'))     ,  indey   =   find(strcmp(tf.lchname,'Ey'));
        end
        chid    = tf.lchid(index)-2;
        tfxx   = squeeze(tf.tf(chid,1,:));
        tfxy   = squeeze(tf.tf(chid,2,:));
        tfxx_se= squeeze(tf.tf_se(chid,1,:));
        tfxy_se= squeeze(tf.tf_se(chid,2,:));
        
        tfxper = tf.periods;

        chid    = tf.lchid(indey)-2;
        tfyx   = squeeze(tf.tf(chid,1,:));
        tfyy   = squeeze(tf.tf(chid,2,:));
        tfyx_se= squeeze(tf.tf_se(chid,1,:));
        tfyy_se= squeeze(tf.tf_se(chid,2,:));
        
        tfyper  = tf.periods;
        
        axes_rhoa = axes;
        grid on;
        set(axes_rhoa,'Position',[  0.1300    0.5580    0.7    0.3881],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',12,'Fontweight','bold','Linewidth',1, ...
            'TickDir','out','GridLineStyle','-', ...
            'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5],'XTicklabel',[], ...
            'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[-1 -0 1 2], ...
            'Nextplot','add','Visible','on');
        plt.rho = [-1 2];
        ylim(plt.rho);    xlim(plt.per);
        h = ylabel('Real part','Fontsize',14,'Fontname','helvetica');
        labpos = get(h,'Position');
        set(h,'Position',[10.^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);
        if ieii
            rho.xx  = real(tfxx);
            rho.yy  = real(tfyy);
            rho.xx_se = real(tfxx_se);
            rho.yy_se = real(tfyy_se);
            % error bars
            loglog([tfxper tfxper]',[rho.xx+rho.xx_se  rho.xx-rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper tfyper]',[rho.yy+rho.yy_se  rho.yy-rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xx+rho.xx_se rho.xx+rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xx-rho.xx_se rho.xx-rho.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yy+rho.yy_se rho.yy+rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yy-rho.yy_se rho.yy-rho.yy_se]','-k','color',[0.7 0.7 0.7]);
            % data points
            loglog(tfxper,rho.xx, ...
                sym{3},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            loglog(tfyper,rho.yy, ...
                sym{4},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
        end
        if ieij
            rho.xy  = real(tfxy);
            rho.yx  = real(tfyx);
            rho.xy_se = real(tfxy_se);
            rho.yx_se = real(tfyx_se);

            % error bars
            loglog([tfxper tfxper]',[rho.xy+rho.xy_se   rho.xy-rho.xy_se]','-k');
            loglog([tfyper tfyper]',[rho.yx+rho.yx_se   rho.yx-rho.yx_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xy+rho.xy_se rho.xy+rho.xy_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [rho.xy-rho.xy_se rho.xy-rho.xy_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yx+rho.yx_se rho.yx+rho.yx_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [rho.yx-rho.yx_se rho.yx-rho.yx_se]','-k');
            % data points
            loglog(tfxper,rho.xy, ...
                sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            loglog(tfyper,rho.yx, ...
                sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
        end
        %     legend
        if ieii & ieij
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                [max(plt.rho)-0.06 max(plt.rho)-0.6 max(plt.rho)-0.6 max(plt.rho)-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),[(max(plt.rho))-0.17],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            text(10^(log10(min(plt.per))+0.35),[(max(plt.rho))-0.17],'Exx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),[(max(plt.rho))-0.17],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            text(10^(log10(min(plt.per))+1.0),[(max(plt.rho))-0.17],'Exy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.2),[(max(plt.rho))-0.43],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
            text(10^(log10(min(plt.per))+0.35),[(max(plt.rho))-0.43],'Eyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),[(max(plt.rho))-0.43],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
            text(10^(log10(min(plt.per))+1.0),[(max(plt.rho))-0.43],'Eyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        elseif ieij
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),10.^[log10(max(plt.rho))-0.17],sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            text(10^(log10(min(plt.per))+0.35),10.^[log10(max(plt.rho))-0.17],'Exy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),10.^[log10(max(plt.rho))-0.17],sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
            text(10^(log10(min(plt.per))+1.0),10.^[log10(max(plt.rho))-0.17],'Eyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        elseif ieii
            patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                10.^[log10(max(plt.rho))-0.04 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.3 log10(max(plt.rho))-0.04], ...
                'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
            plot(10^(log10(min(plt.per))+0.2),10.^[log10(max(plt.rho))-0.17],sym{3},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            text(10^(log10(min(plt.per))+0.35),10.^[log10(max(plt.rho))-0.17],'Exx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
            plot(10^(log10(min(plt.per))+0.85),10.^[log10(max(plt.rho))-0.17],sym{4},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
            text(10^(log10(min(plt.per))+1.0),10.^[log10(max(plt.rho))-0.17],'Eyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
        end

        axes_phs= axes;
        %     if get(handles.holdon,'Value')  ==    1
        %     set(gca,'NextPlot','add');
        %     else
        %         delete(get(gca,'Children'));
        %     end
        grid on;
        set(axes_phs,'position',[ 0.1300    0.2732    0.7     0.2664],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',12,'Fontweight','bold','Linewidth',1, ...
            'TickDir','out','GridLineStyle','-', ...
            'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5],'XTicklabel',[],...
            'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[-1 0 1 2],'YTicklabel',{'-1' '0 ' '1 ' '2 '}, ...
            'Nextplot','add','Visible','on');
        if ~(iiv | it)
            set(gca,'XTicklabel',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5]);
            xlabel('Periods (s)','Fontsize',14,'Fontname','Helvetica');
        end
        plt.phs = [-1 2];
        ylim(plt.phs);    xlim(plt.per);
        h = ylabel('imag','Fontsize',14,'Fontname','Helvetica');
        labpos = get(h,'Position');
        set(h,'Position',[10^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);

        if ieii
            phs.xx  = imag(tfxx);
            phs.yy  = imag(tfyy);
            phs.xx_se = real(tfxy_se);;%real(180./(pi*abs(tfxx)).*(tfxx_se*2));
            phs.yy_se = real(tfxy_se);;%real(180./(pi*abs(tfyy)).*(tfyy_se*2));
            % error bars
            loglog([tfxper tfxper]',[phs.xx+phs.xx_se  phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper tfyper]',[phs.yy+phs.yy_se  phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xx+phs.xx_se phs.xx+phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xx-phs.xx_se phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yy+phs.yy_se phs.yy+phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yy-phs.yy_se phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
            % data points
            loglog(tfxper,phs.xx, ...
                sym{3},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
            loglog(tfyper,phs.yy, ...
                sym{4},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
        end

        if ieij
            phs.xy  = imag(tfxy);
            phs.yx  = imag(tfyx);
            %             for k1 = 1:length(phs.xy)
            %                 if phs.xy(k1) > 180
            %                     phs.xy(k1) = phs.xy(k1)-360;
            %                 elseif phs.xy(k1) < -180
            %                     phs.xy(k1) = phs.xy(k1)+360;
            %                 end
            %                 if phs.yx(k1) > 180
            %                     phs.yx(k1) = phs.yx(k1)-360;
            %                 elseif phs.xy(k1) < -180
            %                     phs.yx(k1) = phs.yx(k1)+360;
            %                 end
            %             end
            phs.xy_se = real(tfxy_se);;%real(180./(pi*abs(tfxy)).*(tfxy_se*2));
            phs.yx_se = real(tfxy_se);;%real(180./(pi*abs(tfyx)).*(tfyx_se*2));
            % error bars
            loglog([tfxper tfxper]',[phs.xy+phs.xy_se   phs.xy-phs.xy_se]','-k');
            loglog([tfyper tfyper]',[phs.yx+phs.yx_se   phs.yx-phs.yx_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xy+phs.xy_se phs.xy+phs.xy_se]','-k');
            loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
                [phs.xy-phs.xy_se phs.xy-phs.xy_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yx+phs.yx_se phs.yx+phs.yx_se]','-k');
            loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
                [phs.yx-phs.yx_se phs.yx-phs.yx_se]','-k');
            % data points
            loglog(tfxper,phs.xy, ...
                sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
            loglog(tfyper,phs.yx, ...
                sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
        end

%         chid   = tf.lchid(indbx)-2;
%         tf.xx   = squeeze(tf.tf(chid,1,:));
%         tf.xy   = squeeze(tf.tf(chid,2,:));
%         tf.xx_se= squeeze(tf.tf_se(chid,1,:));
%         tf.xy_se= squeeze(tf.tf_se(chid,2,:));
%          %tf.smooth= data.smooth;
%         %use = tf.use{chid};
%         tf.per = tf.periods;
% %         tf.xx   = tf.xx(use);     tf.xy   = tf.xy(use);
% %         tf.xx_se= tf.xx_se(use);  tf.xy_se= tf.xy_se(use);
% %         tf.per = tf.per(use)';
% 
%         chid   = tf.lchid(indby)-2;
%         tf.yx   = squeeze(tf.tf(chid,1,:));
%         tf.yy   = squeeze(tf.tf(chid,2,:));
%         tf.yx_se= squeeze(tf.tf_se(chid,1,:));
%         tf.yy_se= squeeze(tf.tf_se(chid,2,:));
% %         use = tf.use{chid};
%         tf.per = tf.periods;
%         %         tf.yx   = tf.yx(use);     tf.yy   = tf.yy(use);
%         %         tf.yx_se= tf.yx_se(use);  tf.yy_se= tf.yy_se(use);
%         %         tf.per = tf.per(use)';
% 
% %         axes(handles.axes_tii);
%         axes_tii = axes;
% %         delete(get(gca,'Children'));
%         %     end
%         set(axes_tii,'Position',[ 0.130000000000000   0.514351320321470   0.798086838534600   0.431748679678531],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
%             'TickDir','out','GridLineStyle','-', ...
%             'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5], ... %,'Xcolor',[0.8 0.8 0.8], ...
%             'Yscale','log','YMinorGrid','off','YMinorTick','off','YTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2], ... % 'Ycolor',[0.8 0.8 0.8], ...
%             'Nextplot','add','Visible','on');
%         grid on;
%         plt.tii =   [1e-3 1e1];
%         ylim(plt.tii);    xlim(plt.per);
%         if ieii
%             h   =   ylabel('etf','Fontsize',14,'Fontname','Helvetica');
%             labpos = get(h,'Position');
%             set(h,'Position',[10.^(log10(min(plt.per))-0.3) labpos(2),labpos(3)]);
%             tf.xx_se = sqrt(tf.xx_se); tf.yy_se = sqrt(tf.yy_se);
%             tf.xy_se = sqrt(tf.xy_se); tf.yx_se = sqrt(tf.yx_se);
%             
%             loglog([tf.per tf.per]',abs([tf.xx+tf.xx_se  tf.xx-tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per tf.per]',abs([tf.xy+tf.xy_se  tf.xy-tf.xy_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.xx+tf.xx_se tf.xx+tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.xx-tf.xx_se tf.xx-tf.xx_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.xy+tf.xy_se tf.xy+tf.xy_se])','-','color',[0.7 0.7 0.7]);
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.xy-tf.xy_se tf.xy-tf.xy_se])','-','color',[0.7 0.7 0.7]);
%             
%             loglog([tf.per tf.per]',abs([tf.yy+tf.yy_se  tf.yy-tf.yy_se])','-k');
%             loglog([tf.per tf.per]',abs([tf.yx+tf.yx_se  tf.yx-tf.yx_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.yy+tf.yy_se tf.yy+tf.yy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.yy-tf.yy_se tf.yy-tf.yy_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.yx+tf.yx_se tf.yx+tf.yx_se])','-k');
%             loglog([tf.per-10.^(log10(tf.per*0.08)) tf.per+10.^(log10(tf.per*0.08))]', ...
%                 abs([tf.yx-tf.yx_se tf.yx-tf.yx_se])','-k');
%             % data points
%             semilogx(tf.per,abs(tf.xx), ...
%                 'o','MarkerSize',4,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%             semilogx(tf.per,abs(tf.xy), ...
%                 'o','MarkerSize',4,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             semilogx(tf.per,abs(tf.yx), ...
%                 'o','MarkerSize',5,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
%             semilogx(tf.per,abs(tf.yy), ...
%                 'o','MarkerSize',5,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
%             %   legend
%             
% %             if smoot
% %                 if ~isempty(tf.smooth)
% %                     if ~isempty(find(strcmp({tf.smooth{:,1}},'Hx')))
% %                         ind = find(strcmp({tf.smooth{:,1}},'Hx'));
% %                         tmp = tf.smooth(ind,:);
% %                         if ~isempty(tmp{4})
% %                             mtf.xxs = (tmp{3});
% %                             loglog(tmp{2}(tmp{5}),real(mtf.xxs(tmp{5})),'-','Color',col{3});
% %                             loglog(tmp{2}(tmp{5}),imag(mtf.xxs(tmp{5})),'-','Color',col{4});
% %                         end
% %                     end
% %                     if ~isempty(find(strcmp({tf.smooth{:,1}},'Hy')))
% %                         ind = find(strcmp({tf.smooth{:,1}},'Hy'));
% %                         tmp = tf.smooth(ind,:);
% %                         if ~isempty(tmp{3})
% %                             mtf.yys = (tmp{4});
% %                             loglog(tmp{2}(tmp{5}),real(mtf.yys(tmp{5})),'-','Color',col{1});
% %                             loglog(tmp{2}(tmp{5}),imag(mtf.yys(tmp{5})),'-','Color',col{2});
% %                         end
% %                     end
% %                 end
% %             end
% %             
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 [max(plt.tii)-0.02 max(plt.tii)-0.13 max(plt.tii)-0.13 max(plt.tii)-0.02], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
%             plot(10^(log10(min(plt.per))+0.2),[max(plt.tii)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor','k');
%             text(10^(log10(min(plt.per))+0.35),[max(plt.tii)-0.07],'Eyy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             plot(10^(log10(min(plt.per))+0.85),[max(plt.tii)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor','k');
%             text(10^(log10(min(plt.per))+1.0),[max(plt.tii)-0.07],'Eyx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
%                 [min(plt.tii)+0.02 min(plt.tii)+0.13 min(plt.tii)+0.13 min(plt.tii)+0.02], ...
%                 'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
%             plot(10^(log10(min(plt.per))+0.2),[min(plt.tii)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             text(10^(log10(min(plt.per))+0.35),[min(plt.tii)+0.07],'Exy','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%             plot(10^(log10(min(plt.per))+0.85),[min(plt.tii)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%             text(10^(log10(min(plt.per))+1.0),[min(plt.tii)+0.07],'Exx','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
%         end
% %         axes(handles.axes_tij);
%         axes_tij = axes;
% %         delete(get(gca,'Children'));
%         %     end
%         set(axes_tij,'position',[ 0.130000000000000   0.096440872560276   0.803514246947083   0.373134328358209],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
%             'TickDir','out','GridLineStyle','-', ...
%             'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5], ... %,'Xcolor',[0.8 0.8 0.8], ...
%             'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]-1, ... % 'Ycolor',[0.8 0.8 0.8], ...
%             'YTickLabel',{'1.0' '-0.8' '-0.6' '-0.4' '-0.2' '0.0' '0.2' '0.4' '0.6' '0.8' '1.0'  '1.2' '1.4'}, ...
%             'Nextplot','add','Visible','on');
%         grid on;
%         plt.tij =   [-180 180];
%         ylim(plt.tij);    xlim(plt.per);
%         if ieij
%             h   =   ylabel('etf','Fontsize',14,'Fontname','Helvetica');
%             labpos = get(h,'Position');
%             set(h,'Position',[10.^(log10(min(plt.per))-0.3) labpos(2),labpos(3)]);
%             phs.xx  = angle(tfxx)*180/pi+180;
%             phs.yy  = angle(tfyy)*180/pi;
%             phs.xx_se = real(180./(pi*abs(tfxx)).*sqrt(tfxx_se/2));
%             phs.yy_se = real(180./(pi*abs(tfyy)).*sqrt(tfyy_se/2));
%             % error bars
%             loglog([tfxper tfxper]',[phs.xx+phs.xx_se  phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
%             loglog([tfyper tfyper]',[phs.yy+phs.yy_se  phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
%             loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
%                 [phs.xx+phs.xx_se phs.xx+phs.xx_se]','-k','color',[0.7 0.7 0.7]);
%             loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
%                 [phs.xx-phs.xx_se phs.xx-phs.xx_se]','-k','color',[0.7 0.7 0.7]);
%             loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
%                 [phs.yy+phs.yy_se phs.yy+phs.yy_se]','-k','color',[0.7 0.7 0.7]);
%             loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
%                 [phs.yy-phs.yy_se phs.yy-phs.yy_se]','-k','color',[0.7 0.7 0.7]);
%             % data points
%             loglog(tfxper,phs.xx, ...
%                 sym{3},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
%             loglog(tfyper,phs.yy, ...
%                 sym{4},'MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
%         
% 
%         phs.xy  = angle(tfxy)*180/pi+180;
%             phs.yx  = angle(tfyx)*180/pi;
%             for k1 = 1:length(phs.xy)
%                 if phs.xy(k1) > 180
%                     phs.xy(k1) = phs.xy(k1)-360;
%                 elseif phs.xy(k1) < -180
%                     phs.xy(k1) = phs.xy(k1)+360;
%                 end
%                 if phs.yx(k1) > 180
%                     phs.yx(k1) = phs.yx(k1)-360;
%                 elseif phs.xy(k1) < -180
%                     phs.yx(k1) = phs.yx(k1)+360;
%                 end
%             end
%             phs.xy_se = real(180./(pi*abs(tfxy)).*sqrt(tfxy_se/2));
%             phs.yx_se = real(180./(pi*abs(tfyx)).*sqrt(tfyx_se/2));
%             % error bars
%             loglog([tfxper tfxper]',[phs.xy+phs.xy_se   phs.xy-phs.xy_se]','-k');
%             loglog([tfyper tfyper]',[phs.yx+phs.yx_se   phs.yx-phs.yx_se]','-k');
%             loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
%                 [phs.xy+phs.xy_se phs.xy+phs.xy_se]','-k');
%             loglog([tfxper-10.^(log10(tfxper*0.08)) tfxper+10.^(log10(tfxper*0.08))]', ...
%                 [phs.xy-phs.xy_se phs.xy-phs.xy_se]','-k');
%             loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
%                 [phs.yx+phs.yx_se phs.yx+phs.yx_se]','-k');
%             loglog([tfyper-10.^(log10(tfyper*0.08)) tfyper+10.^(log10(tfyper*0.08))]', ...
%                 [phs.yx-phs.yx_se phs.yx-phs.yx_se]','-k');
%             % data points
%             loglog(tfxper,phs.xy, ...
%                 sym{1},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
%             loglog(tfyper,phs.yx, ...
%                 sym{2},'MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
%         end        
    end

    
    %%

    if ~(it | iiv)
      %  axes_tip = axes; 
%     elseif ~(any(strcmp(loc.chname,'Hz')) | any(strcmp(loc.chname,'Bz')))
        
    elseif it | iiv  %   plot vertical magnetic transfer function
        axes_tip=axes;  
        %   find Hz data
        indbz   =   [];
        if any(strcmp(tf.lchname,'Hz'))     ,  indbz   =   find(strcmp(tf.lchname,'Hz'));
        elseif any(strcmp(tf.lchname,'Bz')) ,  indbz   =   find(strcmp(tf.lchname,'Bz'));
        end
        if ~isempty(indbz)
            chid   = tf.lchid(indbz)-2;
            tfx   = squeeze(tf.tf(chid,1,:));
            tfy   = squeeze(tf.tf(chid,2,:));
            tfx_se= squeeze(tf.tf_se(chid,1,:));
            tfy_se= squeeze(tf.tf_se(chid,2,:));
            
            tfper = tf.periods;
           
%             delete(get(gca,'Children'));

            set(axes_tip,'Position',[ 0.1300    0.0723    0.7     0.1825],'DefaulttextFontname','Helvetica', 'Box','on','Fontsize',11,'Fontweight','bold','Linewidth',1, ...
                'TickDir','out','GridLineStyle','-', ...
                'Xscale','log','XMinorGrid','off','XMinorTick','off','XTick',10.^[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5], ... %,'Xcolor',[0.8 0.8 0.8], ...
                'Yscale','lin','YMinorGrid','off','YMinorTick','off','YTick',[-1 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.00], ... % 'Ycolor',[0.8 0.8 0.8], ...
                'YTickLabel',{'-1.0' '-0.8' '-0.6' '-0.4' '-0.2' '0.0' '0.2' '0.4' '0.6' '0.8' '1.0'}, ...
                'Nextplot','add','Visible','on');
            grid on;
            ylim(plt.hz);    xlim(plt.per);


            xlabel('Periods (s)','Fontsize',14,'Fontname','Helvetica');
            if 1
                if it           %   plot vertical mag. transfer function
                    h   =   ylabel('vtf','Fontsize',14,'Fontname','Helvetica');
                    labpos = get(h,'Position');
                    set(h,'Position',[10.^(log10(min(plt.per))-0.3) labpos(2),labpos(3)]);
                    % error bars
                    tf.x = tfx; tf.y = tfy;
                    tf.x_se = sqrt(tfx_se); tf.y_se = sqrt(tfy_se);
                    loglog([tfper tfper]',imag([tf.x+i*tf.x_se  tf.x-i*tf.x_se])','-','color',[0.7 0.7 0.7]);
                    loglog([tfper tfper]',real([tf.x+tf.x_se  tf.x-tf.x_se])','-','color',[0.7 0.7 0.7]);
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        imag([tf.x+i*tf.x_se tf.x+i*tf.x_se])','-','color',[0.7 0.7 0.7]);
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        imag([tf.x-i*tf.x_se tf.x-i*tf.x_se])','-','color',[0.7 0.7 0.7]);
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        real([tf.x+tf.x_se tf.x+tf.x_se])','-','color',[0.7 0.7 0.7]);
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        real([tf.x-tf.x_se tf.x-tf.x_se])','-','color',[0.7 0.7 0.7]);
                    loglog([tfper tfper]',imag([tf.y+i*tf.y_se  tf.y-i*tf.y_se])','-k');
                    loglog([tfper tfper]',real([tf.y+tf.y_se  tf.y-tf.y_se])','-k');
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        imag([tf.y+i*tf.y_se tf.y+i*tf.y_se])','-k');
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        imag([tf.y-i*tf.y_se tf.y-i*tf.y_se])','-k');
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        real([tf.y+tf.y_se tf.y+tf.y_se])','-k');
                    loglog([tfper-10.^(log10(tfper*0.08)) tfper+10.^(log10(tfper*0.08))]', ...
                        real([tf.y-tf.y_se tf.y-tf.y_se])','-k');
                    % data points
                    semilogx(tfper,imag(tf.x), ...
                        'o','MarkerSize',4,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
                    semilogx(tfper,real(tf.x), ...
                        'o','MarkerSize',4,'Markerfacecolor',col{3},'Markeredgecolor',col{3});
                    semilogx(tfper,imag(tf.y), ...
                        'o','MarkerSize',5,'Markerfacecolor',col{2},'Markeredgecolor',col{2});
                    semilogx(tfper,real(tf.y), ...
                        'o','MarkerSize',5,'Markerfacecolor',col{1},'Markeredgecolor',col{1});
                    %   smoothed curves
                    
                    %   legend
                    patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                        [max(plt.hz)-0.02 max(plt.hz)-0.13 max(plt.hz)-0.13 max(plt.hz)-0.02], ...
                        'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
                    plot(10^(log10(min(plt.per))+0.2),[max(plt.hz)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{1},'Markeredgecolor','k');
                    text(10^(log10(min(plt.per))+0.35),[max(plt.hz)-0.07],'Tyr','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
                    plot(10^(log10(min(plt.per))+0.85),[max(plt.hz)-0.07],'o','MarkerSize',5,'Linewidth',1,'Markerfacecolor',col{2},'Markeredgecolor','k');
                    text(10^(log10(min(plt.per))+1.0),[max(plt.hz)-0.07],'Tyi','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
                    patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                        [min(plt.hz)+0.02 min(plt.hz)+0.13 min(plt.hz)+0.13 min(plt.hz)+0.02], ...
                        'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
                    plot(10^(log10(min(plt.per))+0.2),[min(plt.hz)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{3},'Markeredgecolor',col{4});
                    text(10^(log10(min(plt.per))+0.35),[min(plt.hz)+0.07],'Txr','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
                    plot(10^(log10(min(plt.per))+0.85),[min(plt.hz)+0.07],'o','MarkerSize',4,'Linewidth',1,'Markerfacecolor',col{4},'Markeredgecolor',col{4});
                    text(10^(log10(min(plt.per))+1.0),[min(plt.hz)+0.07],'Txi','Fontsize',11,'Fontweight','bold','Fontname','Helvetica');
                elseif iiv      %   plot induction vectors
                    h   =   ylabel('Length','Fontsize',14,'Fontname','Helvetica');
                    labpos = get(h,'Position');
                    set(h,'Position',[10.^(log10(min(plt.per))-0.5) labpos(2),labpos(3)]);
                    pos =   get(gca,'Position');
                    xrat=   pos(3)/(log10(max(plt.per))-log10(min(plt.per)));
                    yrat=   pos(4)/(max(plt.hz)-min(plt.hz));
                    fac =   yrat/xrat;
                    for p = 1:length(tfper)
                        startreal(p,:)   =   [tfper(p) 0];
                        stopreal(p,:)    =   [10.^(log10(tfper(p))+fac*real(tfy(p))) ...
                            real(tfx(p))];
                        startimag(p,:)   =   [tfper(p) 0];
                        stopimag(p,:)    =   [10.^(log10(tfper(p))+fac*imag(tfy(p))) ...
                            imag(tfx(p))];
                    end
                    arrow(startimag,stopimag,'Length',8,'EdgeColor',col{2},'FaceColor',col{2},'width',0.3);
                    arrow(startreal,stopreal,'Length',8,'EdgeColor',col{1},'FaceColor',col{1},'width',0.3);
                    %   legend
                    patch([10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04) 10^(log10(min(plt.per))+0.04+1.5) 10^(log10(min(plt.per))+0.04+1.5)], ...
                        [max(plt.hz)-0.02 max(plt.hz)-0.13 max(plt.hz)-0.13 max(plt.hz)-0.02], ...
                        'w','EdgeColor',[0.5 0.5 0.5],'Linewidth',1)
                    arrow([10^(log10(min(plt.per))+0.1) max(plt.hz)-0.07],[10^(log10(min(plt.per))+0.4) max(plt.hz)-0.07], ...
                        'Length',7,'EdgeColor',col{1},'FaceColor',col{1},'Linewidth',1);
                    text(10^(log10(min(plt.per))+0.5),max(plt.hz)-0.07,'\Re','Fontsize',12)
                    arrow([10^(log10(min(plt.per))+0.8) max(plt.hz)-0.07],[10^(log10(min(plt.per))+1.1) max(plt.hz)-0.07], ...
                        'Length',7,'EdgeColor',col{2},'FaceColor',col{2},'Linewidth',1);
                    text(10^(log10(min(plt.per))+1.2),max(plt.hz)-0.07,'\Im','Fontsize',12)
                end
            end
        end
    end
end