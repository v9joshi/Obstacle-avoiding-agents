% agentDecisionContin:
% Agent decision step for the continuous model:
% Reads the state of an agent and its neighbours and determines the desired
% heading direction. The strength of repulsion, attraction & alignment are 
% continuous rather than restricted to distinct zones.
function actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput)
    %% Unpack the required parameters
    % Unpack all the behavior radii
    avoidDistance    = params.avoidDistance;
    attractDistance  = params.attractDistance;
    alignDistance    = params.alignDistance;
    obstacleDistance = params.obstacleDistance;

    % Unpack special variables for continuous model
    obstacleVisibility = params.obstacleVisibility;
    obstacleSize = size(params.obstacleLocations,1);
    
    % Unpack the agent weights
    agentWeights = params.agentWeights;
    
    %% unpack the decision input variable
    % Where are other agents located?
    agentDistanceList = decisionInput.agentDistanceList;
    relativeAgentOrientation = decisionInput.relativeAgentOrientation;
    absoluteAgentOrientation = decisionInput.absoluteAgentOrientation;
    
    % Where are the obstalces and the destination located?
    distanceFromObsLocations = decisionInput.distanceFromObsLocations;
    relativeObsUnitVector = decisionInput.relativeObsUnitVector;

    relativeDesUnitVector = decisionInput.relativeDesUnitVector;
    
    %% Determine the desired heading
    if params.numberOfAgents == 1 % Exception handling when there is just one agent
        % Get repelled by obstacles. Exponentially more the closer you are
        forcesOfObsRep = (1./distanceFromObsLocations)./obstacleSize;
        forcesOfObsRep = forcesOfObsRep*obstacleDistance;
    
        forcesOfObsRep(distanceFromObsLocations > obstacleVisibility, :) = 0; % No repulsion outside visual range
        forcesOfObsRep(distanceFromObsLocations < obstacleDistance, :) =...
            forcesOfObsRep(distanceFromObsLocations < obstacleDistance, :).*1000; % Avoid very close things a lot
        relativeObsUnitVector = relativeObsUnitVector.*[forcesOfObsRep, forcesOfObsRep];
        
        % Sum all the agent behaviors to get the heading direction
        summedUnitVectors =  agentWeights.Destination(currAgent)*sum(relativeDesUnitVector, 1)...
                            - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
    
    else % Typical case with multiple agents
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
    
    
        % Add the unit vectors together and then determine heading direction
        summedUnitVectors = sum(changeInOrientationAttract, 1)...
                            - sum(changeInOrientationAvoid, 1)...
                            + sum(changeInOrientationAlign, 1)...
                            + agentWeights.Destination(currAgent)*sum(relativeDesUnitVector, 1)...
                            - agentWeights.Obstacle(currAgent)*sum(relativeObsUnitVector, 1);
    end
    
    %% Convert the heading direction to an angle
    if sqrt(sum(summedUnitVectors.^2)) == 0
        normalizedSum = [0, 0];
    else
        normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
    end
    
    % Return the resulting desired orientation
    actionInput.desiredOrientation(currAgent) = atan2(normalizedSum(2), normalizedSum(1));

end