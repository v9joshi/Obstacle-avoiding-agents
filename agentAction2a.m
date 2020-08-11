function stateListNew = agentAction2a(stateList, params, actionInput)
% Modified for burst-and-coast model: allow speed to change, remove limit on turning speed, prevent moving through obstacle

% unpack parameters
numberOfAgents = params.numberOfAgents;
stepTime = params.stepTime;
turnRate = params.turnRate;

% unpack the states of the agent
agentX = stateList(1:numberOfAgents);
agentY = stateList(numberOfAgents + 1: 2*numberOfAgents);
agentSpeed = actionInput.desiredSpeed;  % <-- a change from agentAction2 (set new speed rather than old fixed one)
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

% Below here is changed from agentAction2: set new direction instantaneously, stop movement into obstacle
stateListNew = stateList;
newX = agentX + dAgentX*stepTime;
newY = agentY + dAgentY*stepTime;
%for currAgent = 1:numberOfAgents
%    if abs(((newX(currAgent))^2+(newY(currAgent)-11.25)^2) - 56.25)<.05 && newY(currAgent)>11.25
%       newX(currAgent) = agentX(currAgent); newY(currAgent) = agentY(currAgent);
%    end
%end
% this is specific to the obstacle being an arc of this size in this place: if the distance from (0,11.25) is within sqrt(0.05) of 7.5 (the obstacle radius), and it's in the upper half of the circle, then you'd be colliding, so don't take this step
%% above assumes you're not taking giant steps; below should be better able to handle high speeds, checking for crossings rather than proximity
for currAgent = 1:numberOfAgents
    rad12 = (agentX(currAgent))^2 + (agentY(currAgent)-11.25)^2;
    rad22 = (newX(currAgent))^2 + (newY(currAgent)-11.25)^2;
    if ((rad12>56.25 && rad22<56.25) || (rad12<56.25 && rad22>56.25)) && (~(agentY(currAgent)<11.25 && newY(currAgent)<11.25))
       % also, you don't want to freeze the agent in place too far away, or it may be stuck beyond the range of sensing the obstacle; instead you want it to advance until it's close to the obstacle
       % the right way to do this is to calculate the intersection point, see how far along the line segment it is, and pick a new point just short of that, but I'm tired and am just going to kluge something awful
      if abs(rad12-56.25) < .75  % don't keep advancing when you're close enough
            newX(currAgent) = agentX(currAgent); newY(currAgent) = agentY(currAgent);
      else
            p1x = agentX(currAgent); p1y = agentY(currAgent); p2x = newX(currAgent); p2y = newY(currAgent);
	while (p2x-p1x)^2 + (p2y-p1y)^2 > .75
	  p3x = p1x + (p2x-p1x)/2; p3y = p1y + (p2y-p1y)/2;
	  rad12 = p1x^2 + (p1y-11.25)^2; rad22 = p2x^2 + (p2y-11.25)^2; rad32 = p3x^2 + (p3y-11.25)^2;
	  if rad12>56.25
	    if rad32>56.25, p1x = p3x; p1y = p3y; else p2x = p3x; p2y = p3y; end
	  else
	    if rad32<56.25, p1x = p3x; p1y = p3y; else p2x = p3x; p2y = p3y; end
	  end
    end
    
	newX(currAgent) = p1x; newY(currAgent) = p1y;
      end
      
      
    % also also, if you're moving slowly enough to keep getting closer to the obstacle, don't get too close
    elseif ((rad12<56.25 && rad22<56.25 && rad12<rad22 && abs(rad12-56.25)<.75) || (rad12>56.25 && rad22>56.25 && rad12>rad22 && abs(rad12-56.25)<.75)) && (~(agentY(currAgent)<11.25 && newY(currAgent)<11.25))
      newX(currAgent) = agentX(currAgent); newY(currAgent) = agentY(currAgent);
    end
end
% still specific to the obstacle being an arc of this size and position, but now we're checking via if the current position is on the opposite side of the arc from the desired next position, and both points aren't in the bottom half

stateListNew(1:numberOfAgents) = newX;
stateListNew(numberOfAgents+1: 2*numberOfAgents) = newY;
stateListNew(2*numberOfAgents+1 : 3*numberOfAgents) = agentSpeed;
stateListNew(3*numberOfAgents + 1:end) = desiredOrientation;
