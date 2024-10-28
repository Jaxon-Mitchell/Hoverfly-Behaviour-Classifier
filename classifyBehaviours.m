function analysisMatrix = classifyBehaviours(pathToDLCAnalysis, vidRes) 
% Function classifyBehaviours(pathToDLCAnalysis) is designed to read a Deep
% Lab Cut (DLC) file and extract behaviours from a hoverfly subject
% (Estralis Tenax) based on the position of it's limbs and wings, and the
% angle they are positioned at.
%
% Returns a n x 2 array of behaviours, the first column contains the frame
% number in the same manner as DLC, and the second column contains numbers
% corresponding to behaviours on that frame.

    % Remove later, but this is to test the script and if it works
    %pathToDLCAnalysis = '/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/savedData/Jaxon/testData/RE-Video_11-Jul-2023 11_44_30.csv';
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
    axisAngle = getCalculations(dlcClean, vidRes, 'axisAngle');
    
    % Get WBA for both wings
    WBA = getCalculations(dlcClean, vidRes, 'WBA', axisAngle);

    % Get vectors and angle info for both hind legs
    hindCalcs = getCalculations(dlcClean, vidRes, 'hindlegVectors', axisAngle);

    % Get vectors and angle calculations for both front legs
    %frontcalcs = getCalculations(dlcClean, vidRes, 'frontlegVectors', axisAngle);

    % Get vectors for both front legs
    
    % Go through each frame and determine behaviours
    %frame = 0;
    currentBehaviour = 0;
    
    for frame = 1:size(analysisMatrix, 1)
        % Make a boolean of which legs are tucked
        rTuckHind = false;
        lTuckHind = false;
        rTuckFront = false;
        lTuckFront = false;
        if hindCalcs (frame, 1, 2) <= 25
            rTuckHind = true;
        end
        if hindCalcs(frame, 2, 2) <= 25
            lTuckHind = true;
        end
        if frontCalcs(frame, 2, 2) <= 10
            rTuckFront = true;
        end
        if frontCalcs(frame, 2, 2) <= 10
            lTuckFront = true;
        end
        % Check if participant is flying
        if WBA(frame, 1) < 60 && WBA(frame, 2) < 60
            analysisMatrix(frame, 2) = 1;
            currentBehaviour = 6;
            % If not, continue
            continue
        end
        % Check if participant has all limbs out (Starfish)
        if ~rTuckHind && ~lTuckHind && ~rTuckFront && ~lTuckFront
            analysisMatrix(frame, 2) = 6;
            currentBehaviour = 6;
            continue
        end
        % Are the wings turning?
        if abs(WBA(frame, 1) - WBA(frame, 2)) > 15
            % Are the legs ruddering?
            hingeKneeAngleDiff = abs(hindCalcs(frame, 1,3) - hindCalcs(frame, 2,3));
            leftRudderTest = hindCalcs(frame, 2,1) > 25 && hingeKneeAngleDiff > 15;
            rightRudderTest = hindCalcs(frame, 1,1) > 25 && hingeKneeAngleDiff > 15;
            tuckTest = xor(rTuckHind, lTuckHind);
            % Check if participant is doing a turning starfish
            if ~rTuckHind && ~lTuckHind && xor(~rTuckFront, ~lTuckFront)
                analysisMatrix(frame, 2) = 7;
                currentBehaviour = 7;
                continue
            end
            % Test for ruddering behaviour
            if leftRudderTest || rightRudderTest || tuckTest
                analysisMatrix(frame, 2) = 4;
                currentBehaviour = 4;
                continue 
            end
            % Otherwise, it is generic flying
            analysisMatrix(frame, 2) = 3;
            currentBehaviour = 3;
            continue
        end
        % Check if participant is in superman pose
        if ~rTuckHind && ~lTuckHind && rTuckFront && lTuckFront
            analysisMatrix(frame, 2) = 5;
            currentBehaviour = 5;
            continue 
        end
        % If participant is flying straight with no additional movement,
        % mark as such
        analysisMatrix(frame, 2) = 2;
        currentBehaviour = 2;
    end
end

% Behavioural guide:
% 0 - Initialised value, should not be found in a final analysis
% 1 - Not flying
% 2 - Flying straight
% 3 - Turning with no additional behaviour
% 4 - Ruddering behaviour
% 5 - Superman position
% 6 - Starfish

% Hindlegs calculations guide:
% [rightProximalKneeLength, rightKneeDistalLength, rightKneeThoraxAngle, rightInteriorkneeAngle; ...
%  leftProximalKneeLength,  leftKneeDistalLength,  leftKneeThoraxAngle,  leftInteriorkneeAngle]

% Frontlegs calculations guide:
% [rightVectorLength, rightRelativeAngle; ...
%  leftVectorLength,  leftRelativeAngle]
