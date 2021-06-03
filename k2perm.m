function perm = k2perm(n, k)
% If 1 <= k <= n!, generates the "kth" permutation of 1:n. The only requirements are that
% gen_kth_perm(n, k) is different from gen_kth_perm(n, j) iff k ~= j
% and gen_kth_perm(n, 1) is 1:n.

persistent factorials;
if length(factorials) < n
    factorials = [factorials, factorial(length(factorials)+1:n)];
end

assert(k >= 1 && k <= factorials(n), 'Invalid k');

if n == 1
    perm = 1;
    return;
end
    
perm = zeros(1, n);
perm(1) = floor((k-1)/factorials(n-1)) + 1;
rest = [1:perm(1)-1, perm(1)+1:n];
perm(2:end) = rest(k2perm(n-1, mod(k-1, factorials(n-1))+1));

end
