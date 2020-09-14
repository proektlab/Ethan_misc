function sr_dirs = prepSR
global synology_dir;

this_dir = fileparts(mfilename('fullpath'));

sr_dirs.project = fullfile(synology_dir, 'brenna', 'States_rats');
sr_dirs.raw = fullfile(sr_dirs.project, 'RawData');
sr_dirs.processed_lfp = fullfile(sr_dirs.project, 'meanSubtracted_fullTrace');
sr_dirs.results = fullfile(sr_dirs.project, 'forEthan', 'spec-state-trans');
sr_dirs.script = fullfile(this_dir, '..', 'spec-state-trans');
sr_dirs.snippits = fullfile(sr_dirs.project, 'Snippits');

addpath(sr_dirs.script);
addpath(fullfile(sr_dirs.script, 'pipeline'));

% other dependencies
addpath(fullfile(synology_dir, 'code', 'SpectralAnalysis'));
addpath(fullfile(synology_dir, 'code', 'NonNegativeMatrixFactorization'));
addpath(fullfile(synology_dir, 'code', 'Plotting', 'Violinplot-Matlab'));

end
