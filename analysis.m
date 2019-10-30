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

clc;clear;
simParameters = [0 100 0.1]; % Model type, total sim time, stepTime
agentParameters = [10 5 1, 1 5 10, 1 1 50, 2, 1 8 1 3];
obstacleParameters = [1 20 pi 0];

%% Static Plot [add plotting environment]
agent = agnt{9}; % Enter run number in {}

figure(1)
agentsXOut = agent.statesList(1:agentParameters(1),:)';
agentsYOut = agent.statesList(agentParameters(1)+1:agentParameters(1)*2,:)';
plot(agentsXOut, agentsYOut);
% hold on
% plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
% plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
% plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
% hold off

xlabel('Agent x position')
ylabel('Agent y position')
title('Agent world')

axis equal
axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

%% Plotting all movement figures in panels
for run = 1:size(agnt,2)
    subplot(ceil(sqrt(size(agnt,2))),floor(sqrt(size(agnt,2))),run)
    agent = agnt{run};
    agentsXOut = agent.statesList(1:agentParameters(1),:)';
    agentsYOut = agent.statesList(agentParameters(1)+1:agentParameters(1)*2,:)';
    plot(agentsXOut, agentsYOut);
    axis equal
    axisLimits.X = get(gca, 'xlim');
    axisLimits.Y = get(gca, 'ylim');
end
xlabel('Agent x position')
ylabel('Agent y position')
title('Agent world')

%% Make permutation matrix [make better] & run simulation over the parameter space
% Makes matrix of parameter space [make better, full factorial possibility]
wRepParamRange = 1:2:10; wRepSize = size(wRepParamRange,2);
wAliParamRange = 1:2:10; wAliSize = size(wAliParamRange,2);
wAttParamRange = 2:2:10; wAttSize = size(wAttParamRange,2);
agentParamList = repmat(agentParameters,[wRepSize+wAttSize+wAliSize,1]);
agentParamList(1:wRepSize,11) = wRepParamRange; % Inserts param ranges
agentParamList(wRepSize+1:wRepSize+wAliSize,12) = wAliParamRange;
agentParamList(wRepSize+wAliSize+1:wRepSize+wAliSize+wAttSize,13) = wAttParamRange;

% Runs sim over param space
for run = 1:size(agentParamList,1)
    [goalReachTime, agent, environment] = runAgentSimulation(simParameters, agentParamList(run,:), obstacleParameters);
    grt{run} = goalReachTime;
    agnt{run} = agent;
    env{run} = environment;
end

%% Analyze all runs
for run = 1:size(agnt,2)
    agent = agnt{run};
    agentStatesList = agent.statesList;
    agentTimeList = agent.timeList;
    agentParameters = agentParamList(run,:);
    % Group diameter
    rootMeanPairDist(run) = mean(groupSpread(agentParameters, agentStatesList, agentTimeList));
    % Angular velocity
    moveMetrics = moveMetricsMaker(simParameters, agentParameters, agentStatesList, agentTimeList);
    moveMetrics{run} = cell2mat(moveMetrics);
    % Group mean of turning angles/stepTime by time (direction agnostic)
    for t = 1:size(agentStatesList,2)
        angles = moveMetrics{run}(abs(moveMetrics{run}(:,3)-(t*simParameters(3)))<1e-6,13);
        angleMeanByTime(t,run) = mean(abs(angles(~isnan(angles))));
    end
end

%% Plot parameter spaces
% Group Spread in Root Mean Pair Distance 
scatter3(agentParamList(:,11),agentParamList(:,12),agentParamList(:,13),10,rootMeanPairDist, 'filled')
xlabel('Avoid weight'); ylabel('Align weight'); zlabel('Attract weight')
colorbar
title('Group Spread [RMPD]')

%% Plot angles: y=time, x=runs
imagesc(angleMeanByTime(30:end,:))
xlabel('Run')
ylabel('Angular Velocity')
colorbar

%% Plot goal reach time
goalReachTimeList = cell2mat(grt);
boxplot(goalReachTimeList, 'PlotStyle','compact')
xlabel('Run')
ylabel('Goal Reach Time')
