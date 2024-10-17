function analysisMatrix = classifyBehaviours(pathToDLCAnalysis) %#ok<INUSD>
% Function classifyBehaviours(pathToDLCAnalysis) is designed to read a Deep
% Lab Cut (DLC) file and extract behaviours from a hoverfly subject
% (Estralis Tenax) based on the position of it's limbs and wings, and the
% angle they are positioned at.
%
% Returns a n x 2 array of behaviours, the first column contains the frame
% number in the same manner as DLC, and the second column contains numbers
% corresponding to behaviours on that frame.

    % Remove later, but this is to test the script and if it works
    pathToDLCAnalysis = '/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/Jaxon/testData/RE-Video_11-Jul-2023 11_16_06.csv';
    % Load the DLC analysis file to obtain x-y positions of all labels
    dlcAnalysis = readcell(pathToDLCAnalysis);
    % Get the analysis into a format more easy for Matlab to handle
    dlcClean = dlcAnalysis(4:end,2:end);
    dlcClean = cell2mat(dlcClean);
    
    % Initialise the analysis to contain the same amount of frames as the
    % experiment video. A behaviour of '0' means that there was
    % no behaviour found for that frame.
    analysisMatrix = zeros(size(dlcAnalysis, 1) - 3, 2);
    analysisMatrix(:,1) = 0:size(analysisMatrix, 1) - 1;
    
    % Get some important calculations first!!
    axisAngle = getCalculations(dlcClean, 'axisAngle');
    
    % Get WBA for both wings
    WBA = getCalculations(dlcClean, 'WBA', axisAngle);

    % Get Vectors for both hind legs
    hindVectors = getCalculations(dlcClean, 'hindlegVectors');

    % Get vectors for both front legs
    
    % Go through each frame and determine behaviours
    frame = 0;
    
    while frame <= size(analysisMatrix, 1) - 4
        % If WBA < 75 degrees, no flying
        % Then continue
    end
end

% Calculates the axis angle for all frames in the experiment
function axisAngle = getAxisAngle(dlcFile)
    axisAngle = zeros(size(dlcFile, 1), 1);
    for frame = 1:size(dlcFile, 1)
        % Wings_Thorax_Upper_X - Wings_Thorax_Lower_X
        LongitudinalAxis_Width = (dlcFile(frame, 14) - dlcFile(frame, 17));
        % Wings_Thorax_Upper_Y - Wings_Thorax_Lower_Y
        LongitudinalAxis_Height = (dlcFile(frame, 15) - dlcFile(frame, 18));
        %Calculates the absolute arctan and returns the answer in degrees
        axisAngle(frame) = atand(LongitudinalAxis_Width / LongitudinalAxis_Height);
    end
end

% Calculate the wing beat amplitude (WBA) for both the left and right wing
% of the participant, column 1 is for left wing, column 2 is for right wing.
function WBA = getWBA(dlcFile)
    WBA = zeros(size(dlcFile, 1),2);
    for frame = 1:size(dlcFile, 1)
        % SlopeWidth and SlopeHeight %
        % Wings_Distal_Right_X - Wings_Hinge_Right_X
        WBA_SlopeWidth_Right = (dlcFile(frame, 5) - dlcFile(frame, 2));
        % Wings_Distal_Right_Y - Wings_Hinge_Right_Y
        WBA_SlopeHeight_Right = (dlcFile(frame, 6) - dlcFile(frame, 3));
    
        % Wings_Distal_Left_X - Wings_Hinge_Left_X
        WBA_SlopeWidth_Left = (dlcFile(frame, 11) - dlcFile(frame, 8));
        % Wings_Distal_Left_Y - Wings_Hinge_Left_Y
        WBA_SlopeHeight_Left = (dlcFile(frame, 10) - dlcFile(frame, 9));

        % Calculate Wing Beat Amplitudes
        % calculates the arctan and returns the answer in degrees
        WBA_Right = atand(WBA_SlopeWidth_Right/WBA_SlopeHeight_Right);
        if(WBA_SlopeHeight_Right >= 0)
            WBA_Right = 180 - abs(WBA_Right - Axis_Angle);                   
        else
            WBA_Right = abs(WBA_Right - Axis_Angle);
        end
        
        %calculates the arctan and returns the answer in degrees
        WBA_Left = atand(WBA_SlopeWidth_Left/WBA_SlopeHeight_Left);
        if(WBA_SlopeHeight_Left >= 0)
            WBA_Left = 180 - abs(WBA_Left - Axis_Angle);
        else
            WBA_Left = abs(WBA_Left - Axis_Angle);
        end
        WBA(frame, :) = [WBA_Left, WBA_Right];
    end
end




