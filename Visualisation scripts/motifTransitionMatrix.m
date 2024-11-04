% This script is meant to develop a transition matrix between all motifs
% found using my behavioural algorithm

% We want to do this over multiple videos, so get user to select the folder
% containing all behaviour results, so the script can loop over each folder

inputFolder = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select your folder containing behavioural .csv''s');

% Define frame rate
frameRate = 100;

% First, we load our data as an array
motifData = readmatrix([location file]);
% Select all rows after the first (which is empty)
motifData = motifData(2:end, :);
% In Vame, motifs are indexed from 0 onwards, whilst in Matlab, indexing
% starts at one, add 1 to the motifs to make consistent with Matlab indexing
motifData(:,2) = motifData(:, 2) + 1;

% Search through the whole array to find what the biggest motif number is,
% noting that for n motifs they are indexed from 0 to n-1
totalMotifs = 0;
for i = 1:size(motifData, 1)
    currentMotif = motifData(i,2);
    if currentMotif > totalMotifs
        totalMotifs = currentMotif;
    end
end

% Then, we want to define a nxn array, where n represents the number of
% motifs we have. The rows represent the motifs, and the columns represent
% the motif that has been transitioned to afterwards
transitionMatrix = zeros(totalMotifs);

% Init all of our timing info arrays with a dummy time of 0 seconds
for motif = 1:totalMotifs
    motifTiming.("motif" + num2str(motif)) = 0;
end

% Init the first motif in the sequence
currentMotif = motifData(1,2);
motifStartFrame = 1;

% Enter a for loop across all the data to find transitions between motifs
for frame = 1:size(motifData, 1)
    motif = motifData(frame, 2);
    % Check if the motif has changed from the current one we're in
    if motif ~= currentMotif
        % Mark down what frame we have changed at
        motifEndFrame = frame;
        % Determine, in seconds, how long the motif lasted for
        motifTime = (motifEndFrame - motifStartFrame) / frameRate;
        motifTiming.("motif" + num2str(currentMotif))(end+1) = motifTime;
        % Add change onto the transition matrix
        transitionMatrix(currentMotif, motif) = transitionMatrix(currentMotif, motif) + 1;
        % Update what the current motif is
        currentMotif = motif;
        motifStartFrame = frame;
    end
end

% Do timing calculations for the last motif of the experiment
motifEndFrame = motifData(end, 1);
motifTime = (motifEndFrame - motifStartFrame) / frameRate;
motifTiming.("motif" + num2str(currentMotif))(end+1) = motifTime;

% Remove the dummy time from all motif time arrays
for motif = 1:totalMotifs
    motifTiming.("motif" + num2str(motif)) = motifTiming.("motif" + num2str(motif))(2:end);
end

% Normalise the transition matrix relative to the amount of transitions
% made for each motif
transitionMatrixNormalised = zeros(totalMotifs);
for motif = 1:totalMotifs
    transitions = sum(transitionMatrix(motif,:));
    transitionMatrixNormalised(motif, :) = transitionMatrix(motif, :) / transitions; 
end

% Plot our brand new transition matrices onto some figures!
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
xData = motifTiming.motif1';
groupData = ones(size(motifTiming.motif1'));
% Then loop over all motifs and do the same (Note how we use a transposed
% matrix to put it into a format that boxplot() doesn't complain about)
for motif = 2:totalMotifs
    xData = [xData; motifTiming.("motif" + num2str(motif))']; %#ok<AGROW> Supressing as it's too annoying to fix rn >:(
    groupData = [groupData; motif.*ones(size(motifTiming.("motif" + num2str(motif))'))]; %#ok<AGROW>
end

figure
boxplot(xData, groupData);
ylim([0 (max(xData) + 1)]);

