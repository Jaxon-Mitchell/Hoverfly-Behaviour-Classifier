% This function will open and loop through all dlc files relating to
% hoverfly experiment videos and do a behavioural analysis on each

% Start by getting the users folder for storing .csv's
filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder containing all DLC .csv''s');
outputPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder to save your behaviour timeseries to');
if any([filePath == 0, outputPath == 0])
    disp("Cancelled by user")
    return
end

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
videoResolution = inputdlg({'Enter video width:', 'Enter video height:'}, ...
    'Video Resolution', [1 45], {'320', '240'});

% Loop over every analysis file in the folder
for analysis = 1:length(analyses)
    % Print a status message so the user knows what's going on internally
    message = sprintf('Analysing experiment %d out of %d', analysis, length(analyses));
    disp(message);

    % Returns matrix of all behaviours
    behaviours = classifyBehaviours([filePath '/' analyses{analysis}], videoResolution);
    % Save the behavioural analysis as a .csv file (not overriding the old one!)
    fileName = strsplit(analyses{analysis}, '.csv');
    fileName = [fileName{1} '_behaviourAnalysis.csv'];
    writematrix(behaviours, [outputPath '/' fileName])

    % Clear analysis video message for a clean command window 
    for character = 1 : length(message) + 1
        fprintf('\b')
    end
end

disp('Finished analysis!')
