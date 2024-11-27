% This script is designed to search for edge case behaviours based on the
% parameters that the user is looking to test

% Start by getting the users folder to search through
[behaviourPath] = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select file containing your behaviour data');

% Cancel if no file selected
if behaviourPath == 0
   disp('User selected cancel');
   return
end
% Search the folder for any csv's
behaviourFiles = dir([behaviourPath '/*.csv']);

dlcBehaviour = readcell([behaviourPath behaviourFile]);

% Double check video resolution as it's important for our angle
% calculations
vidRes = inputdlg({'Enter video width:', 'Enter video height:'}, ...
    'Video Resolution', [1 45], {'320', '240'});

% Get the analysis into a format more easy for Matlab to handle
behaviourClean = dlcBehaviour(4:end,2:end);
behaviourClean = cell2mat(behaviourClean);
if optionalFile ~= 0
    optionalClean = dlcOptional(4:end,2:end);
    optionalClean = cell2mat(optionalClean);
end

behaviourCalcs = getAnalysisData(behaviourClean, vidRes);
controlCalcs = getAnalysisData(controlClean, vidRes);
if optionalFile ~= 0
    optionalCalcs = getAnalysisData(optionalClean, vidRes);
end

angleEdges = 0:0.5:180;
pixelEdges = 0:1:100;
deviationEdges = -150:1:150;
deviationEdgesAbs = 0:1:150;

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
