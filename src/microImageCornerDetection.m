% find corner points in the micro-images

[file1,path1]=uigetfile({'nearC*.mat'} ,'Near corner mat files','MultiSelect','on');

if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

tic;
disp_str = sprintf('Processing %s ....', file1{1});
disp(disp_str);

% load the query micro-lens centers id
load([path1 file1{1}]);

% load the centers of the micro-lenses
load([path1 'microlens_center_list.mat']);
% load the image
im = imread([path1 file1{1}(numel('nearCorner') + 2:end-3) 'png']);


microImgRad = radius;
allPts = [];
imUse = rgb2gray(im2double(im));


for corn_id = 1:size(nearCorner, 1)

    for i = 1:size(nearCorner, 2)
        
        centr = [center_list(1, nearCorner(corn_id,i)), center_list(2, nearCorner(corn_id,i))];
  
        microImg = extractMicroImgNaN(im2double(im), centr, microImgRad);
        
        if isempty(microImg)
            continue;
        end
        
        % changed the threshhold to 7000 from 8000
        sumThreshold = 6000;
        [pts, line1, line2] = plenopticFindCorner(microImg, sumThreshold);
        
        if isempty(line1) || isempty(line2)
            
            continue;
            
        end
        corners = detectHarrisFeatures(rgb2gray(microImg));
        
        allPts = [allPts; centr - microImgRad + pts];
  
    end
end

% remove invalid points
allPts(isnan(allPts(:, 1)), :) = [];


lightfieldCorners = allPts';
save([path1 'lightfieldCorners' file1{1}(numel('nearCorner') + 1:end)], 'lightfieldCorners');

toc;


  