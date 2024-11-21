% This script is designed to be able to show (in buckets) what the
% distribution is of any vector or calculation made with DLC variables, to
% check for a bimodal distribution or a rough spread.

% Start by getting the users folder for storing .csv's
filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder containing all DLC .csv''s');
% Get all video DLC analysis names in an array
analyses = dir([filePath '/*.csv']);
analyses = {analyses(1:end).name};

% Remove already existing behaviour analysis from the list
existing = find(contains(analyses, "_behaviourAnalysis.csv"));
for i = length(existing):-1:1
    analyses(existing(i)) = [];
end

% Double check video resolution as it's important for our angle
% calculations
vidRes = inputdlg({'Enter video width:', 'Enter video height:'}, ...
    'Video Resolution', [1 45], {'320', '240'});

% Loop over every analysis file in the folder
for analysis = 1:length(analyses)
    % Load the DLC analysis file to obtain x-y positions of all labels
    dlcAnalysis = readcell([filePath '/' analyses{analysis}]);
    % Get the analysis into a format more easy for Matlab to handle
    dlcClean = dlcAnalysis(4:end,2:end);
    dlcClean = cell2mat(dlcClean);
    % Currently, we want to check the difference in WBA between wings
    axisAngle = getCalculations(dlcClean, vidRes, 'axisAngle');
    WBA = getCalculations(dlcClean, vidRes, 'WBA', axisAngle);
    wbaDifference = abs(WBA(:, 1)  - WBA(:, 2));
    % Get vectors and angle info for both hind legs
    hindCalcs = getCalculations(dlcClean, vidRes, 'hindlegVectors', axisAngle);
    % Get vectors and angle calculations for both front legs
    frontCalcs = getCalculations(dlcClean, vidRes, 'frontlegVectors', axisAngle);
    % % Uncomment this to plot WBA stuff
    % if analysis == 1
    %     wbaAll = wbaDifference;
    % else
    %     wbaAll = [wbaAll; wbaDifference]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % % Uncomment this to plot ruddering stuff (hingeKneeAngleDiff)
    % if analysis == 1
    %     hingeKneeAngleDiff = abs(abs(hindCalcs(:, 1,3)) - abs(hindCalcs(:, 2,3)));
    % else
    %     hingeKneeAngleDiff = [hingeKneeAngleDiff; abs(abs(hindCalcs(:, 1,3)) - abs(hindCalcs(:, 2,3)));]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % % Uncomment this to plot ruddering stuff (hindInteriorKneeAngleDiff)
    % if analys is == 1
    %     hindInteriorKneeAngleDiff = abs(abs(hindCalcs(:, 1, 4)) - abs(hindCalcs(:, 2, 4)));
    % else
    %     hindInteriorKneeAngleDiff = [hindInteriorKneeAngleDiff; abs(abs(hindCalcs(:, 1, 4)) - abs(hindCalcs(:, 2, 4)));]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % % Uncomment this to plot ruddering stuff (hindHingeKneeVectors)
    % if analysis == 1
    %     distalHindLengthRight = abs(hindCalcs(:, 1, 2));
    %     distalHindLengthLeft = abs(hindCalcs(:, 2, 2));
    % else
    %     distalHindLengthRight = [distalHindLengthRight; abs(hindCalcs(:, 1, 2))]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    %     distalHindLengthLeft = [distalHindLengthLeft; abs(hindCalcs(:, 2, 2))]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % % Uncomment this to plot starfish stuff (Front leg vector length)
    % if analysis == 1
    %     frontVectorRight = abs(frontCalcs(:, 1, 1));
    %     frontVectorLeft = abs(frontCalcs(:, 2, 1));
    % else
    %     frontVectorRight = [frontVectorRight; abs(frontCalcs(:, 1, 1))]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    %     frontVectorLeft = [frontVectorLeft; abs(frontCalcs(:, 2, 1))]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % % Uncomment this to plot whole hind angle difference
    % if analysis == 1
    %     wholeHindAngleDiff = abs(abs(hindCalcs(:, 1, 5)) - abs(hindCalcs(:, 2, 5)));
    % else
    %     wholeHindAngleDiff = [wholeHindAngleDiff; abs(abs(hindCalcs(:, 1, 5)) - abs(hindCalcs(:, 2, 5)));]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % Uncomment this to plot difference between x-axis deviation from
    % distal hind to proximal hind 
    if analysis == 1
        distalDeviationDiff = hindCalcs(:, 1, 6) + hindCalcs(:, 2, 6);
    else
        distalDeviationDiff = [distalDeviationDiff; hindCalcs(:, 1, 6) + hindCalcs(:, 2, 6)]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    end
    % Uncomment this to plot whole hind angle difference
    if analysis == 1
        distalDeviationRight = hindCalcs(:, 1, 6);
        distalDeviationLeft  = hindCalcs(:, 2, 6);
    else
        distalDeviationRight = [distalDeviationRight; hindCalcs(:, 1, 6)]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
        distalDeviationLeft = [distalDeviationLeft; hindCalcs(:, 2, 6)]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    end
end

angleEdges = 0:0.5:180;
pixelEdges = 0:1:150;
deviationEdges = -150:1:150;
deviationEdgesAbs = 0:1:150;
if exist('wbaAll', 'var')
    figure
    histogram(wbaAll, angleEdges);
    title("Wing Beat Amplitude Difference between L+R")
end
if exist('hingeKneeAngleDiff', 'var')
    figure
    histogram(hingeKneeAngleDiff, angleEdges);
    title("Difference between hinge-knee angle relative to the axis angle for both left and right hind leg")
end
if exist('hindInteriorKneeAngleDiff', 'var')
    figure
    histogram(hindInteriorKneeAngleDiff, angleEdges);
    title("Difference between L+R interior knee angle for hind legs")
end
if exist('distalHindLengthRight', 'var')
    figure
    tiledlayout("horizontal")
    nexttile
    histogram(distalHindLengthLeft, pixelEdges);
    title("Left Hind Knee-Distal Vector Length")
    nexttile
    histogram(distalHindLengthRight, pixelEdges);
    title("Right Hind Knee-Distal Vector Length")
end
if exist('frontVectorRight', 'var')
    figure
    tiledlayout("horizontal")
    nexttile
    histogram(frontVectorLeft, pixelEdges);
    title("Front left leg vector length")
    nexttile
    histogram(frontVectorRight, pixelEdges);
    title("Front right leg vector length")
end
if exist('wholeHindAngleDiff', 'var')
    figure
    histogram(wholeHindAngleDiff, angleEdges);
    title("Difference between whole leg to axis angle for both hind legs")
end
if exist('distalDeviationDiff', 'var')
    figure
    tiledlayout("horizontal")
    nexttile
    histogram(distalDeviationDiff, deviationEdges);
    title("Difference between hind leg deviation for both hind legs (Directional)")
    nexttile
    histogram(abs(distalDeviationDiff), deviationEdgesAbs);
    title("Difference between hind leg deviation for both hind legs (Absolute)")
end
if exist('distalDeviationRight', 'var')
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
