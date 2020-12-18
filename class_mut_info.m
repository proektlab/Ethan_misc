function [minfo, norm_minfo] = class_mut_info(X)
% Similar to class_cond_entropy, but computes
% mututal information rather than conditional entropy.
%
% Second output is the normalized mutual information
% (https://course.ccs.neu.edu/cs6140sp15/7_locality_cluster/Assignment-6/NMI.pdf)

ent = class_entropy(X); % (1 x m vector)
cent = class_cond_entropy(X); % (m x m matrix)

minfo = ent - cent;
norm_minfo = 2 * minfo ./ (ent + ent');
    
end