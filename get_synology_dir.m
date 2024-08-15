function [synology_dir, bigdata_dir] = get_synology_dir
% Get location of lab server in filesystem

if ispc
    synology_dir = 'Z:';
    bigdata_dir = 'Y:';
else
    bigdata_dir = '/mnt/bigdata';
    if exist('/synology', 'dir')
    synology_dir = '/synology';
    else
        synology_dir = '/mnt/synology';
    end
end

end
