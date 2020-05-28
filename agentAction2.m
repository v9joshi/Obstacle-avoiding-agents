function stateListNew = agentAction2(stateList, params, actionInput)

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

desiredChangeInOrientation = 0*agentOrientation;

for currAgent = 1:numberOfAgents
    if abs(agentOrientation(currAgent)) > pi
        agentOrientation(currAgent) = mod(agentOrientation(currAgent) + pi, 2*pi) - pi;
    end
    
    desiredChangeInOrientation(currAgent) = desiredOrientation(currAgent) - agentOrientation(currAgent);
    
    if (abs(desiredChangeInOrientation(currAgent)) > pi)
        desiredChangeInOrientation(currAgent) = mod(desiredChangeInOrientation(currAgent) + pi, 2*pi) - pi;
    end
end


dAgentOrientation = min(abs(desiredChangeInOrientation)/stepTime, turnRate).*sign(desiredChangeInOrientation);

% Store and return derivatives
dStateList = [dAgentX; dAgentY; dAgentSpeed; dAgentOrientation];

% Apply a one step euler integral
stateListNew = stateList + stepTime.*dStateList;
end