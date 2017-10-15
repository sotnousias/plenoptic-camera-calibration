function [ circle_img ] = extractCircleInCornerImage( img, microImgRad, center, corner, crop_radius )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

circle_img = nan(2 * crop_radius + 1, 2 * crop_radius + 1, 3);

[x, y] = meshgrid(-crop_radius:crop_radius);

% find xs and ys inside the circle i.e. the microlens.
circle = find((x.^2 +y.^2) < crop_radius^2);

x_circle = x(circle);
y_circle = y(circle);


around_corner_x = x_circle + corner(1);
around_corner_y = y_circle + corner(2);


in_microlens = find( (around_corner_x - center(1)).^2  + (around_corner_y - center(2)).^2 < microImgRad^2);

x_ids = around_corner_x(in_microlens);
y_ids = around_corner_y(in_microlens);

for i = 1:numel(in_microlens)
    idx = x_circle(in_microlens(i)) + crop_radius + 1;
    idy = y_circle(in_microlens(i)) + crop_radius + 1;
    
    img_idx = x_ids(i);
    img_idy = y_ids(i);
       
    circle_img(ceil(idy),ceil(idx),1:3) = img(ceil(img_idy),ceil(img_idx), 1:3);

end


end

