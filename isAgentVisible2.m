% Determine if the observing agent can see the observed agent given
% obstacle locations and size of the agent.
function agentVisibility = isAgentVisible2(observedAgent, obstacles, agentDistance, obstacleDistance, agentLength)
    % Determine distance of observed agent from observing agent
    observedAgent = observedAgent/agentDistance;
    
    % Angular range required for observation
    angularRange = agentLength/agentDistance; % Observed agent subtends this angle at observing agent eye
   
    % Find vectors that correspond to the visual range occupied by the
    % agent
    cwBound = observedAgent - angularRange*[-observedAgent(2), observedAgent(1)];  % Clockwise bound
    ccwBound = observedAgent + angularRange*[-observedAgent(2), observedAgent(1)]; % Counterclockwise bound
            
    % Check if obstacle lies in the sector
    agentObstruction = ((-obstacles(:,2)*cwBound(1) + obstacles(:,1)*cwBound(2) < 0) & (-obstacles(:,2)*ccwBound(1) + obstacles(:,1)*ccwBound(2) > 0) & (obstacleDistance < agentDistance));
    
    % Set visibility
    agentVisibility = ~sum(agentObstruction); % if even one obstruction is active then visibility is 0    
end