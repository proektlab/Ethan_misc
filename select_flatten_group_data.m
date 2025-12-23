function data_out = select_flatten_group_data(data, opts)
% take a cell of data matrices and do the following operations:
% - If select_dims is non-empty, for each matrix in the cell, select the entries in
%   select_dims(:, 2) from dimensions select_dims(:, 1) and remove these dimensions.
% - If along_dims is non-empty, move these dimensions (in order specified)
%   to the end of each matrix and don't touch them. These must have the same size for all matrices.
% - Flatten other dims into the first dimension
% - Concatenate along the first dimension. 
%   - If group_masks is a scalar struct, each field should be a size(data) logical array.
%     Data selected from the masked matrices are concatenated individually for each group
%     and a struct with the same fields is returned.
%   - Otherwise, an array is returned with all arrays concatenated, in column-major order

arguments
    data cell
    opts.select_dims (:,2) double {mustBeInteger} = zeros(0, 2)
        % dimensions along which to select one row/column/etc (each row is dim, index)
        % e.g. [1, 2] to select the second row of each data matrix
    opts.along_dims (:,1) double {mustBeInteger} = zeros(0, 1)
        % dimensions to loop along for each data matrix
        % (return values will be matrices of size size(data{1}, opts.along_dims))
    opts.group_masks struct {mustBeScalarOrEmpty} = struct.empty
end

if isempty(data)
    if isempty(opts.group_masks)
        data_out = [];
    else
        data_out = structfun(@(~) [], opts.group_masks, 'uni', false);
    end
    return
end

if ~isempty(intersect(opts.along_dims, opts.select_dims(:, 1)))
    error('select_dims and along_dims must be disjoint');
end

if size(opts.select_dims, 1) ~= length(unique(opts.select_dims(:, 1)))
    error('Cannot have duplicate dimensions in select_dims');
end

if ~isempty(opts.group_masks)
    assert(all(structfun(@numel, opts.group_masks) == numel(data)), ...
        'group_masks must all match the size of data')
end

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

if isempty(opts.group_masks)
    data_out = vertcat(data{:});
else
    data_out = structfun(@(mask) vertcat(data{mask}), opts.group_masks, 'uni', false);
end

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
        matrix_out = reshape(matrix_selected, [prod(sz_flatten), sz_along]);
    end
end
