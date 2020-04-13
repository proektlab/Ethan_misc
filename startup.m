% paths
global synology_dir;

if isempty(synology_dir)
    if ispc
        synology_dir = 'Z:';
    else
        synology_dir = '/synology';
    end
end

addpath(fullfile(synology_dir, 'brenna', 'Software', 'eeglab2019_1'));

% disable axis toolbar
set(groot, 'defaultFigureCreateFcn', @(fig,~) addToolbarExplorationButtons(fig));
