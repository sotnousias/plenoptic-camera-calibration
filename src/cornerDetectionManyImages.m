% select images and extract the corners per image. 

% !!!!! Be careful the number of neighbours around each corner is the same.

[file1,path1]=uigetfile('CI*.mat','Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end


% micro-lens radius, used for scaling the centers.
radius = 15;
scale = 2*radius;

% max number of neighbours to the corner in the central sub-aperture image
% considered.
neighbrs = 8;

print_str = sprintf('Using %d neighbours', neighbrs);
disp(print_str);

% load the micro-lens centers center_list (2xN array)
load([path1 'microlens_center_list.mat'])

% % load the corners in the central sub-aperture image
% % positions of the corner in the image are [corner(3,:) corner(4,:)]
% load([path1 'CI' file1{1}(numel('lfCorners') + 1: end)]);

% centers_list is 2xN micro-lens center coordinates
centers_scaled = center_list / (2 * radius) + 0.5;

% get the image number
ImageNum = length(file1);

% micro-image radius used for corner detection
microImgRad = 15;


for n = 1:ImageNum
    
    % load the corner file for this image
    disp_str = sprintf('Processing %s ....', file1{n});
    disp(disp_str);
    
    load([path1 file1{n}]);
    
    nearCorner = zeros(size(corner, 2), neighbrs);
    
    for i = 1:size(corner, 2)

        dist = sqrt(sum((centers_scaled - corner(3:4, i)).^2, 1));
        
        [~, ids] = sort(dist);
        
        ids = ids(1:neighbrs);
        
        nearCorner(i, :) = ids;

    end

    disp('Near Corners found...')
    save([path1 'nearCorner' file1{n}(numel('CI') + 1: end)], 'nearCorner');
    
    % load the corresponding image
    im = imread([path1 file1{n}(numel('CI') + 2:end-3) 'png']);
    
    allPts = [];
    imUse = rgb2gray(im2double(im));
    
    
    
    
    for corn_id = 1:size(nearCorner, 1)
        
        for i = 1:size(nearCorner, 2)
            
            centr = [center_list(1, nearCorner(corn_id,i)), center_list(2, nearCorner(corn_id,i))];
            
            microImg = extractMicroImgNaN(im2double(im), centr, microImgRad);
            
            if isempty(microImg)
                continue;
            end
            
            sumThreshold = 8000;
            [pts, line1, line2] = plenopticFindCorner(microImg, sumThreshold);
            
            if isempty(line1) || isempty(line2)
                
                continue;
                
            end
            
            %does not seem to be needed here
%             corners = detectHarrisFeatures(rgb2gray(microImg));
            
            allPts = [allPts; centr - microImgRad + pts];
            %         x = linspace(-50, 50, 2000);
            
            
        end
    end
    
    % remove invalid points
    allPts(isnan(allPts(:, 1)), :) = [];
    
    
    lightfieldCorners = allPts';
    save([path1 'lightfieldCorners' file1{n}(numel('CI') + 1:end)], 'lightfieldCorners');
    
    
    
    clear lightfieldCorners
    
      
    

end







