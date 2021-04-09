function cent = class_cond_entropy(X, Y)
% Computes the conditional/noise entropy of each class assignment vector
% in Y given each vector in X. X and Y must have the same size in dimension 1.
% 
% If Y is omitted, each column of X is compared with each other column and the
% diagonal is 0 (by definition).
% 
% Output: If X is n x p and Y is n x q, output is a p x q matrix.

[n, p] = size(X);

if nargin == 1
    cent = zeros(p);
    for i = 1:p
        not_i = [1:i-1, i+1:p];
        cent(i, not_i) = class_cond_entropy(X(:, i), X(:, not_i));
    end
    return;
end

% now we definitely have Y
[m, q] = size(Y);
assert(n == m, 'X and Y must have the same length (dimension 1)');
cent = zeros(p, q);

all_y_classes = unique(Y(:));

for i = 1:p
    i_classes = unique(X(:, i));
    for k = 1:length(i_classes)
        kY = Y(X(:, i) == i_classes(k), :);
        pK = size(kY, 1) / n;
        
        cent(i, :) = cent(i, :) + pK * class_entropy(kY, all_y_classes);
    end
end
end