% This script is used to merge all DLC models from a single video into one
% .csv file, so it can be used for vame
inputFolderPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/Saved Data/', 'Select folder containing all experiments');

if inputFolderPath == 0
    disp('Cancelled by user')
    return
end
% List of all folders (experiments)
experimentDayList = dir(inputFolderPath);
% What kind of experiments are we merging? (Uncomment your choice)
% experimentType = 'REVideo';
experimentType = 'REvideo_Nonflying';

% Ignore first two entries '.' and '..' and loop through all folders
for folder = 3:length(experimentDayList)
    experimentDay = experimentDayList(folder).name;
    % Get fly number
    flyNo = dir(fullfile([inputFolderPath '/' experimentDay]));
    % Get pathway to videos and .csv's
    currentFolderPath = [inputFolderPath '/' experimentDay '/' flyNo(3).name '/' experimentType];

    % List of all videos
    videoFileList = dir(fullfile([currentFolderPath, '/*.mp4']));
    % List of all DLC analysis
    csvFileList = dir(fullfile([currentFolderPath, '/*.csv']));

    % If we don't find any videos in a non-flying folder, double check if non-flying was stored elsewhere
    if isempty(videoFileList)
        extraTypes = {'REvideo', 'REVideo'};
        % Loop over other video folder types to find our data
        for i = 1:length(extraTypes)
            currentFolderPath = [inputFolderPath '/' experimentDay '/' flyNo(3).name '/' extraTypes{i}];
            videoFileList = dir(fullfile([currentFolderPath, '/*.mp4']));
            csvFileList = dir(fullfile([currentFolderPath, '/*.csv']));
            csvFileTest = {csvFileList(1:end).name};
            if strcmpi(experimentType, 'REVideo')
                % Double check the folder to see if this is a non-flying dataset
                nameTest = regexp(csvFileTest, 'NonFlying', 'ignorecase'); %#ok<UNRCH>
                wrongFolder = false;
                for j = 1:length(csvFileTest)
                    if ~isempty(nameTest{j})
                        wrongFolder = true;
                        break
                    end
                end
            else
                % If we're looking for non-flying data, check if its there
                nameTest = regexp(csvFileTest, 'NonFlying', 'ignorecase');
                wrongFolder = true;
                for j = 1:length(csvFileTest)
                    if ~isempty(nameTest{j})
                        wrongFolder = false;
                        break
                    end
                end
            end
            % If it turns out to be the correct folder, escape this nightmare
            if wrongFolder == false
                break
            end
        end
    end

    % If we cannot find a match for the files we need, check next folder
    if wrongFolder == true
        continue
    end
   
    clear csvFileTest

    % Print a status message so the user knows what's going on internally
    folderMessage = sprintf('Merging csv''s for folder %d out of %d\n', (folder - 2), (length(experimentDayList) - 2));
    disp(folderMessage);
    
    % Loop through each video so we can combine alike .csv's
    for video = 1:length(videoFileList)
        % Get video name on its own
        videoName = videoFileList(video).name;
        videoName = strsplit(videoName, '.mp4');
        videoName = videoName{1};

        % Ignore labelled DLC videos as we don't need them
        if ~isempty(regexp(videoName, 'labeled', 'ignorecase'))
            continue
        end

        % Ignore hidden videos as they cause issues
        if videoName(1) == '.'
            continue
        end
    
        % Print a status message so the user knows what's going on internally
        message = sprintf('Combining analysis %d out of %d\n',video, length(videoFileList));
        disp(message);
    
        % Find all files within the folder
        TempCSVFiles = ["", "", "", ""];
        
        count = 1;
        % Search through each csv file in the directory
        for j = 1:size(csvFileList)
            % If the file contains the name of the video (a convention followed by DLC)
            if not(isempty(strfind(csvFileList(j).name,[videoName, 'DLC']))) && csvFileList(j).name(1) ~= '.'
                TempCSVFiles(count) = strcat(videoFileList(video).folder,'/',csvFileList(j).name);
                count = count + 1;
            end
            if count == 7
                break
            end
        end
    
        % Loop through the model list so we can combine our .csv's in a
        % specific order consistently
        modelList = ["Wings", "Head", "NonFlying_FrontLegs", "NonFlying_HindLegs"];
        for i = 1:length(modelList)
            % Find what csv matches our model
            nameTest = regexp(TempCSVFiles, modelList(i), 'ignorecase');
            for j = 1:length(TempCSVFiles)
                if ~isempty(nameTest{j})
                    fileIndex = j;
                    break
                end
            end

            if i == 1
                combined = readcell(TempCSVFiles(fileIndex));
            else
                temp = readcell(TempCSVFiles(fileIndex));
                combined = [combined, temp(1:size(temp,1),2:size(temp,2))]; %#ok<AGROW>
            end
        end
        % Write the cell to a CSV file
        writecell(combined, [currentFolderPath '/' videoName '.csv'])

        clear combined fileIndex

        % Clear analysis video message for a clean command window 
        for character = 1 : length(message) + 1
            fprintf('\b')
        end
    end
    % Delete folder message
    for character = 1 : length(folderMessage) + 1
        fprintf('\b')
    end
end
disp("Done!")
