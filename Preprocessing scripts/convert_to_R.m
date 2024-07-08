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
    inputFolderPath = uigetdir('/home/birkwin/', 'Location of data to convert');

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
        
        % Safety Check to make sure we don't accidently add every folder on the system by selecting a folder that is too high up the hierarchy.
        if(NewDirectoryCount > MaximumFolderCount)
            warning('Warning - Tried to search %i folders when the Maximum is %i. If you selected the right folder, remove this check or increase MaximumFolderCount',NewDirectoryCount,MaximumFolderCount);
            return;
        end
        
        % For each of the new directories we have not already searched
        for j = PrevDirectoryCount+1:NewDirectoryCount
            % Locate valid directories within the provided folder and add them to the DirectoryList.
            DirectoryList = [DirectoryList;FindSubFolders(DirectoryList(j).filepath,0)];
        end
        
        % Update PrevDirectoryCount so we know which folders have been searched.
        PrevDirectoryCount = NewDirectoryCount;  
        % Move on to next loop in order to search the new folders that were added this loop
    end
    
    app.analysisProgressLabel.Text = sprintf('Total number of directories being searched is %i\n',size(DirectoryList,1));
    app.analysisProgressLabel.Visible = "on";
    
    %Search each folder and locate all valid video files.
    %For each valid folder provided
    for i = 1:size(DirectoryList)
        
        %Find all files within the folder
        TempFileList = dir(fullfile(DirectoryList(i).filepath));
        
        %For each file remembering to skip the first two as they are . ..
        for j = 3:size(TempFileList)
            
            %If the file contains a valid video type e.g. filename contains .mp4
            if not(isempty(strfind(TempFileList(j).name,FileType)))
                
                %If the video is not a labeled video e.g. filename contains labeled
                if isempty(strfind(TempFileList(j).name,'labeled'))
                    
                    %Add folderpath to structure
                    TempFileList(j).folderpath = DirectoryList(i).filepath;
                    
                    %Add filepath to structure
                    TempFileList(j).filepath = strcat(DirectoryList(i).filepath,'/',TempFileList(j).name);
                    
                    %Add to VideoList
                    videoList = [videoList;TempFileList(j)];
    
                end
            end
        end
    
        %Search next folder in the list
    
    end
    
    app.analysisProgressLabel.Text = sprintf('Total number of videos being processed is %i\n',size(videoList,1));
    
    if size(videoList) < 1
        warning('Warning - There are no videos to analyse');
        return;
    end
    
    % In order to pass several commands to the same (terminal / shell) we need to collate them into a single string.
    AnalysisCommand = ['source /home/hoverfly/anaconda3/bin/activate' ' ' AnacondaEnvironment]; %conda activate DLC2 equivalent (for some reason "conda activate DLC2" doesn't work in this context so we use this alternative)
    AnalysisCommand = strcat(AnalysisCommand,';ipython'); % Add the start of the next command 
    AnalysisCommand = [AnalysisCommand ' ' '''' IpythoncommandsFilePath '''']; % Add a space and then the path to python file encapsulated in '
    AnalysisCommand = [AnalysisCommand ' ' '''']; % Adds a space and begins encapsulation of the argument being passed to the python file in ' as '''' converts to a single '
    
    app.analysisProgressLabel.Text = sprintf('0 out of %i videos have been analyzed by deeplabcut\n', (size(videoList,1)));
    
    for i = 1:size(videoList)
         
        TempVideoPath = videoList(i).filepath;
        
        for j = 1:modelListSize
            
            TempModelPath = modelList(j).filePath;    
            % Create the command deeplabcut required to analyze a video
            TempCommand = ['deeplabcut.analyze_videos(',34,TempModelPath,34,',[',34,TempVideoPath,34,'],save_as_csv=True)'];
    
            % Passes through command responsible for Analysing each video 
            unix(strcat(AnalysisCommand,TempCommand,''''),'-echo'); % concatenate analysis command and temp command then encapsulation the argument in '
    
        end 
    
        progress = sprintf('%i out of %i videos have been analyzed by deeplabcut\n',i,(size(videoList,1)));
    
        disp('---------');
        disp(progress);
        disp('---------');
    
        app.analysisProgressLabel.Text = progress;
    end
end