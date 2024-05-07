function synology_dir = get_synology_dir
% Get location of lab server in filesystem

if ispc
    synology_dir = 'Z:';
elseif exist('/synology', 'dir')
    synology_dir = '/synology';
else
    synology_dir = '/mnt/synology';
end

end
