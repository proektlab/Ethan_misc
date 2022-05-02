function new_table = explode_nested_tables(outer_table)
% vertically concatenate all nested tables in the 'data' variable into one,
% and repeat other columns to match.

nondata_cols = setdiff(outer_table.Properties.VariableNames, 'data');
new_table = vertcat(outer_table.data{:});  % stack inner tables
rep_nums = cellfun(@height, outer_table.data);

for kCol = 1:length(nondata_cols)
    col_name = nondata_cols{kCol};
    new_table.(col_name) = repelem(outer_table.(col_name), rep_nums, 1);
end

end
