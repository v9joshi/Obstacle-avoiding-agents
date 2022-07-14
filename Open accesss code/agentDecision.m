% agentDecision:
% Agent decision step for the discrete/zonal model.
% Reads the state of an agent and its neighbours and determines the desired
% heading direction. Repulsion, attraction & alignment are restricted to 
% distinct zones.
function actionInput = agentDecision(currAgent, params, decisionInput, actionInput)
    %% Unpack required distance parameters
    avoidDistance    = params.avoidDistance;
    attractDistance  = params.attractDistance;
    alignDistance    = params.alignDistance;
    obstacleDistance = params.obstacleDistance;
    
    % Unpack social behavior weights
    agentWeights = params.agentWeights;
    
    %% Unpack the decision input variable that comes from the perception step
    % Where are other agents located?
    agentDistanceList        = decisionInput.agentDistanceList;
    relativeAgentOrientation = decisionInput.relativeAgentOrientation;
    absoluteAgentOrientation = decisionInput.absoluteAgentOrientation;
   
    % Where are the obstalces and the destination located?
    distanceFromObsLocations = decisionInput.distanceFromObsLocations;
    relativeObsUnitVector = decisionInput.relativeObsUnitVector;
    relativeDesUnitVector  = decisionInput.relativeDesUnitVector;
    
    % Get repelled by close by Agents
    changeInOrientationAvoid = relativeAgentOrientation;
    changeInOrientationAvoid(agentDistanceList > avoidDistance, :) = [];
    
    % Get aligned with Agents that are close but not very close
    changeInOrientationAlign = absoluteAgentOrientation;
    changeInOrientationAlign(avoidDistance > agentDistanceList | agentDistanceList > alignDistance, :) = [];
    
    % Get attracted to Agents that are close but not very close
    changeInOrientationAttract = relativeAgentOrientation;
    changeInOrientationAttract(alignDistance > agentDistanceList | agentDistanceList > attractDistance, :) = [];
        
    % Get repelled by obstacles    
    relativeObsUnitVector(obstacleDistance < distanceFromObsLocations, :) = [];
        
    %% Add the unit vectors together and then determine the desired heading
    if params.numberOfAgents == 1 % Special case handling
        if isempty(relativeObsUnitVector) % if you're not near an obstacle still try to go towards the water source
            summedUnitVectors = agentWeights.Destination(currAgent)*sum(relativeDesUnitVector, 1)...
                                + agentWeights.Persistence(currAgent)...
                                * sum([cos(absoluteAgentOrientation),sin(absoluteAgentOrientation)], 1);
        
        else % if you're near an obstacle forget all about the destination
            summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                                - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
        end    
    else % Typical scenario with more than one agent
        if isempty(changeInOrientationAvoid) && isempty(relativeObsUnitVector) % if you're not avoiding an agent or obstacle, consider all behavior
            summedUnitVectors = agentWeights.Attraction(currAgent)*sum(changeInOrientationAttract, 1)...
                                + agentWeights.Alignment(currAgent)*sum(changeInOrientationAlign, 1)...
                                + agentWeights.Destination(currAgent)*sum(relativeDesUnitVector, 1);

        elseif isempty(relativeObsUnitVector) % if you're not near an obstacle still try to go towards the water source
            summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                                + agentWeights.Destination(currAgent)*sum(relativeDesUnitVector, 1);
        
        else % if you're near an obstacle forget all about the destination
            summedUnitVectors = - agentWeights.Avoidance(currAgent)*sum(changeInOrientationAvoid, 1)...
                                - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
        end
    end
    
    % Normalize the result
    if sqrt(sum(summedUnitVectors.^2)) == 0 % Exception handling when sum is 0
        normalizedSum = [0, 0];
    else
        normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
    end
    
    %% Find the heading angle 
    % Convert direction vector to angle
    desiredOrientation = atan2(normalizedSum(2), normalizedSum(1));

    % Store the result and return it
    actionInput.desiredOrientation(currAgent) = desiredOrientation;
end