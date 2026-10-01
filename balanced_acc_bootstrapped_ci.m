function [balanced_acc, ci] = balanced_acc_bootstrapped_ci(n_hit, n_c1, n_cr, n_c2, opts)
% compute balanced accuracy and CI using bootstrapping

arguments (Input)
    n_hit (:,1) double {mustBeNonnegative}  % # correct from class 1
    n_c1 (:,1) double {mustBeInteger,mustBeNonnegative}   % total trials from class 1
    n_cr (:,1) double {mustBeNonnegative}   % # correct from class 2
    n_c2 (:,1) double {mustBeInteger,mustBeNonnegative}   % total trials from class 2
    opts.n_bootstraps (1,1) double {mustBeInteger,mustBePositive} = 1000
    opts.alpha (1,1) double {mustBeInRange(opts.alpha, 0, 1, "exclusive")} = 0.05  % CI alpha
end

arguments (Output)
    balanced_acc (:,1) double
    ci (:,2) double
end

balanced_acc = (n_hit ./ n_c1 + n_cr ./ n_c2) / 2;

% total resampled class-1 samples that were hits
c1_n_correct_samps = cell2mat(arrayfun(@(n, k) binornd(n, k, 1, opts.n_bootstraps), ...
    n_c1, n_hit ./ n_c1, 'uni', false));

% total resampled class-2 samples that were correct rejects
c2_n_correct_samps = cell2mat(arrayfun(@(n, k) binornd(n, k, 1, opts.n_bootstraps), ...
    n_c2, n_cr ./ n_c2, 'uni', false));

balanced_frac_correct_samps = (c1_n_correct_samps ./ n_c1 + c2_n_correct_samps ./ n_c2) / 2;
ci = quantile(balanced_frac_correct_samps, [opts.alpha/2, 1-opts.alpha/2], 2);


end