function varargout = nth_outputs(fn, n, inputs, opts)
% Utility to retrieve the nth output(s) from a function called with given arguments
% Useful e.g. to make function handles returning a later output from a function
% when only one output is expected

arguments
    fn (1,1) function_handle
    n (1,:) double {mustBePositive, mustBeInteger}
end

arguments (Repeating)
    inputs
end

arguments
    opts.n_req (1,1) double {mustBeInteger} = max([0, n]);
end

args_out = cell(1, opts.n_req);
[args_out{:}] = fn(inputs{:});
varargout(:) = args_out(n);

end