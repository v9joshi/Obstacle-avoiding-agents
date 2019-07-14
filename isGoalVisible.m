% Determine if the agent can see the goal given obstacle locations.
function goalVisibility = isGoalVisible(observingAgent, decisionInput, params, obstacles)

% Unpack params & variables
goalDistance = decisionInput.distanceFromWSLocations;
goalSize = params.obstacleDistance;
relativeWSUnitVector = decisionInput.relativeWSUnitVector;

% Assume goal is visible
    goalVisibility = 1; % Yes, goal is visible
    
    % Angular range required for observation. For now replaced by obstacle
    % avoidance distance
%    angularRange = goalSize/goalDistance; % Goal subtends this angle at agent's eye

    % Determine visual obstruction
    relativeObstacleAngle = atan2(obstacles(:,2) - observingAgent(2), obstacles(:,1) - observingAgent(1));
    obstacleDistance = sqrt(sum((obstacles - repmat(observingAgent, size(obstacles, 1), 1)).^2, 2));
    
    % Determine which obstructions are active
    agentObstruction = zeros(length(obstacles), 1);
    agentObstruction((abs(relativeObstacleAngle - relativeWSUnitVector) < goalSize) & (obstacleDistance < goalDistance)) = 1;
    
    % Set visibility
    goalVisibility = ~sum(agentObstruction); % if even one obstruction is active then visibility is 0    
end