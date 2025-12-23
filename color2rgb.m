function rgb = color2rgb(color)
% Get rgb value of a color which is any valid input for the "Color" property of a line

arguments
    color {mustBeA(color, ["char", "string", "double", "cell"])}
end

if iscell(color)
    rgb_all = cellfun(@color2rgb, color, 'uni', false);
    rgb = vertcat(rgb_all{:});
    return
end

if isstring(color)
    if ~isscalar(color)
        rgb_all = arrayfun(@color2rgb, color, 'uni', false);
        rgb = vertcat(rgb_all{:});
        return
    else
        color = char(color);
    end
end

if isnumeric(color)
    if numel(color) == 3
        rgb = reshape(color, 1, 3);
    else
        assert(size(color, 2) == 3 && ismatrix(color), 'Invalid size for RGB color input');
        rgb = color;
    end
    return;
end

% now color must be a char array
assert(size(color, 1) == 1 && ismatrix(color), 'Invalid size for char array color input');
if color(1) == '#'
    rgb = hex2rgb(color);
else
    switch lower(color)
        case {'r', 'red'}
            rgb = [1, 0, 0];
        case {'g', 'green'}
            rgb = [0, 1, 0];
        case {'b', 'blue'}
            rgb = [0, 0, 1];
        case {'y', 'yellow'}
            rgb = [1, 1, 0];
        case {'c', 'cyan'}
            rgb = [0, 1, 1];
        case {'m', 'magenta'}
            rgb = [1, 0, 1];
        case {'k', 'black'}
            rgb = [0, 0, 0];
        case {'w', 'white'}
            rgb = [1, 1, 1];
        otherwise
            error('Unrecognized color name: %s', color);
    end
end

end