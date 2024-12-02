% This script is designed to search for edge case behaviours based on the
% parameters that the user is looking to test

% Start by getting the users folder to search through
[behaviourPath] = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select file containing your behaviour data');

% Cancel if no file selected
if behaviourPath == 0
   disp('User selected cancel');
   return
end

% Double check video resolution as it's important for our angle
% calculations
vidRes = inputdlg({'Enter video width:', 'Enter video height:'}, ...
    'Video Resolution', [1 45], {'320', '240'});

% Search the folder for any csv's
behaviourFiles = dir([behaviourPath '/*.csv']);
behaviourFiles = {behaviourFiles.name};
% Remove already existing behaviour analysis from the list
existing = find(contains(behaviourFiles, "_questionableBehaviour.csv"));
for i = length(existing):-1:1
    behaviourFiles(existing(i)) = [];
end


for file = 1:length(behaviourFiles)
    % Load the .csv file as a cell array
    dlcBehaviour = readcell([behaviourPath '/' behaviourFiles{file}]);    
    % Get the analysis into a format more easy for Matlab to handle
    behaviourClean = dlcBehaviour(4:end,2:end);
    behaviourClean = cell2mat(behaviourClean);
    % Set up a matrix to show what frames are questionable and which are not
    analysisMatrix = ones(size(behaviourClean, 1), 4);
    analysisMatrix(:,1) = 1:size(analysisMatrix, 1);
    % Get all the calculations we need from our file
    behaviourCalcs = getAnalysisData(behaviourClean, vidRes);
    frontLegMax = max(behaviourCalcs.frontVectorRight, behaviourCalcs.frontVectorLeft);
    frontLegAv = (behaviourCalcs.frontVectorRight + behaviourCalcs.frontVectorLeft) / 2;
    distalDeviationDiff = abs(behaviourCalcs.distalDeviationDiff);
    % Loop through frames and make a rolling average (width = 3 frames) of
    % all distal deviations
    distalDeviationRollingAv = ones(length(distalDeviationDiff), 1);
    for frame = 2:length(distalDeviationDiff) - 1
        distalDeviationRollingAv(frame) = (distalDeviationDiff(frame - 1) + distalDeviationDiff(frame) + distalDeviationDiff(frame + 1)) / 3;
    end
    distalDeviationRollingAv(1) = distalDeviationRollingAv(2);
    distalDeviationRollingAv(end) = distalDeviationRollingAv(end - 1);
    analysisMatrix(:, 3) = frontLegMax;
    analysisMatrix(:, 4) = distalDeviationDiff;
    analysisMatrix(:, 5) = frontLegAv;
    analysisMatrix(:, 6) = distalDeviationRollingAv;
    % Report to the user what frames of the experiment pass into the
    % 'questionable' territory and save it to a .csv file
    for frame = 1:length(frontLegMax)
        if frontLegMax(frame) > 5 && frontLegMax(frame) < 20
            analysisMatrix(frame, 2) = 2;
            continue
        elseif distalDeviationDiff(frame) > 15 && distalDeviationDiff(frame) < 40
            analysisMatrix(frame, 2) = 3;
            continue
        end
    end

    % Save the behavioural analysis as a .csv file (not overriding the old one!)
    fileName = strsplit(behaviourFiles{file}, '.csv');
    fileName = [fileName{1} '_questionableBehaviour.csv'];
    writematrix(analysisMatrix, [behaviourPath '/' fileName])
end
disp("All done :D")

function outputData = getAnalysisData(dlcClean, vidRes)
    % Perform calculations to get the desired data to compare
    axisAngle = getCalculations(dlcClean, vidRes, 'axisAngle');
    % Get vectors and angle info for both hind legs
    hindCalcs = getCalculations(dlcClean, vidRes, 'hindlegVectors', axisAngle);
    % Get vectors and angle calculations for both front legs
    frontCalcs = getCalculations(dlcClean, vidRes, 'frontlegVectors', axisAngle);
    
    % Uncomment this to plot starfish stuff (Front leg vector length)
    outputData.frontVectorRight = abs(frontCalcs(:, 1, 1));
    outputData.frontVectorLeft = abs(frontCalcs(:, 2, 1));
    % Uncomment this to plot difference between x-axis deviation from
    % distal hind to abdomen side
    outputData.distalDeviationDiff = hindCalcs(:, 1, 6) + hindCalcs(:, 2, 6);
end
