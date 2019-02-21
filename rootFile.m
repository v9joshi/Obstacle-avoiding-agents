% This program simulates multiple agents interacting with each other and
% the environment. The Agentss have inidivual behaviour designed to 
% a) Move towards a goal.
% b) Avoid obstacles in the way.
% c) Interact with other Agentss so as to move in a group but also not
% collide with each other.

% Clear and close everything
clc; close all; clear all;

%% Define some parameters
% Agent parameters
numberOfAgents = 10; % How many Agents exist?
agentLength = 1; % The length (head to tail) of each Agents in m.
avoidDistance = 2; % Agents within this distance of each other will repel each other.
alignDistance = 5; % Agents within this distance of each other will align with each other.
attractDistance = 10; % Agents within this distance of each other will attract each other.
turnRate = 2; % units of radians per second

% simulation parameters
totalSimulationTime = 200; % How long does the simulation run?
stepTime = 0.01; % Step time for each loop of the simulation

% What are the initial states of the agents?
initialPositionX = zeros(numberOfAgents, 1);%0.2*(1:1:numberOfAgents)';
initialPositionY = 0.5*(1:1:numberOfAgents)';%zeros(numberOfAgents, 1);

initialSpeed = 1*ones(numberOfAgents, 1);

initialOrientation = zeros(numberOfAgents, 1);

% How many agents know the destination?
fractionInformed = 0.3;
informedAgents = round(fractionInformed*numberOfAgents);
agentGains = zeros(numberOfAgents, 1);
listOfInformedAgents = randsample(numberOfAgents, informedAgents);
agentGains(listOfInformedAgents) = 1;

%% Define some environment variables
% What is the area where the agents can roam?
limitsX = [-30, 30];
limitsY = [-30, 30];

% Global attractors
waterSourceLocations = [-20, 20];

% Make some obstacles
groupDiameter = numberOfAgents*avoidDistance;

wallObstacleA.Y = []; %10:avoidDistance/5:15;
wallObstacleA.X = []; %-15*ones(length(wallObstacleA.Y),1);


wallObstacleB.X = -15:avoidDistance/5:(-15 + 2*groupDiameter);
wallObstacleB.Y = 15*ones(length(wallObstacleB.X),1);

obstacleLocations = [wallObstacleA.X(:), wallObstacleA.Y(:);
                     wallObstacleB.X(:), wallObstacleB.Y(:)];


%% Set simulation parameters and initialize variables
% How long do we keep trying for a particular destination?
maxTime = 150;

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
params.obstacleLocations = obstacleLocations;

% Variable initialization
destinationReached = 0;
startTime = 0;
statesList = initialStates;
timeList = startTime;
destination = waterSourceLocations(1,:);
destinationList = waterSourceLocations;
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
        goalReachIndex = find(distanceToGoal < 5, 1, 'first');
        goalReachTime = timeList(goalReachIndex);
        
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
plot(waterSourceLocations(:,1), waterSourceLocations(:,2), 'bo','MarkerFaceColor','b') 
hold off

xlabel('Agent x position')
ylabel('Agent y position')
title('Agent world')

axis equal

axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

%% Animate the motion
figure(2)

% How large do we want each bison to be
semiAgentSize = agentLength/2;

for currTimeIndex = 1:10:length(timeList)
     plot([agentsXOut(currTimeIndex,:) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:));...
          agentsXOut(currTimeIndex,:) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:))],...
          [agentsYOut(currTimeIndex,:) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:));...
          agentsYOut(currTimeIndex,:) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:))] ,'-');
      
     hold on
     plot(agentsXOut(currTimeIndex,:) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:)),...
          agentsYOut(currTimeIndex,:) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:)) ,'v');
      
      
     plot(agentsXOut(currTimeIndex, listOfInformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfInformedAgents)),...
          agentsYOut(currTimeIndex, listOfInformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfInformedAgents)) ,'v', 'markerfacecolor','r');

      
     plot(agentsXOut(currTimeIndex,:) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,:)),...
          agentsYOut(currTimeIndex,:) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,:)) ,'*');
      
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
    plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
    plot(waterSourceLocations(:,1), waterSourceLocations(:,2), 'bo','MarkerFaceColor','b') 
    
      
     hold off

      
%     hold on
%     plot(bisonXOut, bisonYOut, '-');
%     hold off
    xlabel('Bison x position')
    ylabel('Bison y position')

    title('Bison ranch')
    axis equal    
    xlim(axisLimits.X)
    ylim(axisLimits.Y)
    pause(0.1);
end
