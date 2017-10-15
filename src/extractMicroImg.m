function [ micro_img ] = extractMicroImg( img, center, radius )
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


micro_img = zeros(2*radius + 1, 2*radius+1, 3);
center = ceil(center);

micro_img(:, :, 1:3) = img(center(2)-radius:center(2)+radius, center(1)-radius:center(1)+radius, 1:3);


end

