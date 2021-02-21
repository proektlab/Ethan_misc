function synology_dir = get_synology_dir
% Get location of lab server in filesystem

if ispc
    synology_dir = 'Z:';
else
    synology_dir = '/synology';
end

end
