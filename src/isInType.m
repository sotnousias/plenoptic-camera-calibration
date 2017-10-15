function [ boolFlag] = isInType( centers, typeQuery )
% returns whether a set of centers is a member of a specific type of
% micro-lenses. In order to return true, all the centers have to lie on the
% same type. Used to validate classification results.


    inType = ismember(centers, typeQuery);
    inType = inType(1, :) .* inType(2, :);

    boolFlag = (size(centers, 2) == numel(find(inType)));
    
    if (boolFlag)
        if size(centers, 2) ~= size(typeQuery, 2)
            boolFlag = false;
        end
    end
%     howMany = numel(find(inType));
end

