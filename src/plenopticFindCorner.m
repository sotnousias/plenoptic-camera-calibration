function [pts, coeffs1, coeffs2] = plenopticFindCorner(microImg, sumThreshold)

  global showDebug

  % nans = isnan(microImg(:, :, 1));
  % microImg = double(im2bw(microImg, 0.5));
  % microImg(nans(:)) = NaN;
  
  k = 3; % Keep k best-line candidates

  % changed the value to half
  discr = 0.25;
%   discr = 0.25/2;

  x = 1:discr:size(microImg, 2);
  intersectsOriginal = 1:discr:size(microImg, 2);
  
  % change the step to the one tenth
  angles = -pi/2:pi/50:pi/2;
%   angles = -pi/2:pi/100:pi/2;



  [anglesGrid, intersectsGrid] = meshgrid(angles, intersectsOriginal);
  angles = anglesGrid(:);
  intersects = intersectsGrid(:);
  
  % Passes from any pixel on the middle row
  a1 = tan(angles);
  b1 = intersects - a1*size(microImg, 1)/2;
  
  pixelSum = zeros(length(a1), 1);
  
  coeffs = repmat(struct('angle', NaN, 'a', NaN, 'b', NaN), [length(angles), 1]);
  coeffs1 = struct('a', NaN, 'b', NaN);
  coeffs2 = struct('a', NaN, 'b', NaN);
  
  lines = cell(1, 1);
  % Move the corner orientation
  parfor pairIdx = 1:length(angles)
  
    currAngle = angles(pairIdx);
    currA1 = a1(pairIdx);
    currB1 = b1(pairIdx);
    
    line = findLine(x, currA1, currB1, microImg);
    
    if isempty(line)
      continue;
    end
      
    % Sum along line 1
    % vals = interp2(microImg, line(:, 2), line(:, 1));
    idx = (line(:, 1) - 1)*size(microImg, 1) + line(:, 2);
    vals = microImg(idx);
    
    lines{pairIdx} = line;
    coeffs(pairIdx).angle = currAngle;
    coeffs(pairIdx).a = currA1;
    coeffs(pairIdx).b = currB1;
    pixelSum(pairIdx) = sum(vals > 0.7) - sum(vals < 0.3); % sum(vals(vals > 0.5))*sum(vals > 0.5)^2;

  end
  
  % Get k-max of most probable lines
  [maxPixelSums, sortingIndices] = sort(pixelSum, 'descend');
  
  maxPixelSums = maxPixelSums(1:k);
  bestCandidates = sortingIndices(1:k);
  bestAngles = [coeffs(bestCandidates).angle];
  bestBetas = [coeffs(bestCandidates).b];
  
  if showDebug
    
    figure(1);
    imshow(microImg, 'InitialMagnification', 'fit');
    hold on;
    for i = 1:k
      plot(lines{bestCandidates(i)}(:, 1), lines{bestCandidates(i)}(:, 2), 'r', 'LineWidth', 2);
    end
    hold off;
    
  end
  
  % Check with the second line  
  microImg = 1 - microImg;
  numRandAng = 40;
  
  maxPixelSum = -Inf;
  minPixelSum = -Inf;
  sumDiff = -Inf;
  
  % Create random angles for intersection
  randAnglesOriginal = pi/2 - pi/5 + pi/2.5*rand(1, numRandAng);
  bestBetas = repmat(bestBetas(:), [length(intersectsOriginal), 1]);
  
  for bestIdx = 1:k
    
    angles = bestAngles(bestIdx) + randAnglesOriginal;
    
    [anglesGrid, intersectsGrid] = meshgrid(angles, intersectsOriginal);
    angles = anglesGrid(:);
    intersects = intersectsGrid(:);
    
    % Passes from any pixel on the middle row
    a2 = tan(angles);
    b2 = intersects - a2*size(microImg, 1)/2;

    for pairIdx = 1:length(angles)

      currA2 = a2(pairIdx);
      currB2 = b2(pairIdx);

      line = findLine(x, currA2, currB2, microImg);

      if isempty(line)
        continue;
      end

      % Sum along line 1
      % vals = interp2(microImg, line(:, 2), line(:, 1));
      idx = (line(:, 1) - 1)*size(microImg, 1) + line(:, 2);
      vals = microImg(idx);
    
      % this is the correct one from Christos
      % currentPixelSum = sum(~isnan(vals)) - length(vals(vals > 0.2));
      currentPixelSum = sum(vals > 0.7) - sum(vals < 0.3); %1/std(vals)*sum(vals > 0.5); %(sum(vals(vals > 0.5)) - sum*sum(vals > 0.5)^2;

%       currentPixelSum = sum(vals > 0.35) - sum(vals < 0.15); %1/std(vals)*sum(vals > 0.5); %(sum(vals(vals > 0.5)) - sum*sum(vals > 0.5)^2;


      if currentPixelSum > minPixelSum

        minPixelSum = currentPixelSum;

        % Swap angles
        coeffs1.a = tan(bestAngles(bestIdx));
        coeffs1.b = bestBetas(bestIdx);
        maxPixelSum = maxPixelSums(bestIdx);

        coeffs2.a = currA2;
        coeffs2.b = currB2;

        % corner is the intersection point
        pts(1) = (coeffs2.b - coeffs1.b)/(coeffs1.a - coeffs2.a);
        pts(2) = coeffs2.a*pts(1) + coeffs2.b;

        sumDiff = maxPixelSum - minPixelSum;        
        
      end

    end
  end
  
  % maxPixelSum
  % minPixelSum
  % imshow(microImg)
  % Do a sanity check and if the sums are not too much different, ignore
  if maxPixelSum < 0.5*size(microImg, 1) || ...      
     minPixelSum < 0.5*size(microImg, 1) || ...
    abs(maxPixelSum/minPixelSum - 1) > 1 || ...
    min(pts) < 4 || ...
    max(pts) > size(microImg, 1) - 4
         % minPixelSum > 3/size(microImg, 1) || ...
%      sumDiff < sumThreshold || sumDiff < 0 || ...

%    minPixelSum > 5
    
    pts = [NaN NaN];
    
  end
  
end
  