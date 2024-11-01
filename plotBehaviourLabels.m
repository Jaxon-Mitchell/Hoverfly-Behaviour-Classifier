% plotBehaviourLabels is a function meant to take the behaviour analysis
% done on Hoverfly behaviour and 
function plotBehaviourLabels()
% Define variables %
    % Array of all behaviours we expect to see, in ordered number
    behaviours = [
        "Not_flying", "Flying_Straight", "Turning", "Ruddering", "Superman"];
    % = true if you want to ignore behaviour stuff
    useWholeVid = true;
    
    filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder containing all behaviour analysis AND videos');
    outputPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder to save your output videos to');
    
    % Double check video resolution as it determines our figure window size
    videoResolution = inputdlg({'Enter video width:', 'Enter video height:'}, ...
        'Video Resolution', [1 45], {'320', '240'});
    
    % What labels do we want to show for the animation?
    inputStr = {'Show wing labels? y/n', 'Show head labels? y/n', ...
        'Show frontleg labels? y/n', 'Show hindleg labels? y/n'};
    inputDef = {'y', 'n', 'y', 'y'};
    boxSize = [1, 45; 1, 45; 1, 45; 1, 45];
    labelChoices = inputdlg(inputStr, ...
        'Chose calculations', boxSize, inputDef);
    
    % Get all video DLC analysis names in an array
    analyses = dir([filePath '/*_behaviourAnalysis.csv']);
    analyses = {analyses(1:end).name};
    
    % Loop through each experiment to grab out the relevant parts
    for analysis = 1:length(analyses)
        % Get the name of the current experiment
        experimentName = strsplit(analyses{analysis}, '_behaviourAnalysis.csv');
        experimentName = experimentName{1};
        % Read data from the current experiment
        behaviourAnalysis = readmatrix([filePath '/' analyses{analysis}]);
        behaviourAnalysis = behaviourAnalysis(:, 2);
        uniqueBehaviours = unique(behaviourAnalysis);
        % Get the name of the analysis to make a video from
        analysisCSV = strrep(analyses{analysis}, '_behaviourAnalysis', '');
        analysisCSV = [filePath '/' analysisCSV]; %#ok<AGROW> is reset each loop sequence
        % Load the DLC analysis file to obtain x-y positions of all labels
        dlcAnalysis = readcell(analysisCSV);
        % Get the analysis into a format more easy for Matlab to handle
        dlcClean = dlcAnalysis(4:end,2:end);
        dlcClean = cell2mat(dlcClean);
        % Loop through each behaviour found in the experiment and generate videos
        if useWholeVid == true
            % If we want a video without splitting up behaviours, call this
            % once and then continue
            outputName = [outputPath '/' experimentName '_labels.avi'];
            generateBehaviourVid(behaviourAnalysis, useWholeVid, dlcClean, outputName, labelChoices, videoResolution)
            continue
        end
        for behaviour = 1:length(uniqueBehaviours)
            outputName = [outputPath '/' experimentName '_' convertStringsToChars(behaviours(uniqueBehaviours(behaviour))) '.avi'];
            generateBehaviourVid(behaviourAnalysis, uniqueBehaviours(behaviour), dlcClean, outputName, labelChoices, videoResolution)
        end
    end
    disp("All done!")
end

% Generates the example videos for a particular behaviour
function generateBehaviourVid(behaviourAnalysis, behaviour, dlcClean, outputName, labelChoices, videoResolution)
    figure;
    xlim([0 str2double(videoResolution{1})])
    ylim([0 str2double(videoResolution{2})])

    yMax = str2double(videoResolution{2});
    
    counter = 1;
    
    % This loop generates a videoBlock(n,2) matrix where n is the amount of
    % behavioural blocks found in the experiment and the 2 columns
    % represent the start frame and end frame of the block
    for frame = 1:size(dlcClean, 1)
        % Is this code terrible? Yes. Do I care? No
        if behaviourAnalysis(frame) == behaviour || behaviour == true
            hold on
            % Plot wing labels
            if labelChoices{1} == 'y'
                plot(dlcClean(frame, 1) , yMax - dlcClean(frame, 2) , 'c.', 'MarkerSize', 40)
                plot(dlcClean(frame, 4) , yMax - dlcClean(frame, 5) , 'b.', 'MarkerSize', 40)
                plot(dlcClean(frame, 7) , yMax - dlcClean(frame, 8) , 'c.', 'MarkerSize', 40)
                plot(dlcClean(frame, 10), yMax - dlcClean(frame, 11), 'b.', 'MarkerSize', 40)
            end
            % Plot head labels
            if labelChoices{2} == 'y'

            end
            % Plot front leg labels
            if labelChoices{3} == 'y'
                plot(dlcClean(frame, 43), yMax - dlcClean(frame, 44), 'g.', 'MarkerSize', 40)
                plot(dlcClean(frame, 46), yMax - dlcClean(frame, 47), 'r.', 'MarkerSize', 40)
                plot(dlcClean(frame, 49), yMax - dlcClean(frame, 50), 'g.', 'MarkerSize', 40)
                plot(dlcClean(frame, 52), yMax - dlcClean(frame, 53), 'r.', 'MarkerSize', 40)
            end
            % Plot hind leg labels
            if labelChoices{4} == 'y'
                plot(dlcClean(frame, 55), yMax - dlcClean(frame, 56), 'g>', 'MarkerSize', 10)
                plot(dlcClean(frame, 58), yMax - dlcClean(frame, 59), 'b>', 'MarkerSize', 10)
                plot(dlcClean(frame, 61), yMax - dlcClean(frame, 62), 'r>', 'MarkerSize', 10)
                plot(dlcClean(frame, 67), yMax - dlcClean(frame, 68), 'g<', 'MarkerSize', 10)
                plot(dlcClean(frame, 70), yMax - dlcClean(frame, 71), 'b<', 'MarkerSize', 10)
                plot(dlcClean(frame, 73), yMax - dlcClean(frame, 74), 'r<', 'MarkerSize', 10)
            end
            xlim([0 str2double(videoResolution{1})])
            ylim([0 str2double(videoResolution{2})])
            title(['Frame: ' num2str(frame)])
            hold off
            drawnow
            frameData{counter} = getframe(gcf) ; %#ok<AGROW> This needs to be improved later
            counter = counter + 1;
            clf
        end
    end
    close(gcf)
    obj = VideoWriter(outputName);
    obj.Quality = 100;
    obj.FrameRate = 100;
    open(obj);
    for i = 1:length(frameData)
        writeVideo(obj, frameData{i}) ;
    end
    obj.close();
end