function [rhoa,rhoaerr,phi,phierr]=calc_MT(Z,Zvar,f)
%
%[rhoa,rhoaerr,phi,phierr]=calc_MT(Z,Zvar,f)
%
%    [rhoa,rhoaerr,phi,phierr]=calc_MT(Z,Zvar,f)
%    calculates the apparent resifreqtivity
%    and phase including corresponding errors
%    for frequencies f based on the impedance
%    tensor Z. The impedance tensor has to be a
%    2x2xN array where N corresponds to the number
%    of frequencies.

% Specifying constants
mu = 4*pi*10^-7;

% Calculating apparent resifreqtivities and phases
nf=size(Z,3);
rhoa = zeros(2,2,nf);
phi = zeros(2,2,nf);
for ifreq = 1:nf
    rhoa(:,:,ifreq) = 1/(2*pi*f(ifreq)*mu)*abs(Z(:,:,ifreq)).^2;
    phi(:,:,ifreq) = atan(imag(Z(:,:,ifreq))./real(Z(:,:,ifreq)))*360/(2*pi);
    
    % Calculating apparent resifreqtivity and phase errors (using Ersan's rules)
    erZZ(:,:,ifreq)=Zvar(:,:,ifreq)./sqrt(Z(:,:,ifreq).*conj(Z(:,:,ifreq)));
    rhoaerr(:,:,ifreq)=rhoa(:,:,ifreq).*((2*erZZ(:,:,ifreq))+(erZZ(:,:,ifreq)).^2);
    phierr(:,:,ifreq)=rhoaerr(:,:,ifreq)./rhoa(:,:,ifreq) *100*0.29;
end

% Otherwise make errors zero
%rhoaerr = zeros(2,2,size(Z,3));
%phierr = zeros(2,2,size(Z,3));

% Need to include error propagation