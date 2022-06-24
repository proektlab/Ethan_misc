function vr_dirs = prepVRLearn
% Setup for working on VR learning experiment

synology_dir = get_synology_dir;

% Virmen engine
vr_dirs.virmen = fullfile(synology_dir, 'code', 'virmen-for-mouse-vr');
add_subdirs_with_exclusions(vr_dirs.virmen, [".git", ".vscode"]);

vr_dirs.project = fullfile(synology_dir, 'eblackwood', 'VR_learning');

% Our custom virmen code
vr_dirs.expcode = fullfile(vr_dirs.project, 'experiment_code');

% Data save directory
vr_dirs.data = fullfile(vr_dirs.project, 'virmen_data');

end
