% Agent decision step
function actionInput = agentDecision_nlsp(currAgent, params, decisionInput, actionInput)

% unpack required params
avoidDistance = params.avoidDistance;
attractDistance = params.attractDistance;
alignDistance = params.alignDistance;
obstacleDistance = params.obstacleDistance;

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
relativeObsUnitVector = decisionInput.relativeObsUnitVector;
relativeWSUnitVector = decisionInput.relativeWSUnitVector;

% Get repelled by close by Agents
changeInOrientationAvoid = relativeAgentOrientation;
% Replacing binary switches with tanh
avoidScaling = (1 - tanh((agentDistanceList - avoidDistance)*16))/2;
changeInOrientationAvoid = changeInOrientationAvoid.*[avoidScaling, avoidScaling];

% changeInOrientationAvoid(agentDistanceList > avoidDistance, :) = [];

% Get attracted to Agents that are close but not very close
changeInOrientationAttract = relativeAgentOrientation;
% Replacing binary switches with tanh
attractScaling = (1 + tanh((agentDistanceList - alignDistance)*16)).*(1 - tanh((agentDistanceList - attractDistance)*4))/4;
changeInOrientationAttract = changeInOrientationAttract.*[attractScaling, attractScaling];
% changeInOrientationAttract(avoidDistance > agentDistanceList | agentDistanceList > attractDistance, :) = [];

% Get aligned with Agents that are close but not very close
changeInOrientationAlign = absoluteAgentOrientation;

% Replacing binary switches with tanh
alignScaling = (1 + tanh((agentDistanceList - avoidDistance)*16)).*(1 - tanh((agentDistanceList - alignDistance)*4))/4;
changeInOrientationAlign = changeInOrientationAlign.*[alignScaling, alignScaling];
% changeInOrientationAlign(avoidDistance > agentDistanceList | agentDistanceList > alignDistance, :) = [];

% Get repelled by obstacles    
obsScaling = (1 - tanh((distanceFromObsLocations - obstacleDistance)*4))/2;
relativeObsUnitVector = relativeObsUnitVector.*[obsScaling, obsScaling];

% If interacting with obstacle or avoiding another agent forget about
% aligning and attracting
changeInOrientationAlign   = changeInOrientationAlign*min(1 - obsScaling)*min(1 - [avoidScaling; 0]);
changeInOrientationAttract = changeInOrientationAttract*min(1 - obsScaling)*min(1 - [avoidScaling; 0]);


% If interacting with an obstacle forget about the destination
relativeWSUnitVector = relativeWSUnitVector*min(1 - obsScaling);

summedUnitVectors =   agentWeights.Attraction(currAgent)*sum(changeInOrientationAttract, 1)...
                    + agentWeights.Alignment(currAgent)*sum(changeInOrientationAlign, 1)...
                    + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1)...
                    - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                    - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);

% relativeObsUnitVector(obstacleDistance < distanceFromObsLocations, :) = [];

% changeInOrientationRepel = [changeInOrientationRepel; relativeObsUnitVector];

% Add the unit vectors together and then determine the orientation
% if max(obsScaling)%isempty(changeInOrientationAvoid) && isempty(relativeObsUnitVector)
%     summedUnitVectors = agentWeights.Attraction(currAgent)*sum(changeInOrientationAttract, 1)...
%                         + agentWeights.Alignment(currAgent)*sum(changeInOrientationAlign, 1)...
%                         + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1);
% elseif isempty(relativeObsUnitVector) % if you're not near an obstacle still try to go towards the water source
%     summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
%                         + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1);
% else % if you're near an obstacle forget all about the destination
%     summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
%                         - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
%                         + agentGains(currAgent)*sum(relativeWSUnitVector, 1);
% end

if sqrt(sum(summedUnitVectors.^2)) == 0
    normalizedSum = [0, 0];
else
    normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
end

actionInput.desiredOrientation(currAgent) = atan2(normalizedSum(2), normalizedSum(1));

end