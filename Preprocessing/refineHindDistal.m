% This script is used to fix a major issue with the DLC labelling for
% distal hind leg points, as they constantly jump around the screen
% irrespective of where the distal point actually is.

% We fix this using 2 steps:
% 1) Define an 'illegal border' where the labelled points cannot feasibly
%    go to during regular flight, all points that enter this region are
%    called 'illegal' frames.
% 2) for all 'illegal' frames, interpolate between legal frames to create
%    smooth transitions between what we should and should not be able to
%    see.

filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder containing all DLC analysis');
outputPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/', 'Select folder to save your refined DLC analysis to');

% Cancel if no file selected
if any([filePath == 0, outputPath == 0])
   disp('User selected cancel');
   return
end

% Double check video resolution as it's important for our angle
% calculations
vidRes = inputdlg({'Enter video width:', 'Enter video height:'}, ...
    'Video Resolution', [1 45], {'320', '240'});

% Search the folder for any csv's
dlcFiles = dir([filePath '/*.csv']);
dlcFiles = {dlcFiles.name};
% Remove already existing behaviour analysis from the list
existing = find(contains(dlcFiles, ["_questionableBehaviour.csv", "_behaviourAnalysis.csv"]));
for i = length(existing):-1:1
    dlcFiles(existing(i)) = [];
end

for file = 1:length(dlcFiles)
    % Load the .csv file as a cell array
    dlcBehaviour = readcell([filePath '/' dlcFiles{file}]);
    % Make a 2 column matrix representing illegal movements for left (1)
    % and right (2) legs
    isIllegal = zeros(2, size(dlcBehaviour, 1) - 3);
    % For every frame, determine which hind positions are illegal
    for frame = 4:size(dlcBehaviour, 1)
        % The y-position for the distal point cannot be greater than the
        % y-position of the knee point.
        if dlcBehaviour{frame, 75} < dlcBehaviour{frame, 72} % left leg
            isIllegal(1, frame - 3) = 1;
        end
        if dlcBehaviour{frame, 63} < dlcBehaviour{frame, 60} % right leg 
            isIllegal(2, frame - 3) = 1;
        end
        % The x-position of the distal point cannot cross past the
        % x-position of the lower abdomen
        if dlcBehaviour{frame, 74} > dlcBehaviour{frame, 17} % left leg
            isIllegal(1, frame - 3) = 1;
        end
        if dlcBehaviour{frame, 62} < dlcBehaviour{frame, 17} % right leg 
            isIllegal(2, frame - 3) = 1;
        end
    end
    % Once done, go back and interpolate across legal position for illegal
    % frames, start with the left leg
    dlcBehaviour = interpolateOverPoints(dlcBehaviour, 74, 75, isIllegal(1, :));
    % Run it again for the right leg
    dlcBehaviour = interpolateOverPoints(dlcBehaviour, 62, 63, isIllegal(2, :));

    % Save the behavioural analysis as a .csv file (not overriding the old one!)
    fileName = strsplit(dlcFiles{file}, '.csv');
    fileName = [fileName{1} '_interpolated.csv'];
    writecell(dlcBehaviour, [outputPath '/' fileName])
end

function dlcFile = interpolateOverPoints(dlcFile, xPos, yPos, isIllegal)
    % Frame starts at four as we need to ignore the first 3 rows of a DLC file
    frame = 4;
    % If the first frame is illegal, we can't fix things until we get a
    % legal frame.
    if isIllegal(1) == 1
        while isIllegal(frame - 3) == 1
            frame = frame + 1;
        end
    end
    endFile = 0;
    while frame <= size(dlcFile, 1)
        if isIllegal(frame - 3) == 1
            blockStart = frame - 1;
            while isIllegal(frame - 3) == 1
                frame = frame + 1;
                % If the block reaches the end of the file, stop (Jaxon to double check this)
                if frame == size(dlcFile, 1)
                    endFile = 1;
                    break
                end
            end
            % Break out of the main for loop if at end of file
            if endFile == 1
                break
            end
            blockEnd = frame;
            framesToInterpolate = blockEnd - blockStart - 1;
            % Get x and y coordinates (respectively) of the starting
            % position
            x1 = dlcFile{blockStart, xPos};
            y1 = dlcFile{blockStart, yPos};
            % Do the same for the end position
            x2 = dlcFile{blockEnd, xPos};
            y2 = dlcFile{blockEnd, yPos};
            xDiff = x2 - x1;
            yDiff = y2 - y1;
            for illegalFrame = 1:framesToInterpolate
                % Start with x-coord
                dlcFile{blockStart + illegalFrame, xPos} = dlcFile{blockStart, xPos} + ((xDiff / (framesToInterpolate + 1)) * illegalFrame);
                % Then do y-coord
                dlcFile{blockStart + illegalFrame, yPos} = dlcFile{blockStart, yPos} + ((yDiff / (framesToInterpolate + 1)) * illegalFrame);
            end
        end
        frame = frame + 1;
    end
end
