% All the params
clc; clear all; close all;

% paramSet =   [0,300,0.01,0.01,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               1,300,0.01,0.01,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               0,300,0.01,0.1,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               1,300,0.01,0.1,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               0,300,0.01,0.3,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               1,300,0.01,0.3,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               0,300,0.01,0.1,10,inf,0.1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               1,300,0.01,0.1,10,inf,0.1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               0,300,0.01,0.1,10,inf,0.5,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               1,300,0.01,0.1,10,inf,0.5,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               0,300,0.01,0.1,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0;
%               1,300,0.01,0.1,10,inf,1,1,5,10,0.6,1,50,2,1,36.3,1,6.56,3,15,pi,0];

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
% Load the parameters
paramTable = readtable('parameters20200421.csv');

paramSet = [paramTable.modelCalovi, paramTable.totalSimulationTime, paramTable.physicsStepTime, paramTable.agentStepTime,...
            paramTable.numberOfAgents, paramTable.numberOfNeighbors, paramTable.fractionInformed, paramTable.avoidDistance,...
            paramTable.alignDistance, paramTable.attractDistance, paramTable.alignYintercept, paramTable.obstacleDistance,...
            paramTable.obstacleVisibility, paramTable.turnRate, paramTable.avoidWeight, paramTable.alignWeight,...
            paramTable.attractWeight, paramTable.obstacleWeight, paramTable.obstacleType, paramTable.obstacleScale,...
            paramTable.arcAngle, paramTable.gapSize];


numReps = 50;

% Create the data storage folder
if ~exist('Data','dir')
    mkdir('Data')
end

% Loop through the param set
for setNum = 13:14
    % Unpack the parameters
    simParameters      = paramSet(setNum,1:4);
    agentParameters    = paramSet(setNum,5:18);
    obstacleParameters = paramSet(setNum,19:22);
    
    folderName = ['Data\ParameterSet',num2str(setNum)];
    
    if ~exist(folderName,'dir')
        mkdir(folderName);
    end
    
    % Repeat each one 100 times?
    for repNum = 1:numReps
        % What run number are we on?
        run = numReps*(setNum - 1) + repNum;
        display(['Running Set', num2str(setNum),' Rep',num2str(repNum)]);
                
        % Run the set
        [goalReachTime, agent, environment] = runAgentSimulation(simParameters, agentParameters, obstacleParameters);

        % Save the outputs
        fileName = ['ParameterSet',num2str(setNum),'\Rep',num2str(repNum)];
        save(['Data\',fileName,'.mat'],'agent','goalReachTime','environment','simParameters','agentParameters','obstacleParameters')    
        
        % Store the outputs in cells
        grt{run} = goalReachTime;
        agnt{run} = agent;
        env{run} = environment;
    end
end
  
% Save the outputs, might contain variables that are too large
% save('paramSweep.mat')

% %% plot the agents and the obstacle
% 
% figure(1)
% for currRun = 1:length(agnt)
%     
%     goalReachTime = grt{currRun};
%     agent = agnt{currRun};
%     environment = env{run};
%     
%     setNum = 1 + floor((currRun - 1)/numReps);
%     repNum = currRun - numReps*(setNum - 1);
%     
%     agentStatesList = agent.statesList;
%     obstacles = environment.obstacleLocations;
%     
%     numberOfAgents = size(agentStatesList, 1)/4;
%     
%     successRate(currRun) = sum(~isnan(goalReachTime))/numberOfAgents;
%     maxReachTime(currRun) = max(goalReachTime);
%     
    %     xList = agentStatesList(1:numberOfAgents,:);
    %     yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);   
%     
%     hold on
%     plot(xList', yList');
%     plot(obstacles(:,1), obstacles(:,2),'kx')
%     axis equal
%     
%     folderName = ['Data\ParameterSet',num2str(setNum)];
%     
%     if ~exist(folderName,'dir')
%         mkdir(folderName);
%     end
%     
%     fileName = ['ParameterSet',num2str(setNum),'\Rep',num2str(repNum)];
%     
%     simParameters      = paramSet(setNum,1:4);
%     agentParameters    = paramSet(setNum,5:18);
%     obstacleParameters = paramSet(setNum,19:22);
% 
%     save(['Data\',fileName,'.mat'],'agent','goalReachTime','environment','simParameters','agentParameters','obstacleParameters')    
% end
% 
% successRate = reshape(successRate, numReps, size(paramSet,1));
% maxReachTime = reshape(maxReachTime,  numReps, size(paramSet,1));
% 
