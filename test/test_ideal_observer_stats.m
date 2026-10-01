function tests = test_ideal_observer_stats(test_fn)
% Unit tests for ideal_observer_stats

arguments
    test_fn (1,1) function_handle = @ideal_observer_stats
end

tests = functiontests(localfunctions);

% Should work for empty input
try
    [acc, dprime, counts, thresh_info] = test_fn([]);
catch me
    


end