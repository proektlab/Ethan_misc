global processed_lfp_dir;
global script_dir;
global results_dir;
global snippits_dir;

% ** Change the below to local location of Blackwood Box folder: **
box_dir = 'D:\Box Sync\NeuroCore\2020 Student Folders\Blackwood';

this_dir = fileparts(mfilename('fullpath'));

processed_lfp_dir = fullfile(box_dir, 'raw_preprocessed_meansub');
results_dir = fullfile(box_dir, 'results');
script_dir = fullfile(this_dir, '..', 'spec-state-trans');
snippits_dir = fullfile(box_dir, 'snippits');

addpath(this_dir);
addpath(script_dir);
