function [Z,Zvar]=calc_Z(rhoa,rhoaerr,phi,phierr,f)
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

% Specifying constants
mu = 4*pi*10^-7;

% Calculating the impedance tensor
Z = zeros(2,2,size(rhoa,3));
for j = 1:size(Z,3)
    Z(:,:,j) = sign(phi(:,:,j)).*(2*pi*f(j)*mu*rhoa(:,:,j)./...
        (1+tand(phi(:,:,j)).^2)).^(1/2)+...
        i*sign(phi(:,:,j)).*(2*pi*f(j)*mu*rhoa(:,:,j)./...
        (1+cotd(phi(:,:,j)).^2)).^(1/2);
end

% Calculating the impedance tensor variance
Zvar = zeros(2,2,size(rhoa,3));

% Need to include error propagation