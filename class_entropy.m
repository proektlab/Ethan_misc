function ent = class_entropy(X, classes)
% Computes the entropy of each class assignment vector given every other vector.
%
% Input: each column of X should be a vector of m class assignments.
% Vectors need not have the same number of classses.
% If "classes" is provided, it should be the unique classes in X; this is for
% caching purposes and won't be verified.
%
% Ouptut: 1 x m vector of entropy.

if ~exist('classes', 'var') || isempty(classes)
	classes = unique(X(:));
end
	
[n, m] = size(X);
ent = zeros(1, m);
if n == 0
	return;
end

for k = 1:length(classes)
	pK = sum(X == classes(k)) / n;
	new_ent = ent - pK .* log2(pK);
	ent(pK > 0) = new_ent(pK > 0);
end

end
