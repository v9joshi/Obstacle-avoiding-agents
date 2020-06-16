% Agent decision step
% Version where the strength of repulsion, attraction & alignment are
% proportional to the distances to other agents (Calovi et al. 2018)
function actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput)

% unpack required params
avoidDistance = params.avoidDistance;
attractDistance = params.attractDistance;
alignDistance = params.alignDistance;
obstacleDistance = params.obstacleDistance;
obstacleVisibility = params.obstacleVisibility;
obstacleSize = size(params.obstacleLocations,1); % To be replaced by some density measure

agentWeights = params.agentWeights;

% unpack the decision input variable
agentDistanceList = decisionInput.agentDistanceList;
relativeAgentOrientation = decisionInput.relativeAgentOrientation;
absoluteAgentOrientation = decisionInput.absoluteAgentOrientation;
distanceFromObsLocations = decisionInput.distanceFromObsLocations;
relativeWSUnitVector = decisionInput.relativeWSUnitVector;
relativeObsUnitVector = decisionInput.relativeObsUnitVector;

if params.numberOfAgents == 1
    % Get repelled by obstacles. Exponentially more the closer you are
    forcesOfObsRep = (1./distanceFromObsLocations)./obstacleSize;
    forcesOfObsRep = forcesOfObsRep*obstacleDistance;

    forcesOfObsRep(distanceFromObsLocations > obstacleVisibility, :) = 0; % No repulsion outside visual range
    forcesOfObsRep(distanceFromObsLocations < obstacleDistance, :) =...
        forcesOfObsRep(distanceFromObsLocations < obstacleDistance, :).*1000; % Avoid very close things a lot
    relativeObsUnitVector = relativeObsUnitVector.*[forcesOfObsRep, forcesOfObsRep];
    
    % Sum all the agent behaviors
    summedUnitVectors =  agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1)...
                        - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
else
    % Get repulsed by close by Agents
    forcesOfRep = -(agentDistanceList-avoidDistance).^agentWeights.Avoidance(currAgent);
    changeInOrientationAvoid = relativeAgentOrientation.*[forcesOfRep, forcesOfRep];
    changeInOrientationAvoid(agentDistanceList > avoidDistance, :) = [];
    
    % Get attracted by farther away agents
    forcesOfAtt = agentWeights.Attraction(currAgent)-...
        (agentWeights.Attraction(currAgent)/attractDistance^2)...
        *(agentDistanceList-(avoidDistance+attractDistance)).^2;
    changeInOrientationAttract = relativeAgentOrientation.*[forcesOfAtt, forcesOfAtt];
    changeInOrientationAttract(agentDistanceList < avoidDistance, :) = [];

    % Get aligned with Agents
    forcesOfAlign = agentWeights.Alignment(currAgent) -...
        (agentWeights.Alignment(currAgent)/alignDistance)*(agentDistanceList-avoidDistance).^2;
    forcesOfAlign(forcesOfAlign<0) = 0;
    changeInOrientationAlign = absoluteAgentOrientation.*[forcesOfAlign, forcesOfAlign];

    % Get repelled by obstacles. Exponentially more the closer you are
    forcesOfObsRep = (1./distanceFromObsLocations)./obstacleSize;
    forcesOfObsRep = forcesOfObsRep*obstacleDistance;

    forcesOfObsRep(distanceFromObsLocations > obstacleVisibility, :) = 0; % No repulsion outside visual range
    forcesOfObsRep(distanceFromObsLocations < obstacleDistance, :) =...
        forcesOfObsRep(distanceFromObsLocations < obstacleDistance, :).*1000; % Avoid very close things a lot
    relativeObsUnitVector = relativeObsUnitVector.*[forcesOfObsRep, forcesOfObsRep];


    % Add the unit vectors together and then determine the orientation
    summedUnitVectors = sum(changeInOrientationAttract, 1)...
                        - sum(changeInOrientationAvoid, 1)...
                        + sum(changeInOrientationAlign, 1)...
                        + agentWeights.Destination(currAgent)*sum(relativeWSUnitVector, 1)...
                        - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
end

if sqrt(sum(summedUnitVectors.^2)) == 0
    normalizedSum = [0, 0];
else
    normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
end

actionInput.desiredOrientation(currAgent) = atan2(normalizedSum(2), normalizedSum(1));

end