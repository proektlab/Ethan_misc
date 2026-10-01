function dprime = unequal_variance_dprime(values, is_class1, hit_rate, fa_rate, opts)
% Compute dprime from a normal model of the values in each class.
% Adjusts for unequal variance using standard deviation, weighted if weights are provided.
% If 1st dimensions are not 1, operates independently for each row (e.g., bootstraps)

arguments
    values (:,:) double
    is_class1 (:,:) logical
    hit_rate (:,1) double % fraction of actual class-1 samples classified as class 1
    fa_rate (:,1) double  % fraction of actual class-2 samples classified as class 1
    opts.weights (:,:) double = []
    opts.smoothing_method (1,1) string = "laplace"
end

if isvector(is_class1) && length(is_class1) == size(values, 2)
    is_class1 = repmat(is_class1(:)', size(values, 1), 1);
end

% get z-score values
n_class1 = sum(is_class1, 2);
n_class2 = size(is_class1, 2) - n_class1;

switch opts.smoothing_method
    case "eps"  % not recommended, can lead to NaNs and inflated values (used for ideal_observer_stats prior to 7/28/26)
        hit_rate_adj = hit_rate - eps;
        fa_rate_adj = fa_rate + eps;
    case "none"
        hit_rate_adj = hit_rate;
        fa_rate_adj = fa_rate;
    case "laplace"  % rule of succession
        hit_rate_adj = (hit_rate .* n_class1 + 1) ./ (n_class1 + 2);
        fa_rate_adj = (fa_rate .* n_class2 + 1) ./ (n_class2 + 2);
    case "jeffreys"  % Jeffreys prior
        hit_rate_adj = (hit_rate .* n_class1 + 0.5) ./ (n_class1 + 1);
        fa_rate_adj = (fa_rate .* n_class2 + 0.5) ./ (n_class2 + 1);
end

z_hit = norminv(hit_rate_adj);
z_fa = norminv(fa_rate_adj);

% unequal variance adjustment
n_rows = size(values, 1);
if ~isempty(opts.weights)
    sd_c1 = arrayfun(@(kR) weighted_std(values(kR, is_class1(kR, :)), opts.weights(kR, is_class1(kR, :))), (1:n_rows)');
    sd_c2 = arrayfun(@(kR) weighted_std(values(kR, ~is_class1(kR, :)), opts.weights(kR, ~is_class1(kR, :))), (1:n_rows)');
else
    vals_c1 = values;
    vals_c1(~is_class1) = nan;
    sd_c1 = std(vals_c1, 0, 2, 'omitmissing');
    vals_c2 = values;
    vals_c2(is_class1) = nan;
    sd_c2 = std(vals_c2, 0, 2, 'omitmissing');
end

mean_diff = sd_c1 .* z_hit - sd_c2 .* z_fa;

rms_sd = sqrt((sd_c1.^2 + sd_c2.^2) ./ 2);
dprime = mean_diff ./ rms_sd;

end