
%find the micro-lens centers observing the world corners.

[file1,path1]=uigetfile('CI*.mat','Central Sub-Aperture Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

disp_str = sprintf('Processing %s ....', file1{1});
disp(disp_str);
% micro-lens radius, used for scaling the centers.
radius = 15;
scale = 2*radius;

% max number of neighbours to the corner in the central sub-aperture image
% considered.
neighbrs = 12;

% load the Corners, positions of the corner in the image are [corner(3,:)
% corner(4,:)]
load([path1 file1{1}]);

% load the micro-lens centers center_list (2xN array)
load([path1 'microlens_center_list.mat'])

% % load the corners in the central sub-aperture image
% % positions of the corner in the image are [corner(3,:) corner(4,:)]
% load([path1 'CI' file1{1}(numel('lfCorners') + 1: end)]);

% centers_list is 2xN micro-lens center coordinates
centers_scaled = center_list / (2 * radius) + 0.5 ;
% center_scaled=(center_list-0.5-scale*0.5)/scale+1;


% array containing which corner i  world, the closest neighbours see. The
% second dimension contains the indices. First dimension containes the
% index of the corner, the second the corresponding n-nearest microlenses.
nearCorner = zeros(size(corner, 2), neighbrs);

for i = 1:size(corner, 2)

    dist = sqrt(sum((centers_scaled - corner(3:4, i)).^2, 1));
    
    [~, ids] = sort(dist);
    
    ids = ids(1:neighbrs);
    
    nearCorner(i, :) = ids;

end

save([path1 'nearCorner' file1{1}(numel('CI') + 1: end)], 'nearCorner');


