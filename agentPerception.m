% agentPerception:
% Agent Perception step for all models.
% Determine relative orientations and distances to all other agents,
% all obstacle points and the destination.
function decisionInput = agentPerception(currAgent, stateList, params)
    %% unpack some parameters
    numberOfAgents = params.numberOfAgents;

    destinationLocations = params.destinationLocations;
    obstacleLocations    = params.obstacleLocations;
    numberOfNeighbors    = params.numberOfNeighbors;

    %% unpack the states of the agents
    agentX = stateList(1:numberOfAgents);
    agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
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

    %% Where is the destination located relative to the current Agent?
    relativeDesLocations = destinationLocations - repmat(currAgentPosition, size(destinationLocations, 1), 1);
    distanceFromDesLocations = sqrt(sum(relativeDesLocations.^2, 2));
    decisionInput.distanceFromDesLocations = distanceFromDesLocations;

    %% Where are the Obstacles located relative to the current Agent?
    relativeObsLocations = obstacleLocations - repmat(currAgentPosition, size(obstacleLocations, 1), 1);
    distanceFromObsLocations = sqrt(sum(relativeObsLocations.^2, 2));
    decisionInput.distanceFromObsLocations = distanceFromObsLocations;

    % What is the distance between our Agent and the rest?
    agentDistanceList = sqrt(sum(relativePositions.^2, 2));
    
    %% Determine the visibility of other agents and drop agents that can't be seen
    obstacleSpacing = params.obstacleSpacing;
    agentVisible = ones(size(relativePositions, 1), 1);
    
    for otherAgentNum = 1:size(relativePositions, 1)
        agentVisible(otherAgentNum) = isAgentVisible(relativePositions(otherAgentNum,:), relativeObsLocations, agentDistanceList(otherAgentNum), distanceFromObsLocations,obstacleSpacing);
    end

    % Use vectors to obstacle and goal to determine goal visibility
    for goalNumber = 1:size(destinationLocations, 1)
        decisionInput.goalVisibility(goalNumber) = isAgentVisible(relativeDesLocations(goalNumber, :), relativeObsLocations, distanceFromDesLocations(goalNumber), distanceFromObsLocations, obstacleSpacing);
    end

    % Order agents based on distance, closest first, furthest last
    [~, sortedAgentList] = sort(agentDistanceList); % determine the sorting order
    
    % Drop hidden agents
    sortedAgentList = sortedAgentList(agentVisible(sortedAgentList) == 1);
    
    % Drop agents that aren't within the nearest set of neighbors defined by
    % numberOfNeighbors parameter
    neighborIndices = sortedAgentList(1:min(length(sortedAgentList), numberOfNeighbors));

    % Overwrite all the perception variables to contain only neighbors
    agentDistanceList = agentDistanceList(neighborIndices);
    relativePositions = relativePositions(neighborIndices,:);
    otherAgentOrientations = otherAgentOrientations(neighborIndices,:);

    %% Construct the output structure
    % Agent distances
    decisionInput.agentDistanceList = agentDistanceList; 

    % Use distance and location to determine the unit vector to the destination
    decisionInput.relativeDesUnitVector = [relativeDesLocations(:,1)./distanceFromDesLocations, relativeDesLocations(:,2)./distanceFromDesLocations];

    % Use distance and locations to determine unit vectors to the obstacles
    decisionInput.relativeObsUnitVector = [relativeObsLocations(:,1)./distanceFromObsLocations, relativeObsLocations(:,2)./distanceFromObsLocations];

    % Use distance and locations to determine unit vectors to other agents
    decisionInput.relativeAgentOrientation = [relativePositions(:,1)./agentDistanceList, relativePositions(:,2)./agentDistanceList];

    % Use other agent orientations to determine their direction unit vectors
    if numberOfAgents == 1
        decisionInput.absoluteAgentOrientation = agentOrientation(currAgent);
    else
        decisionInput.absoluteAgentOrientation = [cos(otherAgentOrientations), sin(otherAgentOrientations)];
    end
end