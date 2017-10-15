[file1,path1]=uigetfile('light*.mat','lightfield corner files','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

% micro-lens radius, used for scaling the centers.
radius = 20;

% load the lightfieldCorners
load([path1 file1{1}]);

% load the micro-lens centers center_list (2xN array)
load([path1 'microlens_center_list.mat'])

% load the corners in the central sub-aperture image
% positions of the corner in the image are [corner(3,:) corner(4,:)]
% load([path1 'CI' file1{1}(numel('lightfieldCorners') + 1: end)]);

% lightfieldCorners = lightfieldCorners';
% maximum corner distance from the center of a micro-lens (2D euclidean
% distance)
corn_dist = 15;

% centers_list is 2xN micro-lens center coordinates
% centers_scaled = center_list / (2 * radius) + 1;


% lfCorners = zeros(4, size(lightfieldCorners, 1));

% assign the corners to the first two rows.
% lfCorners(1:2, :) = lightfieldCorners';

% output array containing corners (in 1:2) and micro-lens centers (in 3:4)
lfCorners = [];
corner_id = 1;

% find the corresponding center for each corner and assign it to the 3:4
% rows of the lfCorners matrix.
for i = 1:size(lightfieldCorners, 2)
    
    dists = sqrt(sum((center_list - lightfieldCorners(1:2, i)).^2, 1));
    
    if ~(isempty(find(dists < corn_dist)))
    
        lfCorners(1:2, corner_id) = lightfieldCorners(1:2, i);
        lfCorners(3:4, corner_id) = center_list(:, dists < corn_dist);
        
        corner_id = corner_id + 1;
    end     

end

save([path1 'lfCorners' file1{1}(numel('lightfieldCorners') + 1: end)], 'lfCorners');




