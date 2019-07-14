% Agent decision step
% Version where the strength of repulsion, attraction & alignment are
% proportional to the distances to other agents (Calovi et al. 2018)
function actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput)

% unpack required params
avoidDistance = params.avoidDistance;
attractDistance = params.attractDistance;
alignDistance = params.alignDistance;
alignYintercept = params.alignYintercept;
obstacleDistance = params.obstacleDistance;
obstacleVisibility = params.obstacleVisibility;
obstacleSize = size(params.obstacleLocations,1); % To be replaced by some density measure

agentWeights = params.agentWeights;

% % unpack the states of the agent
% agentX = stateList(1:numberOfAgents);
% agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
% agentSpeed = stateList(2*numberOfAgents + 1: 3*numberOfAgents);
% agentOrientation = stateList(3*numberOfAgents + 1:end);

% unpack the decision input variable
agentDistanceList = decisionInput.agentDistanceList;
relativeAgentOrientation = decisionInput.relativeAgentOrientation;
absoluteAgentOrientation = decisionInput.absoluteAgentOrientation;
distanceFromObsLocations = decisionInput.distanceFromObsLocations;
relativeWSUnitVector = decisionInput.relativeWSUnitVector;
goalVisibility = decisionInput.goalVisibility;

% Get repulsed by close & attracted by farther away agents
forcesOfAtt = (agentDistanceList - avoidDistance)./(1+(agentDistanceList/attractDistance).^2);
changeInOrientationAttract = relativeAgentOrientation.*[forcesOfAtt forcesOfAtt];

% Get aligned with Agents
forcesOfAlign = (alignYintercept + agentDistanceList).^(-(agentDistanceList/alignDistance).^2);
changeInOrientationAlign = absoluteAgentOrientation.*[forcesOfAlign forcesOfAlign];

% Get repelled by obstacles. Exponentially more the closer you are
relativeObsUnitVector = (1./distanceFromObsLocations)./obstacleSize;
relativeObsUnitVector(distanceFromObsLocations > obstacleVisibility, :) = 0; % No repulsion outside visual range
relativeObsUnitVector(distanceFromObsLocations < obstacleDistance, :) =...
    relativeObsUnitVector(distanceFromObsLocations < obstacleDistance, :).*1000; % Avoid very close things a lot

if goalVisibility == 1
    relativeObsUnitVector = 0;
end

% Add the unit vectors together and then determine the orientation
summedUnitVectors = agentWeights.Attraction(currAgent)*sum(changeInOrientationAttract, 1)...
                    + agentWeights.Alignment(currAgent)*sum(changeInOrientationAlign, 1)...
                    + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1)...
                    - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);


if sqrt(sum(summedUnitVectors.^2)) == 0
    normalizedSum = [0, 0];
else
    normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
end

actionInput.desiredOrientation(currAgent) = atan2(normalizedSum(2), normalizedSum(1));

end