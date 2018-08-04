classdef EDI

    % read EDI file:
    % e = EDI(filename)    
    %
    % exclude some components:
    % e = EDI(filename,'Z',false), 
    % e = EDI(filename,'impedance',false)        
    % e = EDI(filename,'T',false)    
    % e = EDI(filename,'tipper',false)    
    % e = EDI(filename,'Rhoa',false)    
    % e = EDI(filename,'appres',false)    
    %
    % select frequency band f1 < f < f2:
    % eb = e.band_select(f1,f2) 
    %
    % merge two EDI objects:
    % e = f.merge(g);
    %
    % write EDI-files:
    % e.write(filename)
    %
    % tf = e.has_T
    % tf = e.has_Z
    % tf = e.has_Rhoa

    properties
        filename
        pathname

        f
        Z
        Zvar
        T
        Tvar
        Rhoa
        Rhoaerr
        Phs
        Phserr
        zrot
        rhorot
        trot
        coords

    end
    methods
        function F = EDI(fn,varargin)
            if nargin < 1; return; end
            [p,f,e] = fileparts(fn);
            F.filename = [f,e];
            F.pathname = p;
            [read_Z, read_T, read_Rhoa] = get_info(varargin,{'Z','impedance'},true,{'T','tipper'},true,{'appres','Rhoa'},true);
            F = F.read(read_Z,read_T, read_Rhoa);
        end           
        function F = read(F,rZ,rT,rR)
            if nargin < 4; rR = true; end
            if nargin < 3; rT = true; end
            if nargin < 2; rZ = true; end
            [Z,Zvar,T,Tvar,Rhoa,Rhoaerr,Phs,Phserr,F.f,F.zrot,F.rhorot,F.trot,F.coords] = read_edi_imp(fullfile(F.pathname,F.filename));
            nf = numel(F.f);
            if rZ
                F.Z = Z; F.Zvar = Zvar;
            else
                F.Z = NaN(2,2,nf); F.Zvar = NaN(2,2,nf);
            end
            if rT
                F.T = T; F.Tvar = Tvar;
            else
                F.T = NaN(2,nf); F.Tvar = NaN(2,nf);
            end
            if rR
                F.Rhoa = Rhoa; F.Rhoaerr = Rhoaerr;
                F.Phs = Phs; F.Phserr = Phserr;
            else
                F.Rhoa = NaN(2,2,nf); F.Rhoaerr = NaN(2,2,nf);
                F.Phs = NaN(2,2,nf); F.Phserr = NaN(2,2,nf);
            end
        end
        function write(F, fn)
            if nargin < 2; error('no filename given!'); end            
            write_edi_imp(F.Z,F.Zvar,F.Rhoa,F.Phs,F.Rhoaerr,F.Phserr,F.T,F.Tvar,F.f,F.coords(1),F.coords(2),F.coords(3),F.zrot,F.rhorot,F.trot,fn)
        end
        function G = band_select(F,f1,f2)
            band = F.f > f1 & F.f < f2;
            G = F;
            G.f = G.f(band);
            G.Z = G.Z(:,:,band);
            G.Zvar = G.Zvar(:,:,band);
            G.T = G.T(:,band);
            G.Tvar = G.Tvar(:,band);
            G.Rhoa = G.Rhoa(:,:,band);
            G.Rhoaerr = G.Rhoaerr(:,:,band);
            G.Phs = G.Phs(:,:,band);
            G.Phserr = G.Phserr(:,:,band);
            G.zrot = G.zrot(band);
            G.rhorot = G.rhorot(band);
            G.trot = G.trot(band);
        end        
        function H = merge(F,G)            
            H = EDI;
            H.f = flipud(unique([F.f(:); G.f(:)]));

            nf = numel(H.f);
            H.Z = NaN(2,2,nf);
            H.Zvar = NaN(2,2,nf);
            H.T = NaN(2,nf);
            H.Tvar = NaN(2,nf);
            H.Rhoa = NaN(2,2,nf);
            H.Rhoaerr = NaN(2,2,nf);
            H.Phs = NaN(2,2,nf);
            H.Phserr = NaN(2,2,nf);
            H.zrot = NaN(nf,1);
            H.rhorot = NaN(nf,1);
            H.trot = NaN(nf,1);

            H.coords = F.coords;
            if ~all(F.coords == G.coords);
                del = F.coords - G.coords;
                if norm(del(1:2)) < 0.001 && norm(del(3)) < 1
                    disp(['Shifted non-matching coordinates by ',num2str(norm(del(1:2))),' degree and ',num2str(norm(del(3))),' meters (z).']);
                else
                    disp(['Warning, coordinates do not agree by ',num2str(norm(del(1:2))),' degree and ',num2str(norm(del(3))) ' meters (z). Selected: ', num2str(H.coords(:)')]);
                end
            end

            for ind = 1 : numel(H.f)
                iF = find(F.f == H.f(ind));
                iG = find(G.f == H.f(ind));                                

                if ~isempty(iF)                
                    FZ = F.Z(:,:,iF);
                    FZvar = F.Zvar(:,:,iF);
                    FT = F.T(:,iF);
                    FTvar = F.Tvar(:,iF);
                    FRhoa = F.Rhoa(:,:,iF);
                    FRhoaerr = F.Rhoaerr(:,:,iF);
                    FPhs = F.Phs(:,:,iF);
                    FPhserr = F.Phserr(:,:,iF);
                    Fzrot = F.zrot(iF);
                    Frhorot = F.rhorot(iF);
                    Ftrot = F.trot(iF);
                end
                
                if ~isempty(iG)                
                    GZ = G.Z(:,:,iG);
                    GZvar = G.Zvar(:,:,iG);
                    GT = G.T(:,iG);
                    GTvar = G.Tvar(:,iG);
                    GRhoa = G.Rhoa(:,:,iG);
                    GRhoaerr = G.Rhoaerr(:,:,iG);
                    GPhs = G.Phs(:,:,iG);
                    GPhserr = G.Phserr(:,:,iG);
                    Gzrot = G.zrot(iG);
                    Grhorot = G.rhorot(iG);
                    Gtrot = G.trot(iG);
                end

                if ~isempty(iF) && ~isempty(iG)                
                    if ~all(isnan(FZ(:))) && ~all(isnan(GZ(:)))
                        if Fzrot~=Gzrot
                            warning(['warning, zrot does not agree! Skipping Z for',num2str(H.f(ind))])
                        else  
                            disp(['warning: ',num2str(H.f(ind)),' exists in both sites. Averaging Z!'])
                            H.Z(:,:,ind) = 0.5 * ( FZ + GZ );
                            H.Zvar(:,:,ind) = 0.5 * ( FZvar + GZvar );
                            H.zrot(ind) = Fzrot;
                        end
                    elseif all(isnan(FZ(:)))
                        H.Z(:,:,ind) = GZ;
                        H.Zvar(:,:,ind) = GZvar;
                        H.zrot(ind) = Gzrot;
                    elseif all(isnan(GZ(:)))
                        H.Z(:,:,ind) = FZ;
                        H.Zvar(:,:,ind) = FZvar;
                        H.zrot(ind) = Fzrot;
                    end

                    if ~all(isnan(FT(:))) && ~all(isnan(GT(:)))
                        if Ftrot~=Gtrot
                            warning(['warning, trot does not agree! Skipping T for',num2str(H.f(ind))])
                        else
                            disp(['warning: ',num2str(H.f(ind)),' exists in both sites. Averaging T!'])
                            H.T(:,ind) = 0.5 * ( FT + GT );
                            H.Tvar(:,ind) = 0.5 * ( FTvar + GTvar );
                            H.trot(ind) = Ftrot;
                        end
                    elseif all(isnan(FT(:)))
                        H.T(:,ind) = GT;
                        H.Tvar(:,ind) = GTvar;
                        H.trot(ind) = Gtrot;
                    elseif all(isnan(GT(:)))
                        H.T(:,ind) = FT;
                        H.Tvar(:,ind) = FTvar;
                        H.trot(ind) = Ftrot;
                    end

                    if ~all(isnan(FRhoa(:))) && ~all(isnan(GRhoa(:)))
                        if Frhorot~=Grhorot
                            warning(['warning, rhorot does not agree! Skipping Rhoa and Phs for',num2str(H.f(ind))])
                        else
                            disp(['warning: ',num2str(H.f(ind)),' exists in both sites. Averaging Rhoa (need to revise error averaging)!'])
                            H.Rhoa(:,:,ind) = 0.5 * ( FRhoa + GRhoa );
                            H.Rhoaerr(:,:,ind) = 0.5 * ( FRhoaerr + GRhoaerr );
                            H.rhorot(ind) = Frhorot;
                        end
                    elseif all(isnan(FRhoa(:)))
                        H.Rhoa(:,:,ind) = GRhoa;
                        H.Rhoaerr(:,:,ind) = GRhoaerr;
                        H.rhorot(ind) = Grhorot;
                    elseif all(isnan(GRhoa(:)))
                        H.Rhoa(:,:,ind) = FRhoa;
                        H.Rhoaerr(:,:,ind) = FRhoaerr;
                        H.rhorot(ind) = Frhorot;
                    end

                    if ~all(isnan(FPhs(:))) && ~all(isnan(GPhs(:)))
                        if Frhorot==Grhorot                        
                            disp(['warning: ',num2str(H.f(ind)),' exists in both sites. Averaging Phs (need to revise error averaging)!'])
                            H.Phs(:,:,ind) = 0.5 * ( FPhs + GPhs );
                            H.Phserr(:,:,ind) = 0.5 * ( FPhserr + GPhserr );
                        end
                    elseif ~all(isnan(FPhs(:)))
                        H.Phs(:,:,ind) = GPhs;
                        H.Phserr(:,:,ind) = GPhserr;
                    elseif ~all(isnan(GPhs(:)))
                        H.Phs(:,:,ind) = FPhs;
                        H.Phserr(:,:,ind) = FPhserr;
                    end

                elseif ~isempty(iF)
                    H.Z(:,:,ind) = FZ;
                    H.Zvar(:,:,ind) = FZvar;
                    H.T(:,ind) = FT;
                    H.Tvar(:,ind) = FTvar;
                    H.Rhoa(:,:,ind) = FRhoa;
                    H.Rhoaerr(:,:,ind) = FRhoaerr;
                    H.Phs(:,:,ind) = FPhs;
                    H.Phserr(:,:,ind) = FPhserr;
                    H.zrot(ind) = Fzrot;
                    H.rhorot(ind) = Frhorot;
                    H.trot(ind) = Ftrot;
                elseif ~isempty(iG)
                    H.Z(:,:,ind) = GZ;
                    H.Zvar(:,:,ind) = GZvar;
                    H.T(:,ind) = GT;
                    H.Tvar(:,ind) = GTvar;
                    H.Rhoa(:,:,ind) = GRhoa;
                    H.Rhoaerr(:,:,ind) = GRhoaerr;
                    H.Phs(:,:,ind) = GPhs;
                    H.Phserr(:,:,ind) = GPhserr;
                    H.zrot(ind) = Gzrot;
                    H.rhorot(ind) = Grhorot;
                    H.trot(ind) = Gtrot;                
                end
            end

        end
        function tf = has_T(F)
            tf = any(F.T(:));
        end
        function tf = has_Z(F)
            tf = any(F.Z(:));
        end
        function tf = has_Rhoa(F)
            tf = any(F.Rhoa(:)) | any(F.Phs(:)) ;
        end
        function a = rotation_angle(F)
            a = [];
            if ~any(isnan(F.zrot)); a = [a; F.zrot]; end
            if ~any(isnan(F.trot)); a = [a; F.trot]; end
            if ~any(isnan(F.rhorot)); a = [a; F.rhorot]; end
            a = unique(a);
        end
    end
end