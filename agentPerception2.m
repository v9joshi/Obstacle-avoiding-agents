% Agent perception step
function decisionInput = agentPerception2(currAgent, stateList, params)
    % unpack some parameters
    numberOfAgents = params.numberOfAgents;
    waterSourceLocations = params.waterSourceLocations;
    obstacleLocations = params.obstacleLocations;
    numberOfNeighbors = params.numberOfNeighbors;

    % unpack the states of the agents
    agentX = stateList(1:numberOfAgents);
    agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
    agentSpeed = stateList(2*numberOfAgents + 1: 3*numberOfAgents);
    agentOrientation = stateList(3*numberOfAgents + 1:end);

    % Agent positions in 2D
    agentPositions = [agentX, agentY];

    % Where is the current agent located?
    currAgentPosition = agentPositions(currAgent, :);

    % where are the rest of the agents relative to the current agent
    relativePositions = agentPositions - repmat(currAgentPosition, size(agentPositions, 1), 1);
    relativePositions(currAgent, :) = [];

    otherAgentOrientations = agentOrientation;
    otherAgentOrientations(currAgent) =  [];

    % Where are the Water Sources located relative to the current Agent?
    relativeWSLocations = waterSourceLocations - repmat(currAgentPosition, size(waterSourceLocations, 1), 1);
    distanceFromWSLocations = sqrt(sum(relativeWSLocations.^2, 2));
    decisionInput.distanceFromWSLocations = distanceFromWSLocations;

    % Where are the Obstacles located relative to the current Agent?
    relativeObsLocations = obstacleLocations - repmat(currAgentPosition, size(obstacleLocations, 1), 1);
    distanceFromObsLocations = sqrt(sum(relativeObsLocations.^2, 2));
    decisionInput.distanceFromObsLocations = distanceFromObsLocations;

    % What is the distance between our Agent and the rest?
    agentDistanceList = sqrt(sum(relativePositions.^2, 2));
    
    % Determine the visibility of other agents and drop agents that can't be
    % seen
    agentLength = params.agentLength;
    agentVisible = ones(size(relativePositions, 1), 1);
    
    for otherAgentNum = 1:size(relativePositions, 1)
        agentVisible(otherAgentNum) = isAgentVisible2(relativePositions(otherAgentNum,:), relativeObsLocations, agentDistanceList(otherAgentNum), distanceFromObsLocations,agentLength);
    end

    % Use vectors to obstacle and goal to determine goal visibility
    goalSize = params.goalSize;
    for goalNumber = 1:size(waterSourceLocations, 1)
        decisionInput.goalVisibility(goalNumber) = isAgentVisible2(relativeWSLocations(goalNumber, :), relativeObsLocations, distanceFromWSLocations(goalNumber), distanceFromObsLocations, goalSize);
    end

    % Order agents based on distance, closest first, furthest last, but
    % only for visible agents
    [~, sortedAgentList] = sort(agentDistanceList(agentVisible == 1)); % determine the sorting order
    
    % Drop agents that aren't within the nearest set of neighbors defined by
    % numberOfNeighbors parameter
    neighborIndices = sortedAgentList(1:min(length(sortedAgentList), numberOfNeighbors));

    % Overwrite all the perception variables to contain only neighbors
    agentDistanceList = agentDistanceList(neighborIndices);
    relativePositions = relativePositions(neighborIndices,:);
    otherAgentOrientations = otherAgentOrientations(neighborIndices,:);
    decisionInput.agentDistanceList = agentDistanceList; 

    % Use distance and location to determine the unit vector to the water
    % source
    decisionInput.relativeWSUnitVector = [relativeWSLocations(:,1)./distanceFromWSLocations, relativeWSLocations(:,2)./distanceFromWSLocations];

    % Use distance and locations to determine unit vectors to the obstacles
    decisionInput.relativeObsUnitVector = [relativeObsLocations(:,1)./distanceFromObsLocations, relativeObsLocations(:,2)./distanceFromObsLocations];

    % Use distance and locations to determine unit vectors to other agents
    decisionInput.relativeAgentOrientation = [relativePositions(:,1)./agentDistanceList, relativePositions(:,2)./agentDistanceList];

    % Use other agent orientations to determine their direction unit vectors
    decisionInput.absoluteAgentOrientation = [cos(otherAgentOrientations), sin(otherAgentOrientations)];
end