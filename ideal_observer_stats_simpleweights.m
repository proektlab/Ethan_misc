function [acc, dprime, counts, thresh_info] = ideal_observer_stats(c1_values, c2_values, opts)
% Find maximum accuracy for decoding any 2 classes based on 1-dimensional values.
% If values are matrices, operates along the 2nd dimension (independently for each row).
% If weighted is true, weight to correct for bias in number of class 1 vs class 2 values.
% If directed is true, assumes that the values are greater for class 1 than class 2;
%   otherwise the direction is determined from the data.
%
% Thresholds directly on (rather than between) the values are also considered, with an expected
% success rate of 0.5 * the number of tied samples with that value.
%
% When mutliple thresholds have the best accuracy, the difference between the class 1 and class 2
% accuracy is used as a tiebreaker (to minimize bias towards one class or the other). The same is
% true when considering positive vs. negative thresholds. If there is still a tie, the threshold is
% chosen at random among the candidates.
% 
% counts contains the following additional info:
%   n_c1, n_c2: number of non-nan values in each class for each row
%   n_correct_c1, n_correct_c2: number of correctly-classified values in each class for each row
%   If weighted is true, acc = (n_correct_c1 / n_c1) + (n_correct_c2 / n_c2) / 2.
%   Otherwise, acc = (n_correct_c1 + n_correct_c2) / (n_c1 + n_c2).
%
% thresh_info contains the following additional info:
%   thresh: best threshold value for each row (can be -inf or inf)
%   b_invert: boolean indicating whether the best accuracy is obtained by classifying values 
%       > the threshold as c2 (all false if directed is true).

arguments
    c1_values double
    c2_values double
    opts.weighted (1,1) logical = false
    opts.directed (1,1) logical = false
    opts.flatten_vectors (1,1) logical = true
    opts.c1_weights double = []  % manual weights matrix, overrides opts.weighted
    opts.c2_weights double = []  % must be provided if c1_weights is provided and vice versa
end

if opts.flatten_vectors && isvector(c1_values) && isvector(c2_values)
    c1_values = c1_values(:)'; 
    c2_values = c2_values(:)';
end

if size(c1_values, 1) ~= size(c2_values, 1)
    error('Number of rows must match between class 1 and 2');
end

counts = struct;

% number of actual data points to consider (non-NaN)
n1 = sum(~isnan(c1_values), 2);
n2 = sum(~isnan(c2_values), 2);
n = n1 + n2;
counts.n_c1 = n1;
counts.n_c2 = n2;

% obtain a boolean matrix of whether each observation is in class 1,
% sorted by observation value for each row independently
% NaNs go at the end and won't be considered (masked by b_valid)
gt_c1 = [true(size(c1_values)), false(size(c2_values))];
[nrow, maxobs] = size(gt_c1);
[sorted_values, sortorder] = sort([c1_values, c2_values], 2, MissingPlacement="last");
inds = sub2ind(size(gt_c1), repmat((1:nrow)', 1, maxobs), sortorder);
gt_c1 = gt_c1(inds);
b_valid = (1:maxobs) <= n; % matrix same size as gt_c1

% TODO - finish changing the definition of c1_weight and c2_weight and TEST that it still works!
% if opts.weighted
%     c1_weight = repmat(n2, 1, size(c1_values, 2)); % instead of 1 ./ n1 - avoid small floating point errors
%     c2_weight = repmat(n1, 1, size(c2_values, 2));
% else
%     c1_weight = ones(nrow, size(c1_values, 2));
%     c2_weight = ones(nrow, size(c2_values, 2));
% end
% 
% c1_weight(isnan(c1_values)) = nan;
% c2_weight(isnan(c2_values)) = nan;

if opts.weighted
    c1_weight = n2; % instead of 1 ./ n1 - avoid small floating point errors
    c2_weight = n1;
else
    c1_weight = ones(nrow, 1);
    c2_weight = ones(nrow, 1);
end

% scalar best values for each row
min_w_wrong = inf(nrow, 1);
min_acc_diff = ones(nrow, 1);
all_best = struct(...
    ... 1xn arrays for each best threshold
    'switch_inds', repmat({zeros(1,0)}, nrow, 1), ...
    'thresholds', repmat({zeros(1,0)}, nrow, 1), ...
    'n_wrong_c1', repmat({zeros(1,0)}, nrow, 1), ...
    'n_wrong_c2', repmat({zeros(1,0)}, nrow, 1), ...
    'b_invert', repmat({logical.empty(1,0)}, nrow, 1));

    
    function update_improved_rows(row_inds, n_wrong_c1, n_wrong_c2, switch_inds, thresholds, b_invert)
        % test whether the rows at row_inds are improved given n_wrong values
        % and update min_w_wrong, min_acc_diff, and all_best for improved and tied rows.
        row_inds = reshape(row_inds, 1, []);
        w_wrong = n_wrong_c1(row_inds, 1) .* c1_weight(row_inds, 1) + n_wrong_c2(row_inds, 1) .* c2_weight(row_inds, 1);
        acc_diff = abs(n_wrong_c1(row_inds, 1) ./ n1(row_inds, 1) - n_wrong_c2(row_inds, 1) ./ n2(row_inds, 1));

        b_improve = false(length(row_inds), 1);
        b_tie = false(length(row_inds), 1);
        b_worse_w = w_wrong > min_w_wrong(row_inds, 1);
        if all(b_worse_w)
            return
        end

        b_tie_w = w_wrong == min_w_wrong(row_inds, 1);
        if any(b_tie_w)
            acc_diff_tie = acc_diff(b_tie_w);
            b_tie(b_tie_w) = acc_diff_tie == min_acc_diff(row_inds(b_tie_w), 1);
            b_improve(b_tie_w) = acc_diff_tie < min_acc_diff(row_inds(b_tie_w), 1);
        end

        b_improve(w_wrong < min_w_wrong(row_inds, 1)) = true;
        
        % update minima
        min_w_wrong(row_inds(b_improve)) = w_wrong(b_improve);
        min_acc_diff(row_inds(b_improve)) = acc_diff(b_improve);

        % update all_best for improved and tied rows        
        if isscalar(switch_inds)
            switch_inds = repmat(switch_inds, nrow, 1);
        end

        for kR = row_inds(b_improve)
            all_best(kR).switch_inds = switch_inds(kR);
            all_best(kR).thresholds = thresholds(kR);
            all_best(kR).n_wrong_c1 = n_wrong_c1(kR);
            all_best(kR).n_wrong_c2 = n_wrong_c2(kR);
            all_best(kR).b_invert = b_invert;
        end

        for kR = row_inds(b_tie)
            all_best(kR).switch_inds(1, end+1) = switch_inds(kR);
            all_best(kR).thresholds(1, end+1) = thresholds(kR);
            all_best(kR).n_wrong_c1(1, end+1) = n_wrong_c1(kR);
            all_best(kR).n_wrong_c2(1, end+1) = n_wrong_c2(kR);
            all_best(kR).b_invert(1, end+1) = b_invert;
        end
    end

% start by categorizing all as class 1
% slightly hacky method, keep track of best case for positive and negative threshold
% simulatneously and resolve for each row at the end
% w = "weighted number"
n_wrong_c1_pos = zeros(nrow, 1);
n_wrong_c2_pos = n2;

% same but if we put the threshold on the value
% (resets to the between-value threshold value when not in the middle of a tie)
n_wrong_c1_pos_onval = n_wrong_c1_pos;
n_wrong_c2_pos_onval = n_wrong_c2_pos;
kT_onval = zeros(nrow, 1);

% as a special case, if n = 0, set threshold to nan rather than -inf
start_thresh = nan(nrow, 1);
start_thresh(n > 0) = -inf;

update_improved_rows(1:nrow, n_wrong_c1_pos, n_wrong_c2_pos, ...
    zeros(nrow, 1), start_thresh, false);

if ~opts.directed
    % if we categorize them all as class 2 (negative threshold)
    n_wrong_c1_neg = n1;
    n_wrong_c2_neg = zeros(nrow, 1);
    
    n_wrong_c1_neg_onval = n_wrong_c1_neg;
    n_wrong_c2_neg_onval = n_wrong_c2_neg;

    update_improved_rows(1:nrow, n_wrong_c1_neg, n_wrong_c2_neg, ...
        zeros(nrow, 1), start_thresh, true);
end

for kT = 1:maxobs
    % if we have a tie with the next value, still update n_wrong but don't consider updating
    % all_best until all identical values have been considered
    if kT == maxobs
        istie = false(nrow, 1);
    else
        istie = kT < n & sorted_values(:, kT) == sorted_values(:, kT + 1);
    end
    b_update = ~istie & b_valid(:, kT);
    update_inds = reshape(find(b_update), [], 1); % handle empty array correctly
    kT_onval = kT_onval + 0.5;

    % compute past-value thresholds
    thresholds = inf(nrow, 1);
    if any(kT < n)  % needed to guard against out-of-bounds indexing
        thresholds(kT < n) = mean(sorted_values(kT < n, [kT, kT+1]), 2);
    end

    % what changes by categorizing this one as class 2 (or class 1)
    was_c1 = b_valid(:, kT) & gt_c1(:, kT);
    was_c2 = b_valid(:, kT) & ~gt_c1(:, kT);

    n_wrong_c1_pos(was_c1) = n_wrong_c1_pos(was_c1) + 1;
    n_wrong_c2_pos(was_c2) = n_wrong_c2_pos(was_c2) - 1;

    % also consider putting the threshold directly on this value
    n_wrong_c1_pos_onval(was_c1) = n_wrong_c1_pos_onval(was_c1) + 0.5;
    n_wrong_c2_pos_onval(was_c2) = n_wrong_c2_pos_onval(was_c2) - 0.5;

    % update all_best
    if any(b_update)
        update_improved_rows(update_inds, n_wrong_c1_pos, n_wrong_c2_pos, kT, thresholds, false);
        update_improved_rows(update_inds, n_wrong_c1_pos_onval, n_wrong_c2_pos_onval, ...
            kT_onval, sorted_values(:, kT), false);
    end

    if ~opts.directed
        % try negative classifier
        n_wrong_c2_neg(was_c2) = n_wrong_c2_neg(was_c2) + 1;
        n_wrong_c1_neg(was_c1) = n_wrong_c1_neg(was_c1) - 1;

        % consider putting the threshold directly on value
        n_wrong_c2_neg_onval(was_c2) = n_wrong_c2_neg_onval(was_c2) + 0.5;
        n_wrong_c1_neg_onval(was_c1) = n_wrong_c1_neg_onval(was_c1) - 0.5;

        if any(b_update)
            update_improved_rows(update_inds, n_wrong_c1_neg, n_wrong_c2_neg, kT, thresholds, true);
            update_improved_rows(update_inds, n_wrong_c1_neg_onval, n_wrong_c2_neg_onval, ...
                kT_onval, sorted_values(:, kT), true);
        end
    end

    % reset onval counts for valid values that are not ties
    kT_onval(~istie) = kT;
    n_wrong_c1_pos_onval(~istie) = n_wrong_c1_pos(~istie);
    n_wrong_c2_pos_onval(~istie) = n_wrong_c2_pos(~istie);

    if ~opts.directed
        n_wrong_c1_neg_onval(~istie) = n_wrong_c1_neg(~istie);
        n_wrong_c2_neg_onval(~istie) = n_wrong_c2_neg(~istie);
    end
end

% select results - if there are ties, randomly select among them.
n_found = arrayfun(@(s_best) numel(s_best.thresholds), all_best);
ind_to_take = ceil(rand(nrow, 1) .* n_found);

best_switch = arrayfun(@(s_best, ind) s_best.switch_inds(ind), all_best, ind_to_take);
best_thresh = arrayfun(@(s_best, ind) s_best.thresholds(ind), all_best, ind_to_take);
best_n_wrong_c1 = arrayfun(@(s_best, ind) s_best.n_wrong_c1(ind), all_best, ind_to_take);
best_n_wrong_c2 = arrayfun(@(s_best, ind) s_best.n_wrong_c2(ind), all_best, ind_to_take);
b_invert = arrayfun(@(s_best, ind) s_best.b_invert(ind), all_best, ind_to_take);

acc = 1 - min_w_wrong ./ (c1_weight .* n1 + c2_weight .* n2);
counts.n_correct_c1 = counts.n_c1 - best_n_wrong_c1;
counts.n_correct_c2 = counts.n_c2 - best_n_wrong_c2;

% compute sensitivity as well, using RMS SD (conservative estimate)
best_n1 = zeros(nrow, 1);
n_hits = zeros(nrow, 1);
best_n1(b_invert) = best_switch(b_invert);
best_n1(~b_invert) = n(~b_invert) - best_switch(~b_invert);
n_hits(b_invert) = sum(gt_c1(b_invert, :) & b_valid(b_invert, :) & (1:maxobs) <= best_switch(b_invert, :), 2);
n_hits(~b_invert) = sum(gt_c1(~b_invert, :) & b_valid(~b_invert, :) & (1:maxobs) > best_switch(~b_invert, :), 2);
n_fa = best_n1 - n_hits;

hit_rate = n_hits ./ n1;
fa_rate = n_fa ./ n2;
z_hit = norminv(hit_rate);
z_fa = norminv(fa_rate);

sd_c1 = std(c1_values, 0, 2, "omitmissing");
sd_c2 = std(c2_values, 0, 2, "omitmissing");
mean_diff = sd_c1 .* z_hit - sd_c2 .* z_fa;

rms_sd = sqrt((sd_c1.^2 + sd_c2.^2) ./ 2);
dprime = mean_diff ./ rms_sd;

thresh_info = struct('thresh', best_thresh, 'b_invert', b_invert);

end
