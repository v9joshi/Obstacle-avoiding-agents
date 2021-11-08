% Agent decision step
function actionInput = agentDecision(currAgent, params, decisionInput, actionInput)

% unpack required params
avoidDistance = params.avoidDistance;
attractDistance = params.attractDistance;
alignDistance = params.alignDistance;
obstacleDistance = params.obstacleDistance;

agentWeights = params.agentWeights;

noiseDegree = params.noiseDegree;

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
changeInOrientationAvoid(agentDistanceList > avoidDistance, :) = [];

% Get attracted to Agents that are close but not very close
changeInOrientationAttract = relativeAgentOrientation;
changeInOrientationAttract(alignDistance > agentDistanceList | agentDistanceList > attractDistance, :) = [];

% Get aligned with Agents that are close but not very close
changeInOrientationAlign = absoluteAgentOrientation;
changeInOrientationAlign(avoidDistance > agentDistanceList | agentDistanceList > alignDistance, :) = [];

% Get repelled by obstacles    
relativeObsUnitVector(obstacleDistance < distanceFromObsLocations, :) = [];

% changeInOrientationRepel = [changeInOrientationRepel; relativeObsUnitVector];

% Add the unit vectors together and then determine the orientation
if params.numberOfAgents == 1
    if isempty(relativeObsUnitVector) % if you're not near an obstacle still try to go towards the water source
        summedUnitVectors = agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1)...
                            + agentWeights.Persistence(currAgent)...
                            * sum([cos(absoluteAgentOrientation),sin(absoluteAgentOrientation)], 1);
    else % if you're near an obstacle forget all about the destination
        summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                            - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
    end    
else
    if isempty(changeInOrientationAvoid) && isempty(relativeObsUnitVector) % if you're not avoiding an agent or obstacle, do everything
        summedUnitVectors = agentWeights.Attraction(currAgent)*sum(changeInOrientationAttract, 1)...
                            + agentWeights.Alignment(currAgent)*sum(changeInOrientationAlign, 1)...
                            + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1);
    elseif isempty(relativeObsUnitVector) % if you're not near an obstacle still try to go towards the water source
        summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                            + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1);
    else % if you're near an obstacle forget all about the destination
        summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                            - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
                            % + agentGains(currAgent)*sum(relativeWSUnitVector, 1);
    end
end


if sqrt(sum(summedUnitVectors.^2)) == 0
    normalizedSum = [0, 0];
else
    normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
end

% Convert vectors to angle
desiredOrientation = atan2(normalizedSum(2), normalizedSum(1));

% Add some noise (in degree) to your desired orientation
desiredOrientationNoisy = desiredOrientation + (rand()-0.5)*2*pi*noiseDegree/360;

actionInput.desiredOrientation(currAgent) = desiredOrientationNoisy;

end