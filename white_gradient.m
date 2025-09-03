function cmap = white_gradient(color, opts)
% create a colormap that is a gradient from white to the given color (which can be specified
% as any valid input for the "Color" property of a line)

arguments
    color {mustBeA(color, ["char", "string", "double"])}
    opts.direction (1,1) string {mustBeMember(opts.direction, ["increasing", "decreasing"])} ...
        = "increasing"  % increasing = max value has color given, min value has white & vice versa
    opts.n_values (1,1) double {mustBeInteger} = 256
end

ref_colors = [1, 1, 1; color2rgb(color)];
if opts.direction == "increasing"
    ref_points = [1, opts.n_values];
else
    ref_points = [opts.n_values, 1];
end

cmap = interp1(ref_points, ref_colors, 1:opts.n_values);


end