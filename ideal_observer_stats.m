function [acc, dprime] = ideal_observer_stats(c1_values, c2_values, opts)
% Find maximum accuracy for decoding any 2 classes based on 1-dimensional values.
% If values are matrices, operates along the 2nd dimension (independently for each row).
% If weighted is true, weight to correct for bias in number of class 1 vs class 2 values.
% If directed is true, assumes that the values are greater for class 1 than class 2;
%   otherwise the direction is determined from the data.

arguments
    c1_values double
    c2_values double
    opts.weighted (1,1) logical = false
    opts.directed (1,1) logical = false
end

if isvector(c1_values)
    c1_values = c1_values(:)';
end
if isvector(c2_values)
    c2_values = c2_values(:)';
end

if size(c1_values, 1) ~= size(c2_values, 1)
    error('Number of rows must match between class 1 and 2');
end

% number of actual data points to consider (non-NaN)
n1 = sum(~isnan(c1_values), 2);
n2 = sum(~isnan(c2_values), 2);
n = n1 + n2;

% obtain a boolean matrix of whether each observation is in class 1,
% sorted by observation value for each row independently
% NaNs go at the end and won't be considered (masked by b_valid)
gt_c1 = [true(size(c1_values)), false(size(c2_values))];
[nrow, maxobs] = size(gt_c1);
[~, sortorder] = sort([c1_values, c2_values], 2, MissingPlacement="last");
inds = sub2ind(size(gt_c1), repmat((1:nrow)', 1, maxobs), sortorder);
gt_c1 = gt_c1(inds);
b_valid = (1:maxobs) <= n; % matrix same size as gt_c1

if opts.weighted
    c1_weight = 0.5 * n ./ n1;  % so that weighted sum of all = half the sample
    c2_weight = 0.5 * n ./ n2;
else
    c1_weight = ones(nrow, 1);
    c2_weight = ones(nrow, 1);
end

% start by categorizing all as class 1 (or class 2)
% slightly hacky method, keep track of best case for positive and negative threshold
% simulatneously and resolve for each row at the end
n_wrong_pos = n2 .* c2_weight;
n_wrong_neg = n1 .* c1_weight;
min_n_wrong = n_wrong_pos;
best_switch = zeros(nrow, 1);
b_invert = false(nrow, 1);
if ~opts.directed
    b_invert = n_wrong_neg < n_wrong_pos;
    min_n_wrong(b_invert) = n_wrong_neg(b_invert);
end

for kT = 1:maxobs
    % what changes by categorizing this one as class 2 (or class 1)
    was_c1 = b_valid(:, kT) & gt_c1(:, kT);
    was_c2 = b_valid(:, kT) & ~gt_c1(:, kT);

    n_wrong_pos(was_c1) = n_wrong_pos(was_c1) + c1_weight(was_c1);
    n_wrong_pos(was_c2) = n_wrong_pos(was_c2) - c2_weight(was_c2);

    % update for any rows where this is the optimal threshold so far
    b_improved = n_wrong_pos < min_n_wrong;
    min_n_wrong(b_improved) = n_wrong_pos(b_improved);
    best_switch(b_improved) = kT;

    if ~opts.directed
        b_invert(b_improved) = false;

        % second iteration, try negative classifier
        n_wrong_neg(was_c2) = n_wrong_neg(was_c2) + c2_weight(was_c2);
        n_wrong_neg(was_c1) = n_wrong_neg(was_c1) - c1_weight(was_c1);
        
        b_improved = n_wrong_neg < min_n_wrong;
        min_n_wrong(b_improved) = n_wrong_neg(b_improved);
        best_switch(b_improved) = kT;
        b_invert(b_improved) = true;
    end
end

acc = 1 - min_n_wrong ./ n;

% compute sensitivity as well, using RMS SD (conservative estimate)
best_n1 = zeros(nrow, 1);
n_hits = zeros(nrow, 1);
best_n1(b_invert) = best_switch(b_invert);
best_n1(~b_invert) = n(~b_invert) - best_switch(~b_invert);
n_hits(b_invert) = sum(gt_c1(b_invert, :) & b_valid(b_invert, :) & (1:maxobs) <= best_switch(b_invert, :), 2);
n_hits(~b_invert) = sum(gt_c1(~b_invert, :) & b_valid(~b_invert, :) & (1:maxobs) > best_switch(~b_invert, :), 2);
n_fa = best_n1 - n_hits;

hit_rate = n_hits ./ n1;
fa_rate = n_fa ./ n1;
z_hit = norminv(hit_rate);
z_fa = norminv(fa_rate);

sd_c1 = std(c1_values, 0, 2, "omitmissing");
sd_c2 = std(c2_values, 0, 2, "omitmissing");
mean_diff = sd_c1 .* z_hit - sd_c2 .* z_fa;

rms_sd = sqrt((sd_c1.^2 + sd_c2.^2) ./ 2);
dprime = mean_diff ./ rms_sd;

end
