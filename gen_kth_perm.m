function perm = gen_kth_perm(n, k)
% If 1 <= k <= n!, generates the "kth" permutation of 1:n. The only requirement is that
% gen_kth_perm(n, k) is different from gen_kth_perm(n, j) iff k ~= j.

assert(k >= 1 && k <= factorial(n), 'Invalid k');

perm = zeros(1, n);
perm(1) = floor((k-1)/factorial(n-1)) + 1;

if n > 1
    rest = setdiff(1:n, perm(1));
    perm(2:end) = rest(gen_kth_perm(n-1, mod(k-1, factorial(n-1))+1));
end

end
