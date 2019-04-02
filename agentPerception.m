% Agent perception step
function decisionInput = agentPerception(currAgent, stateList, params)

% unpack some parameters
numberOfAgents = params.numberOfAgents;
waterSourceLocations = params.waterSourceLocations;
obstacleLocations = params.obstacleLocations;

% unpack the states of the agents
agentX = stateList(1:numberOfAgents);
agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
agentSpeed = stateList(2*numberOfAgents + 1: 3*numberOfAgents);
agentOrientation = stateList(3*numberOfAgents + 1:end);

% Agent positions in 2D
agentPositions = [agentX, agentY];
  
% Where is the current agent located?
currAgentPosition = agentPositions(currAgent, :);

% where are the rest of the agents?
otherAgentPositions = agentPositions;
otherAgentPositions(currAgent, :) = [];

otherAgentOrientations = agentOrientation;
otherAgentOrientations(currAgent) =  [];

% What is the distance between our Agent and the rest?
relativePositions = otherAgentPositions - repmat(currAgentPosition, numberOfAgents - 1, 1);
agentDistanceList = sqrt(sum(relativePositions.^2, 2));
decisionInput.agentDistanceList = agentDistanceList;

% Use distance and locations to determine unit vectors to other agents
decisionInput.relativeAgentOrientation = [relativePositions(:,1)./agentDistanceList, relativePositions(:,2)./agentDistanceList];

% Use other agent orientations to determine their direction unit vectors
decisionInput.absoluteAgentOrientation = [cos(otherAgentOrientations), sin(otherAgentOrientations)];

% Where are the Water Sources located relative to the current Agent?
relativeWSLocations = waterSourceLocations - repmat(currAgentPosition, size(waterSourceLocations, 1), 1);
distanceFromWSLocations = sqrt(sum(relativeWSLocations.^2, 2));
decisionInput.distanceFromWSLocations = distanceFromWSLocations;

% Use distance and location to determine the unit vector to the water
% source
decisionInput.relativeWSUnitVector = [relativeWSLocations(:,1)./distanceFromWSLocations, relativeWSLocations(:,2)./distanceFromWSLocations];

% Where are the Obstacles located relative to the current Agent?
relativeObsLocations = obstacleLocations - repmat(currAgentPosition, size(obstacleLocations, 1), 1);
distanceFromObsLocations = sqrt(sum(relativeObsLocations.^2, 2));
decisionInput.distanceFromObsLocations = distanceFromObsLocations;

% Use distance and locations to determine unit vectors to the obstacles
decisionInput.relativeObsUnitVector = [relativeObsLocations(:,1)./distanceFromObsLocations, relativeObsLocations(:,2)./distanceFromObsLocations];
end