% This branch tries to re-create the simulations from
% "The influence of group size and social interactions on collision risk
% with obstacles"
% Simon Croft, Richard Budgey, Jonathan W. Pitchford and A. Jamie Wood
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
numberOfAgents = 50; % How many Agents exist?
agentLength = 0.75; % The length (head to tail) of each Agents in m.
avoidDistance = 1.5; % Agents within this distance of each other will repel each other.
alignDistance = 15; % Agents within this distance of each other will align with each other.
attractDistance = 37.5; % Agents within this distance of each other will attract each other.
turnRate = pi/4; % units of radians per second

% simulation parameters
totalSimulationTime = 400; % How long does the simulation run?
stepTime = 0.1; % Step time for each loop of the simulation

% What are the initial states of the agents?
initialPositionX = avoidDistance*2*(1:1:numberOfAgents)' - avoidDistance*numberOfAgents;%zeros(numberOfAgents, 1);%0.2*(1:1:numberOfAgents)';
initialPositionY = 1000*ones(numberOfAgents,1);% + 0.5*(1:1:numberOfAgents)';%zeros(numberOfAgents, 1);

initialSpeed = 5*ones(numberOfAgents, 1);

initialOrientation = 1.5*pi*ones(numberOfAgents, 1);

% How many agents know the destination?
fractionInformed = 1;
informedAgents = round(fractionInformed*numberOfAgents);
listOfInformedAgents = randsample(numberOfAgents, informedAgents);
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';
agentWeights.Destination(listOfInformedAgents) = 1;

% How much do agents care about social behavior (alignment, attraction,
% avoidance)
agentWeights.Avoidance(:) = 1;
agentWeights.Attraction(:) = 1;
agentWeights.Alignment(:) = 10;

% How much do agents care about obstacle avoidance?
agentWeights.Obstacle(:) = 1;

%% Define some environment variables
% What is the area where the agents can roam?
limitsX = [-3000, 3000];
limitsY = [-3000, 3000];

% Global attractors
waterSourceLocations = [0, -500];
obstaclePose = generateObstacles(avoidDistance, groupDiameter);


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

params.agentGains = agentGains;
params.waterSourceLocations = waterSourceLocations;
params.obstaclePose = obstaclePose;

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
plot(obstaclePose(:,1), obstaclePose(:,2), 'rx','MarkerFaceColor','r') 
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
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
      hold on
    plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
    plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 

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
              arrowheadSize);
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
