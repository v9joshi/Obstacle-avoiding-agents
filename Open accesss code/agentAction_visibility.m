% Agent action:
% Move the agent in the desired direction at the specified speed.
% Check for collisions with obstacles and prevent phasing through.
function stateListNew = agentAction_visibility(stateList, params, actionInput)
    %% unpack parameters
    % General simulation parameters
    numberOfAgents = params.numberOfAgents;
    stepTime = params.stepTime;
    turnRate = params.turnRate;

    % Obstacle parameters
    obstacleType   = params.obstacleType;
    obstacleCenter = params.obstacleCenter;
    obstacleRadius = params.obstacleRadius;

    obstacleSpacing = params.obstacleSpacing;

    % unpack the states of the agent
    agentX = stateList(1:numberOfAgents);
    agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
    
    % unpack the action input
    agentSpeed = actionInput.desiredSpeed;
    agentOrientation = stateList(3*numberOfAgents + 1:end);
    desiredOrientation = actionInput.desiredOrientation;

    % Calculate all the required derivatives
    dAgentX = agentSpeed.*cos(agentOrientation);
    dAgentY = agentSpeed.*sin(agentOrientation);
    
    % Speed is handled without acceleration, just changed instantaneously
    dAgentSpeed = zeros(numberOfAgents, 1); %(actionInput.desiredSpeed - agentSpeed)/stepTime;
    desiredChangeInOrientation = 0*agentOrientation;

    % Determine the correct change in orientation desired
    for currAgent = 1:numberOfAgents
        if abs(agentOrientation(currAgent)) > pi
            agentOrientation(currAgent) = mod(agentOrientation(currAgent) + pi, 2*pi) - pi;
        end

        desiredChangeInOrientation(currAgent) = desiredOrientation(currAgent) - agentOrientation(currAgent);

        if (abs(desiredChangeInOrientation(currAgent)) > pi)
            desiredChangeInOrientation(currAgent) = mod(desiredChangeInOrientation(currAgent) + pi, 2*pi) - pi;
        end
    end
    
    % Limit the change in orientation based on turn rate.
    dAgentOrientation = min(abs(desiredChangeInOrientation)/stepTime, turnRate).*sign(desiredChangeInOrientation);

    % Store the derivatives
    dStateList = [dAgentX; dAgentY; dAgentSpeed; dAgentOrientation];
    
    % Apply a one step euler integral
    stateListNew = stateList + stepTime.*dStateList;
    
    %% Check for wall collisions
    % Where does the agent go?
    newX = agentX + stepTime.*dAgentX;
    newY = agentY + stepTime.*dAgentY;

    %% Check for wall collision (only works with the arc)
    for currAgent = 1:numberOfAgents
        relativePosition     = [newX(currAgent) - agentX(currAgent), newY(currAgent) - agentY(currAgent)];
        relativeObsLocations = [params.obstacleLocations(:,1) - agentX(currAgent), params.obstacleLocations(:,2) - agentY(currAgent)];

        distanceFromObsLocations = sqrt(sum(relativeObsLocations.^2, 2));
        agentDistance            = sqrt(sum(relativePosition.^2));

        if ~isAgentVisible(relativePosition, relativeObsLocations, agentDistance, distanceFromObsLocations, obstacleSpacing)
            newX(currAgent) = agentX(currAgent); %(newX(currAgent) + agentX(currAgent))/2;
            newY(currAgent) = agentY(currAgent); %(newY(currAgent) + agentY(currAgent))/2;
        end
    end   
    
    %% Return the new states
    stateListNew(1:numberOfAgents) = newX;
    stateListNew(numberOfAgents+1: 2*numberOfAgents) = newY;
    stateListNew(2*numberOfAgents+1 : 3*numberOfAgents) = agentSpeed;
end