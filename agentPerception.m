% Agent perception step
function decisionInput = agentPerception(stateList, params)

numberOfBison = params.numberOfBison;
waterSourceLocations = params.waterSourceLocations;
obstacleLocations = params.obstacleLocations;

% unpack the states of the bison
bisonX = stateList(1:numberOfBison);
bisonY = stateList(numberOfBison + 1: 2*numberOfBison);
bisonSpeed = stateList(2*numberOfBison + 1: 3*numberOfBison);
bisonOrientation = stateList(3*numberOfBison + 1:end);

% Bison positions in 2D
bisonPositions = [bisonX, bisonY];

for currBison = 1:numberOfBison
    changeInOrientation = 0;
    
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
    
    absoluteOrientation = [cos(otherBisonOrientations), sin(otherBisonOrientations)];
end


end