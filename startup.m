% necessary on Linux machines - pathdef isn't read from user dir initially
matlabpath(pathdef);

% paths
[synology_dir, bigdata_dir] = get_synology_dir;

global good_green
good_green = [0.39608, 0.67843, 0];

% can always use rng('default') if I want to get consistent results
rng('shuffle');

% add other paths
addpath(genpath2(fullfile(synology_dir, 'eblackwood', 'VR_learning', 'vr_2p_analysis', 'matlab_vr2pcode'), '.git'));
