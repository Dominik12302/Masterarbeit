        function [HdOut,ind]  = merge_headers(HdIn1,HdIn2)
            %  merge two TDataHeader objects ... this could use some error checking!
            [ind,newSites] = compareHeader(HdIn2,HdIn1);
            newCh = zeros(size(HdIn2.siteInd));
            for k = 1:length(newCh)
                newCh(k) =  any(HdIn2.siteInd(k) == newSites);
            end
            chUse = find(newCh);
            HdTemp = UpdateHeader(HdIn2,chUse);
            HdOut = HdIn1;
            nSitesAdd = length(newSites);
            HdOut.NSites = HdOut.NSites+nSitesAdd;
            HdOut.NchSites = [ HdOut.NchSites HdTemp.NchSites];
            HdOut.Nch = sum(HdOut.NchSites);
            HdOut.ih = [ HdOut.ih(1:end-1) HdOut.Nch+HdTemp.ih HdOut.Nch+1];
            
            HdOut.siteInd = [ HdOut.siteInd HdIn1.NSites + HdTemp.siteInd];
            HdOut.chInd = [ HdOut.chInd HdTemp.chInd];
            HdOut.stcor = [ HdOut.stcor HdTemp.stcor];
            HdOut.decl = [HdOut.decl  HdTemp.decl ];
            HdOut.orient = [HdOut.orient  HdTemp.orient ];
            HdOut.Declination = [HdOut.Declination  HdTemp.Declination ];
            HdOut.XY = [HdOut.XY HdTempp.XY ];
            HdOut.LatLong = [HdOut.LatLong HdTempp.LatLong ];
            HdOut.chid = [HdOut.chid HdTemp.chid ];
            HdOut.sta = [HdOut.sta HdTemp.sta ];
            for k = 1:nSitesAdd
                kk = HdIn1.NSites+k;
                HdOut.Sites{kk} = HdTemp.Sites{k};
                HdOut.Channels{kk} = HdTemp.Channels{k};
            end
        end
 
