% This script is meant to go through behaviour output videos and smooth out
% results that shouldn't be there (I.E. turning starfish being there for
% only a frame because one leg came out before the other in a normal
% starfish)

filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder containing all behaviour analysis AND videos');

if any(filePath == 0)
    disp('Cancelled by user')
    return
end

% Get all video DLC analysis names in an array
analyses = dir([filePath '/*_behaviourAnalysis.csv']);
analyses = {analyses(1:end).name};

% Loop through each experiment to grab out the relevant parts
for analysis = 1:length(analyses)
    % Read data from the current experiment
    behaviourAnalysis = readmatrix([filePath '/' analyses{analysis}]);
    behaviourAnalysis = behaviourAnalysis(:, 2);
    uniqueBehaviours = unique(behaviourAnalysis);
    % For each frame in the video, check for bad starfish detection
    frame = 1;
    while frame < length(behaviourAnalysis)
        currentBehaviour = behaviourAnalysis(frame);
        if currentBehaviour == 7
            starfishTest = behaviourAnalysis(frame:frame+3);
            if any(starfishTest == 6)
                behaviourAnalysis(frame:frame+3) = 6;
            end
            frame = frame + 2;
        else
            frame = frame + 2;
        end
        frame = frame + 1;
    end
end