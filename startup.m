% paths
synology_dir = get_synology_dir;

addpath(fullfile(synology_dir, 'brenna', 'Software', 'eeglab2021.1'));

% disable axis toolbar
set(groot, 'defaultFigureCreateFcn', @(fig,~) addToolbarExplorationButtons(fig));

global good_green
good_green = [0.39608, 0.67843, 0];

% can always use rng('default') if I want to get consistent results
rng('shuffle');
