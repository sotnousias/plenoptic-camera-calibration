% cluster the local areas of the microlenses

% load the corners in the central-sub-image
[file1,path1]=uigetfile('CI*.mat','Central Sub-Aperture Image','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

load([path1 file1{1}]);
% load([path1 'L' file1{1}(3:end)])

% load the detected corners
load([path1 'lfCorners' file1{1}(3:end-3) 'mat']);

% get the image to be used in the next step
im = imread([path1 file1{1}(numel('CI_')+1:end-3) 'png']);

% radius of each micro-lens
radius = 15;

center_v = lfCorners(3:4, :);
corner_v = lfCorners(1:2, :);

% scale the centers with respect to the sub-central image.
center_v_scale = center_v / (2*radius) + 1;
quer_idx = 1;
num_centroids = 0;

corner_x = corner(1,:);
sort_corn_x = sort(corner_x);

% the number of cluster that observe the 3D corner are the number of the
% corners in the central-sub-image.
num_centroids = size(corner,2);

centroids = zeros(2, num_centroids);

centr_idx = 1;


% find the centroids of each local cluster, which are used as input in
% k-means

for idx = 1:size(corner,2)
        
    centroids(:, centr_idx) = corner(3:4, idx);
%     centroids = [centroids centroid];
    centr_idx = centr_idx + 1;
end


% find the different local microlens clusters
labels = kmeans(center_v', num_centroids, 'Start', centroids'*2*radius, 'Distance', 'cityblock');%, 'EmptyAction', 'drop', 'Replicates', 18);

% figure;
% hold on
% colormap winter
clusters = {};

for lab = 1:numel(unique(labels))
    
    clusters{lab} = center_v(:, labels == lab);
    
    % save the corresponding corners so we can do the corner-image extraction
    % later.
    corner_cluster{lab} = corner_v(:, labels == lab);
    
%     plot(center_v(1, labels == lab), center_v(2, labels==lab), '.', 'Markersize', 25)%,'Color', [0 1 lab/numel(unique(labels))])   
    
end

