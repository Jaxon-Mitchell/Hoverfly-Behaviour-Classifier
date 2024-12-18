% This script shows (in 10 ms buckets) the average behaviour a hoverfly
% displays for any given stimuli
function ethogramTimeSeries()
    % Get user to select .csv containing VAME motif timeseries
    inputFolder = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select your folder containing motif usage .csv''s');

    % Define variables %
    % Stimuli to choose from, select any from:
    % ["Dorsal_Loom_Fast"     , "Dorsal_Loom_HalfFast", ...
    %  "Dorsal_Loom_Halfslow" , "Dorsal_Loom_Slow", ...
    %  "Ventral_Loom_Fast"    , "Ventral_Loom_HalfFast", ...
    %  "Ventral_Loom_HalfSlow", "Ventral_Loom_Slow", ...
    %  "Dorsal_Loom_control"  , "Ventral_Loom_control"];

    stimuliSearch = ["Dorsal_Loom_Fast"     , "Dorsal_Loom_HalfFast", ...
                     "Dorsal_Loom_Halfslow" , "Dorsal_Loom_Slow", ...
                     "Ventral_Loom_Fast"    , "Ventral_Loom_HalfFast", ...
                     "Ventral_Loom_HalfSlow", "Ventral_Loom_Slow", ...
                     "Dorsal_Loom_control"  , "Ventral_Loom_control"];

    stimuliNames = strrep(stimuliSearch, '_', ' ');

    % Define longest experiment length
    experimentMax = 600; % Frames

    % Get user defined community groupings 
    behaviours = {
        'Undefined', 'Flying Straight', 'Turning', 'Straight Ruddering', ...
        'Turning Ruddering', 'Starfish', 'Turning Starfish'};
    behaviourMap = [128 128 128
                    078 080 199
                    078 147 199
                    076 163 060
                    134 199 078
                    224 076 076
                    224 150 076];
    % Put our colour map into the range [0 1]
    behaviourMap = behaviourMap / 255;

    csvList = dir(fullfile(inputFolder, '*.csv'));
    csvList = {csvList.name};

    fileType = '_behaviourAnalysis';
    csvIndex = find(cell2mat(regexp(csvList, fileType)));
    csvList = csvList(csvIndex);%#ok<FNDSB>

    for stimulus = 1:length(stimuliNames)
        % Init smallest found experiment
        smallestTest = experimentMax;
        % Get only the motif files relevant to our stimuli
        experimentTest = regexp(csvList, stimuliSearch(stimulus));
        for i = 1:length(experimentTest)
            if isempty(experimentTest{i})
                experimentTest{i} = 0;
            end
        end
        stimuliFiles = find(cell2mat(experimentTest));
        % Pre-calculate the rough size of the analysis file we need
        timeSeries = zeros(size(stimuliFiles, 1), experimentMax);
        % Loop over all experiments and extract community info 
        for file = 1:length(stimuliFiles)
            % Load the motif data
            behaviouralTimeSeries = readmatrix([inputFolder, '/', csvList{stimuliFiles(file)}]);
            if length(behaviouralTimeSeries) < smallestTest
                smallestTest = length(behaviouralTimeSeries);
            end
            for frame = 1:length(behaviouralTimeSeries)
                timeSeries(file, frame) = behaviouralTimeSeries(frame, 2);
            end
        end
        % Cut out the first 50ms (prestim time) and go to the length of the
        % smallest experiment in the group
        timeSeries = timeSeries(:, 6:smallestTest);
        % Plot our average behaviour data here!
        figure
        h = pcolor(timeSeries);
        hold on
        set(h, 'EdgeColor', 'none');

        colormap(behaviourMap)
        title(stimuliNames(stimulus))
        % Generate a legend for the figure
        for behaviour = 1:length(behaviours)
            qw{behaviour} = plot(nan, 'Color', behaviourMap(behaviour, :), 'LineWidth', 4);
        end
        l = legend([qw{:}], behaviours, 'location', 'southoutside');
        l.Orientation = "horizontal";
        % Disable y-axis as it is not relevant to this figure
        axis = gca; 
        axis.YAxis.Visible = 'off';
        xlabel("Time (s^-^2)")
        hold off
    end
end




