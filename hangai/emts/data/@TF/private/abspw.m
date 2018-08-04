function p = abspw(w,PT,psi)
w = w*pi/180;
p = PT*[cos(w+psi); sin(w+psi)];
p = p(1).^2+p(2).^2;
end
% w = (0:1:180)*pi/180;
% p = PT*[cos(w+psi); sin(w+psi)];
% p = p(1,:).^2+p(2,:).^2;
