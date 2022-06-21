function add_subdirs_with_exclusions(parent_dir, exclude_strs)
% Adds parent_dir with subdirs to path, except excludes paths that contain a member of exclude_strs
% as a substring (currently does not support regular expressions).
% Like when using the 'path' function, moves dirs to the front rather than duplicating them.

if ~exist('exclude_strs', 'var') || isempty(exclude_strs)
    exclude_strs = ".git";
end

subdir_path = string(genpath(parent_dir));
all_subdirs = split(subdir_path, pathsep);
good_subdirs = all_subdirs(~contains(all_subdirs, exclude_strs));
path(join(good_subdirs, pathsep), path);

end

