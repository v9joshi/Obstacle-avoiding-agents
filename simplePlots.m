%% Summary stats
display([num2str(nnz(~isnan(goalReachTime))),' out of ', num2str(length(goalReachTime)), ' successfully reached the destination']);
display(['minimum time to goal: ', num2str(min(goalReachTime))]);
display(['maximum time to goal: ', num2str(max(goalReachTime))]);
display(['median time to goal: ', num2str(median(goalReachTime,'omitnan'))]);


%% Static Plot [add plotting environment]
numberOfAgents = agentParameters(1);

figure(1)

agentsXOut = statesList(1:numberOfAgents,:)';
agentsYOut = statesList(numberOfAgents + 1: 2*numberOfAgents,:)';
agentsSpeedOut = statesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';
agentsOrientationOut = statesList(3*numberOfAgents + 1 :end,:)';

plot(agentsXOut, agentsYOut);
hold on
plot(environment.obstacleLocations(:,1), environment.obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
%plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
plot(environment.goalLocations(:,1), environment.goalLocations(:,2), 'bo','MarkerFaceColor','b') 
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
agentLength = 1;
arrowheadSize = 7;
semiAgentSize = agentLength/2;
numStepsPerUpdate = floor(simParameters(4)/simParameters(3));
timeList = agent.timeList;

warning('off','arrow:warnlimits')

for currTimeIndex = 1:3*numStepsPerUpdate:length(timeList)
    set(0, 'currentfigure',2);
    plot(environment.goalLocations(:,1), environment.goalLocations(:,2), 'bo','MarkerFaceColor','b') 
    hold on
    %plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
    plot(environment.obstacleLocations(:,1), environment.obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
   
    xlabel('Agents x position')
    ylabel('Agents y position')

    title('Agent home')
    axis equal    
    xlim(axisLimits.X)
    ylim(axisLimits.Y)
    
    % draw regular agents
%     if ~isempty(agent.listOfUninformedAgents)
%         arrow([agentsXOut(currTimeIndex,agent.listOfUninformedAgents) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,agent.listOfUninformedAgents));...
%                agentsYOut(currTimeIndex,agent.listOfUninformedAgents) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,agent.listOfUninformedAgents))]',...
%               [agentsXOut(currTimeIndex,agent.listOfUninformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,agent.listOfUninformedAgents));...
%                agentsYOut(currTimeIndex,agent.listOfUninformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,agent.listOfUninformedAgents))]',...
%               arrowheadSize, 'color', 'k');
%     end
    % draw leader agents
    if ~isempty(agent.listOfInformedAgents)
        arrow([agentsXOut(currTimeIndex,agent.listOfInformedAgents) - semiAgentSize*cos(agentsOrientationOut(currTimeIndex,agent.listOfInformedAgents));...
               agentsYOut(currTimeIndex,agent.listOfInformedAgents) - semiAgentSize*sin(agentsOrientationOut(currTimeIndex,agent.listOfInformedAgents))]',...
              [agentsXOut(currTimeIndex,agent.listOfInformedAgents) + semiAgentSize*cos(agentsOrientationOut(currTimeIndex,agent.listOfInformedAgents));...
               agentsYOut(currTimeIndex,agent.listOfInformedAgents) + semiAgentSize*sin(agentsOrientationOut(currTimeIndex,agent.listOfInformedAgents))]',...
              arrowheadSize, 'color', 'r');
    end
    hold off
    pause(0.01);
    
end