% This function will open and loop through all dlc files relating to
% hoverfly experiment videos and do a behavioural analysis on each

% Start by getting the users folder for storing .csv's
filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/2TB Storage/Saved Data/', 'Select folder containing all DLC .csv''s');
% Get all video DLC analysis names in an array
analyses = dir([filePath '/*.csv']);
analyses = {analyses(1:end).name};

% Loop over every analysis file in the folder
for analysis = 1:length(analyses)
    % Print a status message so the user knows what's going on internally
    message = sprintf('Analysing experiment %d out of %d\n',analysis, size(analyses, 1));
    disp(message);

    % Returns matrix of all behaviours
    behaviours = classifyBehaviours([filePath analyses(analysis)]);
    % Save the behavioural analysis as a .csv file (not overriding the old one!)
    fileName = strsplit(analyses(analysis), '.csv');
    fileName = [fileName{1} '_behaviourAnalysis.csv'];
    writeMatrix(behaviours, [filePath '/' fileName])

    % Clear analysis video message for a clean command window 
    for character = 1 : length(message) + 1
        fprintf('\b')
    end
end

disp('Finished analysis!')