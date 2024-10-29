% This script is used to visualise animal behaviour based on user defined
% communities in a time series

% Get user to select .csv containing VAME motif timeseries
[file,location] = uigetfile('*.csv', 'Select your motif .csv');

% Cancel if no file selected
if isequal(file,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', fullfile(location,file)]);
end

% For each of your communities, input  
% community{i}.motifs = [];
% community{i}.name = 'name';

% Obtain the user set communities
returnCommunities();

commLegend = cell(1,length(community));
for i = 1:length(community)
    commLegend{i} = community{i}.name;
end


% Read your analysis file
temp = readcell([location file]);
% Get only the useful parts
analysis = cell(size(temp,1) - 1, 3);
analysis(1:end,1:2) = temp(2:end,:);
clear temp
% Loop through the entire analysis to find out what the communities are
% over time
for behaviour = 1:length(community)
    for frame = 1:size(analysis, 1)
        if ismember(analysis{frame, 2}, community{behaviour}.motifs)
            analysis{frame,3} = behaviour;
        end
    end
end

A = [22 23 24] ;
B = [5 6 7] ;
plot(A,'-or') ;
hold on
plot(B,'-Ob') ;
legend({'A' ; 'B'})
hold off

%% Plot our community data over time
% What is our framerate (To convert x-axis into seconds)
frameRate = 100;
% Initialise important values for the first frame
startFrame = 0;
prevComm = analysis{1, 3};
% Start a new figure window
commPlot = figure;
hold on
% Loop over all frames and draw a plot to show community over time
for frame = 1:size(analysis, 1)
    %xlim = size(analysis, 1) / 100
    currentComm = analysis{frame, 3};
    if currentComm ~= prevComm
        endFrame = frame;
        startTime = startFrame / frameRate;
        endTime = endFrame / frameRate;
        x = [startTime endTime endTime startTime];
        y = [0 0 1 1];
        switch prevComm
            case 1
                colour = 'red';
                comm1 = patch(x, y, colour, 'EdgeColor', 'none');
            case 2
                colour = 'green';
                comm2 = patch(x, y, colour, 'EdgeColor', 'none');
            case 3
                colour = 'blue';
                comm3 = patch(x, y, colour, 'EdgeColor', 'none');
        end
        patch(x, y, colour, 'EdgeColor', 'none')
        startFrame = frame;
    end
    prevComm = analysis{frame, 3};
end
xlabel('Experiment time (s)'); 
xlim([0 (size(analysis, 1) / frameRate)])
set(gca,'ytick',[])
legend([comm1, comm2, comm3], commLegend)
hold off






