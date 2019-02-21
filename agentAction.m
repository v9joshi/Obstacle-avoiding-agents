function stateListNew = agentAction(stateList, params, actionInput)

% unpack parameters
numberOfAgents = params.numberOfAgents;
stepTime = params.stepTime;
turnRate = params.turnRate;

% unpack the states of the agent
agentX = stateList(1:numberOfAgents);
agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
agentSpeed = stateList(2*numberOfAgents + 1: 3*numberOfAgents);
agentOrientation = stateList(3*numberOfAgents + 1:end);

% unpack the action input
desiredOrientation = actionInput.desiredOrientation;

% Calculate all the derivatives
dAgentX = agentSpeed.*cos(agentOrientation);
dAgentY = agentSpeed.*sin(agentOrientation);
dAgentSpeed = zeros(numberOfAgents, 1);

dAgentOrientation = zeros(numberOfAgents, 1);

for currAgent = 1:numberOfAgents
    agentOrientation(currAgent) = wrapToPi(agentOrientation(currAgent));
    desiredChangeInOrientation = wrapToPi(desiredOrientation(currAgent) - agentOrientation(currAgent));
    if abs(desiredChangeInOrientation) < turnRate*stepTime
        dAgentOrientation(currAgent) = desiredChangeInOrientation/stepTime;
    else
        dAgentOrientation(currAgent) = turnRate*sign(desiredChangeInOrientation);
    end
end

% Store and return derivatives
dStateList = [dAgentX; dAgentY; dAgentSpeed; dAgentOrientation];

% Apply a one step euler integral
stateListNew = stateList + stepTime.*dStateList;
end