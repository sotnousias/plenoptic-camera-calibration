function [ micro_img ] = extractCircularMicroImg( img, center, radius )
%UNTITLED Summary of this function goes here
%   Extract a micro-lens image from a light-field image.
%
% INPUT
% 
% img - The image.
% 
% center - 2x1 center coordinates of the microlens we want tp extract.
% 
% radius - the radius we want to extract.
%
% 


circle_img = zeros(2 * radius + 1, 2 * radius + 1, 3);

[x, y] = meshgrid(-radius:radius);

% find xs and ys inside the circle i.e. the microlens.
circle = find((x.^2 +y.^2) < radius^2);

x_circle = x(circle);
y_circle = y(circle);




% in_microlens = find( (around_corner_x - center(1)).^2  + (around_corner_y - center(2)).^2 < microImgRad^2);
% 
% x_ids = around_corner_x(in_microlens);
% y_ids = around_corner_y(in_microlens);

for i = 1:numel(x_circle)
    idx = x_circle(i) + radius + 1;
    idy = y_circle(i) + radius + 1;
    
    img_idx = x_circle(i) + center(1) + 1;
    img_idy = y_circle(i) + center(2) + 1;
       
    circle_img(ceil(idy),ceil(idx),1:3) = img(ceil(img_idy),ceil(img_idx), 1:3);

end


micro_img = circle_img;

end





