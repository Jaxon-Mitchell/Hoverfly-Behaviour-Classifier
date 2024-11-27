% This script is designed to be able to show (in buckets) what the
% distribution is of any vector or calculation made with DLC variables, to
% check for a bimodal distribution or a rough spread.

% Start by getting the users files to compare
clear optionalFile % Do not delete this or things WILL break
[behaviourFile, behaviourPath] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select file containing your behaviour data');
[controlFile, controlPath] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select file containing your control data');
[optionalFile, optionalPath] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select file containing your 3rd set of comparison data');

% Cancel if no file selected
if any([isequal(behaviourFile,0), isequal(controlFile, 0)])
   disp('User selected cancel on main files needed');
   return
end
% Load the data
dlcBehaviour = readcell([behaviourPath behaviourFile]);
dlcControl = readcell([controlPath controlFile]);
if optionalFile ~= 0
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
if optionalFile ~= 0
    optionalClean = dlcOptional(4:end,2:end);
    optionalClean = cell2mat(optionalClean);
end

behaviourCalcs = getAnalysisData(behaviourClean, vidRes);
controlCalcs = getAnalysisData(controlClean, vidRes);
if optionalFile ~= 0
    optionalCalcs = getAnalysisData(optionalClean, vidRes);
end

field = {'wbaAll', 'hingeKneeAngleDiff', 'hindInteriorKneeAngleDiff', 'distalHindLengthRight',...
    'frontVectorRight', 'wholeHindAngleDiff', 'distalDeviationDiff', 'distalDeviationRight'};
TF = isfield(behaviourCalcs,field);

angleEdges = 0:0.5:180;
pixelEdges = 0:1:100;
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
    % First make a figure that shows the difference between left and right legs
    figure
    tiledlayout("horizontal")
    nexttile
    % Where control movement is happening
    histogram(controlCalcs.frontVectorLeft, pixelEdges, 'Normalization', 'percentage');
    hold on
    % Where behaviour is happening
    histogram(behaviourCalcs.frontVectorLeft, pixelEdges, 'Normalization', 'percentage');
    title("Front left leg vector length")
    if optionalFile ~= 0
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
    if optionalFile ~= 0
        histogram(optionalCalcs.frontVectorRight, pixelEdges, 'Normalization', 'percentage');
        legend(controlFile, behaviourFile, optionalFile)
    else
        legend(controlFile, behaviourFile)
    end
    xlabel("Vector Length (Pixels)")
    ylabel("Percentage (%)")
    % Do it again, but only using the longest vector (left) and average
    % vector length (right)
    figure
    tiledlayout("horizontal")
    nexttile
    % Where control movement is happening
    controlMax = max(controlCalcs.frontVectorRight, controlCalcs.frontVectorLeft);
    histogram(controlMax, pixelEdges, 'Normalization', 'percentage');
    hold on
    behaviourMax = max(behaviourCalcs.frontVectorRight, behaviourCalcs.frontVectorLeft);
    % Where behaviour is happening
    histogram(behaviourMax, pixelEdges, 'Normalization', 'percentage');
    title("Max Front Leg Vector")
    if optionalFile ~= 0
        optionalMax = max(optionalCalcs.frontVectorRight, optionalCalcs.frontVectorLeft);
        histogram(optionalMax, pixelEdges, 'Normalization', 'percentage');
        legend(controlFile, behaviourFile, optionalFile)
    else
        legend(controlFile, behaviourFile)
    end
    xlabel("Vector Length (Pixels)")
    ylabel("Percentage (%)")
    hold off
    nexttile
    % Where control movement is happening
    controlAv = (controlCalcs.frontVectorRight + controlCalcs.frontVectorLeft) / 2;
    histogram(controlAv, pixelEdges, 'Normalization', 'percentage');
    hold on
    % Where behaviour is happening
    behaviourAv = (behaviourCalcs.frontVectorRight + behaviourCalcs.frontVectorLeft) / 2;
    histogram(behaviourAv, pixelEdges, 'Normalization', 'percentage');
    title("Average front leg vector length")
    if optionalFile ~= 0
        optionalAv = (optionalCalcs.frontVectorRight + optionalCalcs.frontVectorLeft) / 2;
        histogram(optionalAv, pixelEdges, 'Normalization', 'percentage');
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
    histogram(controlCalcs.distalDeviationDiff, deviationEdges, 'Normalization', 'percentage');
    hold on
    histogram(behaviourCalcs.distalDeviationDiff, deviationEdges, 'Normalization', 'percentage');
    if optionalFile ~= 0
        histogram(optionalCalcs.distalDeviationDiff, deviationEdges, 'Normalization', 'percentage');
        legend(controlFile, behaviourFile, optionalFile)
    else
        legend(controlFile, behaviourFile)
    end
    title("Difference between hind leg deviation for both hind legs (Directional)")
    xlabel("Vector Length (Pixels)")
    ylabel("Percentage (%)")
    hold off
    nexttile
    histogram(abs(controlCalcs.distalDeviationDiff), deviationEdgesAbs, 'Normalization', 'percentage');
    hold on
    histogram(abs(behaviourCalcs.distalDeviationDiff), deviationEdgesAbs, 'Normalization', 'percentage');
    if optionalFile ~= 0
        histogram(abs(optionalCalcs.distalDeviationDiff), deviationEdgesAbs, 'Normalization', 'percentage');
        legend(controlFile, behaviourFile, optionalFile)
    else
        legend(controlFile, behaviourFile)
    end
    title("Difference between hind leg deviation for both hind legs (Absolute)")
    xlabel("Vector Length (Pixels)")
    ylabel("Percentage (%)")
    hold off
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
    % % Uncomment this to plot starfish stuff (Front leg vector length)
    % outputData.frontVectorRight = abs(frontCalcs(:, 1, 1));
    % outputData.frontVectorLeft = abs(frontCalcs(:, 2, 1));
    % % Uncomment this to plot whole hind angle difference
    % outputData.wholeHindAngleDiff = abs(abs(hindCalcs(:, 1, 5)) - abs(hindCalcs(:, 2, 5)));
    % Uncomment this to plot difference between x-axis deviation from
    % distal hind to proximal hind 
    outputData.distalDeviationDiff = hindCalcs(:, 1, 6) + hindCalcs(:, 2, 6);
    % % Uncomment this to plot whole hind angle difference
    % outputData.angleDeviationRight = hindCalcs(:, 1, 5);
    % outputData.angleDeviationLeft  = hindCalcs(:, 2, 5);
end
