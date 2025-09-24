function matobj = convert_python_obj(pyobj)
% Recursively convert a python object to MATLAB equivalent (somewhat opinionated)

switch class(pyobj)
    case 'py.pandas.core.frame.DataFrame'
        pyobj_table = table(pyobj);
        matobj = varfun(@convert_python_obj, pyobj_table);
        % undo change to variable names from varfun
        matobj.Properties.VariableNames = pyobj_table.Properties.VariableNames;
    case 'py.int'
        matobj = double(pyobj);
    case 'py.str'
        matobj = string(pyobj);
    case 'py.datetime.date'
        % assume zero time
        matobj = py.datetime.datetime.combine(pyobj, py.datetime.time());
    case 'py.dict'
        pyobj_struct = struct(pyobj);
        matobj = structfun(@convert_python_obj, pyobj_struct, 'uni', false);
    case {'py.list', 'py.tuple', 'cell'}
        pyobj_cell = cell(pyobj);
        matobj = cellfun(@convert_python_obj, pyobj_cell, 'uni', false);
        if all(cellfun(@isscalar, matobj))
            try
                matobj = reshape(vertcat(matobj{:}), size(matobj));
            catch  % ignore any error
            end
        end
    case 'py.numpy.ndarray'
        switch char(pyobj.dtype.kind)
            case {'i', 'f', 'c'}
                matobj = double(pyobj);
            case 'b'
                matobj = logical(pyobj);
            case 'u'
                switch double(pyobj.itemsize)
                    case 1
                        matobj = uint8(pyobj);
                    case 2
                        matobj = uint16(pyobj);
                    otherwise
                        matobj = uint64(pyobj);
                end
            case 'M'
                matobj = datetime(pyobj);
            case 'm'
                matobj = duration(pyobj);
            otherwise
                matobj = pyobj;
        end
    otherwise
        matobj = pyobj;
end

% for residual integer types (when recursing)
if isinteger(matobj)
    matobj = double(matobj);
end

end

