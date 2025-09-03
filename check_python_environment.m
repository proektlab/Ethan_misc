function env = check_python_environment(envname, test_command)

arguments
    envname (1,1) string = "caiman"
    test_command (1,1) string = ""  % Python command to test 
end

% If a python environment is not loaded, attempts to initialize it with the camian environment
curr_pyenv = pyenv;
if curr_pyenv.Status ~= "Loaded"
    if ispc
        [~, hostname] = system('hostname');
        if envname == "caiman" && strcmpi(strtrim(hostname), 'lust')
            % use local caiman environment if we're on Lust
            python_path = 'C:\Users\ethan\AppData\Local\miniforge3\envs\mesviz\python';
        else
            synology_dir = get_synology_dir;
            python_path = fullfile(synology_dir, 'conda_envs_windows', envname, 'python');
        end

        fprintf('Initializing python environment from %s\n', python_path);
        env = pyenv('Version', python_path);
    else
        % python might still be usable, but we don't know the path
        
        % TODO try something simple to test
        warning('Python must be initialized to load data from caiman');
        env = curr_pyenv;
    end
else
    env = curr_pyenv;
end

if strlength(env.Version) == 0
    error('Python environment "%s" needed, but none was found', envname);
end

if strlength(test_command) > 0
    try pyrun(test_command)
    catch me
        if isa(me, 'matlab.exception.PyException')
            new_err = MException('EthanCode:badPythonEnv', ...
                'Could not run command "%s" in current python environment', test_command);
            new_err = addCause(new_err, me);
            throw(new_err);
        else
            rethrow(me);
        end
    end        
end

end

