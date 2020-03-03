global synology_dir;
global project_dir;
global raw_dir;
global processed_lfp_dir;
global script_dir;
global results_dir;

project_dir = fullfile(synology_dir, 'brenna', 'States_rats');
raw_dir = fullfile(project_dir, 'RawData');
processed_lfp_dir = fullfile(project_dir, 'meanSubtracted_fullTrace');
results_dir = fullfile(project_dir, 'forEthan', 'spec-state-trans');
script_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'spec-state-trans');
