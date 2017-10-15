% classifies the lenses based on the measure
% requires the clusterCornerPointsLocal to run first.



% figure
% imshow(img);
% hold on
% title('Using the whole micro-image');
img = im;
isGood = ones(numel(unique(labels)), 1);
queryCluster_Labels = find(isGood);

% maximum distance for the neighbours of each microlens
max_dist = 38;

% correct_check = false;
cluster_idx = 1;


for lab = 1:numel(unique(labels))
    
    % centers that observe the same point
    cvs = clusters{lab};
    
    cornervs = corner_cluster{lab};
    
    measures = zeros(size(cvs,2), 1);
    
    % get the focus measure for each micro-lens
    for cv = 1:size(cvs,2)

%         imTemp = extractCircleInCornerImage( img, 15, cvs(:, cv), cornervs(:, cv), 6 );
        imTemp = extractCircleInCornerImage( im2double(img), 15, cvs(:, cv), cornervs(:, cv), 6 );

        measures(cv) = fmeasure(imTemp, 'TENG');
    end

    % if the cluster contains only two corners, skip it
    if numel(measures) < 4
        continue;
    end
   
    [label, centroids] = kmeans(measures,3, 'Distance', 'cityblock', 'Replicates', 30);

    % cell which contains for each local cluster the corresponding labels
    label_cluster{cluster_idx} = label;
    cluster_idx = cluster_idx + 1;
        
    clear cvs
end




%% Plot the correct labels
% figure
% imshow(img)
% hold on
% 
% for i = 1:length(queryCluster_Labels)
% 
%     lab = (queryCluster_Labels(i));
% 
%     % obtain one local cluster per loop
%     cvs = center_v(:, labels == lab);
% %
%     for j = 1:size(cvs,2)
% 
%         if label_cluster{lab}(j) == 1
%             color = [196,124,0] / 255;
%         elseif label_cluster{lab}(j) == 2
%             color = [153,41,50]/255;
%         elseif label_cluster{lab}(j) == 3
%             color = [22,76,110]/255;
%         end
% 
% 
%         plot(cvs(1,j), cvs(2, j) ,'.', 'Color', color, 'MarkerSize', 25);
%     end
% %     i
% %     pause();
% 
% end