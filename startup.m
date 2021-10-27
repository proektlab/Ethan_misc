% paths
synology_dir = get_synology_dir;

addpath(fullfile(synology_dir, 'brenna', 'Software', 'eeglab2021.1'));

% disable axis toolbar
set(groot, 'defaultFigureCreateFcn', @(fig,~) addToolbarExplorationButtons(fig));
