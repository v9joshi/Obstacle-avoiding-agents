% This program simulates multiple agents interacting with each other and
% the environment. The agents have individual behaviour designed to 
% a) Move towards a goal.
% b) Avoid obstacles in the way.
% c) Interact with other agents so as to move in a group but also not
% collide with each other.

% Clear and close everything
clc; close all; clear;

%% Define sim parameters
% Model being used
modelSelection = 2; % 0 = Couzin et al, fixed radii; 1 = Calovi et al 2018, gaussian att/ali functions; 2 = burst-and-coast modification of 1
% Simulation parameters
totalSimulationTime = 1000; % How long does the simulation run?
simStepTime = 0.01; % Step time for each loop of the simulation

%% Define agent parameters
% How many Agents exist?
numberOfAgents = 10;

% How often do agents update decisions
numStepsPerUpdate = 10*ones(numberOfAgents,1);
%agentStepTime = simStepTime*numStepsPerUpdate;

% distribution of times (in seconds) between agent bursts in the burst-and-coast model
burstTimeMean = 0.514;
burstTimeStd = 0.12;

% Set steps per update
if modelSelection == 1
   numStepsPerUpdate = round(numStepsPerUpdate + (2*rand(numberOfAgents,1) - 1)*simStepTime.*numStepsPerUpdate);
elseif modelSelection == 2
    % This will be treated as a list of time step numbers at which the agents will update with a new kick
    numStepsPerUpdate = round((burstTimeMean + burstTimeStd*randn(numberOfAgents,1))/simStepTime);
end

% How many neighbors should the agent social dynamics consider?
numberOfNeighbors = 7;

% How many agents know the destination?
fractionInformed = 1;
informedAgents = round(fractionInformed*numberOfAgents);
listOfInformedAgents = randsample(numberOfAgents, informedAgents);
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

% Radii for the agents
avoidDistance = 1; % Closer than that to another agent = repulsion farther = attraction.
alignDistance = 5; %  Distance to other agents where alignment is maximal.
attractDistance = 10; % Distance to other agents where attraction is maximal.

% Calovi specific params
alignYintercept = 0.6; % Y-intercept of alignment gaussian.
obstacleDistance = 1; % Distance to obstacle where agents get repelled a lot
obstacleVisibility = 1; % Obstacle visibility: Higher = Obs. avoidance 'starts' farther from obstacle.

% Agent dynamics
turnRate = inf; % units of radians per second. turning speed limit (applies only to modelCalovi = 0 or 1)
agentSpeed = 1; % How fast do agents move?
noiseDegree = 0; % How noisy is the agent motion from step to step

% Agent social weights
avoidWeight = 1;
alignWeight = 7;
attractWeight = 1;
obstacleWeight = 1;

% Obstacle parameters
obstacleType = 3;    % convex arc = 1, wall = 2, or concave arc = 3, otherwise nothing
obstacleScale = 15;  % length scale of obstacle
arcLength = pi*7.5;  % length of the obstacle arc in length units (regardless of angle & radius)
arcRadius = 7.5; % radius of the arc (position stays the same)
arcAngle = arcLength/arcRadius; % how many degrees should arc obstacles cover?
gapSize = 0;         % size of gap in the middle of the wall

obstacleCenter = [0,11.25]; % The center for the obstacle

% What are the initial states of the agents?
initialPositionX = (5+5).*rand(numberOfAgents,1) - 5; % m
initialPositionY = (5+5).*rand(numberOfAgents,1); % m
initialSpeed = agentSpeed*ones(numberOfAgents, 1); % m/s
initialOrientation = pi/2*ones(numberOfAgents, 1); % radians

% Animation only params
agentLength = 1; % The length (head to tail) of each Agents in m. Used only for plotting.
arrowheadSize = 7; % Size of arrowheads on plotted agents, in pixels.

% How close to the destination do you need to be to have succeeded?
destinationSuccessCriterion = 1000;

%% Set up some weights for the agents
agentWeights.Destination = zeros(numberOfAgents, 1);
agentWeights.Avoidance = zeros(numberOfAgents, 1);
agentWeights.Attraction = zeros(numberOfAgents, 1);
agentWeights.Alignment = zeros(numberOfAgents, 1);
agentWeights.Obstacle = zeros(numberOfAgents, 1);

% How much do agents care about the destination
agentWeights.Destination(listOfInformedAgents) = 1;

% How much do agents care about social behavior (alignment, attraction,
% avoidance)
agentWeights.Avoidance(:) = avoidWeight;%1.8;
agentWeights.Attraction(:) = attractWeight;%1.8;
agentWeights.Alignment(:) = alignWeight;%1;

% How much do agents care about obstacle avoidance?
agentWeights.Obstacle(:) = obstacleWeight;

%% Define some environment variables

% What is the area where the agents can roam?
limitsX = [-30, 30];
limitsY = [-10, 50];

% Global attractors
goalLocations = [0, 1050];

% Build the obstacle
groupDiameter = numberOfAgents*avoidDistance;
obstacleSpacing = obstacleDistance/10; % Distance between two points on the obstacle

obstacleX = [];
obstacleY = [];

switch obstacleType
    % make convex arc obstacle
    case 1
        arcRadius = obstacleScale/2;
        obstacleCenter = [obstacleCenter(1), obstacleCenter(2)];
        obstacle = obstArc(obstacleCenter(1),obstacleCenter(2),...
                           arcRadius,(pi/2)+(arcAngle/2),(pi/2)-(arcAngle/2),obstacleSpacing);
    
    % make wall obstacle
    case 2
        x1 = obstacleCenter(1) - obstacleScale/2;
        y1 = obstacleCenter(2);
        x2 = obstacleCenter(1) + obstacleScale/2;
        y2 = obstacleCenter(2);
        obstacle = obstLine(x1, y1, x2, y2, obstacleSpacing, gapSize);
    
    % make concave arc obstacle
    case 3
        arcRadius = obstacleScale/2;
        obstacleCenter = [obstacleCenter(1), obstacleCenter(2)];
        obstacle = obstArc(obstacleCenter(1),obstacleCenter(2),...
                           arcRadius,(pi/2)-(arcAngle/2),(pi/2)+(arcAngle/2),obstacleSpacing);
    otherwise
        obstacle = [];
end

if ~isempty(obstacle)
    obstacleX = obstacle(:,1);
    obstacleY = obstacle(:,2);
end

obstacleLocations = [obstacleX(:), obstacleY(:)];
                 
%% Plot the obstacle
% figure(11)
% plot(obstacleX, obstacleY, 'rx')
% %xlim(limitsX);
% %xlim(limitsY);
% axis 'equal'

%% Set simulation parameters and initialize variables
% Collect all the initial states together
initialStates = [initialPositionX; initialPositionY; initialSpeed; initialOrientation];

% Collect all the parameters
params.numberOfAgents = numberOfAgents;

params.avoidDistance = avoidDistance;
params.alignDistance = alignDistance;
params.attractDistance = attractDistance;

params.numberOfNeighbors = numberOfNeighbors;

params.alignYintercept = alignYintercept;
params.obstacleDistance = obstacleDistance;
params.obstacleVisibility = obstacleVisibility;

params.turnRate = turnRate;
params.stepTime = simStepTime;

params.noiseDegree = noiseDegree;

params.agentWeights = agentWeights;
params.waterSourceLocations = goalLocations;
params.obstacleLocations = obstacleLocations;

params.agentLength = agentLength;

params.obstacleSpacing = obstacleSpacing;
params.obstacleCenter = obstacleCenter;
params.obstacleRadius = arcRadius;

% Variable initialization
startTime = 0;
statesList = initialStates;
timeList = startTime;

destination = goalLocations(1,:);
destinationList = goalLocations;

numberOfBouts = 0;
goalReachTime = NaN(numberOfAgents,1); % time when goal was reached
destinationReached = zeros(numberOfAgents,1); % flag for reaching the goal

% Define these variables
actionInput.desiredSpeed = initialSpeed;
actionInput.desiredOrientation = initialOrientation;

%% Run the simulation
while timeList(end) < totalSimulationTime
%     display('step')
    
    % What is the current state?
    statesNow = statesList(:,end);
    timeNow = timeList(end);
    
    % Run perception and decision  steps for each agent
    for currAgent = 1:numberOfAgents
        if modelSelection == 0 || modelSelection == 1
            if (mod(length(timeList), numStepsPerUpdate(currAgent)) == 0)
              % run the perception step and update decision input
              decisionInput = agentPerception3(currAgent, statesNow, params);

              % run the decision step and update action input
              if modelSelection == 1 % Gaussian curves rather than radii
                actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput);
              else % Fixed radii
                actionInput = agentDecision(currAgent, params, decisionInput, actionInput);
              end
            end
        elseif modelSelection == 2
            if length(timeList) == numStepsPerUpdate(currAgent)  % if you've hit the next decision point, re-burst
              disp(['burst ', num2str(currAgent)])
              decisionInput = agentPerception3(currAgent, statesNow, params);
              actionInput = agentDecisionCalovi(currAgent, params, decisionInput, actionInput);
              actionInput.desiredSpeed(currAgent) = agentSpeed;
              % now set the next time when you'll burst again:
              numStepsPerUpdate(currAgent) = max(numStepsPerUpdate(currAgent) + round((burstTimeMean + burstTimeStd*randn)/simStepTime),numStepsPerUpdate(currAgent)+1);  % the max is for low-end outliers of the gaussian so you don't get stuck never updating again
            else  % keep coasting: reduce speed
              actionInput.desiredSpeed(currAgent) = actionInput.desiredSpeed(currAgent) * exp(-simStepTime/0.8);
            end
        else
            disp('Undefined movement model')
        end
    end    
    % If destination was reached, set desired agent speed and current
    % agents speed to 0.1
    % actionInput.desiredSpeed(destinationReached == 0 ) = 0.1;
    statesNow(2*numberOfAgents + find(destinationReached)) = 0.1;

    %if length(timeList)>800, keyboard, end% && (currAgent==1 || currAgent==2), keyboard, end
    % run the action step for all the agents and update the state list
    if modelSelection == 0 || modelSelection == 1
        statesNow = agentAction3(statesNow, params, actionInput);  
    elseif modelSelection == 2
        statesNow = agentAction3(statesNow, params, actionInput);
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

%% Plot and output some data
figure(1)
plot(agentsXOut, agentsYOut);
hold on
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
hold off

xlabel('Agent x position')
ylabel('Agent y position')
title('Agent world')

axis equal
axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

%% Animate the motion
figure(2)
% How large do we want each agent to be
semiAgentSize = agentLength/2;

warning('off','arrow:warnlimits')

if modelSelection==0 || modelSelection==1
    showStep = 10*numStepsPerUpdate;
else
    showStep = 10;
end

for currTimeIndex = 1:showStep:length(timeList)
    set(0, 'currentfigure',2);
    plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
    hold on
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

% * avoidDistance function determined by:
%   1. simulating different group sizes w/ different avoidDist,
%   2. determining the avoidDistance which gave a [mean distance to closest neighbor] closest to 1
%   3. fitting a regression model to the above avoidDistances vs numberOfAgents
