function calculations = getCalculations(dlcAnalysis, keyword, optArg)
% This function takes a matlab array containing Deep Lab Cut (DLC) data and
% provides to the user the desired calculations based on the 'keyword'
% argument.

switch keyword
    case 'axisAngle'
    % Calculates the axis angle for all frames in the experiment
        axisAngle = zeros(size(dlcAnalysis, 1), 1);
        for frame = 1:size(dlcAnalysis, 1)
            % Wings_Thorax_Upper_X - Wings_Thorax_Lower_X
            LongitudinalAxis_Width = (dlcAnalysis(frame, 14) - dlcAnalysis(frame, 17));
            % Wings_Thorax_Upper_Y - Wings_Thorax_Lower_Y
            LongitudinalAxis_Height = (dlcAnalysis(frame, 15) - dlcAnalysis(frame, 18));
            %Calculates the absolute arctan and returns the answer in degrees
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
            WBA_SlopeWidth_Right = (dlcAnalysis(frame, 5) - dlcAnalysis(frame, 2));
            % Wings_Distal_Right_Y - Wings_Hinge_Right_Y
            WBA_SlopeHeight_Right = (dlcAnalysis(frame, 6) - dlcAnalysis(frame, 3));
        
            % Wings_Distal_Left_X - Wings_Hinge_Left_X
            WBA_SlopeWidth_Left = (dlcAnalysis(frame, 11) - dlcAnalysis(frame, 8));
            % Wings_Distal_Left_Y - Wings_Hinge_Left_Y
            WBA_SlopeHeight_Left = (dlcAnalysis(frame, 10) - dlcAnalysis(frame, 9));
    
            % Calculate Wing Beat Amplitudes
            % calculates the arctan and returns the answer in degrees
            WBA_Right = atand(WBA_SlopeWidth_Right/WBA_SlopeHeight_Right);
            if(WBA_SlopeHeight_Right >= 0)
                WBA_Right = 180 - abs(WBA_Right - axisAngle(frame));                   
            else
                WBA_Right = abs(WBA_Right - axisAngle(frame));
            end
            
            %calculates the arctan and returns the answer in degrees
            WBA_Left = atand(WBA_SlopeWidth_Left/WBA_SlopeHeight_Left);
            if(WBA_SlopeHeight_Left >= 0)
                WBA_Left = 180 - abs(WBA_Left - axisAngle(frame));
            else
                WBA_Left = abs(WBA_Left - axisAngle(frame));
            end
            WBA(frame, :) = [WBA_Left, WBA_Right];
        end
        calculations = WBA;
    case 'hindlegVectors'
    % Need description here
        hindVectors = zeros(size(dlcAnalysis, 1), 2, 4);
        for frame = 1:size(dlcAnalysis, 1)

        end
        calculations = hindVectors;
    case 'frontlegVectors'

end

% Important guide for writing functions with the DLC Output in mind:
% 1) each label is in groups of 3: the first is x coordinate, then y
%    coordinate, and then likelihood
% 2) We do not need likelihood as an input
%
% Thorax starting points     :
% - Longitudinal axis upper   : column 14
% - Longitudinal axis lower   : column 17
% Wing starting points       :
% - Right hinge               : Column 2
% - Right wing                : Column 5
% - Left hinge                : Column 8
% - Left wing                 : Column 11
% Hind legs starting points  :
% - Hindlegs_Proximal_Right   : Column 56
% - Hindlegs_Knee_Right       : Column 59
% - Hindlegs_Distal_Right     : Column 62
% - Hindlegs_Proximal_Left    : Column 68
% - Hindlegs_Knee_Left        : Column 71
% - Hindlegs_Distal_Left      : Column 74
% Front legs starting points :
% - Frontlegs_Hinge_Right     : Column 44
% - Frontlegs_Distal_Right    : Column 47
% - Frontlegs_Hinge_Left      : Column 50
% - Frontlegs_Distal_Left     : Column 53