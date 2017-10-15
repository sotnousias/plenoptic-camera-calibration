%% Step I. Sort the same type lenses so you can find the vector grids.
% priot to running this script, typeClassificationUsingCircularRegion has
% to run

% TO DO: upload the voting scheme code

if ~(exist('center_list') == 1)
    load([path1 'microlens_center_list.mat'])
end

num_of_types = 3;
typeStruct = cell(length(queryCluster_Labels), num_of_types);

% the distance we want the centers to lie on a vertical line.
max_vertical_pixel_distance = 1;


rand_ind = randperm(length(queryCluster_Labels));
struct_idx = 1;

for n = 1:length(rand_ind)
    
    clust = queryCluster_Labels(rand_ind(n));
    
    % get all the centers of the good cluster
    query = clusters{clust};
    
    % get the corresponding labels
    query_lab = label_cluster{clust};
    
    for lab = 1:num_of_types
        
        % find the centers of the label 1 (type 1)
        typeQuery = query(:, query_lab == lab);
        
        
        % if we have less than 3 corners, we can not construct the grid
        % using this cluster, so skip and continue.
        if (size(typeQuery, 2) < 3)
            continue;
        end
        
        
        % sort them
        [~, idx] = sort(typeQuery(1,:));
        
        % take the sorted list of centers
        typeQuery = typeQuery(:, idx);
        
        % find the number of micro-lens centers which lie on the same vertical.
        % Given that, we know the next micro-lens center on the hexagonal grid
        % basis.
        start = 1;
        jump = numel(find(typeQuery(1,:) <= (typeQuery(1,1) + max_vertical_pixel_distance)));
        
        % check if the obtained point is left-most       
        if (jump < 1)
            jump = numel(find(typeQuery(1,:) <= (typeQuery(1,2) + max_vertical_pixel_distance)));
            start = 2;
        end
        
        % if all the centers are on the same vertical, move on
        if ( ~( jump < size(typeQuery, 2)) )
            continue;
        end
        
        % find vertical translation
        b_v = norm(typeQuery(:,start) - typeQuery(:, start + 1));
        
        % now find the line vector of this type
        a = (typeQuery(2, start) - typeQuery(2, start + jump) )/ (typeQuery(1, start) - typeQuery(1, start + jump));
        
        % find the b value of the line
        b_l = typeQuery(2, start) - a*typeQuery(1, start);
        
        line = [a b_l];
        
        for i = -60:60
            
            % translate along the line
            b = line(2) + i*b_v;
            
            temp_line = [line(1) b]';
            
            % y-ax-b has to equal zero (or close to zero)
            dot_prods = center_list(2,:) - temp_line(1)*center_list(1,:) - temp_line(2);
            
            typeStruct{struct_idx, lab} = [typeStruct{n, lab}; center_list(1,abs(dot_prods)<3)' center_list(2,abs(dot_prods)<3)'];
            
            %     plot(center_list(1,abs(dot_prods)<3), center_list(2,abs(dot_prods)<3), '.b', 'MarkerSize', 25)
        end
        
    end
    
    struct_idx = struct_idx + 1;
end

%% Check correctness.
% The different type structs have to be the same when we circle-permute the
% lables. Check each full cluster to find the final grid.

% first clean the empty lists

finalStruct = {};
idx = 1;

for i = 1 : length(typeStruct)
    
    if ~( isempty(typeStruct{i, 1}) || isempty(typeStruct{i, 2}) || isempty(typeStruct{i, 3}) )
        finalStruct(idx, :) = typeStruct(i, :);
        idx = idx + 1;
    end
end


clear typeStruct

typeStruct = finalStruct;

correct_flag = false;

search_idx = 1;
% while (~isempty(typeStruct))
% end
correctStruct = cell(3, 1);
    
for  i = 1:size(typeStruct, 1)
    
    queryStruct{1} = typeStruct{i, 1};
    queryStruct{2} = typeStruct{i, 2};
    queryStruct{3} = typeStruct{i, 3};
    
    % loop through all the typeStructs until you find two that span the
    % same grid.
    % The main idea is to correct all the centers assigned to a specific
    % types along different clusters and permute the labels. When we have a
    % matching between two different clusters, we have the correct grid.
    
    for n = (i + 1):size(typeStruct, 1)
        
        % check first type
        checkfl_11 = ismember(queryStruct{1}', typeStruct{n, 1}');
        checkfl_12 = ismember(queryStruct{1}', typeStruct{n, 2}');
        checkfl_13 = ismember(queryStruct{1}', typeStruct{n, 3}');        
        
        if ~(isempty(checkfl_11))
            checkfl_11 = numel(find(checkfl_11(1, :))) == size(typeStruct{n, 1}, 1);
        else
            checkfl_11 = 0;
        end
        
        if ~(isempty(checkfl_12))
            checkfl_12 = numel(find(checkfl_12(1, :))) == size(typeStruct{n, 2}, 1);
        else
            checkfl_12 = 0;
        end
        
        if ~(isempty(checkfl_11))
            checkfl_13 = numel(find(checkfl_13(1, :))) == size(typeStruct{n, 3}, 1);
        else
            checkfl_13 = 0;
        end
        
        bool1 = checkfl_11 || checkfl_12 || checkfl_13;
        
        % check second type
        checkfl_21 = ismember(queryStruct{2}', typeStruct{n, 1}');
        checkfl_22 = ismember(queryStruct{2}', typeStruct{n, 2}');
        checkfl_23 = ismember(queryStruct{2}', typeStruct{n, 3}');
 
        if ~(isempty(checkfl_21))
            checkfl_21 = numel(find(checkfl_21(1, :))) == size(typeStruct{n, 1}, 1);
        else
            checkfl_21 = 0;
        end
        
        if ~(isempty(checkfl_22))
            checkfl_22 = numel(find(checkfl_22(1, :))) == size(typeStruct{n, 2}, 1);
        else
            checkfl_22 = 0;
        end
        
        if ~(isempty(checkfl_23))
            checkfl_23 = numel(find(checkfl_23(1, :))) == size(typeStruct{n, 3}, 1);
        else
            checkfl_23 = 0;
        end        
                    
        bool2 = checkfl_21 || checkfl_22 || checkfl_23;
        
        % check third type
        checkfl_31 = ismember(queryStruct{3}', typeStruct{n, 1}');
        checkfl_32 = ismember(queryStruct{3}', typeStruct{n, 2}');
        checkfl_33 = ismember(queryStruct{3}', typeStruct{n, 3}');

        if ~(isempty(checkfl_31))
            checkfl_31 = numel(find(checkfl_31(1, :))) == size(typeStruct{n, 1}, 1);
        else
            checkfl_31 = 0;
        end
        
        if ~(isempty(checkfl_32))
            checkfl_32 = numel(find(checkfl_32(1, :))) == size(typeStruct{n, 2}, 1);
        else
            checkfl_32 = 0;
        end
        
        if ~(isempty(checkfl_33))
            checkfl_33 = numel(find(checkfl_33(1, :))) == size(typeStruct{n, 3}, 1);
        else
            checkfl_33 = 0;
        end        
                
        bool3 = checkfl_31 || checkfl_32 || checkfl_33;
        
        % did we find the correct struct?
        if (bool1 && bool2 && bool3)
            correctStruct = queryStruct;
            correct_flag = true;
            lens_types = correctStruct;
            type1_struct = correctStruct{1};
            type2_struct = correctStruct{2};
            type3_struct = correctStruct{3};
            save([path1 'lens_types.mat'], 'type1_struct', 'type2_struct', 'type3_struct')
            break;
        end
        
    end

    if (correct_flag)
        disp('Correct match found! Exiting ...');
        break;
    end
    
end





