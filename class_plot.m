function h = class_plot(ax, xaxis, class_vec)
% class_plot: colored area plot showing classifications over time
% class_vec should be a numeric vector of class assignments; classes are plotted in sorted order.
% If there are more than 7 classes, patches are distinguished by edge color.
%
% Syntaxes:
%     h = class_plot([ax]=gca, [xaxis]=1:length(class_vec), class_vec)
%
% Returns h, a vector of patch objects, one per class.

assert(nargin >= 1, 'Must at least provide class_vec input');

if nargin < 3
    if ~isa(ax, 'matlab.graphics.axis.Axes')
        if nargin < 2
            class_vec = ax;
            xaxis = 1:numel(class_vec);
        else
            class_vec = xaxis;
            xaxis = ax;
        end
        ax = gca;
    else
        class_vec = xaxis;
        xaxis = 1:length(class_vec);
    end
end

% validation
assert(isa(ax, 'matlab.graphics.axis.Axes'), 'Invalid axes provided');
assert(isvector(xaxis) && isreal(xaxis) && isnumeric(xaxis) && all(diff(xaxis) > 0), 'Invalid xaxis');
assert(isvector(class_vec) && isreal(class_vec) && isnumeric(class_vec), 'class_vec must be a real vector');
assert(length(class_vec) == length(xaxis), 'Length of class_vec doesn''t match length of xaxis');

xaxis = xaxis(:).';

classes = unique(class_vec);
n_classes = length(classes);

if n_classes <= 7
    colors = lines(n_classes);
else
    colors = jet(n_classes);
end

halfdt = mean(diff(xaxis)) / 2;

h = gobjects(n_classes, 1);

for kC = 1:n_classes
    class = classes(kC);
    is_class_start = [nan; class_vec(1:end-1)] ~= class & class_vec(:) == class;
    is_class_end = class_vec(:) == class & [class_vec(2:end); nan] ~= class;


    class_start_times = xaxis(is_class_start);
    class_start_times = max(xaxis(1), class_start_times - halfdt);

    class_end_times = xaxis(is_class_end);
    class_end_times = min(xaxis(end), class_end_times + halfdt);

    X = [class_start_times; class_end_times; class_end_times; class_start_times];
    Y = repmat([1; 1; 0; 0], 1, size(X, 2));

    h(kC) = patch(ax, X, Y, colors(kC, :), 'LineStyle', 'none');
end

ylim(ax, [0, 1]);
yticks(ax, []);
xlim(ax, [xaxis(1), xaxis(end)]);

legend(ax, arrayfun(@num2str, classes, 'uni', false), ...
    'Location', 'southoutside', 'NumColumns', 8);

end

