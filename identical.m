function tf = identical(arr1, arr2)
% Tests whether two arrays are the same shape and have the same values
if ~strcmp(class(arr1), class(arr2))
    tf = false;
    return;
end

if iscell(arr1)
    tf = all(cellfun(@identical, arr1, arr2), 'all');
    return;
end

shape1 = size(arr1);
shape2 = size(arr2);

tf = length(shape1) == length(shape2) && ...
    all(shape1 == shape2) && ...
    all(arr1 == arr2, 'all');

end

