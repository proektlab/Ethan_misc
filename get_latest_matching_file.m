function filename = get_latest_matching_file(directory, file_pattern, opts)
% Finds the last-modified file in the given directory matching the given regexp
% and returns the name of the file.
% If "before" is given (keyword argument), restricts files to those saved before that date.
arguments
    directory (1,1) string
    file_pattern (1,1) string
    opts.before (1,1) datetime = NaT
end

all_files = dir(directory);
pattern = regexpPattern(file_pattern);

b_matches = matches({all_files.name}', pattern);
matching_files = all_files(b_matches);

if isempty(matching_files)
    error('No matching files found');
end

modified_dates = datetime({matching_files.date}');
if ~isnat(opts.before)
    before_cutoff = modified_dates < opts.before;
    if ~any(before_cutoff)
        error('No matching files found before %s', opts.before);
    end
    matching_files = matching_files(before_cutoff);
    modified_dates = modified_dates(before_cutoff);
end

[~, order] = sort(modified_dates, "descend");
filename = matching_files(order(1)).name;

end