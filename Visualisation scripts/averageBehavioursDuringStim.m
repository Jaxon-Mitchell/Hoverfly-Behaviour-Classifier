% This script shows (in 10 ms buckets) the average behaviour a hoverfly
% displays for any given stimuli
function averageBehavioursDuringStim()
    % Get user to select .csv containing VAME motif timeseries
    inputFolder = uigetdir('Select your folder containing motif usage .csv''s');
    
    % Define variables %
    % Stimuli to choose from, select any from:
    % ["Dorsal_Loom_Fast"     , "Dorsal_Loom_HalfFast", ...
    %  "Dorsal_Loom_Halfslow" , "Dorsal_Loom_Slow", ...
    %  "Ventral_Loom_Fast"    , "Ventral_Loom_HalfFast", ...
    %  "Ventral_Loom_HalfSlow", "Ventral_Loom_Slow", ...
    %  "Dorsal_Loom_control"  , "Ventral_Loom_control"];
    
    stimuli = ["Dorsal_Loom_Fast"     , "Dorsal_Loom_HalfFast", ...
               "Dorsal_Loom_Halfslow" , "Dorsal_Loom_Slow", ...
               "Ventral_Loom_Fast"    , "Ventral_Loom_HalfFast", ...
               "Ventral_Loom_HalfSlow", "Ventral_Loom_Slow", ...
               "Dorsal_Loom_control"  , "Ventral_Loom_control"];
    
    % Define camera frame rate (FPS) and analysis time bucket (ms)
    frameRate = 100;
    timeBucket = 100;
    framesPerBucket = floor((timeBucket * 10^(-3)) / (1 / frameRate));
    
    % Define longest experiment length
    experimentMax = 5; % Seconds
    
    % This string should contain the expected file name format for motif usage
    fileType = "40_hmm_label";
    
    % Get user defined community groupings 
    community = returnCommunities();
    
    csvList = dir(fullfile(inputFolder, '*.csv'));
    csvList = {csvList.name};
    
    csvIndex = find(cell2mat(regexp(csvList, fileType)));
    csvList = csvList(csvIndex); %#ok<FNDSB>
    
    for stimulus = 1:length(stimuli)
        % Pre-calculate the rough size of the analysis file we need
        behaviourAnalysis = zeros((experimentMax / (timeBucket * 10^(-3))),length(community));
        % Get only the motif files relevant to our stimuli
        stimuliFiles = find(cell2mat(regexp(csvList, stimuli(stimulus))));
        % Loop over all experiments and extract community info 
        for file = 1:length(stimuliFiles)
            % Load the motif data
            experiment = readmatrix([inputFolder, '/', csvList{file}]);
            % Initialise the frame bucket system
            bucket = 1;
            bucketOffset = framesPerBucket * (bucket - 1);
            while bucketOffset < (size(experiment, 1) - framesPerBucket)
                % This variable accounts for different bucket indexing
                behaviourAnalysis = bucketFilling(community, framesPerBucket, behaviourAnalysis, experiment, bucket, bucketOffset);
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
        bar(behaviourAnalysis,'stacked', 'barwidth', 1)
    end
end

function behaviourAnalysis = bucketFilling(community, framesPerBucket, behaviourAnalysis, experiment, bucket, bucketOffset)
    for frame = 1:framesPerBucket
        for group = 1:length(community)
            if ismember(experiment((bucketOffset + frame), 2), community{group}.motifs)
                behaviourAnalysis(bucket, group) = behaviourAnalysis(bucket, group) + 1;
                break
            end
        end
    end
end



