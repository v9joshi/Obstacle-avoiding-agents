% load some data
% close all;

% Unpack data and plot it
agentStatesList = agent.statesList;
obsSkip = 1;%20

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
plot(obstacleLocations(1:obsSkip:end,1), obstacleLocations(1:obsSkip:end,2), 'k-','MarkerFaceColor','k') 
% plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
hold off

set(gcf, 'color','w')
set(gca,'visible','off')
set(findall(gca, 'type', 'text'), 'visible', 'on')

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

% Measure the density of the flock
agentArea = (max(agentsXOut,[],2) - min(agentsXOut,[],2)).*(max(agentsYOut,[],2) - min(agentsYOut,[],2));
agentDensity = numberOfAgents./agentArea;

% Determine the order parameter of the flock over time
orderParam = abs(sum(exp(sqrt(-1)*agentsOrientationOut')))/numberOfAgents;

% Plot order parameter and y-position of all agents
figure(2)
subplot(1,3,1)
hold on
plot(agent.timeList,smooth(mean(yList),200))
ylabel('mean of the y position of all agents')
xlabel('time (s)')
title('Where are the agents?')

subplot(1,3,2)
hold on
orderParam = smooth(orderParam, 200);
plot(agent.timeList,orderParam)
ylabel('Order Parameter')
xlabel('time (s)')
title('How aligned are the agents?')
ylim([0,1.5])

subplot(1,3,3)
hold on
plot(agent.timeList,agentDensity)
ylabel('Density (number of agents/area)')
xlabel('time (s)')
title('What is the density of the agents?')
ylim([0,1.5])

set(gcf, 'color','w')

% Plot order parameter and y-position on the same axes.
figure(3)
yyaxis left
plot(agent.timeList,mean(yList))

yyaxis right
plot(agent.timeList,orderParam)
ylim([0,2])

figure(6)
plot(std(goalReachTime))


%% Animation specific variables
% How large do we want each agent to be
agentLength = 1;
arrowheadSize = 7;

listOfInformedAgents = agent.listOfInformedAgents;
listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

timeList = agent.timeList;
destinationList = goalLocations;

semiAgentSize = agentLength/2;

currTimeIndex = 1;

%% Animate the data and make a video
figure(4)

plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')

% Name the video file
% videoFileName = 'testmovie4.mp4';
% vidfile = VideoWriter(videoFileName,'MPEG-4');
% open(vidfile);

warning('off','arrow:warnlimits')

numStepsPerUpdate = 50;
set(gcf, 'color','w')

% Animate and make video
for currTimeIndex = 1:2 %numStepsPerUpdate:length(timeList)
    set(0, 'currentfigure',4);
    plot(obstacleLocations(1:obsSkip:end,1), obstacleLocations(1:obsSkip:end,2), 'k-','MarkerFaceColor','k') 
    hold on
    
%     xlabel('Agents x position')
%     ylabel('Agents y position')

    title(['Align weight = ', num2str(agentParameters(12))])
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

    text(0.15,0.95,sprintf('t = %3.1f s',agent.timeList(currTimeIndex)),'units','normalized','HorizontalAlignment', 'left','FontSize',10)
    set(gca, 'visible','off')
    set(findall(gca, 'type', 'text'), 'visible', 'on')
    hold off
    pause(0.01);
    
    % Save the frame
    F = getframe(gcf);
    
    % Write the frame to the video file
%     writeVideo(vidfile,F);
end

% close the video maker to make the file
% close(vidfile)

%% Gif writing
% Name the video file
gifFileName = 'single_agent_scrape.gif';
% Video settings
numStepsPerUpdate = 10;

% How large do we want each agent to be
agentLength = 1;
arrowheadSize = 20;
figHandle = figure(5);
% axes('Position',[0,0,1.2,1.2])
% plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
plot(obstacleLocations(1:obsSkip:end,1), obstacleLocations(1:obsSkip:end,2), 'k-','MarkerFaceColor','k')
hold on
plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')


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
warning('off','arrow:warnlimits')

set(gcf, 'color','w')
mainAx = gca;

% Make inset figure
axes('Position',[0.6,0.05,0.3,0.3])

% Agent positions
plot(xList', yList');
hold on
% Environment elements
plot(obstacleLocations(1:obsSkip:end,1), obstacleLocations(1:obsSkip:end,2), 'k-','MarkerFaceColor','k') 
set(gca,'xtick',[],'ytick',[])
% xlim(axisLimits.X)
% ylim(axisLimits.Y)
hold off
axis equal
box on

% Switch back to main axis
set(figHandle,'currentaxes',mainAx)

% Animate and make video
for currTimeIndex = 1:20*numStepsPerUpdate:length(timeList)
    set(0, 'currentfigure',figHandle)
    plot(obstacleLocations(1:obsSkip:end,1), obstacleLocations(1:obsSkip:end,2), 'k-','MarkerFaceColor','k')
%     hold on
%     plot([-2000, 2000], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')

%     xlabel('Agents x position')
%     ylabel('Agents y position')

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
%     title(['Align weight = ', num2str(agentParameters(12))])
    title(['Turn rate = ', num2str(agentParameters(10))])
    text(0,0.95,sprintf('t = %3.1f s',agent.timeList(currTimeIndex)),'units','normalized','HorizontalAlignment', 'left','FontSize',10)
    set(gca, 'visible','off')
    set(findall(gca, 'type', 'text'), 'visible', 'on')

    hold off
    ylim([-20,50])

    pause(0.01);
%     pause(0.01);
    
    % Save the frame
    F = getframe(figHandle); 
    im = frame2im(F);
    [imind, cm] = rgb2ind(im, 256);
    
    % Write the frame to the gif file
    if currTimeIndex == 1 
        imwrite(imind,cm,gifFileName,'gif','DelayTime',0, 'Loopcount',inf); 
    else 
        imwrite(imind,cm,gifFileName,'gif','DelayTime',0,'WriteMode','append'); 
    end 
end