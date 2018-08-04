function thRot =  sphericalProjection(stcor)


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
  
 % ux = v0'*v;
 % uy = r0'*vCross;
 %quiver(stcor(2,:),stcor(1,:),uy,ux)
% hold on
% quiver(stcor(2,:),stcor(1,:),ux,-uy,'r')