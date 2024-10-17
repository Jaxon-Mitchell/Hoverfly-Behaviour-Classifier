% Requires ffmpeg, this script will create videos based on the results of
% behaviourFinder.m and organise them into categories for analysis

% If FFMPEG doesn't work on Ubuntu, launch matlab using this command:
% LD_PRELOAD=/lib/x86_64-linux-gnu/libstdc++.so.6 matlab

%% Define variables

% Array of all behaviours we expect to see, in ordered number
behaviours = [
    'No Behaviour', ...
    'Ruddering'];

filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/2TB Storage/Saved Data/', 'Select folder containing all behaviour analysis AND videos');
outputPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/2TB Storage/Saved Data/', 'Select folder to save your output videos to');

% Get all video DLC analysis names in an array
analyses = dir([filePath '/*_behaviourAnalysis.csv']);
analyses = {analyses(1:end).name};

% Loop through each experiment to grab out the relevant parts
for analysis = 1:length(analyses)
    % Get the name of the current experiment
    experimentName = strsplit(analyses{analysis}, '_behaviourAnalysis.csv');
    experimentName = experimentName{1};
    % Read data from the current experiment
    behaviourAnalysis = readmatrix([filePath '/' analysis]);
    behaviourAnalysis = behaviourAnalysis(2, :);
    uniqueBehaviours = unique(behaviours);
    % Get the name of the video to trim
    analysisVideo = strrep(analysis, '_behaviourAnalysis.csv', '.mp4');
    analysisVideo = [filePath '/' analysisVideo]; %#ok<AGROW> is reset each loop sequence
    % Loop through each behaviour found in the experiment and generate videos
    for behaviour = 1:length(uniqueBehaviours)
        generateBehaviourVid(behaviourAnalysis, behaviour, behaviours, analysisVideo, outputPath, experimentName)
    end
end


% Generates the example videos for a particular behaviour
function generateBehaviourVid(behaviourAnalysis, behaviour, behaviours, analysisVideo, outputPath, experimentName)
    inBlock = false;
    currentBlock = 1;
    % This loop generates a videoBlock(n,2) matrix where n is the amount of
    % behavioural blocks found in the experiment and the 2 columns
    % represent the start frame and end frame of the block
    for frame = 1:length(behaviourAnalysis)
        % Is this code terrible? Yes. Do I care? No
        if behaviourAnalysis(frame) == behaviour && inBlock == false
            videoBlock(currentBlock,1) = frame; %#ok<AGROW> We can't pre-allocate as we don't know the number of blocks prior
            inBlock = true;
        elseif behaviourAnalysis(frame) == behaviour && inBlock == true
            continue
        end
        if behaviourAnalysis(frame) ~= behaviour && inBlock == false
            continue
        elseif behaviourAnalysis(frame) ~= behaviour && inBlock == true
            videoBlock(currentBlock,2) = frame; %#ok<AGROW>
            currentBlock = currentBlock + 1;
        end
    end

    % If current behaviour ends on the last frame of the experiment, do this
    if inBlock == true
        videoBlock(currentBlock,2) = length(behaviourAnalysis);
    end

    if size(videoBlock, 1) == 1
        % If there is one data block, save as the final output
        % ffmpeg -i input.mp4 -vf trim=start_frame=I:end_frame=O+1 -an output.mp4
        startFrame = num2str(videoBlock(1,1));
        endFrame = num2str(videoBlock(1,2));
        outputVideo = [outputPath '/' experimentName '_' behaviours(behaviour) '.mp4'];
        command = ['ffmpeg -i ' analysisVideo ' -vf trim=' startFrame '=I:' endFrame '=O+1 -an ' outputVideo];
        system(command)
    else
        % If there is more than one data block, trim each example and combine
        % them into the final output

        % Initialise file for merging all blocks together
        fid = fopen([outputPath '/videos.txt'], 'wt');
        for block = 1:size(videoBlock, 1)
            startFrame = num2str(videoBlock(block,1));
            endFrame = num2str(videoBlock(block,2));
            outputVideo = [outputPath '/temp_' num2str(block) '.mp4'];
            command = ['ffmpeg -i ' analysisVideo ' -vf trim=' startFrame '=I:' endFrame '=O+1 -an ' outputVideo];
            system(command)
            fprintf(fid, 'file ''temp_%i.mp4''\n', block);
        end
        fclose(fid);
        % Concatenate all the videos of a single experiment type using ffmpeg
        outputVideo = [outputPath '/' experimentName '_' behaviours(behaviour) '.mp4'];
        system(['ffmpeg -f concat -safe 0 -i ''' outputPath '/videos.txt'' -c copy ''' outputPath '/' outputVideo '''']);
        system(['rm ''' filePath '/videos.txt''']);
        % Clean up, and delete the temp files
        for block = 1:size(videoBlock, 1)
            delete([outputPath '/temp_' num2str(block) '.mp4'])
        end
    end
end
