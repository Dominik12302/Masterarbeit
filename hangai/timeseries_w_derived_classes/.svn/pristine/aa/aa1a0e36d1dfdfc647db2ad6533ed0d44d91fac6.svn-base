 %**********************************************************************
    function [ind,sitesOmit] = compare_headers(hd1,hd2)
        %
        %  Usage: [ind,sitesOmit] = compareHeader(hd1,hd2)
        %
        %   Compares two SDMheader objects with different site lists.
        %
        %   For sites listed in hd1, find order of this site in hd2 list, 
        %    returning index in ind; all sites in hd1 not found in hd2, 
        %    are listed in output array sitesOmit 

        ind = zeros(hd1.NSites,1);
        sitesOmit = zeros(hd1.NSites,1);
        kk = 0;
        for k = 1:hd1.NSites
            omit = true;
            for j = 1:hd2.NSites
                if strcmp(hd1.Sites{k},hd2.Sites{j})
                    ind(k) = j;
                    omit = false;
                    break
                end
            end
            if omit
                kk = kk+1;
                sitesOmit(kk)  = k;
            end
        end
        sitesOmit = sitesOmit(sitesOmit>0);
    end