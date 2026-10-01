classdef IdealObserverStatsTest < matlab.unittest.TestCase
% Unit tests for ideal_observer_stats

properties (TestParameter)
    testFn = {@ideal_observer_stats}
    inputStyle = {"separate", "concatenated"};
end

methods (Test)
    function testEmpty(testCase, testFn, inputStyle)
        switch inputStyle
            case "separate"
                inputs = {[], []};
            case "concatenated"
                inputs = {[]};
        end

        [acc, dprime, counts, thresh_info, auroc_out] = testFn(inputs{:});
        testCase.verifyEqual(acc, zeros(0, 1));
        testCase.verifyEqual(dprime, zeros(0, 1));
        testCase.verifyEqual(counts, struct(...
            'n_c1', zeros(0, 1), ...
            'n_c2', zeros(0, 1), ...
            'n_correct_c1', zeros(0, 1), ...
            'n_correct_c2', zeros(0, 1)));
        testCase.verifyEqual(thresh_info, struct(...
            'thresh', zeros(0, 1), ...
            'b_invert', logical.empty(0, 1)));
        testCase.verifyEqual(auroc_out, zeros(0, 1));
    end

    function testScalar(testCase, testFn, inputStyle)
        c1_values = 1;
        c2_values = 0;

        switch inputStyle
            case "separate"
                inputs = {c1_values, c2_values};
            case "concatenated"
                inputs = {[c1_values, c2_values], 'is_class1', [true, false]};
        end

        [acc, dprime, counts, thresh_info] = testFn(inputs{:});
        testCase.verifyEqual(acc, 1);
        testCase.verifyEqual(dprime, nan);  % can't quantify d-prime with 0 variance in each class
        testCase.verifyEqual(counts, struct('n_c1', 1, 'n_c2', 1, 'n_correct_c1', 1, 'n_correct_c2', 1));
        testCase.verifyEqual(thresh_info, struct('thresh', 0.5, 'b_invert', false));
    end

    function testSingleFullySeparated(testCase, testFn, inputStyle)
        c1_values = [0, 0.1, 0.2];
        c2_values = [0.8, 0.9, 1];
        n_c1 = length(c1_values);
        n_c2 = length(c2_values);
        thresh = (max(c1_values) + min(c2_values)) / 2;

        switch inputStyle
            case "separate"
                inputs = {c1_values, c2_values};
            case "concatenated"
                inputs = {[c1_values, c2_values], 'is_class1', repelem([true, false], [n_c1, n_c2])};
        end

        [acc, dprime, counts, thresh_info] = testFn(inputs{:});
        testCase.verifyEqual(acc, 1);
        testCase.verifyEqual(dprime, inf);
        testCase.verifyEqual(counts, struct('n_c1', n_c1, 'n_c2', n_c2, 'n_correct_c1', n_c1, 'n_correct_c2', n_c2));
        testCase.verifyEqual(thresh_info, struct('thresh', thresh, 'b_invert', true));
    end

    function testDirected(testCase, testFn)
        % should give non-"optimal" results when directed is on and classes are reversed
        c1_values = [0, 0.1, 0.2, 0.3];
        c2_values = [0.8, 0.9, 1];
        n_c1 = length(c1_values);
        n_c2 = length(c2_values);
        n = n_c1 + n_c2;
        n_correct = max(n_c1, n_c2);

        [acc, dprime, counts, thresh_info] = testFn(c1_values, c2_values, directed=true);
        testCase.verifyEqual(acc, n_correct / n);  % can only classify one class correctly
        testCase.verifyEqual(dprime, nan);
        testCase.verifyEqual(counts, struct('n_c1', n_c1, 'n_c2', n_c2, 'n_correct_c1', n_c1, 'n_correct_c2', 0));
        testCase.verifyEqual(thresh_info, struct('thresh', -inf, 'b_invert', false));
    end

    function testMultiple(testCase, testFn, inputStyle)
        c1_values = [
            0,    0.1, 0.2
            0.8,  0.9, 1
            0.5,  0.6, 0.7
            ];
        n_c1 = size(c1_values, 2);

        c2_values = [
            0.8, 0.9,  1
            0,   0.1,  0.2
            0.3, 0.4, 0.5
            ];
        n_c2 = size(c2_values, 2);

        switch inputStyle
            case "separate"
                inputs = {c1_values, c2_values};
            case "concatenated"
                inputs = {[c1_values, c2_values], 'is_class1', repelem([true, false], [n_c1, n_c2])};
        end

        [acc, dprime, counts, thresh_info] = testFn(inputs{:});
        % for last case, should choose the one with least accuracy difference b/w classes -
        % threshold directly on 0.5
        testCase.verifyEqual(acc, [1; 1; 5/6], AbsTol=eps);
        testCase.verifyEqual(dprime, [inf; inf; norminv(5/6)-norminv(1/6)], AbsTol=eps);
        testCase.verifyEqual(counts, struct('n_c1', [3;3;3], 'n_c2', [3;3;3], ...
            'n_correct_c1', [3; 3; 2.5], 'n_correct_c2', [3; 3; 2.5]));
        testCase.verifyEqual(thresh_info, struct('thresh', [0.5; 0.5; 0.5], 'b_invert', [true; false; false]));
    end

    function testWithNans(testCase, testFn)
        c1_values = [
            0.8, 0.9, 1
            nan, 0.9, 1
            ];
        n_c1 = size(c1_values, 2);
        nn_c1 = sum(~isnan(c1_values), 2);
        
        c2_values = [
            0, 0.1, 0.2
            0, 0.1, nan
            ];
        n_c2 = size(c2_values, 2);
        nn_c2 = sum(~isnan(c2_values), 2);

        values = [c1_values, c2_values];
        is_c1 = repelem([true, false], [n_c1, n_c2]);

        [acc, dprime, counts, thresh_info] = testFn(values, is_class1=is_c1);
        testCase.verifyEqual(acc, [1; 1]);
        testCase.verifyEqual(dprime, [inf; inf]);
        testCase.verifyEqual(counts, struct('n_c1', nn_c1, 'n_c2', nn_c2, 'n_correct_c1', nn_c1, 'n_correct_c2', nn_c2));
        testCase.verifyEqual(thresh_info, struct('thresh', [0.5; 0.5], 'b_invert', [false; false]));
    end

    function testUnequalNPerClass(testCase, testFn)
        % Test using is_class1 to identify samples in each class independently for each row
        values = [
            0.8, 0.9, 1, 0, 0.1, 0.2
            0.9, 1, 0, 0.1, nan, nan
            ];

        is_class1 = logical([
            1, 1, 1, 0, 0, 0
            1, 1, 0, 0, 0, 0
            ]);

        [acc, dprime, counts, thresh_info] = testFn(values, is_class1=is_class1);
        testCase.verifyEqual(acc, [1; 1]);
        testCase.verifyEqual(dprime, [inf; inf]);
        testCase.verifyEqual(counts, struct('n_c1', [3; 2], 'n_c2', [3; 2], 'n_correct_c1', [3; 2], 'n_correct_c2', [3; 2]));
        testCase.verifyEqual(thresh_info, struct('thresh', [0.5; 0.5], 'b_invert', [false; false]));
    end

    function testUnweightedUnequal(testCase, testFn)
        % Test accuracy reflecting unequal number of samples per class by default
        c1_values = [0, 0.1, 0.2, 0.3];
        c2_values = repelem([0.8, 0.9, 1], 2);
        
        [acc, dprime, counts, thresh_info] = testFn(c1_values, c2_values, directed=true);
        testCase.verifyEqual(acc, 0.6);
        testCase.verifyEqual(dprime, nan);
        testCase.verifyEqual(counts, struct('n_c1', 4, 'n_c2', 6, 'n_correct_c1', 0, 'n_correct_c2', 6));
        testCase.verifyEqual(thresh_info, struct('thresh', inf, 'b_invert', false));
    end

    function testAutoWeights(testCase, testFn)
        % Test automatically weighting samples to correct unequal number of samples
        c1_values = [0, 0.1, 0.2, 0.3];
        c2_values = repelem([0.8, 0.9, 1], 2);

        [acc, dprime, counts, thresh_info] = testFn(c1_values, c2_values, directed=true, weighted=true);
        testCase.verifyEqual(acc, 0.5);
        testCase.verifyEqual(dprime, nan);
        testCase.verifyEqual(counts.n_c1, 4);
        testCase.verifyEqual(counts.n_c2, 6);
        testCase.verifyTrue((thresh_info.thresh == -inf && counts.n_correct_c1 == 4 && counts.n_correct_c2 == 0) || ...
            (thresh_info.thresh == inf && counts.n_correct_c1 == 0 && counts.n_correct_c2 == 6));
        testCase.verifyEqual(thresh_info.b_invert, false);
    end

    function testManualWeights(testCase, testFn)
        values = [0, 0.1, 0.2, 0.3, 0.8, 0.9, 1];
        weights = [0, 1, 1, 1, 2, 2, 3];  % relative weights: c1 = 3, c2 = 7
        is_c1 = [true, true, true, true, false, false, false];

        [acc, dprime, counts, thresh_info] = testFn(values, is_class1=is_c1, directed=true, weights=weights);
        testCase.verifyEqual(acc, 0.7);
        testCase.verifyEqual(dprime, nan);
        testCase.verifyEqual(counts, struct('n_c1', 4, 'n_c2', 3, 'n_correct_c1', 0, 'n_correct_c2', 3));
        testCase.verifyEqual(thresh_info, struct('thresh', inf, 'b_invert', false));
    end

    function testDirectedDprime(testCase, testFn)
        % when using directed_dprime option, even if directed is off, dprime should be negative if
        % mean(c1_values) < mean(c2_values)
        c1_values = [0.3, 0.4, 0.5];
        c2_values = [0.5, 0.6, 0.7];

        [acc, dprime] = testFn(c1_values, c2_values, directed_dprime=false);
        testCase.verifyEqual(acc, 5/6, AbsTol=eps);
        testCase.verifyEqual(dprime, norminv(5/6) - norminv(1/6), AbsTol=eps); % positive value

        [acc, dprime] = testFn(c1_values, c2_values, directed_dprime=true);
        testCase.verifyEqual(acc, 5/6, AbsTol=eps);
        testCase.verifyEqual(dprime, norminv(1/6) - norminv(5/6), AbsTol=eps); % negative value
    end

    function testWeightedDprime(testCase, testFn)
        % ensure dprime calculation takes subclass weights into account
        c1_values = [0.1, 0.3, 0.4, 0.5, 0.7];
        c2_values = [0, 0.2, 0.3, 0.4, 0.6];
        values = [c1_values, c2_values];
        is_c1 = [true(size(c1_values)), false(size(c2_values))];

        c1_weights = [2, 2, 2, 3, 3];
        c2_weights = [3, 3, 2, 2, 2];
        weights = [c1_weights, c2_weights];

        exp_thresh = 0.35;
        exp_correct = (is_c1 & values > exp_thresh) | (~is_c1 & values < exp_thresh);
        w_correct = sum(weights(exp_correct));
        exp_acc = w_correct / sum(weights);

        % compute weighted dprime
        sd1 = weighted_std(c1_values, c1_weights);
        sd2 = weighted_std(c2_values, c2_weights);
        z_hit = norminv(sum(c1_weights(c1_values > exp_thresh)) / sum(c1_weights));
        z_fa = norminv(sum(c2_weights(c2_values > exp_thresh)) / sum(c2_weights));
        mean_diff = sd1 * z_hit - sd2 * z_fa;
        exp_dprime = mean_diff / sqrt((sd1 ^ 2 + sd2 ^ 2)/2);

        [acc, dprime] = testFn(values, is_class1=is_c1, weights=weights);
        testCase.verifyEqual(acc, exp_acc, AbsTol=eps);
        testCase.verifyEqual(dprime, exp_dprime, AbsTol=eps);
    end

    function testAuroc(testCase, testFn)
        % test area under ROC (unweighted) using reference function auroc
        c1_values = [0.2, 0.4, 0.5];
        c2_values = [0, 0.1, 0.3];

        [~, ~, ~, ~, auroc_ios_pos] = testFn(c1_values, c2_values, directed_dprime=true);
        auroc_ref_pos = auroc(c1_values', c2_values', roc_class=1);
        testCase.verifyEqual(auroc_ios_pos, auroc_ref_pos, AbsTol=eps);

        [~, ~, ~, ~, auroc_ios_inv] = testFn(c2_values, c1_values, directed_dprime=true);
        auroc_ref_inv = auroc(c1_values', c2_values', roc_class=2);
        testCase.verifyEqual(auroc_ios_inv, auroc_ref_inv, AbsTol=eps);
    end

    function testWeightedAuroc(testCase, testFn)
        % test area under ROC with manual subclass weights
        % set up so there's one "square" in upper left not under the curve
        % which has normalized weight 0.5 in both dimensions, so AUROC should be 0.75
        c1_values = [0.2, 0.4, 0.5];
        c2_values = [0, 0.1, 0.3];
        c1_weights = [2, 1, 1];
        c2_weights = [1, 1, 2];

        values = [c1_values, c2_values];
        weights = [c1_weights, c2_weights];
        is_c1 = repelem([true, false], [length(c1_values), length(c2_values)]);

        [~, ~, ~, ~, auroc_ios] = testFn(values, is_class1=is_c1, weights=weights, directed_dprime=true);
        testCase.verifyEqual(auroc_ios, 0.75, AbsTol=eps);
    end
end

end