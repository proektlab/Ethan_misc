function [concat_data, weights, b_valid, classes, b_heldout] = concat_and_weight_data(...
    nested_data, opts, toplevel_opts)
% recursively build weights that are inversely proportional to the number of sub-items in
% nested_data (which should be either a cell array vector or an nunits x nsamples matrix)
% output weights will sum to base_weight (default 1) along concat_dim dimension (default 2).
% If skip_nans is true (default false), weights will be the same size as concat_data, where nan items
%   in the data are assigned zero weight. Otherwise, weights is a vector along concat_dim.
% Either way, if there are < valid_threshold nonzero elements in any subclass,
%   b_valid will be false (array with size matching concat_data except 1 along concat_dim if 
%   skip_nans is true, else scalar).
% classes gives the positive integer index of the (top-level) cell each sample came from
%   (all 1s if a matrix is passed). If class_labels is given, it must be a vector the same length as 
%   nested_data (if a cell) or a scalar, and these values are used intead of 1:N.
%
% integer_weights overrides base_weight and scales all weights to be integers rather than having
% them sum to a specific value. This can help avoid floating-point errors.
% If integer_weights and skip_nans are true, each row's weights will sum to a different value.
%
% If holdout_ind is nonempty, holds out this index in the *flattened* data (along concat_dim)
% and adjusts weights/b_valid accordingly.

arguments
    nested_data {mustBeA(nested_data, ["cell", "double"])}
    opts.concat_dim (1,1) double {mustBeInteger,mustBePositive} = 2
    opts.skip_nans (1,1) logical = false
    opts.integer_weights (1,1) logical = false
    opts.valid_threshold (1,1) double {mustBeInteger} = 1

    % options not forwarded to recursive calls
    toplevel_opts.base_weight (1,1) double = 1
    toplevel_opts.class_labels {mustBeVector} = zeros(1,0)
    toplevel_opts.holdout_ind double {mustBeInteger,mustBePositive,mustBeScalarOrEmpty} = []

    % for internal use in recursive calls
    toplevel_opts.allow_oob_holdout (1,1) logical = false
end

% hack to reshape to a vector along given dimension
concat_vector_shape = [num2cell(ones(1, opts.concat_dim-1)), {[], 1}];

b_heldout = false;

if iscell(nested_data)
    if ~isvector(nested_data)
        error('Cell array inputs must be vectors')
    end
    nested_data = reshape(nested_data, concat_vector_shape{:}); 

    if isempty(toplevel_opts.class_labels)
        class_values = 1:length(nested_data);
    else
        class_values = toplevel_opts.class_labels;
        assert(length(class_values) == length(nested_data), 'Length of class_values does not match input');
    end
else
    if isempty(toplevel_opts.class_labels)
        class_values = 1;
    else
        class_values = toplevel_opts.class_labels;
        assert(isscalar(class_values), 'class_values should be a scalar when a cell is not passed');
    end

    if ~isempty(toplevel_opts.holdout_ind)
        if toplevel_opts.holdout_ind <= size(nested_data, opts.concat_dim)
            del_inds = repmat({':'}, 1, ndims(nested_data));
            del_inds{opts.concat_dim} = toplevel_opts.holdout_ind;
            nested_data(del_inds{:}) = [];
            b_heldout = true;
        end
    end
end

n_items = size(nested_data, opts.concat_dim);
if opts.integer_weights
    weights = reshape(ones(1, n_items), concat_vector_shape{:});
else
    weights = reshape(repmat(toplevel_opts.base_weight / n_items, 1, n_items), concat_vector_shape{:});
end

if iscell(nested_data)
    % recurse into cells
    optcell = namedargs2cell(opts);

    sub_data_flat = cell(size(nested_data));
    sub_weights = cell(size(nested_data));
    sub_b_valid = cell(size(nested_data));
    cum_n = 0;

    for kSub = 1:numel(nested_data)
        if ~isempty(toplevel_opts.holdout_ind) && ~b_heldout
            holdout_ind_rel = toplevel_opts.holdout_ind - cum_n;
        else
            holdout_ind_rel = [];
        end

        [sub_data_flat{kSub}, sub_weights{kSub}, sub_b_valid{kSub}, ~, sub_b_heldout] = ...
            concat_and_weight_data(nested_data{kSub}, optcell{:}, base_weight=weights(kSub), ...
            holdout_ind=holdout_ind_rel, allow_oob_holdout=true);

        cum_n = cum_n + size(sub_data_flat{kSub}, opts.concat_dim);
        b_heldout = b_heldout || sub_b_heldout;
    end

    % [sub_data_flat, sub_weights, sub_b_valid] = arrayfun(@(sub_data, w) ...
    %     concat_and_weight_data(sub_data{1}, optcell{:}, base_weight=w), ...
    %     nested_data, weights, 'uni', false);
    concat_data = cell2mat(sub_data_flat);

    if opts.integer_weights
        % weight by prod of sum of other classes
        weight_sums = cellfun(@(subw) sum(subw, opts.concat_dim), sub_weights, 'uni', false);
        weight_sums = cat(opts.concat_dim, weight_sums{:});

        for kW = 1:n_items
            % exclude this slice along concat_dim and take product of the other weights to get
            % factor to multiply weights for this item by
            other_weight_inds = repmat({':'}, 1, ndims(weight_sums));
            other_weight_inds{opts.concat_dim} = [1:kW-1, kW+1:n_items];
            sub_weights{kW} = sub_weights{kW} .* prod(weight_sums(other_weight_inds{:}), opts.concat_dim);
        end
    end
     
    weights = cell2mat(sub_weights);
    b_valid = all(cell2mat(sub_b_valid), opts.concat_dim);

    % classes only takes into account top-level membership (doesn't use classes from recursive calls)
    n_per_class = cellfun('size', sub_data_flat, opts.concat_dim);
    classes = reshape(repelem(class_values, n_per_class), concat_vector_shape{:});
else
    if opts.skip_nans
        % make weights by counting non-nan in each row
        n_nonnan = sum(~isnan(nested_data), opts.concat_dim);
        if opts.integer_weights
            weights = ones(size(nested_data));
        else
            rep_shape = concat_vector_shape;
            rep_shape{opts.concat_dim} = n_items;
            weights = repmat(toplevel_opts.base_weight ./ n_nonnan, rep_shape{:});
        end
        weights(isnan(nested_data)) = 0;
        b_valid = n_nonnan >= opts.valid_threshold;
    else
        % use weights as defined above
        b_valid = n_items >= opts.valid_threshold;
    end
    concat_data = nested_data;
    classes = reshape(repmat(class_values, 1, n_items), concat_vector_shape{:});
end

if ~isempty(toplevel_opts.holdout_ind) && ~toplevel_opts.allow_oob_holdout && ~b_heldout
    error('Cannot hold out index %d - out of bounds', toplevel_opts.holdout_ind);
end

end