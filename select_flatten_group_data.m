function [data_out, weights, b_valid, classes] = select_flatten_group_data(data, opts, concat_opts)
% take a cell of data matrices and do the following operations:
% - If select_dims is non-empty, for each matrix in the cell, select the entries in
%   select_dims(:, 2) from dimensions select_dims(:, 1) and remove these dimensions.
%
% - If along_dims is non-empty, move these dimensions (in order specified)
%   to the end of each matrix and don't touch them. These must have the same size for all matrices.
%
% - Flatten other dims into the first dimension
%
% - Concatenate along the first dimension, using concat_and_weight data. group_masks is a dictionary
%   mapping class labels to logical arrays the same size as data defining top-level groups
%   (by default, all data are in one group with the label 1). When concatenating, data are passed as
%   a nested cell with these groups at the top level, so that classes reflect the groups but weights
%   reflect the amount of data in each sub-cell. Options skip_nans, integer_weights, base_weight,
%   and holdout_ind are also passed through to concat_and_weight_data, and b_valid is returned.

arguments
    data cell
    opts.select_dims (:,2) double {mustBeInteger} = zeros(0, 2)
        % dimensions along which to select one row/column/etc (each row is dim, index)
        % e.g. [1, 2] to select the second row of each data matrix
    opts.along_dims (:,1) double {mustBeInteger} = zeros(0, 1)
        % dimensions to loop along for each data matrix
        % (return values will be matrices of size size(data{1}, opts.along_dims))
    opts.group_masks dictionary = dictionary(1, {true(size(data))})

    % forwarded to concat_and_weight_data
    concat_opts.skip_nans (1,1) logical = false
    concat_opts.integer_weights (1,1) logical = false
    concat_opts.base_weight (1,1) double = 1
    concat_opts.holdout_ind double {mustBeInteger,mustBePositive,mustBeScalarOrEmpty} = []
end

class_labels = keys(opts.group_masks);

if isempty(data)
    % we don't have any matrices to take the size of, so can't do anything
    data_out = [];
    classes = class_labels([], 1);  % expected to be a column vector
    if concat_opts.skip_nans
        weights = [];
        b_valid = logical.empty(1, 0);
    else
        weights = zeros(0, 1);  % expected to be a column vector
        b_valid = false;
    end
    return
end

if ~isempty(intersect(opts.along_dims, opts.select_dims(:, 1)))
    error('select_dims and along_dims must be disjoint');
end

if size(opts.select_dims, 1) ~= length(unique(opts.select_dims(:, 1)))
    error('Cannot have duplicate dimensions in select_dims');
end

assert(all(cellfun(@numel, values(opts.group_masks)) == numel(data)), ...
    'group_masks must all match the size of data')

% process each matrix so they are [prod(other dims), along_dims...] size
nd = max(cellfun('ndims', data), [], "all");
flatten_dims = setdiff((1:nd)', [opts.along_dims; opts.select_dims(:, 1)]);
data = cellfun(@process_dims, data, 'uni', false);

% validate that along_dims dimensions are the same
for kD = 1:length(opts.along_dims)
    if any(cellfun('size', data, kD+1) ~= size(data{1}, kD+1))
        error('To work along dim %d, data must all be the same size in this dimension', opts.along_dims(kD));
    end
end

% group data according to group_masks and weight/concatenate
nested_data = cellfun(@(group_mask) data(group_mask), values(opts.group_masks), 'uni', false);
concat_optcell = namedargs2cell(concat_opts);
[data_out, weights, b_valid, classes] = concat_and_weight_data(nested_data, ...
    concat_optcell{:}, concat_dim=1, class_labels=class_labels);

    function matrix_out = process_dims(data_matrix)
        % select dimensions according to select_dims and shift them to the end (squeeze)
        % move along_dims to the end and flatten other dims to the first dimension.
        
        % first permute to (flatten, along, select) dims
        sz = size(data_matrix, 1:nd);
        sz_flatten = sz(flatten_dims);
        sz_along = sz(opts.along_dims);

        matrix_permuted = permute(data_matrix, [flatten_dims; opts.along_dims; opts.select_dims(:,1)]);
        
        % select select_dims
        inds_select = [repmat({':'}, length(sz_flatten) + length(sz_along), 1); opts.select_dims(:, 2)];
        matrix_selected = matrix_permuted(inds_select{:});


        % flatten flatten_dims
        matrix_out = reshape(matrix_selected, [prod(sz_flatten), sz_along, 1]);
    end
end
