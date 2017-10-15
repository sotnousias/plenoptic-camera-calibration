
% Classifies which micro-lens detected corner corresponds to which world
% corner, i.e. checkerboard corner. It works with the handcrafted corners.

disp('Select the corners in the light-field image')
[file1,path1]=uigetfile({'lfC*.mat'} ,'lfCorners files','MultiSelect','on');

if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

% load lfCorners
load([path1 file1{1}]);

% load the micro-lens centers center_list (2xN array)
load([path1 'microlens_center_list.mat'])

% load corners
load([path1 'CI' file1{1}(numel('lfCorners') + 1:end)]);

% load the query (near corners) micro-lens centers
load([path1 'nearCorner' file1{1}(numel('lfCorners') + 1:end)]);

% load the lens types
load lens_types.mat
type1 = type1_struct';
type2 = type2_struct';
type3 = type3_struct';

% decide if you want to select a specific type or not
use_type = 45;

% 6xN array containing the correspondences between 3D corners, 2D light
% field corners and the associated micro-lens centers.
%
%   1:2 - corner coordinates in light-field image
%   3:4 - coordinates of the corresponding micro-lens center
%   5:6 - coordinates of the world corner (assume z-coordinate is 0)
correspondences = [];

% maximum distance from the corner to the center of the micro-lens,
% usually set to 8 for types 1-3 and to 12 for type 2.
max_corn_dist = 12;

% loop through all the checkerboard corners.
idx = 1;

for i = 1:size(nearCorner, 1)
    
    quer_ids = nearCorner(i, :);
    quer_centers_x = center_list(1, quer_ids);
    quer_centers_y = center_list(2, quer_ids);
    
    x_in = ismember(lfCorners(3, :), quer_centers_x);
    y_in = ismember(lfCorners(4, :), quer_centers_y);
    
    cent_in = find(x_in .* y_in);
    
    if (isempty(cent_in))
        continue;
    end
    
%     correspondences(1:4) = lfCorners(1:4, cent_in);
    
    for idx_in = 1:numel(cent_in)
        
    	correspondences(1:4, idx) = lfCorners(1:4, cent_in(idx_in));
        correspondences(5:6, idx) = corner(1:2, i);
        
        idx = idx + 1;
    end  
    
end


switch use_type
    
    case 1
        for v = 1:size(correspondences, 2)
            
            isin = find(bsxfun(@eq, correspondences(3:4,v), type1));
            
            if isempty(isin)
                correspondences(:,v) = nan;
                correspondences(:, v) = nan;
                correspondences(:, v) = nan;
            end
        end
        
    case 2
        
        for v = 1:size(correspondences, 2)
            
            isin = find(bsxfun(@eq, correspondences(3:4,v), type2));
            
            if isempty(isin)
                correspondences(:,v) = nan;
                correspondences(:, v) = nan;
                correspondences(:, v) = nan;
            end
        end
        
    case 3
        for v = 1:size(correspondences, 2)
            
            isin = find(bsxfun(@eq, correspondences(3:4,v), type3));
            
            if isempty(isin)
                correspondences(:,v) = nan;
                correspondences(:, v) = nan;
                correspondences(:, v) = nan;
            end
        end
 
    otherwise
        disp('No type selected');
        
end

correspondences(:, isnan(correspondences(1,:))) = [];      


% use corners which are around a specific radius around the micro-lens
new_correspondences = correspondences(:, sqrt(sum((correspondences(3:4, :) - correspondences(1:2, :)).^2)) < max_corn_dist);

correspondences = new_correspondences;

        
if (use_type ==1 || use_type == 2 || use_type == 3)        
    save([path1 'correspondences' sprintf('Type%d', use_type) file1{1}(numel('lfCorners') + 1 : end)], 'correspondences');
else
    save([path1 'correspondencesAll' file1{1}(numel('lfCorners') + 1 : end)], 'correspondences');
    
end


    