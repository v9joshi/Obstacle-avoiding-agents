function [meanSuccessRate] = optimizeAgents(inputs)

    % Initialize the success rate and the number of runs
    successRate = 0;
    numRuns = 300;
    
    % constant sim params
    simParameters = [1 250 0.01 0.1]; % Model type, total sim time, stepTime
    
    % variable agent weights
    agentParameters = [5 inf 1, 1 5 10, 0.6 1 50, 2, 1 inputs 1 1]; % 1 50 1 1
    
    % Constant obstacle
    obstacleParameters = [3 15 pi 0];   
    
    % Run the simulation several times
    for run = 1:numRuns %size(agentParamList,1)
        [goalReachTime, ~, ~] = runAgentSimulation(simParameters, agentParameters, obstacleParameters);
    %     grt{run} = goalReachTime;
    %     agnt{run} = agent;
    %     env{run} = environment;
        
        % Measure the success rate of the agents
        numberOfAgents = agentParameters(1);
        successRate = successRate + sum(~isnan(goalReachTime))/numberOfAgents;

    %     agentStatesList = agent.statesList;
    %     
    %     xList = agentStatesList(1:numberOfAgents,:);
    %     yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);
    %     
    %     hold on
    %     plot(xList', yList');
    %     axis equal
    end
    
    % Calculate the mean success rate across runs
    meanSuccessRate = successRate/numRuns;

end