% ODE file thatsimlates collective bison movement
function dStateList = bisonODE(t, stateList, params)

% unpack parameters
numberOfBison = params.numberOfBison;
turnRate = params.turnRate;
avoidDistance = params.avoidDistance;
attractDistance = params.attractDistance;
alignDistance = params.alignDistance;
waterSourceLocations = params.waterSourceLocations;
bisonGains = params.bisonGains;

% unpack the states of the bison
bisonX = stateList(1:numberOfBison);
bisonY = stateList(numberOfBison + 1: 2*numberOfBison);
bisonSpeed = stateList(2*numberOfBison + 1: 3*numberOfBison);
bisonOrientation = stateList(3*numberOfBison + 1:end);

% Bison positions in 2D
bisonPositions = [bisonX, bisonY];

% Calculate the desired orientation for each bison
desiredOrientation = bisonOrientation; % ideally each bison would continue on it's current path

for currBison = 1:numberOfBison    
    % Where is the Bison we're looking at/
    currBisonPosition = bisonPositions(currBison, :);
    
    % where are the rest of the Bison?
    otherBisonPositions = bisonPositions;
    otherBisonPositions(currBison, :) = [];
    
    otherBisonOrientations = bisonOrientation;
    otherBisonOrientations(currBison) =  [];
    
    % What is the distance between our Bison and the rest?
    relativePositions = otherBisonPositions - repmat(currBisonPosition, numberOfBison - 1, 1);
    distanceList = sqrt(sum(relativePositions.^2, 2)); 
    relativeOrientation = [relativePositions(:,1)./distanceList, relativePositions(:,2)./distanceList]; %atan2(relativePositions(:,2), relativePositions(:,1));
    
    % Repel List
    changeInOrientationRepel = relativeOrientation;
    changeInOrientationRepel(distanceList > avoidDistance, :) = [];
    changeInOrientationRepelAngles = atan2(changeInOrientationRepel(:,2), changeInOrientationRepel(:,1));
    
    % Attract List
    changeInOrientationAttract = relativeOrientation;
    changeInOrientationAttract(avoidDistance > distanceList | distanceList > attractDistance, :) = [];
    changeInOrientationAttractAngles = atan2(changeInOrientationAttract(:,2), changeInOrientationAttract(:,1));
    
    % Align List
    changeInOrientationAlign = relativeOrientation;
    changeInOrientationAlign(avoidDistance > distanceList | distanceList > alignDistance, :) = [];
    changeInOrientationAlignAngles = atan2(changeInOrientationAlign(:,2), changeInOrientationAlign(:,1));
    
    % Relative Position of water sources
    relativeWSLocations = waterSourceLocations - repmat(currBisonPosition, size(waterSourceLocations, 1), 1);
    distanceFromWSLocations = sqrt(sum(relativeWSLocations.^2, 2));
    relativeWSUnitVector = [relativeWSLocations(:,1)./distanceFromWSLocations, relativeWSLocations(:,2)./distanceFromWSLocations];
    changeInOrientationWSAngles = atan2(relativeWSLocations(:,2), relativeWSLocations(:,1));
    
    % Attempted implementation with nested loops
    %    for otherBison = 1:numberOfBison
    %        otherBisonPosition = [bisonX(otherBison), bisonY(otherBison)];
    %        distanceBetweenBisons = dist(currBisonPosition, otherBisonPosition);
    %        if distanceBetweenBisons < avoidDistance
    %            changeInOrientation = changeInOrientation - atan2(currBisonPosition(2) - otherBisonPosition(2), currBisonPosition(1) - otherBisonPosition(1));
    %        end
    %    end

    % Using angles directly    
    % % Get repelled by nearby Bison
    % desiredOrientation(currBison) = desiredOrientation(currBison) - mean(changeInOrientationRepelAngles);
    % % Get attracted by Bison within the attract region
    % desiredOrientation(currBison) = desiredOrientation(currBison) + mean(changeInOrientationAttractAngles);
    % % Align to Bison in the align region
    % desiredOrientation(currBison) = desiredOrientation(currBison) + mean(changeInOrientationAlignAngles);  
    % % Get attracted to Water Sources with some gain
    % desiredOrientation(currBison) = desiredOrientation(currBison) + bisonGains(currBison)*changeInOrientationWSAngles;
    
    % Add the unit vectors together and then determine the orientation
    summedUnitVectors = -sum(changeInOrientationRepel, 1) + sum(changeInOrientationAttract, 1) + sum(changeInOrientationAlign, 1) + bisonGains(currBison)*sum(relativeWSUnitVector, 1);
%     desiredOrientation(currBison) = desiredOrientation(currBison) + atan2(summedUnitVectors(2), summedUnitVectors(1));
    desiredOrientation(currBison) = atan2(summedUnitVectors(2), summedUnitVectors(1));
end

% Calculate all the derivatives
dBisonX = bisonSpeed.*cos(bisonOrientation);
dBisonY = bisonSpeed.*sin(bisonOrientation);
dBisonSpeed = zeros(numberOfBison, 1);

desiredChangeInOrientation = wrapToPi(desiredOrientation - bisonOrientation);
dBisonOrientation = turnRate*sign(desiredChangeInOrientation);

% Store and return derivatives
dStateList = [dBisonX; dBisonY; dBisonSpeed; dBisonOrientation];
end