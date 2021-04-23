function sr_dirs = prepSR
% Setup for workign on States_rats i.e. spec-state-trans
% For non-Proekt Lab users: modify/rewrite as necessary so that sr_dirs points to the
% appropriate places and the library paths are correct.

synology_dir = get_synology_dir;  % our lab server
this_dir = fileparts(mfilename('fullpath'));

% parent folder to all data
sr_dirs.project = fullfile(synology_dir, 'brenna', 'States_rats');

% contains raw data LFP matfiles (before artifact removal/mean subtraction) - probably not used
sr_dirs.raw = fullfile(sr_dirs.project, 'RawData');

% contains matfiles with continuous preprocessed LFP
sr_dirs.processed_lfp = fullfile(sr_dirs.project, 'meanSubtracted_fullTrace');

% contains matfiles with preprocessed LFP broken into stim trials. Used for CSD.
sr_dirs.snippits = fullfile(sr_dirs.project, 'Snippits');

% place to save results and figures - currently the same as script dir but could be different
sr_dirs.results = fullfile(sr_dirs.project, 'forEthan', 'spec-state-trans');

% root folder of the spec-state-trans repository
sr_dirs.script = fullfile(this_dir, '..', 'spec-state-trans');

addpath(sr_dirs.script);
addpath(fullfile(sr_dirs.script, 'pipeline'));

% other dependencies
% https://github.com/proektlab/SpectralAnalysis
addpath(fullfile(synology_dir, 'code', 'SpectralAnalysis'));
% https://github.com/proektlab/NonNegativeMatrixFactorization
addpath(fullfile(synology_dir, 'code', 'NonNegativeMatrixFactorization'));
% https://github.com/bastibe/Violinplot-Matlab
addpath(fullfile(synology_dir, 'code', 'Plotting', 'Violinplot-Matlab'));
% https://github.com/raacampbell/sigstar
addpath(fullfile(synology_dir, 'code', 'Plotting', 'sigstar'));

end
