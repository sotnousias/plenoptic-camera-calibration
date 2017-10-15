function [ micro_img ] = extractMicroImgNaN( img, ci, radius )
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
% This version fills with NaN's out of the microimage regions.
% The output image is uint8.

  ci = ceil(ci);

  if ~within(radius + 1, ci(2), size(img, 1) - radius) || ...
    ~within(radius + 1, ci(1), size(img, 2) - radius)
    
    micro_img = [];

  else

    micro_img(:, :, 1:3) = img(ci(2)-radius:ci(2)+radius, ci(1)-radius:ci(1)+radius, 1:3);
    
    imageSize = size(micro_img);
    [xx,yy] = ndgrid(1:imageSize(1),1:imageSize(2));
    mask = double(((xx - imageSize(2)/2).^2 + (yy - imageSize(1)/2).^2) < radius^2);
    
% multiplication seems to complain using double in mask.
%     mask = (((xx - imageSize(2)/2).^2 + (yy - imageSize(1)/2).^2) < radius^2);
%     mask = uint8(mask);

    r = micro_img(:,:,1).*mask;
    r(mask == 0) = NaN;
    
    b = micro_img(:,:,1).*mask;
    b(mask == 0) = NaN;
    
    g = micro_img(:,:,1).*mask;
    g(mask == 0) = NaN;
    
    micro_img(:,:,1) = r;
    micro_img(:,:,2) = g;
    micro_img(:,:,3) = b;
      
    % micro_img(:, :, 1:3) = img(ci(2)-radius:ci(2)+radius, ci(1)-radius:ci(1)+radius, 1:3);

  end

end

