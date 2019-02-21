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
numberOfAgentss = 10; % How many Agents exist?
agentLength = 2; % The length (head to tail) of each Agents in m.
repelRadius = 2; % Agentss within this distance of each other will repel each other.
alignRadius = 5; % Agentss within this distance of each other will align with each other.
attractRadius = 10; % Agentss within this distance of each other will attract each other.

% simulation parameters
totalSimulationTime = 500; % How long does the simulation run?
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

% Global repellors
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
params.timeStep = timeStep;

params.agentGains = agentGains;
params.waterSourceLocations = waterSourceLocations;
params.obstacleLocations = obstacleLocations;

% Variable initialization
destinationReached = 0;
startTime = 0;
statesList = [];
timeList = [startTime];
destination = waterSourceLocations(1,:);
destinationList = waterSourceLocations;
numberOfBouts = 0;


%% Run the simulation

while timeList(end) < totalSimulationtime
    timeList(end+1) =  timeList(end) + stepTime;
    
    % Run perception, decision and action steps for each bison
    for currBison = 1:numberOfBison
        % run the perception step
        decisionInput = agentPerception(currBison, stateList, params);    
    
        % run the decision step
        actionInput = agentDecision(currBison, stateList, params, decisionInput);    
    end
    
    % run the action step for all Bison
    stateList = agentAction(stateList, params, actionInput);  
    
    % check if destination has been reached
    meanAgentsX = mean(statesOutCurrBout(:,1:numberOfAgents), 2);
    meanAgentsY = mean(statesOutCurrBout(:,numberOfAgents + 1: 2*numberOfAgents), 2);
    
    distanceToGoal = sqrt((meanAgentsX -  destination(1)).^2 + (meanAgentsY - destination(2)).^2);
    if min(distanceToGoal) < 5
        destinationReached = 1;
        goalReachIndex = find(distanceToGoal < 5, 1, 'first');
        goalReachTime = timeList(goalReachIndex);
        
        display(['Reached destination at time t = ', num2str(goalReachTime)]);
    else
        if mod(numberOfBouts, 2) == 0
            destinationX = waterSourceLocations(1,1);
            destinationY = waterSourceLocations(1,2);
        else            
            destinationX = limitsX(1) + range(limitsX)*rand(1,1);
            destinationY = limitsY(1) + range(limitsY)*rand(1,1);
        end
        params.waterSourceLocations = [destinationX, destinationY];
        destinationList = [destinationList; destinationX, destinationY];
    end    
end

% Unpack output states
AgentsXOut = statesOut(:,1:numberOfAgents);
AgentsYOut = statesOut(:,numberOfAgents + 1: 2*numberOfAgents);
AgentsSpeedOut = statesOut(:,2*numberOfAgents + 1: 3*numberOfAgents);
AgentsOrientationOut = statesOut(:,3*numberOfAgents + 1 :end);

%% Plot and output some data
%% Plot the motion
figure
plot(bisonXOut, bisonYOut);
hold on
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
plot(waterSourceLocations(:,1), waterSourceLocations(:,2), 'bo','MarkerFaceColor','b') 
hold off

xlabel('Bison x position')
ylabel('Bison y position')
title('Bison ranch')

axis equal

axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');