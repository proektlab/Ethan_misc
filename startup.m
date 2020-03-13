% paths
global synology_dir;

if isempty(synology_dir)
    if ispc
        synology_dir = 'Z:';
    else
        synology_dir = '/synology';
    end
end

addpath(fullfile(synology_dir, 'brenna', 'Software', 'eeglab2019_1'));

% disable axis toolbar and datatip interaction (which slows things down)
set(groot, 'defaultFigureCreateFcn', @(fig,~) addToolbarExplorationButtons(fig));
set(groot, 'defaultAxesCreateFcn', getAxesCreateFcn('zba'));
set(groot, 'defaultPolarAxesCreateFcn', getAxesCreateFcn('t'));

% makes hold 'on' by default (which is kind of nice but also required now
% for the defaultAxesCreateFcn change above to work)
set(groot, 'defaultAxesNextPlot', 'add');
set(groot, 'defaultPolarAxesNextPlot', 'add');

function fcn = getAxesCreateFcn(code)

    interactions = cell(1, length(code));
    for kI = 1:length(code)
        switch code(kI)
            case 'z'
                interactions{kI} = zoomInteraction;
            case 'b'
                interactions{kI} = regionZoomInteraction;
            case 'p'
                interactions{kI} = panInteraction;
            case 'a'
                interactions{kI} = rulerPanInteraction;
            case 'r'
                interactions{kI} = rotateInteraction;
            case 't'
                interactions{kI} = dataTipInteraction;
            otherwise
                error('Bad interactions code');
        end
    end
    interactions = [interactions{:}];

    function axesCreateFcn(ax, ~)
        ax.Interactions = interactions;
        ax.Toolbar = [];
    end

fcn = @axesCreateFcn;
end