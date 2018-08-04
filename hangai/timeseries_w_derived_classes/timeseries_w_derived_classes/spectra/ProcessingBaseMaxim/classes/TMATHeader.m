classdef TMATHeader < TDataHeader
    % class for storing SDM header object
    % 2009 (c) Gary Egbert
    % Oregon State University, Fall 2009
    
methods 
function obj = TMATHeader(InFile, TS_Parameters)
  ChInd =  TS_Parameters.ChannelsID; 
  orient = TS_Parameters.ChannelsOrient;
  fid = fopen(InFile);  
  Header = textscan(fid, '%s %f %f %f %f %f','commentStyle', '//');
  fclose(fid);
  obj.NSites = length(Header{1});
  obj.LatLong(1,:) = Header{2};
  obj.LatLong(2,:) = Header{3};    
  obj.Declination = Header{4}';
  obj.XY(1,:) = Header{5}';
  obj.XY(2,:) = Header{6}'; 
  obj.orient = orient(TS_Parameters.Channels);
  obj.orient(2,:) = 0;
  
  obj.StartTime = '2000/01/01 00:00:00';  
  obj.NchSites = zeros(1,obj.NSites);
  obj.siteInd = zeros(1,obj.NSites);
  obj.NchSites(1:obj.NSites)  = length(TS_Parameters.Channels); 
  k1  = 1;
  for k = 1:obj.NSites        
    if k>1; obj.orient = horzcat(obj.orient(1,:), orient(TS_Parameters.Channels)); end;
    obj.Channels = [obj.Channels  ChInd(TS_Parameters.Channels,:)'];
    obj.Sites = [obj.Sites char(Header{1}(k))'];
    ih(k)  =  find('H'==ChInd(TS_Parameters.Channels,1)',1); 
    k2 = k1+obj.NchSites(k)-1;
    obj.siteInd(k1:k2)  = k;
    obj.chInd(k1:k2)  = 1:obj.NchSites(k);
    k1 = k2+1;
  end
  obj.Sites = cellstr(obj.Sites');
  obj.ih = ih +[0 cumsum(obj.NchSites(1:end-1))]; 
  obj.Nch = sum(obj.NchSites);   
end
%**************************************************************************  
end;
end  % classdef
