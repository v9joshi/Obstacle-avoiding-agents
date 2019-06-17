% Determine if the observing agent can see the observed agent given
% obstacle locations and size of the agent.
function agentVisibility = isAgentVisible(observingAgent, observedAgent, obstacles, agentLength)
    % Assume agent is visible
    agentVisibility = 1; % Yes agent is visible
    
    % Determine distance and orientation of observed agent from observing
    % agent
    relativeAgentAngle = atan2(observedAgent(2) - observingAgent(2), observedAgent(1) - observingAgent(1));
    agentDistance = sqrt(sum(observedAgent - observingAgent).^2);
    
    % Angular range required for observation
    angularRange = agentLength/agentDistance; % Observed agent subtends this angle at observing agent eye

    % Determine visual obstruction
    relativeObstacleAngle = atan2(obstacles(:,2) - observingAgent(2), obstacles(:,1) - observingAgent(1));
    obstacleDistance = sqrt(sum((obstacles - repmat(observingAgent, length(obstacles), 1)).^2, 2));
    
    % Determine which obstructions are active
    agentObstruction = zeros(length(obstacles), 1);
    agentObstruction((abs(relativeObstacleAngle - relativeAgentAngle) < angularRange) & (obstacleDistance < agentDistance)) = 1;
    
    % Set visibility
    agentVisibility = ~sum(agentObstruction); % if even one obstruction is active then visibility is 0    
end