function vr_dirs = prepVRLearn(online)
% Setup for working on VR learning experiment

vr_dirs = get_vrlearn_dirs(online);
add_subdirs_with_exclusions(vr_dirs.virmen, [".git", ".vscode"]);
path(vr_dirs.expcode, path);

end
