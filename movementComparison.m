% This script is designed to be able to show (in buckets) what the
% distribution is of any vector or calculation made with DLC variables, to
% check for a bimodal distribution or a rough spread.

% Start by getting the users files to compare
clear optionalFile % Do not delete this or things WILL break
[behaviourFile, behaviourPath] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select file containing your behaviour data');
[controlFile, controlPath] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select file containing your control data');
[optionalFile, optionalPath] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select file containing your 3rd set of comparison data');

% Load the data
dlcBehaviour = readcell([behaviourPath behaviourFile]);
dlcControl = readcell([controlPath controlFile]);
if exist('optionalFile', 'var')
    dlcOptional = readcell([optionalPath optionalFile]);
end

% Double check video resolution as it's important for our angle
% calculations
vidRes = inputdlg({'Enter video width:', 'Enter video height:'}, ...
    'Video Resolution', [1 45], {'320', '240'});


% Get the analysis into a format more easy for Matlab to handle
behaviourClean = dlcBehaviour(4:end,2:end);
behaviourClean = cell2mat(behaviourClean);
controlClean = dlcControl(4:end,2:end);
controlClean = cell2mat(controlClean);
if exist('optionalFile', 'var')
    optionalClean = dlcOptional(4:end,2:end);
    optionalClean = cell2mat(optionalClean);
end

behaviourCalcs = getAnalysisData(behaviourClean, vidRes);
controlCalcs = getAnalysisData(controlClean, vidRes);
if exist('optionalFile', 'var')
    optionalCalcs = getAnalysisData(optionalClean, vidRes);
end

field = {'wbaAll', 'hingeKneeAngleDiff', 'hindInteriorKneeAngleDiff', 'distalHindLengthRight',...
    'frontVectorRight', 'wholeHindAngleDiff', 'distalDeviationDiff', 'distalDeviationRight'};
TF = isfield(behaviourCalcs,field);

angleEdges = 0:0.5:180;
pixelEdges = 0:1:150;
deviationEdges = -150:1:150;
deviationEdgesAbs = 0:1:150;
if TF(1) == 1
    figure
    histogram(wbaAll, angleEdges);
    title("Wing Beat Amplitude Difference between L+R")
end
if TF(2) == 1
    figure
    histogram(hingeKneeAngleDiff, angleEdges);
    title("Difference between hinge-knee angle relative to the axis angle for both left and right hind leg")
end
if TF(3) == 1
    figure
    histogram(hindInteriorKneeAngleDiff, angleEdges);
    title("Difference between L+R interior knee angle for hind legs")
end
if TF(4) == 1
    figure
    tiledlayout("horizontal")
    nexttile
    histogram(distalHindLengthLeft, pixelEdges);
    title("Left Hind Knee-Distal Vector Length")
    nexttile
    histogram(distalHindLengthRight, pixelEdges);
    title("Right Hind Knee-Distal Vector Length")
end
if TF(5) == 1 % Comparison of front leg vector lengths
    figure
    tiledlayout("horizontal")
    nexttile
    % Where control movement is happening
    histogram(controlCalcs.frontVectorLeft, pixelEdges, 'Normalization', 'percentage');
    hold on
    % Where behaviour is happening
    histogram(behaviourCalcs.frontVectorLeft, pixelEdges, 'Normalization', 'percentage');
    title("Front left leg vector length")
    if exist('optionalFile', 'var')
        histogram(optionalCalcs.frontVectorLeft, pixelEdges, 'Normalization', 'percentage');
        legend(controlFile, behaviourFile, optionalFile)
    else
        legend(controlFile, behaviourFile)
    end
    xlabel("Vector Length (Pixels)")
    ylabel("Percentage (%)")
    hold off
    nexttile
    % Where control movement is happening
    histogram(controlCalcs.frontVectorRight, pixelEdges, 'Normalization', 'percentage');
    hold on
    % Where behaviour is happening
    histogram(behaviourCalcs.frontVectorRight, pixelEdges, 'Normalization', 'percentage');
    title("Front right leg vector length")
    if exist('optionalFile', 'var')
        histogram(optionalCalcs.frontVectorRight, pixelEdges, 'Normalization', 'percentage');
        legend(controlFile, behaviourFile, optionalFile)
    else
        legend(controlFile, behaviourFile)
    end
    xlabel("Vector Length (Pixels)")
    ylabel("Percentage (%)")
end
if TF(6) == 1
    figure
    histogram(wholeHindAngleDiff, angleEdges);
    title("Difference between whole leg to axis angle for both hind legs")
end
if TF(7) == 1
    figure
    tiledlayout("horizontal")
    nexttile
    histogram(distalDeviationDiff, deviationEdges);
    title("Difference between hind leg deviation for both hind legs (Directional)")
    nexttile
    histogram(abs(distalDeviationDiff), deviationEdgesAbs);
    title("Difference between hind leg deviation for both hind legs (Absolute)")
end
if TF(8) == 1
    figure
    tiledlayout("horizontal")
    nexttile
    histogram(distalDeviationLeft, deviationEdges);
    title("Hind left leg x-axis deviation")
    xlabel("Distance (pixels)")
    nexttile
    histogram(distalDeviationRight, deviationEdges);
    title("Hind right leg x-axis deviation")
    xlabel("Distance (pixels)")
end

disp('Finished analysis!')


function outputData = getAnalysisData(dlcClean, vidRes)
    % Perform calculations to get the desired data to compare
    axisAngle = getCalculations(dlcClean, vidRes, 'axisAngle');
    WBA = getCalculations(dlcClean, vidRes, 'WBA', axisAngle);
    wbaDifference = abs(WBA(:, 1)  - WBA(:, 2));
    % Get vectors and angle info for both hind legs
    hindCalcs = getCalculations(dlcClean, vidRes, 'hindlegVectors', axisAngle);
    % Get vectors and angle calculations for both front legs
    frontCalcs = getCalculations(dlcClean, vidRes, 'frontlegVectors', axisAngle);
    % % Uncomment this to plot WBA stuff
    % outputData.wbaAll = wbaDifference;
    % % Uncomment this to plot ruddering stuff (hingeKneeAngleDiff)
    % outputData.hingeKneeAngleDiff = abs(abs(hindCalcs(:, 1,3)) - abs(hindCalcs(:, 2,3)));
    % % Uncomment this to plot ruddering stuff (hindInteriorKneeAngleDiff)
    % outputData.hindInteriorKneeAngleDiff = abs(abs(hindCalcs(:, 1, 4)) - abs(hindCalcs(:, 2, 4)));
    % % Uncomment this to plot ruddering stuff (hindHingeKneeVectors)
    % outputData.distalHindLengthRight = abs(hindCalcs(:, 1, 2));
    % outputData.distalHindLengthLeft = abs(hindCalcs(:, 2, 2));
    % Uncomment this to plot starfish stuff (Front leg vector length)
    outputData.frontVectorRight = abs(frontCalcs(:, 1, 1));
    outputData.frontVectorLeft = abs(frontCalcs(:, 2, 1));
    % % Uncomment this to plot whole hind angle difference
    % outputData.wholeHindAngleDiff = abs(abs(hindCalcs(:, 1, 5)) - abs(hindCalcs(:, 2, 5)));
    % % Uncomment this to plot difference between x-axis deviation from
    % % distal hind to proximal hind 
    % outputData.distalDeviationDiff = hindCalcs(:, 1, 6) + hindCalcs(:, 2, 6);
    % % Uncomment this to plot whole hind angle difference
    % outputData.distalDeviationRight = hindCalcs(:, 1, 6);
    % outputData.distalDeviationLeft  = hindCalcs(:, 2, 6);
end
