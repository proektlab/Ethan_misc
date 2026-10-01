function wstd = weighted_std(vals, weights)
vals = vals(~isnan(vals));
weights = weights(~isnan(vals));
N = length(weights);
weights = weights / sum(weights) * N; % sum to N

s1 = weights(:)' * vals(:);
s2 = weights(:)' * vals(:).^2;
wt_sum_sq_minus_wt_sq_sum = N*s2 - s1^2;

% correct for error when close to 0 - should be positive
wt_sum_sq_minus_wt_sq_sum = max(0, wt_sum_sq_minus_wt_sq_sum);

wstd = sqrt(wt_sum_sq_minus_wt_sq_sum / (N * (N-1)));

% weights = weights / sum(weights) * length(weights) / (length(weights)-1);
% wstd = sqrt(weights(:)' * (vals(:) - mean(vals)).^2);
end