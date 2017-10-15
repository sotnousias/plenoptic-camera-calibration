function [ clusters, centroids, labels ] = clusterCenters( centers, corners, radius, debug )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


centers_scaled = centers / (2*radius) + 1;
quer_idx = 1;
num_centroids = 0;

corner_x = corners(1,:);
sort_corn_x = sort(corner_x);

while (quer_idx<= size(corners,2))
    num_corners =  numel(find(sort_corn_x == sort_corn_x(quer_idx)));
    
    num_centroids = num_centroids + num_corners - 1;
    
    quer_idx = quer_idx + num_corners;
end


centroids = zeros(2, num_centroids);

centr_idx = 1;

for idx = 1:size(corners,2)
    
    corner1 = corners(3:4, idx);
    
    idx2 = find(corners(1,:) == corners(1,idx) & (corners(2,:) == corners(2, idx) - 1));
    
    if isempty(idx2)
        idx2 = find(corners(1,:) == corners(1,idx) & (corners(2,:) == corners(2, idx) + 1));
    end
    
   
    if isempty(idx2)
        continue;
    end
    
    
    corner2 = corners(3:4, idx2);
    
    centroid = (corner1 + corner2)/ 2;
    
    if find(bsxfun(@eq, centroids, centroid))
        continue;
    end
    
    
    centroids(:, centr_idx) = centroid;

    centr_idx = centr_idx + 1;
end

labels = kmeans(centers_scaled', num_centroids, 'Start', centroids');

clusters = cell(numel(unique(labels)),1);

if debug
    figure;
    hold on;
end


for lab = 1:numel(unique(labels))
    
    clusters{lab} = centers(:, labels == lab);
    
    if debug
        plot(centers(1, labels == lab), centers(2, labels==lab), '.', 'Markersize', 25)%,'Color', [0 1 lab/numel(unique(labels))])   
    end
    
    
end

if (debug)
    hold off
end

end

