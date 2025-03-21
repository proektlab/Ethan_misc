% paths
[synology_dir, bigdata_dir] = get_synology_dir;

global good_green
good_green = [0.39608, 0.67843, 0];

% can always use rng('default') if I want to get consistent results
rng('shuffle');

% necessary on treachery for some reason
matlabpath(pathdef);

% add other paths
addpath(genpath2(fullfile(synology_dir, 'eblackwood', 'VR_learning', 'vr_2p_analysis'), '.git'));

% activate caiman python environment
if ispc
    pyenv('Version', fullfile(synology_dir, 'conda_envs_windows', 'caiman', 'python'));
end