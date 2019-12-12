% Determine if the observing agent can see the observed agent given
% obstacle locations and size of the agent.
function agentVisibility = isAgentVisible3(observedAgent, obstacles, agentDistance, obstacleDistance, obstacleSpacing)
    % Determine vector in the observer observed agent direction - OO line
    observedAgent = observedAgent/agentDistance;
    
    % Determine normal distance between the OO line and the obstacle
    obstacleNormalDistance = abs(-obstacles(:,2)*observedAgent(1) + obstacles(:,1)*observedAgent(2));
    
    % Determine dot product between OO vector and the observer-Obstacle
    % vector
    vectorDotProduct = (obstacles(:,1)*observedAgent(1) + obstacles(:,2)*observedAgent(2));
    
    % If 
    % 1) The obstacle is very close to the OO line.
    % 2) The obstacle is closer to the observer than the observed agent is.
    % 3) The dot product of the OO vector and the Observer-Obstacle vector
    %    should be positive.
    % Then the observed agent is being blocked
    agentObstruction = ((obstacleNormalDistance < obstacleSpacing/2) & obstacleDistance < agentDistance & vectorDotProduct >= 0);    
    
    % Set visibility
    agentVisibility = ~any(agentObstruction); % if even one obstruction is active then visibility is 0    
end