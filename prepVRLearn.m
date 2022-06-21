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

% Output 5V on AO0 to close the valve, if applicable
daqs = daq.getDevices;
daq_inds = find(ismember({daqs.ID}, {'BallController', 'SimBallController'}));

if isempty(daq_inds)
    warning('No ball controller DAQ found');
else
    s = daq.createSession('ni');
    for ind = daq_inds
        addAnalogOutputChannel(s, daqs(ind).ID, 'ao0', 'Voltage');
    end
    outputSingleScan(s, repelem(5, length(daq_inds)));
end

end
