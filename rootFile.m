% This program simulates multiple agents interacting with each other and
% the environment. The agents have inidivual behaviour designed to 
% a) Move towards a goal.
% b) Avoid obstacles in the way.
% c) Interact with other agents so as to move in a group but also not
% collide with each other.

% Clear and close everything
clc; clear;% close all; 
figure

%% Define sim parameters
paramNames = ["modelCalovi";"numberOfAgents";"numberOfNeighbors";...
    "fractionInformed";"avoidDistance";"alignDistance";"attractDistance";...
    "avoidWeight";"alignWeight";"attractWeight";"obstacleWeight";
    "arcRadius";"noiseDegree";"persistenceWeight"];
paramValues =...
[0, 1,7, 1,1, 5,10, 1,3,1,1, 7.5,0,30;
 0, 1,7, 1,1, 5,10, 1,3,1,1, 7.5,0,40;
 0, 1,7, 1,1, 5,10, 1,3,1,1, 7.5,0,50;
 0, 1,7, 1,1, 5,10, 1,3,1,1, 7.5,0,150;
 1,10,7, 1,1, 5,10, 1,3,1,6, 7.5 15,1;
 1,10,7, 1,1, 5,10, 1,6,1,6, 7.5 15,1;
 1,10,7, 1,1, 5,10, 1,9,1,6, 7.5 15,1;
 1,10,7, 1,1, 5,10, 1,12,1,6, 7.5 15,1;
 0,10,7, 1,1, 5,10, 1,12,1,6,7.5 0,1;
 0,10,7, 1,1, 5,10, 1,6,2,6, 7.5 0,1;
 0,10,7, 1,1, 5,10, 1,6,1,12,7.5 0,1];
p = array2table(paramValues, 'VariableNames',paramNames);

tiledlayout('flow')
for s = 1:4%size(paramValues,1)
% Model being used
modelCalovi = p.modelCalovi(s); % 1 = Calovi et al 2018, gaussian att/ali functions; 0 = Couzin et al, fixed radii
% Simulation parameters
totalSimulationTime = 300; % How long does the simulation run?
simStepTime = 0.01; % Step time for each loop of the simulation

%% Define agent parameters
% How many Agents exist?
numberOfAgents = p.numberOfAgents(s);

% How often do agents update decisions
numStepsPerUpdate = 10*ones(numberOfAgents,1);
agentStepTime = simStepTime*numStepsPerUpdate;

if modelCalovi == 1
   numStepsPerUpdate = round(numStepsPerUpdate + (2*rand(numberOfAgents,1) - 1)*0.1.*numStepsPerUpdate);
end

% How many neighbors should the agent social dynamics consider?
numberOfNeighbors = p.numberOfNeighbors(s);

% How many agents know the destination?
fractionInformed = p.fractionInformed(s);
informedAgents = round(fractionInformed*numberOfAgents);
listOfInformedAgents = randsample(numberOfAgents, informedAgents);
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

% Radii for the agents
avoidDistance = p.avoidDistance(s); %Closer than that to another agent = repulsion farther = attraction.x0.15
alignDistance = p.alignDistance(s); %  Distance to other agents where alignment is maximal.
attractDistance = p.attractDistance(s); % Distance to other agents where attraction is maximal.

% Colovi specific params
obstacleDistance = 1; %p.obstacleDistance(s); % Distance to obstacle where agents get repelled a lot
obstacleVisibility = 1; %p.obstacleVisibility(s); % Obstacle visibility: Higher = Obs. avoidance 'starts' farther from obstacle.

% Agent dynamics
turnRate = 2; % p.turnRate(s); % units of radians per second. turning speed limit
noiseDegree = p.noiseDegree(s);

% Agent social weights
avoidWeight = p.avoidWeight(s);
alignWeight = p.alignWeight(s);
attractWeight = p.attractWeight(s);
obstacleWeight = p.obstacleWeight(s);
persistenceWeight = p.persistenceWeight(s);

% Obstacle parameters
obstacleType = 3;    % convex arc = 1, wall = 2, or concave arc = 3, otherwise nothing
obstacleScale = 15;  % length scale of obstacle [obsolete in arc]
arcLength = pi*7.5;  % length of the obstacle arc in length units (regardless of angle & radius)
arcRadius = p.arcRadius(s); % radius of the arc (position stays the same)
arcAngle = arcLength/arcRadius; % how many degrees should arc obstacles cover?
gapSize = 0;         % size of gap in the middle of the wall

obstacleLocation = [0,20]; % The center for the obstacle

% How large is the goal. This affects visibility and how close the agents have to be to the goal location to succeed
goalSize = 0; 

% What are the initial states of the agents?
initialPositionX = (5+5).*rand(numberOfAgents,1) - 5; % m
initialPositionY = (5+5).*rand(numberOfAgents,1); % m
initialSpeed = 1*ones(numberOfAgents, 1); % m/s
initialOrientation = pi/2*ones(numberOfAgents, 1); % radians

% Animation only params
agentLength = 1; % The length (head to tail) of each Agents in m. Used only for plotting.
arrowheadSize = 7; % Size of arrowheads on plotted agents, in pixels.

% How close to the destination do you need to be to have succeeded?
destinationSuccessCriterion = goalSize+1000;

%% Set up some weights for the agents
agentWeights.Destination = zeros(numberOfAgents, 1);
agentWeights.Avoidance = zeros(numberOfAgents, 1);
agentWeights.Attraction = zeros(numberOfAgents, 1);
agentWeights.Alignment = zeros(numberOfAgents, 1);
agentWeights.Obstacle = zeros(numberOfAgents, 1);
agentWeights.Persistence = zeros(numberOfAgents, 1);

% How much do agents care about the destination
agentWeights.Destination(listOfInformedAgents) = 1;

% How much do agents care about social behavior (alignment, attraction,
% avoidance)
agentWeights.Avoidance(:) = avoidWeight;%1.8;
agentWeights.Attraction(:) = attractWeight;%1.8;
agentWeights.Alignment(:) = alignWeight;%1;
agentWeights.Persistence(:) = persistenceWeight;

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
        obstacleLocation = [obstacleLocation(1), obstacleLocation(2) - ...
                             arcRadius/2];
        obstacle = obstArc(obstacleLocation(1),obstacleLocation(2),...
                           arcRadius,(pi/2)+(arcAngle/2),(pi/2)-(arcAngle/2),obstacleSpacing);
    % make wall obstacle
    case 2
        x1 = obstacleLocation(1) - obstacleScale/2;
        y1 = obstacleLocation(2);
        x2 = obstacleLocation(1) + obstacleScale/2;
        y2 = obstacleLocation(2);
        obstacle = obstLine(x1, y1, x2, y2, obstacleSpacing, gapSize);
    % make concave arc obstacle
    case 3
        obstacleLocation = [obstacleLocation(1), obstacleLocation(2) - ...
                            arcRadius];
        obstacle = obstArc(obstacleLocation(1),obstacleLocation(2),...
                           arcRadius,(pi/2)-(arcAngle/2),(pi/2)+(arcAngle/2),obstacleSpacing);
    otherwise
        obstacle = [];
end

if ~isempty(obstacle)
    obstacleX = obstacle(:,1);
    obstacleY = obstacle(:,2);
end

%wallObstacleA.Y = []; %  10:avoidDistance/5:15;
%wallObstacleA.X = []; % -15*ones(length(wallObstacleA.Y),1);

%wallObstacleB.X = -15:obstacleSpacing:(-15 + 2*groupDiameter);
%wallObstacleB.Y = 15*ones(length(wallObstacleB.X),1);

%obstacleLocations = [wallObstacleA.X(:), wallObstacleA.Y(:);
%                     wallObstacleB.X(:), wallObstacleB.Y(:)];
obstacleLocations = [obstacleX(:), obstacleY(:)];

%% Set simulation parameters and initialize variables
% Collect all the initial states together
initialStates = [initialPositionX; initialPositionY; initialSpeed; initialOrientation];

% Collect all the parameters
params.numberOfAgents = numberOfAgents;

params.avoidDistance = avoidDistance;
params.alignDistance = alignDistance;
params.attractDistance = attractDistance;

params.numberOfNeighbors = numberOfNeighbors;

params.obstacleDistance = obstacleDistance;
params.obstacleVisibility = obstacleVisibility;

params.turnRate = turnRate;
params.stepTime = simStepTime;
params.noiseDegree = noiseDegree;

params.agentWeights = agentWeights;
params.waterSourceLocations = goalLocations;
params.obstacleLocations = obstacleLocations;

params.agentLength = agentLength;
params.goalSize = goalSize;

params.obstacleSpacing = obstacleSpacing;

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
       if (mod(length(timeList), numStepsPerUpdate(currAgent)) == 0)
            % run the perception step and update decision input
            decisionInput = agentPerception3(currAgent, statesNow, params);
            
            % run the decision step and update action input
            if modelCalovi == 1 % Gaussian curves rather than radii
                actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput);
            else % Fixed radii
                actionInput = agentDecision(currAgent, params, decisionInput, actionInput);
            end
        end
    end
    
%     % If destination was reached, set desired agent speed and current
%     % agents speed to 0.1
%     actionInput.desiredSpeed(destinationReached == 0 ) = 0.1;
%     statesNow(2*numberOfAgents + find(destinationReached)) = 0.1;

    % run the action step for all the agents and update the state list
    statesNow = agentAction2(statesNow, params, actionInput);  
    
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

% Output number of succesfuly agents
% disp([num2str(sum(destinationReached)),' out of ', num2str(numberOfAgents), ' successfully reached the destination']);
% disp(['minimum time to goal: ', num2str(min(goalReachTime))]);
% disp(['maximum time to goal: ', num2str(max(goalReachTime))]);
% disp(['median time to goal: ', num2str(median(goalReachTime,'omitnan'))]);

%% Unpack output states
agentsXOut = statesList(1:numberOfAgents,:)';
agentsYOut = statesList(numberOfAgents + 1: 2*numberOfAgents,:)';
agentsSpeedOut = statesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';
agentsOrientationOut = statesList(3*numberOfAgents + 1 :end,:)';

%% Plot and output some data
nexttile
plot(agentsXOut, agentsYOut);
hold on
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
% plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
% plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
plot([-20 20], [50 50],'b') 
hold off

xlabel(paramNames(s))
ylabel('Agent y position')
title([num2str(paramValues(s,end))])

axis equal
axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

% annotation('textbox',[.1 .05 1 0],'string',num2str(paramValues(1,:),2))
% annotation('textbox',[.95 .2 1 0],'string',cellstr(paramNames)','fontsize',5)  
% annotation('textbox',[.75 .3 0 0],'string',...
%     cellstr(paramNames(1:7)))
% annotation('textbox',[.85 .3 0 0],'string',...
%     cellstr(paramNames(8:end)))

end
%% Animate the motion
% figure(2)
% % How large do we want each agent to be
% semiAgentSize = agentLength/2;
% 
% warning('off','arrow:warnlimits')
% 
% for currTimeIndex = 1:10*numStepsPerUpdate:length(timeList)
%     set(0, 'currentfigure',2);
%     plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
%     hold on
%     plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
%     plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
%    
%     xlabel('Agents x position')
%     ylabel('Agents y position')
% 
%     title('Agent home')
%     axis equal    
%     xlim(axisLimits.X)
%     ylim(axisLimits.Y)
%     
%     % draw regular agents
%     if ~isempty(listOfUninformedAgents)
%         arrow([agentsXOut(currTimeIndex,listOfUninformedAgents) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfUninformedAgents));...
%                agentsYOut(currTimeIndex,listOfUninformedAgents) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfUninformedAgents))]',...
%               [agentsXOut(currTimeIndex,listOfUninformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfUninformedAgents));...
%                agentsYOut(currTimeIndex,listOfUninformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfUninformedAgents))]',...
%               arrowheadSize, 'color', 'k');
%     end
%     % draw leader agents
%     if ~isempty(listOfInformedAgents)
%         arrow([agentsXOut(currTimeIndex,listOfInformedAgents) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfInformedAgents));...
%                agentsYOut(currTimeIndex,listOfInformedAgents) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfInformedAgents))]',...
%               [agentsXOut(currTimeIndex,listOfInformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,listOfInformedAgents));...
%                agentsYOut(currTimeIndex,listOfInformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,listOfInformedAgents))]',...
%               arrowheadSize, 'color', 'r');
%     end
%     hold off
%     pause(0.01);
%     if double(get(gcf,'CurrentCharacter')) == 27 % Stop animation if Esc pressed
%         break
%     end
% end
% 
% % * avoidDistance function determined by:
% %   1. simulating different group sizes w/ different avoidDist,
% %   2. determining the avoidDistance which gave a [mean distance to closest neighbor] closest to 1
% %   3. fitting a regression model to the above avoidDistances vs numberOfAgents
