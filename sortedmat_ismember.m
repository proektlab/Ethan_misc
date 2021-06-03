function b = sortedmat_ismember(row, mat)

b = ismember(row(1), mat(:, 1));
    
if length(row) > 1
    b = b && sortedmat_ismember(row(2:end), mat(mat(:, 1) == row(1), :));
end

end