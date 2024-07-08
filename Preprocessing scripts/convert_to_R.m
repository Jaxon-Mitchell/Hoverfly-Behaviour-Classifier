% Small script that converts your DLC data from FlyFly to a .csv file
% suitable for the R scripts in this repo.
% Opens a window asking for the folder to your DLC data, and will 
% handle the rest, include adding data headers, normalising data, 
% and adding new calculations. 

function convert_to_R()
    %Set constants
    FileType = '.mat';                  % Used to identify data files
    MaximumSubFolderDepth = 8;          % Safety to stop this script grabbing too many data files
    MaximumFolderCount = 500;           % Safety to stop this script grabbing too many data files

    % Ask user to locate the inputFolderPath where the data they wish to convert should be located
    inputFolderPath = uigetdir('/home/', 'Location of data to convert');

    % Ask user where to save output files
    outputFolderPath = uigetdir('/home/', 'Location to store converted data');

    % Check to make sure the file path is valid before continuing
    if(length(inputFolderPath) <= 1)
        disp('Chosen file path is invalid');
        return;
    end

    Temp = strsplit(inputFolderPath,'/');

    % Add only the Initial Directory to list
    DirectoryList = dir(fullfile(inputFolderPath));
    DirectoryList = DirectoryList(2);
    DirectoryList(1).name = Temp{end};
    DirectoryList(1).filepath = inputFolderPath;
    
    % Set initial DirectoryCount
    PrevDirectoryCount = 0;
    
    % Find all valid Folders upto the MaximumSubFolderDepth
    for i = 1:MaximumSubFolderDepth
        
        % Set NewDirectoryCount which is the current number of valid Directories
        NewDirectoryCount = size(DirectoryList,1);
        
        % Safety check to make sure we don't accidently add every folder on the system by selecting a folder that is too high up the hierarchy.
        if(NewDirectoryCount > MaximumFolderCount)
            warning('Warning - Tried to search %i folders when the Maximum is %i. If you selected the right folder, remove this check or increase MaximumFolderCount',NewDirectoryCount,MaximumFolderCount);
            return;
        end
        
        % For each of the new directories we have not already searched
        for j = PrevDirectoryCount+1:NewDirectoryCount
            % Locate valid directories within the provided folder and add them to the DirectoryList.
            DirectoryList = [DirectoryList;FindSubFolders(DirectoryList(j).filepath,0)]; %#ok<AGROW>, supressed as we don't know full depth of subfolders until we check
        end
        
        % Update PrevDirectoryCount so we know which folders have been searched.
        PrevDirectoryCount = NewDirectoryCount;  
        % Move on to next loop in order to search the new folders that were added this loop
    end
    
    app.analysisProgressLabel.Text = sprintf('Total number of directories being searched is %i\n',size(DirectoryList,1));
    app.analysisProgressLabel.Visible = "on";
    
    % Search each folder and locate all valid data files.
    % For each valid folder provided
    for i = 1:size(DirectoryList)
        % Find all files within the folder
        TempFileList = dir(fullfile(DirectoryList(i).filepath));
        % For each file remembering to skip the first two as they are '.' and '..'
        for j = 3:size(TempFileList)
            % If the filename contains .mat
            if not(isempty(strfind(TempFileList(j).name,FileType)))
                % Add folderpath to structure
                TempFileList(j).folderpath = DirectoryList(i).filepath;
                
                % Add filepath to structure
                TempFileList(j).filepath = strcat(DirectoryList(i).filepath,'/',TempFileList(j).name);
                
                % Add to VideoList
                fileList = [fileList;TempFileList(j)]; %#ok<AGROW>, supressed as we don't know all files until we search list
            end
        end
    end
    
    app.analysisProgressLabel.Text = sprintf('Total number of data files being processed is %i\n',size(fileList,1));
    
    if size(fileList) < 1
        warning('Warning - There are no files to analyse!! D:');
        return;
    end
    
    app.analysisProgressLabel.Text = sprintf('0 out of %i files have been converted\n', (size(fileList,1)));
    
    % Loop through all .mat files to run calculations and package
    for i = 1:size(fileList) 
        tempFilePath = fileList(i).filepath;
        [data, fileName] = calculate_velocities(tempFilePath);
        savePath = strcat(outputFolderPath, fileName);
        convert_to_csv(data, savePath);

        disp('---------');
        fprintf('%i out of %i files have been converted\n',i,(size(fileList,1)));
        disp('---------');
    end
end