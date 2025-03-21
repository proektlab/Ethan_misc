function check_python_environment
% If a python environment is not loaded, attempts to initialize it with the camian environment
curr_pyenv = pyenv;
if curr_pyenv.Status ~= "Loaded"
    if ispc
        disp('Initializing python environment from Z:\conda_envs_windows\caiman');
        synology_dir = get_synology_dir;
        pyenv('Version', fullfile(synology_dir, 'conda_envs_windows', 'caiman', 'python'));
    else
        error('Python must be initialized to load data from caiman');
    end
end

end

