function analysisMatrix = classifyBehaviours(pathToDLCAnalysis, vidRes) 
% Function classifyBehaviours(pathToDLCAnalysis) is designed to read a Deep
% Lab Cut (DLC) file and extract behaviours from a hoverfly subject
% (Estralis Tenax) based on the position of it's limbs and wings, and the
% angle they are positioned at.
%
% Returns a n x 2 array of behaviours, the first column contains the frame
% number in the same manner as DLC, and the second column contains numbers
% corresponding to behaviours on that frame.

    % Load the DLC analysis file to obtain x-y positions of all labels
    dlcAnalysis = readcell(pathToDLCAnalysis);
    % Get the analysis into a format more easy for Matlab to handle
    dlcClean = dlcAnalysis(4:end,2:end);
    dlcClean = cell2mat(dlcClean);

    % Initialise the analysis to contain the same amount of frames as the
    % experiment video. A behaviour of '1' means that there was
    % no behaviour found for that frame.
    analysisMatrix = ones(size(dlcAnalysis, 1) - 3, 2);
    analysisMatrix(:,1) = 1:size(analysisMatrix, 1);

    % Get some important calculations first!!
    axisAngle = getCalculations(dlcClean, vidRes, 'axisAngle');

    % Get WBA for both wings
    WBA = getCalculations(dlcClean, vidRes, 'WBA', axisAngle);

    % Get vectors and angle info for both hind legs
    hindCalcs = getCalculations(dlcClean, vidRes, 'hindlegVectors', axisAngle);

    % Get vectors and angle calculations for both front legs
    frontCalcs = getCalculations(dlcClean, vidRes, 'frontlegVectors', axisAngle);

    for frame = 1:size(analysisMatrix, 1)

        % Make a boolean of which legs are tucked
        tucked.rHind = false;
        tucked.lHind = false;
        tucked.rFront = false;
        tucked.lFront = false;
        if hindCalcs(frame, 1, 2) <= 25
            tucked.rHind = true;
        end
        if hindCalcs(frame, 2, 2) <= 25
            tucked.lHind = true;
        end
        % Find the difference between hind knee - hind distal vectors to
        % prevent incorrectly identifying ruddering
        tuckDiff = abs(hindCalcs(frame, 1, 2) - hindCalcs(frame, 2, 2));
        if frontCalcs(frame, 1, 1) <= 7
            tucked.rFront = true;
        end
        if frontCalcs(frame, 2, 1) <= 7
            tucked.lFront = true;
        end

        % If it is no longer the same held behaviour, go through the
        % flowchart to find the current behaviour.
        % count = 0;
        % Check if participant is flying
        if WBA(frame, 1) < 60 && WBA(frame, 2) < 60
            % If not flying, continue and lump in with undefined
            continue
        end
        

        % Are the legs ruddering?
        hingeKneeAngleDiff = abs(abs(hindCalcs(frame, 1,3)) - abs(hindCalcs(frame, 2,3)));
        leftRudderTest = hindCalcs(frame, 2,1) > 25 && hingeKneeAngleDiff > 25;
        rightRudderTest = hindCalcs(frame, 1,1) > 25 && hingeKneeAngleDiff > 25;
        tuckTest = all([xor(tucked.rHind, tucked.lHind), tuckDiff > 13]);

        % Are the wings turning?
        if abs(WBA(frame, 1) - WBA(frame, 2)) > 20
            % Check if participant is doing a turning starfish
            if ~tucked.rHind && ~tucked.lHind && any([~tucked.rFront, ~tucked.lFront])
                analysisMatrix(frame, 2) = 7;
                continue
            end
            % Test for turning ruddering behaviour
            if any([leftRudderTest, rightRudderTest, tuckTest]) && any([~tucked.rHind, ~tucked.lHind])
                analysisMatrix(frame, 2) = 5;
                continue 
            end
            % Otherwise, it is generic flying
            if all([tucked.rFront, tucked.lFront])
                analysisMatrix(frame, 2) = 3;
                continue
            end
        end
        % Check if participant has all limbs out (Starfish) and if flying
        % straight
        if ~tucked.rHind && ~tucked.lHind && any([~tucked.rFront, ~tucked.lFront])
            analysisMatrix(frame, 2) = 6;
            continue
        end
        % Test for straight ruddering behaviour
        if any([leftRudderTest, rightRudderTest, tuckTest]) && any([~tucked.rHind, ~tucked.lHind])
            analysisMatrix(frame, 2) = 4;
            continue 
        end
        % If participant is flying straight with no additional movement,
        % mark as such
        if all([tucked.rFront, tucked.lFront])
            analysisMatrix(frame, 2) = 2;
        end
    end
end

% Behavioural guide:
% 1  - Undefined
% 2  - Flying straight
% 3  - Turning
% 4  - Straight rudder
% 5  - Turning rudder
% 6  - Starfish
% 7  - Turning starfish

% Hindlegs calculations guide:
% [rightProximalKneeLength, rightKneeDistalLength, rightKneeThoraxAngle, rightInteriorkneeAngle; ...
%  leftProximalKneeLength,  leftKneeDistalLength,  leftKneeThoraxAngle,  leftInteriorkneeAngle]

% Frontlegs calculations guide:
% [rightVectorLength, rightRelativeAngle; ...
%  leftVectorLength,  leftRelativeAngle]
