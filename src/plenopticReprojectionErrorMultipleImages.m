function [ cost ] = plenopticReprojectionErrorMultipleImages(params, correspondences, num_correspo, pattern_size )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

K1 = params(1);
K2 = params(2);
fx = params(3);
fy = params(4);
cx = params(5);
cy = params(6);
k1 = params(7);
k2 = params(8);

ext_param = params(9:end);
cost = zeros(size(correspondences, 2), 1);
Image_Num = length(num_correspo);



idx = 0;

for n = 1:Image_Num
    
    RT = SetAxis(ext_param(6 * n - 5 : 6 * n));
    
    % construct the matrix of world points
    Xw = [correspondences(5:6, idx + 1: idx + num_correspo(n) )*pattern_size; zeros(1, num_correspo(n))];
    
    
    % get the micro-lens centers
    ucs = correspondences(3, idx + 1 : idx + num_correspo(n));
    vcs = correspondences(4, idx + 1: idx + num_correspo(n));
    
    % get the corners in the image
    corns = correspondences(1:2, idx + 1: idx + num_correspo(n));
    
    
    % Xc = R*Xw + t
    Xc = RT(1:3, 1:3)*Xw + RT(1:3, 4);
    
    % try to add rotation of the main lens?
%     Xc = rotx(k1)*roty(k2)*Xc;
    
    
    % try to input thin lens distortion
%     r = sqrt( sum ( (Xc(1, :)./ Xc(3, :)).^2 + ( Xc(2, :)./ Xc(3, :).^2) ));
% 
%     Xc(1, :) = (1 + k1 * r.^2 + k2 * r.^4).*Xc(1, :);
%     Xc(2, :) = (1 + k1 * r.^2 + k2 * r.^4).*Xc(2, :);
    
    % equations in my geometric calibration using corners 
    nominator = 1./(K1 * Xc(3, :) + K2);

    
%     xcs = (ucs - cx) / fx;
%     
%     ycs = (vcs - cy) / fy;
%         
%     r = sqrt(xcs.^2 + ycs.^2);
%     
%     xcs_u = (1 + k1.*r.^2 + k2.*r.^4) .* xcs;
%     
%     ycs_u = (1 + k1.*r.^2 + k2.*r.^4) .* ycs;
%     
%     ucs = fx * xcs_u + cx;
%     vcs = fy * ycs_u + cy;
    
    du = fx * Xc(1, :) - Xc(3, :).*(ucs - cx);
    
    dv = fy * Xc(2, :) - Xc(3, :).*(vcs - cy);
   
    du = nominator.*du;
    
    dv = nominator.*dv;
    
    % get the estimated corners, nx2 vectors
    us = ucs + du;
    vs = vcs + dv;
%     

    % remove distorion, for ICCV submission it was cancelled.
%     xcs = (us - cx) / fx;
%     
%     ycs = (vs - cy) / fy;
%         
%     r = sqrt(xcs.^2 + ycs.^2);
%     
%     xcs_u = (1 + k1.*r.^2 + k2.*r.^4) .* xcs;
%     
%     ycs_u = (1 + k1.*r.^2 + k2.*r.^4) .* ycs;
%     
%     us = fx * xcs_u + cx;
%     vs = fy * ycs_u + cy;

    
    
    
    corn_est= [us;vs];
    
    err = corns - corn_est;

    cost(idx + 1 : idx + num_correspo(n)) = sqrt(sum(err.^2, 1));
    
    idx = idx + num_correspo(n);


end


end

