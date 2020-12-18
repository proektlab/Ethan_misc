function h = class_plot(varargin)
% class_plot: colored area plot showing classifications over time
% class_vecs should be a numeric vector of class assignments; classes are plotted in sorted order.
% class_vecs can also be a cell of vectors, in whcih case they are stacked
% on the y axis.
%
% Syntax:
%     h = class_plot([ax]=gca, [xaxis]=1:length(class_vecs{1}), [ylabel]={''}, class_vecs)
%
% Returns h, a vector of patch objects, one per class.

assert(~isempty(varargin), 'Must at least provide class_vec input');

% last argument is always class_vecs
class_vecs = varargin{end};
if ~iscell(class_vecs)
    class_vecs = {class_vecs};
end

n_vecs = numel(class_vecs);

for kV = 1:n_vecs
    class_vec = class_vecs{kV};
    assert(isvector(class_vec) && isnumeric(class_vec) && isreal(class_vec), ...
        'class_vec must be a real vector');

    if kV == 1
        n_pts = length(class_vec);
    else
        assert(length(class_vec) == n_pts, 'Class vectors have mismatched lengths');
    end
    class_vecs{kV} = class_vec(:);
end
class_vecs = class_vecs(:);

% check optional arguments
optargs = varargin(1:end-1);

if ~isempty(optargs) && isa(optargs{1}, 'matlab.graphics.axis.Axes')
    ax = optargs{1};
    optargs = optargs(2:end);
else
    ax = gca;
end

if ~isempty(optargs) && isvector(optargs{1}) && isnumeric(optargs{1})
    assert(length(optargs{1}) == n_pts, 'X axis is the wrong length');
    xaxis = optargs{1}(:).';
    assert(isreal(xaxis) && all(diff(xaxis) > 0), 'Invalid xaxis');
    optargs = optargs(2:end);
else
    xaxis = 1:n_pts;
end

if ~isempty(optargs) && ischar(optargs{1})
    optargs{1} = optargs(1); % (confusing syntax but this encloses it in a cell)
end

if ~isempty(optargs) && iscell(optargs{1})
    assert(length(optargs{1}) == n_vecs, 'Number of y labels provided does not match number of series');
    y_labels = optargs{1};
    optargs = optargs(2:end);
else
    y_labels = repmat({''}, n_vecs, 1);
end

assert(isempty(optargs), 'Too many or invalid arguments (see help for syntax)');

% make y limits for each series/vector
ylims_all = [-0.5, 0.5] + (1:n_vecs)';

all_classes = cell2mat(class_vecs);
classes = unique(all_classes(~isnan(all_classes)));
n_classes = length(classes);
colors = jet(n_classes);

tsteps = diff(xaxis);
dt = min(tsteps);
% identify gaps as places where the timestep is different
before_gap = [tsteps > dt, false];
after_gap = [false, before_gap(1:end-1)];

h = gobjects(n_classes, 1);
newplot;

for kC = 1:n_classes
    class = classes(kC);

    X = cell(1, n_vecs);
    Y = cell(1, n_vecs);

    for kV = 1:n_vecs
        class_vec = class_vecs{kV};

        is_class_start = class_vec(:) == class & ([nan; class_vec(1:end-1)] ~= class | after_gap(:));
        is_class_end = class_vec(:) == class & ([class_vec(2:end); nan] ~= class | before_gap(:));


        class_start_times = xaxis(is_class_start);
        class_start_times = max(xaxis(1), class_start_times - dt/2);

        class_end_times = xaxis(is_class_end);
        class_end_times = min(xaxis(end), class_end_times + dt/2);

        ylims = ylims_all(kV, :);

        X{kV} = [class_start_times; class_end_times; class_end_times; class_start_times];
        Y{kV} = repmat([ylims(1); ylims(1); ylims(2); ylims(2)], 1, size(X{kV}, 2));
    end

    X = cell2mat(X);
    Y = cell2mat(Y);

    h(kC) = patch(ax, X, Y, colors(kC, :), 'LineStyle', 'none', 'DisplayName', num2str(class));
end

axis tight;
ylim([ylims_all(1, 1), ylims_all(end, end)]);
ax.YDir = 'reverse';
yticks(1:n_vecs);
yticklabels(y_labels);
ax.TickLabelInterpreter = 'none';

legend(ax, 'Location', 'southoutside', 'NumColumns', 8);

end

