% This script shows (in 10 ms buckets) the average behaviour a hoverfly
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

    stimuliNames = ["Dorsal Loom Fast"     , "Dorsal Loom HalfFast", ...
                    "Dorsal Loom Halfslow" , "Dorsal Loom Slow", ...
                    "Ventral Loom Fast"    , "Ventral Loom HalfFast", ...
                    "Ventral Loom HalfSlow", "Ventral Loom Slow", ...
                    "Dorsal Loom control"  , "Ventral Loom control"];

    % Define camera frame rate (FPS) and analysis time bucket (ms)
    frameRate = 100;
    timeBucket = 100;
    framesPerBucket = floor((timeBucket * 10^(-3)) / (1 / frameRate));

    % Define longest experiment length
    experimentMax = 5; % Seconds

    % Get user defined community groupings 
    behaviours = [
        "Not flying", "Flying Straight", "Turning", "Straight Ruddering", ...
        "Turning Ruddering", "Superman", "Starfish", "Turning Starfish", "Front Kick"];

    csvList = dir(fullfile(inputFolder, '*.csv'));
    csvList = {csvList.name};

    fileType = '_behaviourAnalysis';
    csvIndex = find(cell2mat(regexp(csvList, fileType)));
    csvList = csvList(csvIndex);%#ok<FNDSB>

    for stimulus = 1:length(stimuliNames)
        % Pre-calculate the rough size of the analysis file we need
        behaviourAnalysis = zeros((experimentMax / (timeBucket * 10^(-3))),length(behaviours));
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
            % shift behaviours to remove unidentified ones
            behaviouralTimeSeries = behaviouralTimeSeries - 1;
            % Initialise the frame bucket system
            bucket = 1;
            bucketOffset = framesPerBucket * (bucket - 1);
            while bucketOffset < ((floor(size(behaviouralTimeSeries, 1) / 10) * 10) - framesPerBucket) && bucket <= size(behaviourAnalysis, 1)
                % This variable accounts for different bucket indexing
                behaviourAnalysis = bucketFilling(framesPerBucket, behaviourAnalysis, behaviouralTimeSeries, bucket, bucketOffset);
                bucket = bucket + 1;
                bucketOffset = framesPerBucket * (bucket - 1);
            end
        end
        % Normalise our bar data into a percentage variable
        for bucketNo = 1:size(behaviourAnalysis, 1)
            bucketSum = sum(behaviourAnalysis(bucketNo, :));
            behaviourAnalysis(bucketNo, :) = behaviourAnalysis(bucketNo, :) / bucketSum;
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

function behaviourAnalysis = bucketFilling(framesPerBucket, behaviourAnalysis, behaviouralTimeSeries, bucket, bucketOffset)
    for frame = 1:framesPerBucket
        currentBehaviour = behaviouralTimeSeries(bucketOffset + frame ,2);
        behaviourAnalysis(bucket, currentBehaviour) = behaviourAnalysis(bucket, currentBehaviour) + 1;   
    end
end



