% This program simulates multiple agents interacting with each other and
% the environment. The agents have individual behaviour designed to 
% a) Move towards a goal.
% b) Avoid obstacles in the way.
% c) Interact with other agents so as to move in a group
% d) Avoid collisions with other agents.

% Clear and close everything
clc; close all; clear;

%% Define sim parameters
% Model being used
modelSelection = 2; % 0 = discrete zones of behavior; 1 = continuous variant; 2 = burst-and-coast modification of 0

% Simulation parameters
totalSimulationTime = 100; % How long does the simulation run?
simStepTime = 0.01; % Step time for each loop of the simulation

%% Define agent parameters
% How many Agents do we want to simulate?
numberOfAgents = 10;

% How often do agents update their decisions
numStepsPerUpdate = 10*ones(numberOfAgents,1);

% Distribution of times (in seconds) between agent bursts in the burst-and-coast model
burstTimeMean = 0.514;
burstTimeStd  = 0.12;

% Set steps per update for burst and coast variant
if modelSelection == 2
    % This will be treated as a list of time step numbers at which the agents will update with a new kick
    numStepsPerUpdate = round((burstTimeMean + burstTimeStd*randn(numberOfAgents,1))/simStepTime);
end

% How many neighbors should the agent social dynamics consider?
numberOfNeighbors = 7;

% How many agents know the destination?
fractionInformed       = 1;
informedAgents         = round(fractionInformed*numberOfAgents);
listOfInformedAgents   = randsample(numberOfAgents, informedAgents);
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

% Radii for the agents
avoidDistance   = 1; % Closer than that to another agent = repulsion farther = attraction.
alignDistance   = 5; %  Distance to other agents where alignment is maximal.
attractDistance = 10; % Distance to other agents where attraction is maximal.

% Continuous model specific params
obstacleDistance   = 1; % Distance to obstacle where agents get repelled a lot
obstacleVisibility = obstacleDistance; % Obstacle visibility: Higher = Obs. avoidance 'starts' farther from obstacle.

% Agent movement speeds
turnRate   = 2;  % units of radians per second. turning speed limit (applies only to model = 0 or 1)
agentSpeed = 10; % How fast do agents move?

% Agent social weights
avoidWeight    = 1;
alignWeight    = 10;
attractWeight  = 1;
obstacleWeight = 1;

% Agent noise parameter
noiseDegree = 0; % Standard deviation (in radians) for wrapped gaussian (von-mises distribution noise).
                 % Depends on the vmrand in matlab file exchange function developed by Dylan Muir

%% Store all the weights for the agents
agentWeights.Destination = zeros(numberOfAgents, 1);
agentWeights.Avoidance   = zeros(numberOfAgents, 1);
agentWeights.Attraction  = zeros(numberOfAgents, 1);
agentWeights.Alignment   = zeros(numberOfAgents, 1);
agentWeights.Obstacle    = zeros(numberOfAgents, 1);

% How much do agents care about the destination
agentWeights.Destination(listOfInformedAgents) = 1;

% How much do agents care about social behavior?
agentWeights.Avoidance(:)  = avoidWeight;
agentWeights.Attraction(:) = attractWeight;
agentWeights.Alignment(:)  = alignWeight;

% How much do agents care about obstacle avoidance?
agentWeights.Obstacle(:) = obstacleWeight;

%% Obstacle parameters
obstacleType  = 3;    % box = 1, wall = 2, arc = 3, caret = 4
obstacleScale = 15;  % length scale of obstacle
arcLength     = pi*obstacleScale/2;  % length of the obstacle arc in length units (regardless of angle & radius)
arcRadius     = obstacleScale/2; % radius of the arc (position stays the same)
arcAngle      = arcLength/arcRadius; % how many degrees should arc obstacles cover?
gapSize       = 0;         % size of gap in the middle of the wall

obstacleCenter = [0,20]; % The center for the obstacle

%% Define some environment variables
% What is the area where the agents can roam?
limitsX = [-30, 30];
limitsY = [-10, 50];

% Where is the goal located?
goalLocations = [0, 1050];

% Build the obstacle
groupDiameter  = numberOfAgents*avoidDistance;
obstacleSpacing = obstacleDistance/10; % Distance between two points on the obstacle

obstacleX = [];
obstacleY = [];

switch obstacleType
    % make box obstacle
    case 1
        x1 = obstacleCenter(1) - obstacleScale/2;
        y1 = obstacleCenter(2);
        x2 = obstacleCenter(1) + obstacleScale/2;
        obstacle = obstBox(x1, y1, x2, obstacleSpacing, gapSize);
        
    % make wall obstacle
    case 2
        x1 = obstacleCenter(1) - obstacleScale/2;
        y1 = obstacleCenter(2);
        x2 = obstacleCenter(1) + obstacleScale/2;
        y2 = obstacleCenter(2);
        obstacle = obstLine(x1, y1, x2, y2, obstacleSpacing, gapSize);
        
    % make concave arc obstacle
    case 3
        obstacleCenter = [obstacleCenter(1), obstacleCenter(2) - ...
                            arcRadius/2];
        obstacle = obstArc(obstacleCenter(1),obstacleCenter(2),...
                           arcRadius,(pi/2)-(arcAngle/2),(pi/2)+(arcAngle/2),obstacleSpacing);

    % make caret obstacle using lines
    case 4
        x1 = obstacleCenter(1) - obstacleScale/2;
        y1 = obstacleCenter(2) - obstacleScale/2;
        x2 = obstacleCenter(1);
        y2 = obstacleCenter(2);
        obstacleLeft = obstLine(x1, y1, x2, y2, obstacleSpacing, gapSize);

        x1 = obstacleCenter(1);
        y1 = obstacleCenter(2);
        x2 = obstacleCenter(1) + obstacleScale/2;
        y2 = obstacleCenter(2) - obstacleScale/2;
        obstacleRight = obstLine(x1, y1, x2, y2, obstacleSpacing, gapSize);

        obstacle = [obstacleLeft; obstacleRight];
    otherwise
        obstacle = [];
end

if ~isempty(obstacle)
    obstacleX = obstacle(:,1);
    obstacleY = obstacle(:,2);
end

% Store the obstacle
obstacleLocations = [obstacleX(:), obstacleY(:)];
                 
%% What are the initial states of the agents?
initialPositionX   = (5+5).*rand(numberOfAgents,1) - 5; % m
initialPositionY   = (5+5).*rand(numberOfAgents,1); % m
initialSpeed       = agentSpeed*ones(numberOfAgents, 1); % m/s
initialOrientation = pi/2*ones(numberOfAgents, 1); % radians

%% Set simulation parameters and initialize variables
% How close to the destination do you need to be to have succeeded?
destinationSuccessCriterion = 1000;

% Collect all the initial states together
initialStates = [initialPositionX; initialPositionY; initialSpeed; initialOrientation];

% Collect all the parameters
params.numberOfAgents  = numberOfAgents;

params.avoidDistance   = avoidDistance;
params.alignDistance   = alignDistance;
params.attractDistance = attractDistance;

params.noiseDegree     = noiseDegree;

params.numberOfNeighbors = numberOfNeighbors;

params.obstacleDistance   = obstacleDistance;
params.obstacleVisibility = obstacleVisibility;

params.turnRate = turnRate;
params.stepTime = simStepTime;

params.agentWeights         = agentWeights;
params.destinationLocations = goalLocations;
params.obstacleLocations    = obstacleLocations;

params.obstacleType    = obstacleType;
params.obstacleSpacing = obstacleSpacing;
params.obstacleCenter  = obstacleCenter;
params.obstacleRadius  = arcRadius;

% Variable initialization
startTime  = 0;
statesList = initialStates;
timeList   = startTime;

destination     = goalLocations(1,:);
destinationList = goalLocations;

numberOfBouts      = 0;
goalReachTime      = NaN(numberOfAgents,1); % time when goal was reached
destinationReached = zeros(numberOfAgents,1); % flag for reaching the goal

% Define these variables
actionInput.desiredSpeed       = initialSpeed;
actionInput.desiredOrientation = initialOrientation;

%% Run the simulation
while timeList(end) < totalSimulationTime
%     display('step')
    
    % What is the current state?
    statesNow = statesList(:,end);
    timeNow = timeList(end);
    
    % Run perception and decision steps for each agent
    for currAgent = 1:numberOfAgents
        if modelSelection == 0 || modelSelection == 1 % Discrete or continuous behaviors
            if (mod(length(timeList), numStepsPerUpdate(currAgent)) == 0)

              % run the perception step and determine the decision input
              decisionInput = agentPerception(currAgent, statesNow, params);

              % run the decision step and determine the action input
              if modelSelection == 1 % Continuous functions for behavior
                actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput);
              else % Discrete zones for behaviors
                actionInput = agentDecision(currAgent, params, decisionInput, actionInput);
              end

            end

        elseif modelSelection == 2 % Burst and coast model of agents with continuous behavior zones  
            if length(timeList) == numStepsPerUpdate(currAgent)  % if you've hit the next decision point, re-burst

              % Run the perception step and determine the decision input
              decisionInput = agentPerception(currAgent, statesNow, params);

              % Run the decision step and determine the action input
              actionInput   = agentDecision(currAgent, params, decisionInput, actionInput);
              
              % Set the desired speed to the burst speed.
              actionInput.desiredSpeed(currAgent) = agentSpeed;
         
              % Set the next time when you'll burst again:
              numStepsPerUpdate(currAgent) = max(numStepsPerUpdate(currAgent) + round((burstTimeMean + burstTimeStd*randn)/simStepTime),numStepsPerUpdate(currAgent)+1);  % the max is for low-end outliers of the gaussian so you don't get stuck never updating again
            
            else  % keep coasting
              % Reduce speed based on exponential curve.
              actionInput.desiredSpeed(currAgent) = actionInput.desiredSpeed(currAgent) * exp(-simStepTime/0.8);
            end

        else
            disp('Undefined movement model')
        end
    end

    % If destination was reached, set desired agent speed and current
    % agents speed to 0.1
    actionInput.desiredSpeed(destinationReached == 1 ) = 0.1;

    % run the action step for all the agents and update the state list
    if modelSelection == 0 || modelSelection == 1
        statesNow = agentAction(statesNow, params, actionInput);  
    elseif modelSelection == 2
        statesNow = agentAction(statesNow, params, actionInput);
    else
        disp('Undefined movement model'),keyboard
    end
    
    % add on the states
    statesList(:, end+1) = statesNow;
    
    % Increment the time counter
    timeList(end+1) =  timeList(end) + simStepTime;    
    
    % check if destination has been reached for each agent
    agentX = statesNow(1:numberOfAgents);
    agentY = statesNow(numberOfAgents + 1: 2*numberOfAgents);
    
    distanceToGoal = sqrt((agentX -  destination(1)).^2 + (agentY - destination(2)).^2);
    
    % If agent is close to goal and hasn't been marked as having reached
    % the destination yet, then record the time it reached, and mark it as having reached 
    goalReachTime(distanceToGoal.*~destinationReached < destinationSuccessCriterion & ~destinationReached) = timeList(end);
    destinationReached(distanceToGoal < destinationSuccessCriterion) = 1;
    
    % How many agents have reached the destination?
    fractionReached = sum(destinationReached)/numberOfAgents;
    
    % If all the agents reached the destination, then stop the simulation
    if fractionReached == 1
        break;
    end
end

% Output number of successful agents
disp([num2str(sum(destinationReached)),' out of ', num2str(numberOfAgents), ' successfully reached the destination']);
disp(['minimum time to goal: ', num2str(min(goalReachTime))]);
disp(['maximum time to goal: ', num2str(max(goalReachTime))]);
disp(['median time to goal: ', num2str(nanmedian(goalReachTime))]);

%% Unpack output states
agentsXOut = statesList(1:numberOfAgents,:)';
agentsYOut = statesList(numberOfAgents + 1: 2*numberOfAgents,:)';
agentsSpeedOut = statesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';
agentsOrientationOut = statesList(3*numberOfAgents + 1 :end,:)';

%% Plot the motion of all agents
figure(1)
set(gcf,'color','w')
% Plot agent locations
plot(agentsXOut, agentsYOut);
hold on
% Plot obstacle locations
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'k-','MarkerFaceColor','k') 

% Plot destination line
plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
hold off

xlabel('Agent x position')
ylabel('Agent y position')
title('Agent world')

axis equal
axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

%% Animation only params
agentLength   = 1; % The length (head to tail) of each Agents in m. Used only for plotting.
arrowheadSize = 7; % Size of arrowheads on plotted agents, in pixels.

%% Animate the motion
figure(2)
% How large do we want each agent to be
semiAgentSize = agentLength/2;
set(gcf,'color','w')

warning('off','arrow:warnlimits')

if modelSelection==0 || modelSelection==1
    showStep = 10*numStepsPerUpdate;
else
    showStep = 10;
end

for currTimeIndex = 1:showStep:length(timeList)
    set(0, 'currentfigure',2);
    % Plot the destination line
    plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
    hold on

    % Plot the obstacle
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
   
    xlabel('Agents x position')
    ylabel('Agents y position')

    title('Agent home')
    axis equal    
    xlim(axisLimits.X)
    ylim(axisLimits.Y)
    
    % draw regular agents
    if ~isempty(listOfUninformedAgents)
        arrow([agentsXOut(currTimeIndex,listOfUninformedAgents) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfUninformedAgents));...
               agentsYOut(currTimeIndex,listOfUninformedAgents) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfUninformedAgents))]',...
              [agentsXOut(currTimeIndex,listOfUninformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfUninformedAgents));...
               agentsYOut(currTimeIndex,listOfUninformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfUninformedAgents))]',...
              arrowheadSize, 'color', 'k');
    end
    % draw leader agents
    if ~isempty(listOfInformedAgents)
        arrow([agentsXOut(currTimeIndex,listOfInformedAgents) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfInformedAgents));...
               agentsYOut(currTimeIndex,listOfInformedAgents) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfInformedAgents))]',...
              [agentsXOut(currTimeIndex,listOfInformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfInformedAgents));...
               agentsYOut(currTimeIndex,listOfInformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfInformedAgents))]',...
              arrowheadSize, 'color', 'r');
    end
    hold off
    pause(0.01);
    
end