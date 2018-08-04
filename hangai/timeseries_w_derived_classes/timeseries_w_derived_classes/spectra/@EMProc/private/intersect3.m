function [a,b,c,d] = intersect3(v1,v2,v3)
[a1,b1,c1] = intersect(v1,v2);
v11 = v1(b1);
v21 = v2(c1);
[a,b2,c2] = intersect(a1,v3);
[a,b,c]  = intersect(v1,a);
[a,c,d]  = intersect(v2,a);
[a,d,e]  = intersect(v3,a);
end

