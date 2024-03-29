% Agent action:
% Move the agent in the desired direction at the specified speed.
% Check for collisions with obstacles and prevent phasing through.
function stateListNew = agentAction(stateList, params, actionInput)
    %% unpack parameters
    % General simulation parameters
    numberOfAgents = params.numberOfAgents;
    stepTime = params.stepTime;
    turnRate = params.turnRate;

    % Obstacle parameters
    obstacleType   = params.obstacleType;
    obstacleCenter = params.obstacleCenter;
    obstacleRadius = params.obstacleRadius;

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

    % Obstacle bounds
    obsMinX = min(params.obstacleLocations(:,1));
    obsMaxX = max(params.obstacleLocations(:,1));

    obsMinY = min(params.obstacleLocations(:,2));
    obsMaxY = max(params.obstacleLocations(:,2));

    distLim = 0.9*params.obstacleDistance^2;

    %% Check for wall collision (only works with the arc)
    if obstacleType == 3 % Arc type obstacle
        for currAgent = 1:numberOfAgents
            rad12 = ((agentX(currAgent) - obstacleCenter(1))^2 + (agentY(currAgent)- obstacleCenter(2))^2); % Find squared distance from obstacle center
            rad22 = ((newX(currAgent) - obstacleCenter(1))^2 + (newY(currAgent) - obstacleCenter(2))^2); % Find squared distance from obstacle center

            % Check to see that we are not in the part of the circle without the obstacle
            if(~(agentY(currAgent) < obsMinY && newY(currAgent) < obsMinY))
            % Case 1: old and new position are on opposite sides of the obstacle
                if ((rad12 - obstacleRadius^2)*(rad22 - obstacleRadius^2) < 0)
                   % also, you don't want to freeze the agent in place too far away, or it may be stuck beyond the range of sensing the obstacle; instead you want it to advance until it's close to the obstacle
                   % the right way to do this is to calculate the intersection point, see how far along the line segment it is, and pick a new point just short of that, but I'm tired and am just going to kluge something awful
                  if abs(rad12 - obstacleRadius^2) < distLim  % don't keep advancing when you're close enough
                    newX(currAgent) = agentX(currAgent); 
                    newY(currAgent) = agentY(currAgent);
                  else
                    p1x = agentX(currAgent);
                    p1y = agentY(currAgent);

                    p2x = newX(currAgent);
                    p2y = newY(currAgent);

                    while (p2x-p1x)^2 + (p2y-p1y)^2 > distLim
                      p3x = p1x + (p2x-p1x)/2; 
                      p3y = p1y + (p2y-p1y)/2;

                      rad12 = (p1x - obstacleCenter(1))^2 + (p1y  - obstacleCenter(2))^2; 
                      rad22 = (p2x - obstacleCenter(1))^2 + (p2y  - obstacleCenter(2))^2; 
                      rad32 = (p3x - obstacleCenter(1))^2 + (p3y  - obstacleCenter(2))^2;

                      if rad12 > obstacleRadius^2
                        if rad32 > obstacleRadius^2
                            p1x = p3x;
                            p1y = p3y;
                        else
                            p2x = p3x;
                            p2y = p3y;
                        end
                      else
                        if rad32 < obstacleRadius^2
                            p1x = p3x;
                            p1y = p3y;
                        else
                            p2x = p3x;
                            p2y = p3y;
                        end
                      end
                    end

                    newX(currAgent) = p1x;
                    newY(currAgent) = p1y;
                  end
                % If you're moving slowly enough to keep getting closer to the obstacle, don't get too close

                % Case 2: Old and new position are on the same side of the obstacle
                elseif ((rad12<obstacleRadius^2 && rad22<obstacleRadius^2 && rad12<rad22 && abs(rad12-obstacleRadius^2)<.75)...
                     || (rad12 > obstacleRadius^2 && rad22 > obstacleRadius^2 && rad12 > rad22 && abs(rad12-obstacleRadius^2)<.75))
                  newX(currAgent) = agentX(currAgent); 
                  newY(currAgent) = agentY(currAgent);
                end
            end
        end 
    end   
    
    %% Return the new states
    stateListNew(1:numberOfAgents) = newX;
    stateListNew(numberOfAgents+1: 2*numberOfAgents) = newY;
    stateListNew(2*numberOfAgents+1 : 3*numberOfAgents) = agentSpeed;
end