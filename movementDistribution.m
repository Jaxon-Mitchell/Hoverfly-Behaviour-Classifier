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
    % Uncomment this to plot WBA stuff
    % if analysis == 1
    %     wbaAll = wbaDifference;
    % else
    %     wbaAll = [wbaAll; wbaDifference]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
    % end
    % Uncomment this to plot hind leg stuff
    if analysis == 1
        calcsToPlot1 = hindCalcs(:, 1, 2);
        calcsToPlot2 = hindCalcs(:, 2, 2);
    else
        calcsToPlot1 = [calcsToPlot1; hindCalcs(:, 1, 2)]; %#ok<AGROW> I could, but I'm lazy and don't wanna see the yellow
        calcsToPlot2 = [calcsToPlot2; hindCalcs(:, 2, 2)]; %#ok<AGROW>
    end
end

edges = 0:5:100;
figure
histogram(calcsToPlot1, edges);
figure
histogram(calcsToPlot2, edges);

disp('Finished analysis!')