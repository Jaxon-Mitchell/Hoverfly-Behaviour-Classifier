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

    currentBehaviour = 1;
    count = 0;

    for frame = 1:size(analysisMatrix, 1)

        % Make a boolean of which legs are tucked
        tucked.rHind = false;
        tucked.lHind = false;
        tucked.rFront = false;
        tucked.lFront = false;
        if hindCalcs(frame, 1, 2) <= 20
            tucked.rHind = true;
        end
        if hindCalcs(frame, 2, 2) <= 20
            tucked.lHind = true;
        end
        if frontCalcs(frame, 1, 1) <= 7
            tucked.rFront = true;
        end
        if frontCalcs(frame, 2, 1) <= 7
            tucked.lFront = true;
        end

        % This check is in place to deal with edge cases and prevent rapid
        % switching between behaviours
        if currentBehaviour ~= 0
            [count, outcome] = checkCurrentBehaviour(currentBehaviour, count, tucked, WBA(frame, :), frontCalcs(frame, :, :), squeeze(hindCalcs(frame, :, :)));
            if outcome == 1
                analysisMatrix(frame, 2) = currentBehaviour;
                continue
            end
        end

        % If it is no longer the same held behaviour, go through the
        % flowchart to find the current behaviour.
        count = 0;
        % Check if participant is flying
        if WBA(frame, 1) < 60 && WBA(frame, 2) < 60
            analysisMatrix(frame, 2) = 2;
            currentBehaviour = 2;
            % If not, continue
            continue
        end
        % Check if participant has all limbs out (Starfish) NEED TO REDEFINE THIS
        if ~tucked.rHind && ~tucked.lHind && ~tucked.rFront && ~tucked.lFront
            analysisMatrix(frame, 2) = 8;
            currentBehaviour = 8;
            continue
        end

        % Are the legs ruddering?
        hingeKneeAngleDiff = abs(hindCalcs(frame, 1,3) - hindCalcs(frame, 2,3));
        leftRudderTest = hindCalcs(frame, 2,1) > 25 && hingeKneeAngleDiff > 15;
        rightRudderTest = hindCalcs(frame, 1,1) > 25 && hingeKneeAngleDiff > 15;
        tuckTest = xor(tucked.rHind, tucked.lHind);

        % Are the wings turning?
        if abs(WBA(frame, 1) - WBA(frame, 2)) > 20
            % Check if participant is doing a turning starfish
            if ~tucked.rHind && ~tucked.lHind && xor(~tucked.rFront, ~tucked.lFront)
                analysisMatrix(frame, 2) = 9;
                currentBehaviour = 9;
                continue
            end
            % Test for turning ruddering behaviour
            if any([leftRudderTest, rightRudderTest, tuckTest]) && any([~tucked.rHind, ~tucked.lHind])
                analysisMatrix(frame, 2) = 6;
                currentBehaviour = 6;
                continue 
            end
            % Otherwise, it is generic flying
            if all([tucked.rHind, tucked.lHind, tucked.rFront, tucked.lFront])
                analysisMatrix(frame, 2) = 4;
                currentBehaviour = 4;
                continue
            end
        end
        % Test for straight ruddering behaviour
        if any([leftRudderTest, rightRudderTest, tuckTest]) && any([~tucked.rHind, ~tucked.lHind])
            analysisMatrix(frame, 2) = 5;
            currentBehaviour = 5;
            continue 
        end
        % Check if participant is in superman pose
        if all([~tucked.rHind, ~tucked.lHind, tucked.rFront, tucked.lFront])
            analysisMatrix(frame, 2) = 7;
            currentBehaviour = 7;
            continue 
        end
        % If participant is flying straight with no additional movement,
        % mark as such
        if all([tucked.rHind, tucked.lHind, tucked.rFront, tucked.lFront])
            analysisMatrix(frame, 2) = 3;
            currentBehaviour = 3;
        end
        if all([tucked.rHind, tucked.lHind]) && any([~tucked.rFront, ~tucked.lFront])
            analysisMatrix(frame, 2) = 10;
            currentBehaviour = 10;
        end
    end
end

% Behavioural guide:
% 1  - Initialised value, should not be found in a final analysis
% 2  - Not flying
% 3  - Flying straight
% 4  - Turning with no additional behaviour
% 5  - Straight rudder
% 6  - Turning rudder
% 7  - Superman position
% 8  - Starfish
% 9  - Turning starfish
% 10 - Front Kick

% Hindlegs calculations guide:
% [rightProximalKneeLength, rightKneeDistalLength, rightKneeThoraxAngle, rightInteriorkneeAngle; ...
%  leftProximalKneeLength,  leftKneeDistalLength,  leftKneeThoraxAngle,  leftInteriorkneeAngle]

% Frontlegs calculations guide:
% [rightVectorLength, rightRelativeAngle; ...
%  leftVectorLength,  leftRelativeAngle]

% This function is designed to provide inertia to prevent rapid switching
% between behaviours during edge cases
function [count, outcome] = checkCurrentBehaviour(currentBehaviour, count, tucked, WBA, ~, hindCalcs) % Add back in frontCalcs where '~' later on
    % 'outcome' refers whether to stay on the same behaviour (= 1) or to
    % move onto the next behaviour (= 0)
    outcome = 1;
    switch currentBehaviour
        case 1 % Undefined behaviour
            % Always double check what behaviour we have next, rather than
            % leave undefined
            count = 3;
        case 2 % Not flying
            if all([WBA(1) < 60, WBA(2) < 60])
                count = 0;
            else
                count = count + 1;
            end
        case 3 % Flying Straight
            if any([~tucked.rHind, ~tucked.lHind, ~tucked.rFront, ~tucked.lFront]) || abs(WBA(1) - WBA(2)) > 30
                count = 3;
            elseif abs(WBA(1) - WBA(2)) < 20 && any([WBA(1) > 60, WBA(2) > 60])
                count = 0;
            else
                count = count + 1;
            end
        case 4 % Turning with no additional behaviour
            if any([~tucked.rHind, ~tucked.lHind, ~tucked.rFront, ~tucked.lFront]) || abs(WBA(1) - WBA(2)) < 10
                count = 3;
            elseif abs(WBA(1) - WBA(2)) > 20 && any([WBA(1) > 60, WBA(2) > 60])
                count = 0;
            else
                count = count + 1;
            end
        case 5 % Straight ruddering
            hingeKneeAngleDiff = abs(hindCalcs(1,3) - hindCalcs(2,3));
            leftRudderTest = hindCalcs(2,1) > 25 && hingeKneeAngleDiff > 15;
            rightRudderTest = hindCalcs(1,1) > 25 && hingeKneeAngleDiff > 15;
            tuckTest = xor(tucked.rHind, tucked.lHind);
            if any([~tucked.rFront, ~tucked.lFront])
                count = 3;
            elseif abs(WBA(1) - WBA(2)) < 20 && any([leftRudderTest, rightRudderTest, tuckTest])
                count = 0;
            else
                count = count + 1;
            end
        case 6 % Turning ruddering
            hingeKneeAngleDiff = abs(hindCalcs(1,3) - hindCalcs(2,3));
            leftRudderTest = hindCalcs(2,1) > 25 && hingeKneeAngleDiff > 15;
            rightRudderTest = hindCalcs(1,1) > 25 && hingeKneeAngleDiff > 15;
            tuckTest = xor(tucked.rHind, tucked.lHind);
            if any([~tucked.rFront, ~tucked.lFront])
                count = 3;
            elseif abs(WBA(1) - WBA(2)) > 20 && any([leftRudderTest, rightRudderTest, tuckTest])
                count = 0;
            else
                count = count + 1;
            end
        case 7 % Superman position
            if any([~tucked.rFront, ~tucked.lFront])
                count = 3;
            elseif all([~tucked.rHind, ~tucked.lHind])
                count = 0;
            else
                count = count + 1;
            end
        case 8 % Starfish
            if all([~tucked.rHind, ~tucked.lHind]) && any([~tucked.rFront, ~tucked.lFront])
                count = 0;
            else
                count = count + 1;
            end
        case 9 % Turning Starfish
            if all([~tucked.rFront, ~tucked.lFront])
                count = 3;
            elseif all([~tucked.rHind, ~tucked.lHind]) && xor(~tucked.rFront, ~tucked.lFront)
                count = 0;
            else
                count = count + 1;
            end
        case 10 % Front Kick
            if any([~tucked.rHind, ~tucked.lHind]) || abs(WBA(1) - WBA(2)) > 20
                count = 3;
            else
                count = count + 1;
            end
    end
    if count > 2
        outcome = 0;
    end
end





