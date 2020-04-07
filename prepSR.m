global synology_dir;
global project_dir;
global raw_dir;
global processed_lfp_dir;
global script_dir;
global results_dir;
global snippits_dir;

this_dir = fileparts(mfilename('fullpath'));

project_dir = fullfile(synology_dir, 'brenna', 'States_rats');
raw_dir = fullfile(project_dir, 'RawData');
processed_lfp_dir = fullfile(project_dir, 'meanSubtracted_fullTrace');
results_dir = fullfile(project_dir, 'forEthan', 'spec-state-trans');
script_dir = fullfile(this_dir, '..', 'spec-state-trans');
snippits_dir = fullfile(project_dir, 'Snippits');

addpath(script_dir);

% other dependencies
addpath(fullfile(this_dir, '..', 'SpectralAnalysis'));
