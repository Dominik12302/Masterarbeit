function [Z,Zvar]=calc_Z_v2(rhoa,rhoaerr,phi,phierr,f)
%
%[Z,Zvar]=calc_Z(rhoa,rhoaerr,phi,phierr,f)
%
%    [Z,Zvar]=calc_Z(rhoa,rhoaerr,phi,phierr,f)
%    calculates the impedance tensor and variance 
%    for frequencies f based on the apparent
%    resistivity rhoa and the phase phi.
%    The apparent resistivity and phase have to be
%    2x2xN arrays where N corresponds to the number
%    of frequencies.

%    NOTE - this formulation will produce elements ReZ and ImZ with the correct sign 
%    only if the angle Phi is in the "polar coordinates" frame. This is
%    altered from the traditional "North = 0" MT Phi frame.
%    This alternate version by MVL - hunting suspected bugs

phi(2,1,:)=phi(2,1,:)-180;
phi(2,2,:)=phi(2,2,:)-180;

% Specifying constants
mu = 4*pi*10^-7;

% Calculating the impedance tensor
Z = zeros(2,2,length(f));
for j = 1:length(f)
    Z(:,:,j) = sqrt(2*pi*f(j)*mu*rhoa(:,:,j)).*cosd(phi(:,:,j))+...
        1i*sqrt(2*pi*f(j)*mu*rhoa(:,:,j)).*sind(phi(:,:,j));
end

% Calculating the impedance tensor variance
Zvar = zeros(2,2,size(rhoa,3));

% Need to include error propagation