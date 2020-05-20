function cent = class_cond_entropy(X)
% Computes the conditional/noise entropy of each class
% assignment vector given each other vector.
%
% Input: each column of X should be a vector of m class assignments.
% Vectors need not have the same number of classses.
%
% Ouptut: m x m matrix of conditional entropy with zero diagonal.
% Element i,j is the conditional entropy of
% assignment j given assignmnent i.

[n, m] = size(X);
cent = zeros(m);

all_classes = unique(X(:));

for i = 1:m
    i_classes = unique(X(:, i));

    js = [1:i-1, i+1:m];

    cent_i = zeros(1, m-1);

    for k = 1:length(i_classes)
        kX = X(X(:, i) == i_classes(k), js);
        pK = size(kX, 1) / n;

        cent_i = cent_i + pK * class_entropy(kX, all_classes);
    end

    cent(i, js) = cent_i;
end

end

% compute entropy for each column of X
function ent = class_entropy(X, classes)
[n, m] = size(X);
ent = zeros(1, m);
if n == 0
    return;
end

for kK = 1:length(classes)
    pK = sum(X == classes(kK)) / n;
    new_ent = ent - pK .* log2(pK);
    ent(pK > 0) = new_ent(pK > 0);
end
end