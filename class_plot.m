function h = class_plot(varargin)
% class_plot: colored area plot showing classifications over time
% class_vec should be a numeric vector of class assignments; classes are plotted in sorted order.
%
% Syntax:
%     h = class_plot([ax]=gca, [xaxis]=1:length(class_vec), [ylims]=[0,1], class_vec)
%
% Returns h, a vector of patch objects, one per class.

assert(~isempty(varargin), 'Must at least provide class_vec input');

% last argument is always class_vec
class_vec = varargin{end};
assert(isvector(class_vec) && isnumeric(class_vec) && isreal(class_vec), 'class_vec must be a real vector');
n_pts = length(class_vec);
class_vec = class_vec(:);

% check optional arguments
optargs = varargin(1:end-1);

if ~isempty(optargs) && isa(optargs{1}, 'matlab.graphics.axis.Axes')
    ax = optargs{1};
    optargs = optargs(2:end);
else
    ax = gca;
end

if ~isempty(optargs) && isvector(optargs{1}) && length(optargs{1}) == n_pts
    xaxis = optargs{1}(:).';
    assert(isnumeric(xaxis) && isreal(xaxis) && all(diff(xaxis) > 0), 'Invalid xaxis');
    optargs = optargs(2:end);
else
    xaxis = 1:n_pts;
end

% quit early if it looks like x axis was the wrong length
if ~isempty(optargs) && length(optargs{1}) > 2 && length(optargs{1}) ~= n_pts
    error('Invalid argument - probably x axis is the wrong length');
end

if ~isempty(optargs) && numel(optargs{1}) == 2
    ylims = optargs{1};
    optargs = optargs(2:end);
else
    ylims = [0, 1];
end

assert(isempty(optargs), 'Too many or invalid arguments (see help for syntax)');

classes = unique(class_vec(~isnan(class_vec)));
n_classes = length(classes);
colors = jet(n_classes);

halfdt = mean(diff(xaxis)) / 2;

h = gobjects(n_classes, 1);
newplot;

for kC = 1:n_classes
    class = classes(kC);
    is_class_start = [nan; class_vec(1:end-1)] ~= class & class_vec(:) == class;
    is_class_end = class_vec(:) == class & [class_vec(2:end); nan] ~= class;


    class_start_times = xaxis(is_class_start);
    class_start_times = max(xaxis(1), class_start_times - halfdt);

    class_end_times = xaxis(is_class_end);
    class_end_times = min(xaxis(end), class_end_times + halfdt);

    X = [class_start_times; class_end_times; class_end_times; class_start_times];
    Y = repmat([ylims(1); ylims(1); ylims(2); ylims(2)], 1, size(X, 2));

    h(kC) = patch(ax, X, Y, colors(kC, :), 'LineStyle', 'none', 'DisplayName', num2str(class));
end

axis tight;

legend(ax, 'Location', 'southoutside', 'NumColumns', 8);

end

