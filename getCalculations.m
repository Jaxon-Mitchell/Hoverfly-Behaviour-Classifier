function calculations = getCalculations(dlcAnalysis, vidRes, keyword, optArg)
% This function takes a matlab array containing Deep Lab Cut (DLC) data and
% provides to the user the desired calculations based on the 'keyword'
% argument.

% Loop through all frames, and correct y-coordinates to start from bottom
% of the video, not the top
yMax = str2double(vidRes{2});
for frame = 1:size(dlcAnalysis, 1)
    for i = 2:3:size(dlcAnalysis, 2)
        dlcAnalysis(frame, i) = yMax - dlcAnalysis(frame, i);
    end
end

switch keyword
    case 'axisAngle'
    % Calculates the axis angle for all frames in the experiment
        axisAngle = zeros(size(dlcAnalysis, 1), 1);
        for frame = 1:size(dlcAnalysis, 1)
            % Wings_Thorax_Upper_X - Wings_Thorax_Lower_X
            LongitudinalAxis_Width = (dlcAnalysis(frame, 13) - dlcAnalysis(frame, 16));
            % Wings_Thorax_Upper_Y - Wings_Thorax_Lower_Y
            LongitudinalAxis_Height = (dlcAnalysis(frame, 14) - dlcAnalysis(frame, 17));
            % Calculates the absolute arctan and returns the answer in degrees
            axisAngle(frame) = atand(LongitudinalAxis_Width / LongitudinalAxis_Height);
        end
        calculations = axisAngle;
    case 'WBA'
    % Calculate the wing beat amplitude (WBA) for both the left and right wing
    % of the participant, column 1 is for left wing, column 2 is for right wing.
        WBA = zeros(size(dlcAnalysis, 1), 2);
        axisAngle = optArg;
        for frame = 1:size(dlcAnalysis, 1)
            % SlopeWidth and SlopeHeight %
            % Wings_Distal_Right_X - Wings_Hinge_Right_X
            WBA_SlopeWidth_Right = (dlcAnalysis(frame, 4) - dlcAnalysis(frame, 1));
            % Wings_Distal_Right_Y - Wings_Hinge_Right_Y
            WBA_SlopeHeight_Right = (dlcAnalysis(frame, 5) - dlcAnalysis(frame, 2));
        
            % Wings_Distal_Left_X - Wings_Hinge_Left_X
            WBA_SlopeWidth_Left = (dlcAnalysis(frame, 10) - dlcAnalysis(frame, 7));
            % Wings_Distal_Left_Y - Wings_Hinge_Left_Y
            WBA_SlopeHeight_Left = (dlcAnalysis(frame, 11) - dlcAnalysis(frame, 8));
            
            % Calculate Wing Beat Amplitudes
            % calculates the arctan and returns the answer in degrees
            WBA_Right = abs(atand(WBA_SlopeWidth_Right/WBA_SlopeHeight_Right));
            if(WBA_SlopeHeight_Right >= 0)
                WBA_Right = 180 - WBA_Right;
            end
            WBA_Right = abs(WBA_Right - axisAngle(frame));
            
            %calculates the arctan and returns the answer in degrees
            WBA_Left = abs(atand(WBA_SlopeWidth_Left/WBA_SlopeHeight_Left));
            if(WBA_SlopeHeight_Left >= 0)
                WBA_Left = 180 - WBA_Left;
            end
            WBA_Left = abs(WBA_Left - axisAngle(frame));
            WBA(frame, :) = [WBA_Left, WBA_Right];
        end
        calculations = WBA;
    case 'hindlegVectors'
    % Need description here
        hindVectors = zeros(size(dlcAnalysis, 1), 2, 6);
        axisAngle = optArg;
        for frame = 1:size(dlcAnalysis, 1)
            % Pull out coordinates for leg labels
            rightProximal = [dlcAnalysis(frame, 55) dlcAnalysis(frame, 56)];
            rightKnee = [dlcAnalysis(frame, 58) dlcAnalysis(frame, 59)];
            rightDistal = [dlcAnalysis(frame, 61) dlcAnalysis(frame, 62)];
            % Put into terms of vectors
            rightKneeProximalVector = rightProximal - rightKnee;
            rightKneeDistalVector = rightDistal - rightKnee;
            rightProximalDistalVector = rightDistal - rightProximal;
            % Calculate vector lengths
            rightProximalKneeLength = norm(rightKneeProximalVector);
            rightKneeDistalLength = norm(rightKneeDistalVector);
            rightHingeDistalDeviation = rightDistal(1) - rightProximal(1);
            % Get useful angles
            rightKneeThoraxAngle = atand(rightKneeProximalVector(1) / rightKneeProximalVector(2));
            rightKneeThoraxAngle = rightKneeThoraxAngle - axisAngle(frame);
            %rightInteriorkneeAngle = dot(rightProximalKneeVector,rightKneeDistalVector)/(rightProximalKneeLength*rightKneeDistalLength);
            %rightInteriorkneeAngle = real(acosd(rightInteriorkneeAngle));
            rightInteriorkneeAngle = rad2deg(atan2(...
               rightKneeProximalVector(2)*rightKneeDistalVector(1) - rightKneeProximalVector(1)*rightKneeDistalVector(2), ...
               rightKneeProximalVector(1)*rightKneeDistalVector(1) + rightKneeProximalVector(2)*rightKneeDistalVector(2)));
            rightHingeDistalAngle = atand(rightProximalDistalVector(1) / rightProximalDistalVector(2));
            rightHingeDistalAngle = rightHingeDistalAngle - axisAngle(frame);
            % Save right leg info
            hindVectors(frame, 1, :) = [rightProximalKneeLength, rightKneeDistalLength, rightKneeThoraxAngle, ...
                rightInteriorkneeAngle, rightHingeDistalAngle, rightHingeDistalDeviation];

            % Do the same for the left leg
            leftProximal = [dlcAnalysis(frame, 67) dlcAnalysis(frame, 68)];
            leftKnee = [dlcAnalysis(frame, 70) dlcAnalysis(frame, 71)];
            leftDistal = [dlcAnalysis(frame, 73) dlcAnalysis(frame, 74)];
            leftProximalKneeVector = leftKnee - leftProximal;
            leftKneeDistalVector = leftDistal - leftKnee;
            leftProximalDistalVector = leftDistal - leftProximal;
            leftProximalKneeLength = norm(leftProximalKneeVector);
            leftKneeDistalLength = norm(leftKneeDistalVector);
            leftHingeDistalDeviation = leftDistal(1) - leftProximal(1);
            leftKneeThoraxAngle = atand(leftProximalKneeVector(1) / leftProximalKneeVector(2));
            leftKneeThoraxAngle = leftKneeThoraxAngle - axisAngle(frame);
            leftInteriorkneeAngle = rad2deg(atan2(...
               leftProximalKneeVector(2)*leftKneeDistalVector(1) - leftProximalKneeVector(1)*leftKneeDistalVector(2), ...
               leftProximalKneeVector(1)*leftKneeDistalVector(1) + leftProximalKneeVector(2)*leftKneeDistalVector(2)));
            leftHingeDistalAngle = atand(leftProximalDistalVector(1) / leftProximalDistalVector(2));
            leftHingeDistalAngle = leftHingeDistalAngle - axisAngle(frame);
            % Save left leg info
            hindVectors(frame, 2, :) = [leftProximalKneeLength, leftKneeDistalLength, leftKneeThoraxAngle, ...
                leftInteriorkneeAngle, leftHingeDistalAngle, leftHingeDistalDeviation];
        end
        calculations = hindVectors;
    case 'frontlegVectors'
        frontVectors = zeros(size(dlcAnalysis, 1), 2, 2);
        axisAngle = optArg;
        for frame = 1:size(dlcAnalysis, 1)
            % Get labels
            rightHinge = [dlcAnalysis(frame, 43), dlcAnalysis(frame, 44)];
            rightDistal = [dlcAnalysis(frame, 46), dlcAnalysis(frame, 47)];
            % Get vector + vector length
            rightVector = rightDistal - rightHinge;
            rightVectorLength = norm(rightVector);
            % Get useful angle
            rightRelativeAngle = atand(rightVector(1) / rightVector(2));
            rightRelativeAngle = rightRelativeAngle - axisAngle(frame);
            % Package together
            frontVectors(frame, 1, :) = [rightVectorLength, rightRelativeAngle]; 
            % Repeat for left leg
            leftHinge = [dlcAnalysis(frame, 49), dlcAnalysis(frame, 50)];
            leftDistal = [dlcAnalysis(frame, 52), dlcAnalysis(frame, 53)];
            leftVector = leftDistal - leftHinge;
            leftVectorLength = norm(leftVector);
            leftRelativeAngle = atand(leftVector(1) / leftVector(2));
            leftRelativeAngle = leftRelativeAngle - axisAngle(frame);
            % Save left leg info
            frontVectors(frame, 2, :) = [leftVectorLength, leftRelativeAngle]; 
        end
        calculations = frontVectors;
end

% Important guide for writing functions with the DLC Output in mind:
% 1) each label is in groups of 3: the first is x coordinate, then y
%    coordinate, and then likelihood
% 2) We do not need likelihood as an input
%
% Thorax starting points     :
% - Longitudinal axis upper   : column 13
% - Longitudinal axis lower   : column 16
% Wing starting points       :
% - Right hinge               : Column 1
% - Right wing                : Column 4
% - Left hinge                : Column 7
% - Left wing                 : Column 10
% Hind legs starting points  :
% - Hindlegs_Proximal_Right   : Column 55
% - Hindlegs_Knee_Right       : Column 58
% - Hindlegs_Distal_Right     : Column 61
% - Hindlegs_Proximal_Left    : Column 67
% - Hindlegs_Knee_Left        : Column 70
% - Hindlegs_Distal_Left      : Column 73
% Front legs starting points :
% - Frontlegs_Hinge_Right     : Column 43
% - Frontlegs_Distal_Right    : Column 46
% - Frontlegs_Hinge_Left      : Column 49
% - Frontlegs_Distal_Left     : Column 52