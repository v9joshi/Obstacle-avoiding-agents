function stateListNew = agentAction(currAgent, stateList, params, actionInput)

    % unpack parameters
    stepTime = params.stepTime;
    turnRate = params.turnRate;
    agentSpeed = params.agentSpeed;
    agentOrientation = actionInput.agentOrientation;
    desiredOrientation = actionInput.desiredOrientation;

    % Calculate all the derivatives
    dAgentX = agentSpeed.*cos(agentOrientation);
    dAgentY = agentSpeed.*sin(agentOrientation);
    dAgentSpeed = zeros(numberOfAgents, 1);

    dAgentOrientation = zeros(numberOfagent, 1);
    
    agentOrientation(curragent) = wrapToPi(agentOrientation(currAgent));
    desiredChangeInOrientation = wrapToPi(desiredOrientation(currAgent) - agentOrientation(currAgent));
    if abs(desiredChangeInOrientation) < turnRate*timeStep
        dAgentOrientation(currAgent) = desiredChangeInOrientation/timeStep;
    else
        dAgentOrientation(currAgent) = turnRate*sign(desiredChangeInOrientation);
    end
    
    % Store and return derivatives
    dStateList = [dAgentX; dAgentY; dAgentSpeed; dAgentOrientation];

    % Apply a one step euler integral
    stateListNew = stateList + stepTime.*dStateList;
end