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
    behaviourMat = behaviourAnalysis(:, 2);
    % For each frame in the video, check for bad starfish detection
    frame = 1;
    while frame < length(behaviourMat)
        currentBehaviour = behaviourMat(frame);
        if currentBehaviour == 7
            starfishTest = behaviourMat(frame:frame+3);
            if any(starfishTest == 6)
                behaviourMat(frame:frame+3) = 6;
                frame = frame + 2;
            else
                while currentBehaviour == 7
                    frame = frame + 1;
                    currentBehaviour = behaviourMat(frame);
                end
                frame = frame - 1;
            end
        end
        if currentBehaviour == 2
            starfishTest = behaviourMat(frame:frame+3);
            if any(starfishTest == 5)
                behaviourMat(frame:frame+3) = 5;
                frame = frame + 2;
            else
                while currentBehaviour == 2
                    frame = frame + 1;
                    currentBehaviour = behaviourMat(frame);
                end
                frame = frame - 1;
            end
            
        end
        frame = frame + 1;
    end
    % After we've gone through the whole file, go back and save all our
    % lovely adjusted data!
    behaviourAnalysis(:,2) = behaviourMat;
    writematrix(behaviourAnalysis, [filePath '/' analyses{analysis}])
end

disp("All Done!")