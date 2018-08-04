classdef TFCHeader < TDataHeader
    % class for storing data header object
    % 2012 (c) Gary Egbert
    % Oregon State University, 2012
    
    % some of the properties are redundent and could cleaned later
    % also longer names for variables are preferable
    

methods 
   function obj = TFCHeader(Array,Sites,iBand)

      %  constructs array meta data SDMheader object from Array and iBand 
      %    structures, and list of site names
      %  Usage:  header = SDMheader(Array,Sites,iBand);
      %   If called with no arguments, creates empty header structure;
      %   If called with 2 arguments, # of bands is left empty; 
      %    cannot be called with 1 argument
   
    if nargin > 0
      if nargin ==1
         error('cannot call TDataHeader with one argument')
      end
      obj.NSites = length(Array);
     
      obj.NchSites = zeros(1,obj.NSites);
      obj.stcor  = zeros(2,obj.NSites);
      obj.orient = [];
      obj.decl  = zeros(1,obj.NSites);
      obj.siteInd = zeros(1,obj.NSites);
      for k = 1:obj.NSites
          nchar(k)  = length(Sites{k});
      end
      maxchar = max(nchar);
      for k = 1:obj.NSites
          temp  =  blanks(maxchar);
          temp(1:nchar(k))  = Sites{k};
          Sites{k} =  temp;
      end
      obj.chid =  [];
      obj.sta   = [];
      obj.ih = zeros(obj.NSites+1,1);
      Channels = cell(obj.NSites,1); 
   
      k1  = 1;
      for k = 1:obj.NSites
          obj.NchSites(k)  = Array{k}(1).FChead.nch;
          obj.stcor(:,k) = Array{k}(1).FChead.stcor;
          obj.orient = [obj.orient Array{k}(1).FChead.orient];
          obj.decl(k) = Array{k}(1).FChead.decl;
          obj.chid = [obj.chid  Array{k}(1).FChead.chid'];
          Channels{k} = char(Array{k}(1).FChead.chid); 
          obj.sta = [obj.sta char(Sites{k}')];
          ihk = find('H'==Array{k}(1).FChead.chid(:,1)',1);
          if ~isempty(ihk)
             ih(k)  =  ihk;
          else
              ih(k) = NaN;
          end
          k2 = k1+obj.NchSites(k)-1;
          obj.siteInd(k1:k2)  = k;
          obj.chInd(k1:k2)  = 1:obj.NchSites(k);
          k1 = k2+1;
      end
      obj.ih = [ih 1] +[0 cumsum(obj.NchSites)]; 
      obj.Sites = Sites;
      obj.Channels = Channels; 
      obj.Nch = sum(obj.NchSites);
      if nargin >2
           obj.NBands = length(iBand);
      end
      %   for FC files if field "decl" are all zeros, then azimuths are
      %   already in geographic coordinate
      obj.geogCor = all(obj.decl==0) ;
    end
   end
   %***********************************************************************
   function obj = defaultHeaderOneSite(obj,nch)
       
       obj.NSites = 1;
       obj.NchSites = nch;
       obj.Nch =  nch;
       obj.ih = [1 nch+1];
       obj.siteInd = [1];
       obj.chInd = 1:nch;
       switch nch
           case 3
               chid = ['Hx     ';'Hy     ';'Hz     '];
               orient = [0 90 0 ; 0 0 0];
           case 4
               chid = ['Hx     ';'Hy     ';'Ex     ';'Ey     '];
               orient = [0 90 0 90; 0 0 0 0];
           case 5
               chid = ['Hx     ';'Hy     ';'Hz     ';'Ex     ';'Ey     '];
               orient = [0 90 0 0 90; 0 0 0 0 0];
       end
       obj.chid = chid';
       obj.Channels{1} = chid;
       obj.orient = orient;
   end
end   % methods

end  % classdef