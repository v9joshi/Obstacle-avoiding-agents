% This program simulates multiple agents interacting with each other and
% the environment. The agents have inidivual behaviour designed to 
% a) Move towards a goal.
% b) Avoid obstacles in the way.
% c) Interact with other agents so as to move in a group but also not
% collide with each other.

% Clear and close everything
clc; close all; clear all;

%% Define some parameters
% Agent parameters
numberOfAgents = 10; % How many Agents exist?

agentLength = 1; % The length (head to tail) of each Agents in m. Used only for plotting.
arrowheadSize = 10; % Size of arrowheads on plotted agents, in pixels.

% Radii for the agents
avoidDistance = 1; % Agents within this distance of each other will repel each other.
alignDistance = 10; % Agents within this distance of each other will align with each other.
attractDistance = 10; % Agents within this distance of each other will attract each other.

% Agent dynamics
turnRate = 2; % units of radians per second. speed limit

% Simulation parameters
totalSimulationTime = 200; % How long does the simulation run?
stepTime = 0.1; % Step time for each loop of the simulation

% What are the initial states of the agents?
initialPositionX = zeros(numberOfAgents, 1); %0.2*(1:1:numberOfAgents)';
initialPositionY = 0.5*(1:1:numberOfAgents)'; %zeros(numberOfAgents, 1);
initialSpeed = 1*ones(numberOfAgents, 1); % m/s
initialOrientation = zeros(numberOfAgents, 1); % radians

%% Set up some weights for the agents
agentWeights.Destination = zeros(numberOfAgents, 1);
agentWeights.Avoidance = zeros(numberOfAgents, 1);
agentWeights.Attraction = zeros(numberOfAgents, 1);
agentWeights.Alignment = zeros(numberOfAgents, 1);
agentWeights.Obstacle = zeros(numberOfAgents, 1);

% How many agents know the destination?
fractionInformed = 0.7;
informedAgents = round(fractionInformed*numberOfAgents);
listOfInformedAgents = randsample(numberOfAgents, informedAgents);
agentWeights.Destination(listOfInformedAgents) = 1;

% How much do agents care about social behavior (alignment, attraction,
% avoidance)
agentWeights.Avoidance(:) = 1;
agentWeights.Attraction(:) = 1;
agentWeights.Alignment(:) = 1;

% How much do agents care about obstacle avoidance?
agentWeights.Obstacle(:) = 1;

%% Define some environment variables
% What is the area where the agents can roam?
limitsX = [-30, 30];
limitsY = [-30, 30];

% Global attractors
goalLocations = [-20, 20];

% Obstacle parameters
groupDiameter = numberOfAgents*avoidDistance;
obstacleSpacing = avoidDistance/5; % Distance between two points on the obstacle

% Make some obstacles
wallObstacleA.Y = []; %  10:avoidDistance/5:15;
wallObstacleA.X = []; % -15*ones(length(wallObstacleA.Y),1);

wallObstacleB.X = -15:obstacleSpacing:(-15 + 2*groupDiameter);
wallObstacleB.Y = 15*ones(length(wallObstacleB.X),1);

obstacleLocations = [wallObstacleA.X(:), wallObstacleA.Y(:);
                     wallObstacleB.X(:), wallObstacleB.Y(:)];
                 
% Plot the obstacle
figure(11)
plot(wallObstacleB.X, wallObstacleB.Y, 'rx')
xlim(limitsX);
xlim(limitsY);

axis 'equal'

%% Set simulation parameters and initialize variables
% Collect all the initial states together
initialStates = [initialPositionX; initialPositionY; initialSpeed; initialOrientation];

% Collect all the parameters
params.numberOfAgents = numberOfAgents;
params.avoidDistance = avoidDistance;
params.alignDistance = alignDistance;
params.attractDistance = attractDistance;

params.turnRate = turnRate;
params.stepTime = stepTime;

params.agentWeights = agentWeights;
params.waterSourceLocations = goalLocations;
params.obstacleLocations = obstacleLocations;

% Variable initialization
destinationReached = 0; % Flag for reaching the destination

startTime = 0;
statesList = initialStates;
timeList = startTime;

destination = goalLocations(1,:);
destinationList = goalLocations;

numberOfBouts = 0;

%% Run the simulation
while timeList(end) < totalSimulationTime
    timeList(end+1) =  timeList(end) + stepTime;
    
    % What is the current state?
    statesNow = statesList(:,end);
    
    % What can we change for the agents?
    actionInput.desiredSpeed = statesNow(2*numberOfAgents + 1: 3*numberOfAgents);
    actionInput.desiredOrientation = statesNow(3*numberOfAgents + 1: end);
    
    % Run perception and decision  steps for each agent
    for currAgent = 1:numberOfAgents
        % run the perception step and update decision input
        decisionInput = agentPerception(currAgent, statesNow, params);    
    
        % run the decision step and update action input
        actionInput = agentDecision(currAgent, params, decisionInput, actionInput);
    end
  
    % run the action step for all the agents and update the state list
    statesNow = agentAction(statesNow, params, actionInput);  
    
    % add on the states
    statesList = [statesList, statesNow];
    
    % check if destination has been reached
    meanAgentX = mean(statesNow(1:numberOfAgents));
    meanAgentY = mean(statesNow(numberOfAgents + 1: 2*numberOfAgents));
    
    distanceToGoal = sqrt((meanAgentX -  destination(1)).^2 + (meanAgentY - destination(2)).^2);
    
    if min(distanceToGoal) < 5
        destinationReached = 1;
        goalReachTime = timeList(end);
        
        display(['Reached destination at time t = ', num2str(goalReachTime)]);
        break
    end    
end

%% Unpack output states
agentsXOut = statesList(1:numberOfAgents,:)';
agentsYOut = statesList(numberOfAgents + 1: 2*numberOfAgents,:)';
agentsSpeedOut = statesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';
agentsOrientationOut = statesList(3*numberOfAgents + 1 :end,:)';

%% Plot and output some data
figure(1)
plot(agentsXOut, agentsYOut);
hold on
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
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

for currTimeIndex = 1:10:length(timeList)
%     plot([agentsXOut(currTimeIndex,:) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:));...
%          agentsXOut(currTimeIndex,:) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:))],...
%          [agentsYOut(currTimeIndex,:) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:));...
%          agentsYOut(currTimeIndex,:) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:))] ,'-');
%      
%     hold on
%     plot(agentsXOut(currTimeIndex,:) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:)),...
%          agentsYOut(currTimeIndex,:) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:)) ,'v');
%      
%      
%     plot(agentsXOut(currTimeIndex, listOfInformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfInformedAgents)),...
%          agentsYOut(currTimeIndex, listOfInformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfInformedAgents)) ,'v', 'markerfacecolor','r');
%
%      
%     plot(agentsXOut(currTimeIndex,:) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:)),...
%          agentsYOut(currTimeIndex,:) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:)) ,'*');
%      
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
      hold on
    plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
    plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
%    
%      
%    hold off

    xlabel('Agents x position')
    ylabel('Agents y position')

    title('Agent home')
    axis equal    
    xlim(axisLimits.X)
    ylim(axisLimits.Y)
      axis(axis)
      arrow([agentsXOut(currTimeIndex,:) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:));...
	     agentsYOut(currTimeIndex,:) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:))],...
	    [agentsXOut(currTimeIndex,:) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:));...
	     agentsYOut(currTimeIndex,:) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:))],...
	   arrowheadSize);
      hold off
    pause(0.01);
end
