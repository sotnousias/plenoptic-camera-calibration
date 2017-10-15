% need to run clusterCornerPointsLocal priori to this

img = im;
isGood = ones(numel(unique(labels)), 1);
% maximum distance for the neighbours of each microlens
max_dist = 38;

% radius for micro-image extraction
radius = 13;

% method used for focus measure, depending on the method you have to change
% rgb2rgay etc
method = 'GDER';

correct_1 = 0;
correct_2 = 0;
correct_3 = 0;

for lab = 1:numel(unique(labels))
    
    % get the centers of the cluster
    cvs = clusters{lab};
    measures = zeros(size(cvs,2), 1);
    
    for cv = 1:size(cvs,2)
        
        
        %         imTemp = double(rgb2gray(uint8(extractMicroImg(img, [cvs(1,cv) cvs(2,cv)], 12))));
        imTemp = (((extractMicroImgNaN(im2double(img), [cvs(1,cv) cvs(2,cv)], radius))));

        measures(cv) = fmeasure(rgb2gray(imTemp), method);
    end

    % if the cluster contains only two corners, skip it
    if numel(measures) < 4
        break;
    end
    
    [label, centroids] = kmeans(measures,3, 'Distance', 'cityblock', 'Replicates', 30);

    
    % check if the micro-lenses of the same label are in the correct type
    centers1 = cvs(:, label == 1);
    centers2 = cvs(:, label == 2);
    centers3 = cvs(:, label == 3);
    
    % check if all the centers lie in one of the types
    type1 = cvs(:, find(sum(ismember(cvs, type_1struct))==2));
    type2 = cvs(:, find(sum(ismember(cvs, type_2struct))==2));
    type3 = cvs(:, find(sum(ismember(cvs, type_3struct))==2));

    
    
    % label-1 with type1, type2, type3
%     [bool1_1, n11] = isInType(centers1, type_1struct);
%     [bool1_2, n12] = isInType(centers1, type_2struct);
%     [bool1_3, n13] = isInType(centers1, type_3struct);

    [bool1_1] = isInType(centers1, type1);
    [bool1_2] = isInType(centers1, type2);
    [bool1_3] = isInType(centers1, type3);
    
%     % label-2 with type1, type2, type3
%     bool2_1 = isInType(centers2, type_1struct);
%     bool2_2 = isInType(centers2, type_2struct);
%     bool2_3 = isInType(centers2, type_3struct);
%     
    bool2_1 = isInType(centers2, type1);
    bool2_2 = isInType(centers2, type2);
    bool2_3 = isInType(centers2, type3);


%     % label-3 with type1, type2, type3
%     bool3_1 = isInType(centers3, type_1struct);
%     bool3_2 = isInType(centers3, type_2struct);
%     bool3_3 = isInType(centers3, type_3struct);
%     
%     
    bool3_1 = isInType(centers3, type1);
    bool3_2 = isInType(centers3, type2);
    bool3_3 = isInType(centers3, type3);



    if (bool1_1 || bool2_1 || bool3_1)
        correct_1 = correct_1 + 1;
    end
    
     if (bool1_2 || bool2_2 || bool3_2)
        correct_2 = correct_2 + 1;
     end
    
     if (bool1_3 || bool2_3 || bool3_3)
         correct_3 = correct_3 + 1;
     end
     
    
    
    % in order for the classification of each cluster to be correct, if
    % label1 is type 1, then label 2 has to be type 2 or 3.. etc
    
    
    
    
    % cell which contains for each local cluster the corresponding labels
    label_cluster{lab} = label;

    
    clear cvs
end



%%

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
