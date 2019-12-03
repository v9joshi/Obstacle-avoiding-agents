function [meanSuccessRate] = optimizeAgents(inputs)

    successRate = 0;
    numRuns = 100;
    
    % constant sim params
    simParameters = [0 250 0.01 0.1]; % Model type, total sim time, stepTime
    
    % variable agent weights
    agentParameters = [5 inf 1, 1 5 10, 0.6 1 50, 2, 1 inputs 1 1]; % 1 50 1 1
    
    % Constant obstacle
    obstacleParameters = [3 15 pi 0];   
    
    for run = 1:numRuns %size(agentParamList,1)
        [goalReachTime, ~, ~] = runAgentSimulation(simParameters, agentParameters, obstacleParameters);
    %     grt{run} = goalReachTime;
    %     agnt{run} = agent;
    %     env{run} = environment;

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

    meanSuccessRate = successRate/numRuns;

end