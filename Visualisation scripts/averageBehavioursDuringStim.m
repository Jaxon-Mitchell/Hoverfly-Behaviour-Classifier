% This script shows the average behaviour a hoverfly
% displays for any given stimuli
function averageBehavioursDuringStim()
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
    behaviours = [
        "Undefined", "Flying Straight", "Turning", "Straight Ruddering", ...
        "Turning Ruddering", "Starfish", "Turning Starfish"];

    csvList = dir(fullfile(inputFolder, '*.csv'));
    csvList = {csvList.name};

    fileType = '_behaviourAnalysis';
    csvIndex = find(cell2mat(regexp(csvList, fileType)));
    csvList = csvList(csvIndex); %#ok<FNDSB>

    for stimulus = 1:length(stimuliNames)
        % Pre-calculate the rough size of the analysis file we need
        behaviourAnalysis = zeros(experimentMax,length(behaviours));
        % Get only the motif files relevant to our stimuli
        experimentTest = regexp(csvList, stimuliSearch(stimulus));
        for i = 1:length(experimentTest)
            if isempty(experimentTest{i})
                experimentTest{i} = 0;
            end
        end
        stimuliFiles = find(cell2mat(experimentTest));
        % Loop over all experiments and extract community info 
        for file = 1:length(stimuliFiles)
            % Load the motif data
            behaviouralTimeSeries = readmatrix([inputFolder, '/', csvList{stimuliFiles(file)}]);
            % Cull the first 50ms as it is pre-stim
            behaviouralTimeSeries = behaviouralTimeSeries(6:end, :);
            for frame = 1:size(behaviouralTimeSeries, 1)
                % Loop over the whole video and fill the time series
                currentBehaviour = behaviouralTimeSeries(frame, 2);
                behaviourAnalysis(frame, currentBehaviour) = behaviourAnalysis(frame, currentBehaviour) + 1;
            end
        end
        % Normalise our bar data into a percentage variable
        for frame = 1:size(behaviourAnalysis, 1)
            bucketSum = sum(behaviourAnalysis(frame, :));
            behaviourAnalysis(frame, :) = behaviourAnalysis(frame, :) / bucketSum;
        end
        behaviourAnalysis = rmmissing(behaviourAnalysis);
        % Plot our average behaviour data here!
        figure
        bar(behaviourAnalysis, 'stacked', 'barwidth', 1)
        ylim([0 1])
        title(stimuliNames(stimulus))
        legend(behaviours, 'Location', 'southwest')
    end
end
