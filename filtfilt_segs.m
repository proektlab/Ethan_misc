function data = filtfilt_segs(b, a, data, segs, dim)
% filtfilt_segs: Apply filtfilt on individual segments of input data (e.g. runs of non-nan values).
%
% Inputs 'b', 'a' are as in filtfilt.
% Input 'data' should be a vector, matrix, or cell of matrices; will be returned in the same format.
% Input 'segs' should be a cell of vectors which are indices into data (or into each member if data
%       is a cell). They should probably be non-overlapping although it's not checked.
% Input 'dim' specifies the dimension to operate along for a matrix or cell of matrix input (ignored
%       for vectors/cells of vectors.

if iscell(data)
    data = cellfun(@(d) filtfilt_segs_mat(b, a, d, segs, dim), data, 'uni', false);
else
    data = filtfilt_segs_mat(b, a, data, segs, dim);
end

end

function data = filtfilt_segs_mat(b, a, data, segs, dim)

% filtfilt only operates along the first dimension, so permute
nd = ndims(data);
perm = [dim, 1:dim-1, dim+1:nd];
data = permute(data, perm);

% reshape so it's a matrix
permuted_size = size(data);
data = reshape(data, permuted_size(1), []);

n_segs = numel(segs);
for kS = 1:n_segs
    data(segs{kS}, :) = filtfilt(b, a, data(segs{kS}, :));
end

data = reshape(data, permuted_size);
data = ipermute(data, perm);

end