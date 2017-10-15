function line = findLine(x, a, b, microImg, rnd)

  if nargin < 5
    rnd = true;
  end

  line = [x; (a*x + b)]';
  toKeep = (line(:, 1) > 0.51 & line(:, 1) <= size(microImg, 1)) & ...
    (line(:, 2) > 0.51 & line(:, 2) <= size(microImg, 2));

  if rnd == true
    line = round(line(toKeep, :));
    line = unique(line, 'rows');
  end

end