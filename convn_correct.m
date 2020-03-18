function y = convn_correct(x, h, omitnan)
% 'same' convn with corrections from matlab.internal.math.smoothgauss
% (mostly copied from that function)
% only handles a vector kernel, which should already be normalized.
% omitnan defaults to false

if nargin < 3
    omitnan = false;
end

assert(~isempty(h), 'Kernel must not be empty');

dim = find(size(h) > 1); % convolution dimension
if isempty(dim)
    % simple case
    y = x * h;
    return;
    
elseif numel(dim) > 1
    error('edge_correct only works with a 1-D kernel');
end

winsz = length(h);

y = x;
assert(dim <= ndims(x), 'Convolution dimension not present in input');

% Operate along the 1st dimension
if dim ~= 1
    pind = [dim, 1:(dim-1), (dim+1):ndims(y)];
    y = permute(y, pind);
end
h = h(:);

% Keep track of indices of NaN inputs
if omitnan && any(isnan(y(:)))
    nanInd = isnan(y);
    y(nanInd) = 0;
else
    nanInd = false(size(y));
end

% Compensate for how "conv" handles even lengths with 'same'
if rem(length(h), 2) == 0
    h = [0; h];
end

% Convolve
y = convn(y, h, 'same');

% Compensate for endpoints and NaN locations by computing the sum of
% the filter coefficients contributing at each location
halfwinsz = ceil(winsz / 2);
sz = size(nanInd);
sz(1) = halfwinsz;
nanInd = cat(1, true(sz), nanInd, true(sz));
ync = sum(h) - convn(double(nanInd), h, 'same');
ync = ync((halfwinsz+1):(halfwinsz+size(y,1)), :);
ync = reshape(ync, size(y));
y = y ./ ync;
if any(nanInd)
    % Correct NaN values that disappear because of roundoff.
    ycnt = convn(double(nanInd), ones(size(h)), 'same');
    ycnt = ycnt((halfwinsz+1):(halfwinsz+size(y,1)), :) == numel(h);
    y(ycnt) = NaN;
end

if dim ~= 1
    y = ipermute(y, pind);
end

end