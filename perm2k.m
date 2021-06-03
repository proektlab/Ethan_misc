function k = perm2k(perm)
% Precondition: perm is a permutation of 1:length(perm)
% Returns k such that k2perm(length(perm), k) = perm, i.e. a unique index for this permutation.

n = length(perm);
k = (perm(1)-1) * factorial(n-1) + 1;

if n > 1
    % get remaining permutation
    [~, order] = sort(perm(2:end));
    perm_left(order) = 1:n-1;
    k = k + perm2k(perm_left) - 1;
end

end
