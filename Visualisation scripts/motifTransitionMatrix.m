% This script is meant to develop a transition matrix between all motifs
% found using my behavioural algorithm

% We want to do this over multiple videos, so get user to select the folder
% containing all behaviour results, so the script can loop over each folder

inputFolder = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select your folder containing behavioural .csv''s');

csvList = dir(fullfile(inputFolder, '*.csv'));
csvList = {csvList.name};

fileType = '_behaviourAnalysis';
csvIndex = find(cell2mat(regexp(csvList, fileType)));
csvList = csvList(csvIndex);
totalExperiments = length(csvList);

% Define frame rate
frameRate = 100;

% First, we load the first behavioural .csv to initialise files
behaviourData = readmatrix([inputFolder '/' csvList{1}]);

% Get user defined community groupings 
behaviours = [
    "Not flying", "Flying Straight", "Turning", "Straight Ruddering", ...
    "Turning Ruddering", "Superman", "Starfish", "Turning Starfish"];
totalBehaviours = length(behaviours);

% Then, we want to define a nxn array, where n represents the number of
% behaviours we have. The rows represent the behaviours, and the columns 
% represent the behaviour that has been transitioned to afterwards
transitionMatrix = zeros(totalBehaviours);

% Init all of our timing info arrays with a dummy time of 0 seconds
for behaviour = 1:totalBehaviours
    behaviourTiming.("behaviour" + num2str(behaviour)) = 0;
end

% Init the first motif in the sequence
currentBehaviour = behaviourData(1,2);
behaviourStartFrame = 1;

for experiment = 1:totalExperiments
    behaviourData = readmatrix([inputFolder '/' csvList{experiment}]);
    % Init the first motif in the sequence
    currentBehaviour = behaviourData(1,2);
    behaviourStartFrame = 1;
    % Enter a for loop across all the data to find transitions between motifs
    for frame = 2:size(behaviourData, 1)
        behaviour = behaviourData(frame, 2);
        % Check if the motif has changed from the current one we're in
        if behaviour ~= currentBehaviour
            % Mark down what frame we have changed at
            behaviourEndFrame = frame;
            % Determine, in seconds, how long the motif lasted for
            behaviourTime = (behaviourEndFrame - behaviourStartFrame) / frameRate;
            behaviourTiming.("behaviour" + num2str(currentBehaviour))(end+1) = behaviourTime;
            % Add change onto the transition matrix
            transitionMatrix(currentBehaviour, behaviour) = transitionMatrix(currentBehaviour, behaviour) + 1;
            % Update what the current motif is
            currentBehaviour = behaviour;
            behaviourStartFrame = frame;
        end
    end
    
    % Do timing calculations for the last motif of the experiment
    behaviourEndFrame = behaviourData(end, 1);
    behaviourTime = (behaviourEndFrame - behaviourStartFrame) / frameRate;
    behaviourTiming.("behaviour" + num2str(currentBehaviour))(end+1) = behaviourTime;
end

% Normalise the transition matrix relative to the amount of transitions
% made for each motif
transitionMatrixNormalised = zeros(totalBehaviours);
for behaviour = 1:totalBehaviours
    transitions = sum(transitionMatrix(behaviour,:));
    transitionMatrixNormalised(behaviour, :) = transitionMatrix(behaviour, :) / transitions; 
end

% Remove the dummy time from all motif time arrays
for behaviour = 1:totalBehaviours
    behaviourTiming.("behaviour" + num2str(behaviour)) = behaviourTiming.("behaviour" + num2str(behaviour))(2:end);
end

% Plot our brand new transition matrices onto some figures`!
figure
transition = heatmap(transitionMatrix);
figure
transitionNormalised = heatmap(transitionMatrixNormalised);
figure;
% Create a markov chain model
mc = dtmc(transitionMatrixNormalised);
graphplot(mc,ColorEdges=true);

% Plot the timing data onto some boxplots too! :D
% Start by inititalising our timing data and grouping information
xData = behaviourTiming.behaviour1';
groupData = ones(size(behaviourTiming.behaviour1'));
% Then loop over all motifs and do the same (Note how we use a transposed
% matrix to put it into a format that boxplot() doesn't complain about)
for behaviour = 2:totalBehaviours
    xData = [xData; behaviourTiming.("behaviour" + num2str(behaviour))']; %#ok<AGROW> Supressing as it's too annoying to fix rn >:(
    groupData = [groupData; behaviour.*ones(size(behaviourTiming.("behaviour" + num2str(behaviour))'))]; %#ok<AGROW>
end

figure
boxplot(xData, groupData);
ylim([0 (max(xData) + 1)]);

for i = 1:totalBehaviours
    figure
    edges = 0:0.2:5;
    h = histogram(behaviourTiming.("behaviour" + num2str(i)),edges);
end

