function [Hind,Eind] = get_H_E_index(Header,Site)
%    use header to find indicies (in spatial mode vectors)
%     for Hx,Hy and Ex,Ey for named site
Hind = [Header.findChannel(Site,'Hx');Header.findChannel(Site,'Hy')];
Eind = [Header.findChannel(Site,'Ex');Header.findChannel(Site,'Ey')];
end