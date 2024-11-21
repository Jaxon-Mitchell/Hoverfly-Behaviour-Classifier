% This script is used to visualise animal behaviour based on user defined
% communities in a time series

% Get user to select .csv containing VAME motif timeseries
[file,location] = uigetfile('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/*.csv', 'Select your behaviour .csv');

% Cancel if no file selected
if isequal(file,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(location,file)]);
end

% Write in the behaviour to show the occurrence of, select from:
% Behavioural guide:
% 1  - Undefined
% 2  - Flying straight
% 3  - Turning
% 4  - Straight rudder
% 5  - Turning rudder
% 6  - Starfish
% 7  - Turning starfish
behaviourToFind = [4, 5];

% Read your analysis file
temp = readcell([location file]);
% Get only the useful parts
analysis = temp(1:end,2);
clear temp

%% Plot our community data over time
% What is our framerate (To convert x-axis into seconds)
frameRate = 100;
% Initialise important values for the first frame
startFrame = 0;
prevResult = any(analysis{1} == behaviourToFind);
% Start a new figure window
commPlot = figure;
hold on
% Loop over all frames and draw a plot to show community over time
for frame = 1:size(analysis, 1)
    currentResult = any(analysis{frame} == behaviourToFind);
    if currentResult ~= prevResult
        endFrame = frame;
        startTime = startFrame / frameRate;
        endTime = endFrame / frameRate;
        x = [startTime endTime endTime startTime];
        y = [0 0 1 1];
        switch prevResult
            case 0 % Is a behaviour other than our desired one
                colour = [1 1 1];
                patch(x, y, colour, 'EdgeColor', 'none');
            case 1 % Matches our desired behaviour
                colour = [0 0.4470 0.7410];
                patch(x, y, colour, 'EdgeColor', 'none');
        end
        startFrame = frame;
    end
    prevResult = any(analysis{frame} == behaviourToFind);
end
xlabel('Experiment time (s)'); 
xlim([0 (size(analysis, 1) / frameRate)])
set(gca,'ytick',[])
% Get handle to current axes.
ax = gca;
ax.YColor = 'k';
ax.XColor = 'k';
set(gca, 'Layer', 'top')
box on
hold off






