function idx = within(lowerBound, values, upperBound)
%
% FUNCTION
%   within returns a binary vector specifying with "ones" which values of
%   VALUES fall within the LOWERBOUND and the UPPERBOUND.
%
% USAGE
%   idx = within(lowerBound, value, upperBound).
%
% INPUT
%   lowerBound - A single value specifying the lower bound to be checked.
%
%   values - The vector of values to be checked against the bounds.
%
%   upperBound - A single value specifying the upper bound to be checked.
%
% OUTPUT
%   idx - A vector of size(values) specifying which indices are inside the
%   specified bounds.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   2014/01/16
%

  if nargin < 3
    error('within: Three input arguments are required.');
  end
  if numel(lowerBound) ~= 1
    error('within: Lower bound should be a single value.');
  end
  if numel(upperBound) ~= 1
    error('within: Upper bound should be a single value.');
  end
  if lowerBound > upperBound
    error('within: Lower bound should be less or equal to the upper bound.');
  end
  
  idx = (values >= lowerBound & values <= upperBound);

end