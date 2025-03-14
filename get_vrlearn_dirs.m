function vr_dirs = get_vrlearn_dirs(online)
% Just get VR learn dirs without touching the path (faster than prepVRLearn)

if ~exist("online", 'var') || isempty(online)
    online = true;
end

matlab_dir = userpath;
[synology_dir, bigdata_dir] = get_synology_dir;

% Virmen engine
if online
    vr_dirs.virmen = fullfile(synology_dir, 'code', 'virmen-for-mouse-vr');
else
    vr_dirs.virmen = fullfile(matlab_dir, 'virmen-for-mouse-vr');
end

vr_dirs.project = fullfile(synology_dir, 'eblackwood', 'VR_learning');

% Our custom virmen code
if online
    vr_dirs.expcode = fullfile(vr_dirs.project, 'experiment_code');
else
    vr_dirs.expcode = fullfile(matlab_dir, 'cue-learning-virmen-expcode');
end

% Data save directory
if online
    vr_dirs.data = fullfile(vr_dirs.project, 'virmen_data');
else
    vr_dirs.data = fullfile(matlab_dir, '..', 'virmen_data');
end

% 2p data directory
vr_dirs.data_2p = fullfile(bigdata_dir, 'eblackwood', '2p_data');

end