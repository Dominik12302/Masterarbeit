function pc = fixedCoordinateSystem(pc,theta0,SPHEREproject)
%   function to put PC object into fixed coordinate system.   This is a
%   potentially tricky, as one needs to "pair up" channels that should be
%   rotated together.   To make use of this now I am coding for the MT case
%   where all sites have 5 channels; channels 1 and 2 and 4 and 5 are
%   assumed paired so that they should be rotated together.  Limited error
%   checking!!!!

%   puts into an ortogonal coordinate system with x axis oriented theta
%   degrees E of N

    if nargin == 2
        SPHEREproject = false;
    end
    
    if SPHEREproject
        thRot = sphericalProjection(pc.Header.stcor);
    end
    
    for k = 1:pc.Header.NSites
        k1 = (k-1)*5+1;
        k2 = k1+1;
        azimuth = pc.Header.orient(1,k1:k2);
        theta = theta0-thRot(k);
        pc.U(k1:k2,:) = rotateVec(pc.U(k1:k2,:),azimuth,theta);
        pc.Header.orient(1,k1:k2) = [0 90]+theta;
        k1 = (k-1)*5+3;
        k2 = k1+1;
        azimuth = pc.Header.orient(1,k1:k2);
        pc.U(k1:k2,:) = rotateVec(pc.U(k1:k2,:),azimuth,theta);
        pc.Header.orient(1,k1:k2) = [0 90]+theta;
    end
    pc.Header.geogCor = 1;
    
end


function [rotVec] = rotateVec(vec,azimuth,theta)
%  puts vec in an orthogonal right handed coordinate system (z down)
%  with x-axis oriented theta degrees E of geographic N; on input
%  vec(1:2) is expressed in (not necessarily orthogonal) coordinates with
%  unit vector basis oriented in directions given by azimuth(1:2)
    theta1 = azimuth(1)-theta;
    theta2 = azimuth(2)-theta;
    theta1 = pi*theta1/180;
    theta2 = pi*theta2/180;
    U =  [cos(theta1) sin(theta1); ...
        cos(theta2) sin(theta2)];
    rotVec =  U\vec;
end

function thRot =  sphericalProjection(stcor);

  %   put N/S basis vectors in Cartesian coordinates
  [~,nsta] = size(stcor);
  stcor0 = mean(stcor,2);
  theta = stcor(1,:)*pi/180;
  phi = stcor(2,:)*pi/180;
  theta0 = stcor0(1)*pi/180;
  phi0 = stcor0(2)*pi/180;
  r0 = [cos(theta0)*cos(phi0); cos(theta0)*sin(phi0); sin(theta0)];
  v = [-sin(theta).*cos(phi); -sin(theta).*sin(phi); cos(theta) ];
  v0 = [-sin(theta0).*cos(phi0); -sin(theta0).*sin(phi0); cos(theta0) ];
  xyz = [cos(theta).*cos(phi); cos(theta).*sin(phi); sin(theta)];
  
  %   project onto plane perpendicular to r0 (radial vector at center of
  %   array)
  
  vProj = v-r0*r0'*v;
  vProjNorm = sqrt(sum(vProj.*vProj,1));
  vProj = vProj*diag(1./vProjNorm);
  vCross = cross(v,v0*ones(1,nsta));
  thRot = asin(r0'*vCross)*180/pi;
end
  