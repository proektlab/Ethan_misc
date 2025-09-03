function C = generic_bsxfun(func, A, B)
% bsxfun that works for anything arrayfun works on

if (isnumeric(A) || islogical(A) || ischar(A)) && ...
        (isnumeric(B) || islogical(B) || ischar(B))
    C = bsxfun(func, A, B);
    return;
end

% https://stackoverflow.com/questions/17090047/using-bsxfun-for-non-numeric-data
idx_A = reshape(1:numel(A), size(A));
idx_B = reshape(1:numel(B), size(B));
idx_mixed = bsxfun(@complex, idx_A, idx_B);
idx_A_expanded = real(idx_mixed);
idx_B_expanded = imag(idx_mixed);

% use arrayfun, except that it doesn't work on heterogeneous arrays
if ~isa(A, 'matlab.mixin.Heterogeneous') && ~isa(B, 'matlab.mixin.Heterogeneous')
    C = arrayfun(func, A(idx_A_expanded), B(idx_B_expanded));
else
    C_cell = arrayfun(func, A(idx_A_expanded), B(idx_B_expanded), 'uni', false);
    C = reshape(vertcat(C_cell{:}), size(idx_A_expanded));
end
end