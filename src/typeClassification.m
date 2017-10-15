% classifies the lenses based on the measure
% requires the clusterCornerPointsLocal to run first.

% figure
% imshow(img);
% hold on
% title('Using the whole micro-image');
img = im;
isGood = ones(numel(unique(labels)), 1);
% maximum distance for the neighbours of each microlens
max_dist = 38;

for lab = 1:numel(unique(labels))
    
    cvs = clusters{lab};
    measures = zeros(size(cvs,2), 1);
    
    for cv = 1:size(cvs,2)
        
        
        %         imTemp = double(rgb2gray(uint8(extractMicroImg(img, [cvs(1,cv) cvs(2,cv)], 12))));
        imTemp = (((extractMicroImgNaN(im2double(img), [cvs(1,cv) cvs(2,cv)], 12))));

        measures(cv) = fmeasure(imTemp, 'TENG');
    end

    % if the cluster contains only two corners, skip it
    if numel(measures) < 4
        break;
    end
    
    [label, centroids] = kmeans(measures,3, 'Distance', 'cityblock', 'Replicates', 30);

    % cell which contains for each local cluster the corresponding labels
    label_cluster{lab} = label;
    
    if lab == 31
        5;
    end
%     for cv = 1:size(cvs,2)
%         
%          difs = cvs - cvs(:,cv);
%          
%          difs = difs.^2;
%          
%          dist = sqrt(sum(difs,1));
%          
%          ids = find(dist < max_dist);
%          
%          isEqual = (label(ids) == label(cv));
%          
%          if (numel(find(isEqual))>1)
%              
%              isGood(lab) = 0;
%              break;
%          
%          end
%     end
    
    
    
    
%     for i = 1:size(cvs,2)
%     
%         if label(i) == 1
%             col_str = '.r';
%         elseif label(i) == 2
%             col_str = '.g';
%         elseif label(i) == 3
%             col_str = '.b';
%         end
%         
%         
%         plot(cvs(1,i), cvs(2, i) , col_str, 'MarkerSize', 25);
%     end
    
    clear cvs
end




%% Plot the correct labels

imshow(im)
hold on

% if (exist('isGood'))
    queryCluster_Labels = find(isGood);
% else
%     queryLabels = 1:length(
for i = 1:length(queryCluster_Labels)
    
    lab = (queryCluster_Labels(i));
    
    % obtain one local cluster per loop
    cvs = center_v(:, labels == lab);
%     lines = line_v(:, labels == lab);
    
%     
%     measures = zeros(size(cvs,2), 1);
%     
%     for cv = 1:size(cvs,2)
%         
%         
%         %         [x,y] = lineCircleIntersection(line_v(:,cv), radius, center_v(:,cv));
%         
%         
%         line_image = (extractLineImage( lines(:, cv), img, cvs(:,cv), 15, 5  ));
%         
%         % caution, they should not be grayscale!!!
%         imTemp = double(rgb2gray(line_image));
%         measures(cv) = fmeasure((line_image), 'TENG');
%         
%     end
%     
%     
%     label = kmeans(measures,3, 'Distance', 'cityblock', 'Replicates', 20);
%     
%     
    for j = 1:size(cvs,2)
        
        if label_cluster{lab}(j) == 1
            col_str = '.r';
        elseif label_cluster{lab}(j) == 2
            col_str = '.g';
        elseif label_cluster{lab}(j) == 3
            col_str = '.b';
        end
        
        
        plot(cvs(1,j), cvs(2, j) , col_str, 'MarkerSize', 25);
    end
end