function [xu,yu]=RemoveDistortion(xd,yd,k1,k2)



r=xd.^2+yd.^2;
r=1+k1*r+k2*r.^2;
xu=xd.*r;
yu=yd.*r;

% edit by sotiris, canceled the distortion
% xu = xd;
% yu = yd;

end