%% function for plotting runtimes, code originaly from EMTimeSeries.m by Michael Becken
% - runtimes format: runtimes().start(), runtimes().stop(), runtimes().sitename

function plot_runtimes(runtimes)
    
    for i = 1:numel(runtimes)
        runtimes(i).firststart = min(datenum(cell2mat(runtimes(i).start(:))));
    end
    [~,perm] = sort([runtimes.firststart]);
    runtimes = runtimes(perm);

    isy = 0; % position on y-axes
    hax = {}; ylab = [];
    x = []; y = []; c = []; % vectors for start/stop dates
    for is = 1:numel(runtimes)
        if ~isempty(runtimes(is))
            isy = isy + 1;
            ylab{end+1} = runtimes(is).sitename;
            for ir = 1:numel(runtimes(is).start)
                start = datenum(cell2mat(runtimes(is).start(ir)));
                stop  = datenum(cell2mat(runtimes(is).stop(ir)));
                x(end+1,:) = [start start stop stop];
                y(end+1,:) = [isy-0.2 isy+0.2 isy+0.2 isy-0.2];
                if strfind(runtimes(is).sitename,'T')
                    c(end+1) = 1;
                elseif (strfind(runtimes(is).sitename,'B'))
                    c(end+1) = 2;
                elseif (strfind(runtimes(is).sitename,'L'))
                    c(end+1) = 3;
                end
            end
        end
    end
    if isempty(hax)
        figure;
        set(gcf,'Position',[42 10  1800 1000]);
        hax = axes;
    end
    axes(hax);
    set(hax,'Nextplot','replace','XTickmode','auto'); plot(1,1); delete(get(hax,'children'));
    %set(gcf,'visible','off');
    p = patch(x',y',c,'Edgecolor',[0.3 .3 .3],'LineWidth',0.05,'EdgeAlpha',0.5);
    colormap prism;
    set(gca,'Ytick',[1:numel(ylab)],'YTicklabel',ylab,'Ygrid','on','Fontsize',9,'box','on','Fontname','Hevetica','Yaxislocation','right');
    datetick('x',6,'keepticks');
    ylim([0 numel(runtimes)+1]);
    set(gcf,'PaperPositionMode','manual','PaperOrientation','landscape','PaperUnits','centimeters','PaperPosition',[0 0 30 22]);
    print(gcf,'-dpdf','runtimes.pdf')
end


