% load some data
close all;

% Unpack data and plot it
agentStatesList = agent.statesList;
numberOfAgents = size(agentStatesList, 1)/4;
xList = agentStatesList(1:numberOfAgents,:);
yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);

goalLocations = environment.goalLocations;

figure(1)
plot(xList', yList');
obstacles = environment.obstacleLocations;
hold on
plot(obstacles(:,1), obstacles(:,2),'kx')
plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
axis equal

axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

% Animate the data
figure(2)
% How large do we want each agent to be
agentLength = 1;
arrowheadSize = 7;

agentsXOut = xList';
agentsYOut = yList';
obstacleLocations = obstacles;

agentsOrientationOut = agentStatesList(3*numberOfAgents + 1 :end,:)';

listOfInformedAgents = agent.listOfInformedAgents;
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

timeList = agent.timeList;
destinationList = goalLocations;

semiAgentSize = agentLength/2;

warning('off','arrow:warnlimits')

numStepsPerUpdate = 10;

for currTimeIndex = 1:10*numStepsPerUpdate:length(timeList)
    set(0, 'currentfigure',2);
    plot(goalLocations(:,1), goalLocations(:,2), 'bo','MarkerFaceColor','b') 
    hold on
    plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
   
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
              arrowheadSize, 'color', 'k');
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
    