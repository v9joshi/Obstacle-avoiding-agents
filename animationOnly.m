% load some data
close all;

% Unpack data and plot it
agentStatesList = agent.statesList;

% How many agents are there?
numberOfAgents = size(agentStatesList, 1)/4;

% What are the positions of all the agents?
xList = agentStatesList(1:numberOfAgents,:);
yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);

% Where are the environment elements located?
goalLocations = environment.goalLocations;
obstacleLocations = environment.obstacleLocations;
    
% Simple plot of agent and environment positions over time
figure(1)
% Agent positions
plot(xList', yList');
hold on
% Environment elements
plot(obstacleLocations(1:20:end,1), obstacleLocations(1:20:end,2), 'k-','MarkerFaceColor','k') 
plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
hold off

% Get plot limits
axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');
axis equal

% reformat the outputs
agentsXOut = xList';
agentsYOut = yList';

% What is the orientation and speed of the agents?
agentsOrientationOut = agentStatesList(3*numberOfAgents + 1 :end,:)';
agentsSpeedOut = agentStatesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';

% Determine the order parameter of the flock over time
orderParam = abs(sum(exp(sqrt(-1)*agentsOrientationOut')))/numberOfAgents;

% Plot order parameter and y-position of all agents
figure(2)
subplot(1,2,1)
plot(agent.timeList,smooth(mean(yList),200))
ylabel('mean of the y position of all agents')
xlabel('time (s)')
title('Where are the agents?')

subplot(1,2,2)
orderParam = smooth(orderParam, 200);
plot(agent.timeList,orderParam)
ylabel('Order Parameter')
xlabel('time (s)')
title('How aligned are the agents?')
ylim([0,1.5])

set(gcf, 'color','w')

% Plot order parameter and y-position on the same axes.
figure(3)
yyaxis left
plot(agent.timeList,mean(yList))

yyaxis right
plot(agent.timeList,orderParam)
ylim([0,2])

%% Animate the data and make a video
figure(4)
% How large do we want each agent to be
agentLength = 1;
arrowheadSize = 7;


listOfInformedAgents = agent.listOfInformedAgents;
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

timeList = agent.timeList;
destinationList = goalLocations;

semiAgentSize = agentLength/2;

 plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
 plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
      plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')

% Name the video file
videoFileName = 'testmovie2.mp4';
vidfile = VideoWriter(videoFileName,'MPEG-4');
open(vidfile);

warning('off','arrow:warnlimits')

numStepsPerUpdate = 10;
set(gcf, 'color','w')

% Animate and make video
for currTimeIndex = 1:5*numStepsPerUpdate:length(timeList)
    set(0, 'currentfigure',4);
    plot(obstacleLocations(1:20:end,1), obstacleLocations(1:20:end,2), 'k-','MarkerFaceColor','k') 
    hold on
      
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
    
    % Save the frame
    F = getframe(gcf); 
    
    % Write the frame to the video file
    writeVideo(vidfile,F);
end

% close the video maker to make the file
close(vidfile)

    