function [minfo, norm_minfo] = class_mut_info(X, Y)
% Similar to class_cond_entropy, but computes
% mututal information rather than conditional entropy.
%
% If one argument is provided, gives mutual info between all pairs of columns.
% If both X and Y are provided, gives mutual info between columns of X and columns of Y.
%
% Second output is the normalized mutual information
% (https://course.ccs.neu.edu/cs6140sp15/7_locality_cluster/Assignment-6/NMI.pdf)

ent_x = class_entropy(X); % (1 x p vector)
if nargin == 2
    ent_y = class_entropy(Y); % (1 x q vector)
    cent = class_cond_entropy(X, Y); % (p x q matrix)
else
    ent_y = ent_x;
    cent = class_cond_entropy(X);
end
    
minfo = ent_y - cent;
norm_minfo = 2 * minfo ./ (ent_x' + ent_y);
    
end