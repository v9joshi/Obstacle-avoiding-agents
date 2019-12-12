% This program simulates multiple agents interacting with each other and
% the environment. The agents have inidivual behaviour designed to 
% a) Move towards a goal.
% b) Avoid obstacles in the way.
% c) Interact with other agents so as to move in a group but also not
% collide with each other.

% simParameters is a 4 parameter vector consisting of 
%   1) Model type - 0 Couzin 1 calovi
%   2) Total simulation time in seconds
%   3) Step time for the simulation in seconds
%   4) Step time for the agent update

% agentParameters is a 14 parameter vector consisting of 
%   1) Number of agents
%   2) Number of neighbours for each agent
%   3) Fraction of informed agents
%   4 - 9) avoid radius, align radius, attract radius, align Y intercept,
%          obstacle radius, obstacle visibility range
%   10) Turn rate
%   11 - 14) avoid weight, align weight, attract weight, obstacle weight

% obstacleParameters is a 4 parameter vector consisting of 
%   1) Obstacle type - 1 Convex, 2 Wall, 3 Concave
%   2) Obstacle scale - The diameter/length of the obstacle
%   3) Obstacle arc - The angular range of a convex/concave obstacle
%   4) Gap size - The size of the gap in the middle of the obstacle

% The outputs are the list of goal reach times for each agent. NaN if agent
% didn't reach the goal.
% The time list, statelist and list of informed agents.
%   states are X, Y, Speed and Orientation
% The location of the obstacles
% If 'verbose' is given as an argument, displays goal reach times

function [goalReachTime, agent, environment] = runAgentSimulation(simParameters, agentParameters, obstacleParameters, varargin)    
    % Model being used
    modelCalovi = simParameters(1); % 1 = Calovi et al 2018, gaussian att/ali functions; 0 = Couzin et al, fixed radii

    % Agent parameters
    numberOfAgents = agentParameters(1); % How many Agents exist?
    
    % What are the initial states of the agents?
    initialPositionX = (5+5).*rand(numberOfAgents,1) - 5; % m
    initialPositionY = (5+5).*rand(numberOfAgents,1) - 5; % m
    initialSpeed = 1*ones(numberOfAgents, 1); % m/s
    initialOrientation = (pi/2)+zeros(numberOfAgents, 1); % radians

    % Animation only params
    agentLength = 1; % The length (head to tail) of each Agents in m.
    
    % How large is the goal. This affects visibility and how close the agents have to be to the goal location to succeed
    goalSize = 5; 

    % How many neighbors should the agent social dynamics consider?
    numberOfNeighbors = agentParameters(2);
    
    % Radii for the agents
    avoidDistance = agentParameters(4);% + 0.15*numberOfAgents; %Closer than that to another agent = repulsion farther = attraction.x0.15
    alignDistance = agentParameters(5); %  Distance to other agents where alignment is maximal.
    attractDistance = agentParameters(6); % Distance to other agents where attraction is maximal.  

    % Colovi specific params
    alignYintercept = agentParameters(7); % Y-intercept of alignment gaussian.
    obstacleDistance = agentParameters(8); % Distance to obstacle where agents get repelled a lot
    obstacleVisibility = agentParameters(9); % Obstacle visibility: Higher = Obs. avoidance 'starts' farther from obstacle.

    % Agent dynamics
    turnRate = agentParameters(10); % units of radians per second. turning speed limit

    % How close to the destination do you need to be to have succeeded?
    destinationSuccessCriterion = goalSize;

    % Simulation parameters
    totalSimulationTime = simParameters(2); % How long does the simulation run?
    simStepTime = simParameters(3); % Step time for each loop of the simulation
    agentStepTime = simParameters(4);
    numStepsPerUpdate = floor(agentStepTime/simStepTime);


    %% Set up some weights for the agents
    agentWeights.Destination = zeros(numberOfAgents, 1);
    agentWeights.Avoidance = zeros(numberOfAgents, 1);
    agentWeights.Attraction = zeros(numberOfAgents, 1);
    agentWeights.Alignment = zeros(numberOfAgents, 1);
    agentWeights.Obstacle = zeros(numberOfAgents, 1);

    % How many agents know the destination?
    fractionInformed = agentParameters(3);
    
    informedAgents = round(fractionInformed*numberOfAgents);
    listOfInformedAgents = randsample(numberOfAgents, informedAgents);
    
    agentWeights.Destination(listOfInformedAgents) = 1;

    % How much do agents care about social behavior (alignment, attraction,
    % avoidance)
    agentWeights.Avoidance(:) = agentParameters(11);%1.8;
    agentWeights.Alignment(:) = agentParameters(12);%1;
    agentWeights.Attraction(:) = agentParameters(13);%1.8;

    % How much do agents care about obstacle avoidance?
    agentWeights.Obstacle(:) = agentParameters(14);

    %% Define some environment variables
    % Global attractors
    goalLocations = [0, 50];

    % Obstacle parameters
    obstacleLocation = [0,20];
    obstacleType = obstacleParameters(1); % convex arc = 1, wall = 2, or concave arc = 3, otherwise nothing
    obstacleScale = obstacleParameters(2); % length scale of obstacle
    arcAngle = obstacleParameters(3); % how many radians should arc obstacles cover?
    gapSize = obstacleParameters(4); % size of gap in the middle of the wall

    obstacleSpacing = obstacleDistance/10; % Distance between two points on the obstacle

    % Make some obstacles
    obstacleX = [];
    obstacleY = [];

    switch obstacleType
        % make convex arc obstacle
        case 1
            arcRadius = obstacleScale/2;
            obstacleLocation = [obstacleLocation(1), obstacleLocation(2) + ...
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
            arcRadius = obstacleScale/2;
            obstacleLocation = [obstacleLocation(1), obstacleLocation(2) - ...
                                arcRadius/2];
            obstacle = obstArc(obstacleLocation(1),obstacleLocation(2),...
                               arcRadius,(pi/2)-(arcAngle/2),(pi/2)+(arcAngle/2),obstacleSpacing);
        otherwise
            obstacle = [];
    end

    if ~isempty(obstacle)
        obstacleX = obstacle(:,1);
        obstacleY = obstacle(:,2);
    end
    
    % Store the obstacle
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

    params.alignYintercept = alignYintercept;
    params.obstacleDistance = obstacleDistance;
    params.obstacleVisibility = obstacleVisibility;

    params.turnRate = turnRate;
    params.stepTime = simStepTime;

    params.agentWeights = agentWeights;
    params.waterSourceLocations = goalLocations;
    params.obstacleLocations = obstacleLocations;

    params.agentLength = agentLength;
    params.goalSize = goalSize;

    % Variable initialization
    startTime = 0;
    statesList = initialStates;
    timeList = startTime;

    destination = goalLocations(1,:);

    goalReachTime = NaN(numberOfAgents,1); % time when goal was reached
    destinationReached = zeros(numberOfAgents,1); % flag for reaching the goal
    
    % What can we change for the agents?
    actionInput.desiredSpeed = initialSpeed;
    actionInput.desiredOrientation = initialOrientation;


    %% Run the simulation
    while timeList(end) < totalSimulationTime

        % What is the current state?
        statesNow = statesList(:,end);

        % Run perception and decision  steps for each agent
        if (mod(length(timeList), numStepsPerUpdate) == 0)
            for currAgent = 1:numberOfAgents
                % run the perception step and update decision input
                decisionInput = agentPerception2(currAgent, statesNow, params);    

                % run the decision step and update action input
                if modelCalovi == 1 % Gaussian curves rather than radii
                    actionInput = agentDecisionContin(currAgent, params, decisionInput, actionInput);
                else % Fixed radii
                    actionInput = agentDecision(currAgent, params, decisionInput, actionInput);
                end
            end
        end
        
        % If destination was reached, set desired agent speed and current
        % agents speed to 0.1
        actionInput.desiredSpeed(destinationReached == 0 ) = 0.1;
        statesNow(2*numberOfAgents + find(destinationReached)) = 0.1;

        % run the action step for all the agents and update the state list
        statesNow = agentAction(statesNow, params, actionInput);  

        % add on the states
        statesList = [statesList, statesNow];
        
        % update the time
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
    
    % Store the agent info
    agent.timeList = timeList;
    agent.statesList = statesList;
    agent.listOfInformedAgents = listOfInformedAgents;
    
    % Store the environment
    environment.obstacleLocations = obstacleLocations;
    environment.goalLocations = goalLocations;
    
    % Output number of succesful agents
    if any(strcmp('verbose',varargin))
        display([num2str(sum(destinationReached)),' out of ', num2str(numberOfAgents), ' successfully reached the destination']);
        display(['minimum time to goal: ', num2str(min(goalReachTime))]);
        display(['maximum time to goal: ', num2str(max(goalReachTime))]);
        display(['median time to goal: ', num2str(median(goalReachTime,'omitnan'))]);
    end
end