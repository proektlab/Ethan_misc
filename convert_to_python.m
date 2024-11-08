function pyobj = convert_to_python(matobj)
% conversion helper for some annoying types of matlab objects
if iscell(matobj)
    % first recursively make sure contents are python-compatible
    matobj = cellfun(@convert_to_python, matobj, 'uni', false);

    if isempty(matobj)
        pyobj = py.list();
    elseif isvector(matobj)
        pyobj = py.list(reshape(matobj, 1, []));
    else
        % recursively convert to list of lists
        pyobj = py.list();
        other_dims = arrayfun(@(kd) 1:size(matobj, kd), 2:ndims(matobj), 'uni', false);
        for row = 1:size(matobj, 1)
            nth_row = shiftdim(matobj(row, other_dims{:}), 1);
            pyobj.append(convert_to_python(nth_row));
        end
    end
elseif isstruct(matobj)
    if ~isscalar(matobj)
        % treat as a cell to convert to list or list of lists
        pyobj = convert_to_python(num2cell(matobj));
    else
        % recursively convert fields
        pyobj = structfun(@convert_to_python, matobj, 'uni', false);
    end
elseif istable(matobj)
    pyobj = varfun(@convert_int_array, matobj);
    pyobj.Properties.VariableNames = matobj.Properties.VariableNames;

elseif islogical(matobj) || isnumeric(matobj)
    matobj = convert_int_array(matobj);

    % some arrays seem to convert to memoryview by default, so just make it into an array explicitly
    pyobj = py.numpy.array(matobj);
else
    pyobj = matobj;
end

    function matobj = convert_int_array(matobj)
        if isa(matobj, 'double') && all(mod(matobj, 1) == 0, 'all')
            % make int arrays actually integral type
            matobj = int32(matobj);
        end
    end

end

