function version_check(required_release, missing_functionality)
% check that the MATLAB release is at least a given version
% and if not, raise an error with the reason that is a problem

arguments
    required_release (1,1) string
    missing_functionality (1,1) string
end


try
    old = isMATLABReleaseOlderThan(required_release);
catch me
    if strcmp(me.identifier, 'MATLAB:UndefinedFunction')
        old = true;
    else
        rethrow(me);
    end
end
if old
    error('MATLAB %s or newer required to %s', required_release, missing_functionality);
end

end

