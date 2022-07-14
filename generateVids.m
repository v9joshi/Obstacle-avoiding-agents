clearvars

% Read the table of files
vidSources = readtable('vidFileNames.xlsx');

for currFile  = 1:height(vidSources)
    % load some data
    close all;
    load(vidSources.FileName{currFile})
    
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

    % Make lists of informed and uninformed agents
    listOfInformedAgents = agent.listOfInformedAgents;
    listOfUninformedAgents = setdiff(1:numberOfAgents, listOfInformedAgents)';

    % Unpack some information
    timeList = agent.timeList;
    destinationList = goalLocations;
    
    % What is the orientation and speed of the agents?
    agentsOrientationOut = agentStatesList(3*numberOfAgents + 1 :end,:)';
    agentsSpeedOut = agentStatesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';
    
    % Determine the order parameter of the flock over time
    orderParam = abs(sum(exp(sqrt(-1)*agentsOrientationOut')))/numberOfAgents;
          
    %% Gif and video writing
    % Name the video file
    videoFileName = ['C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Figures and tables\videos\',vidSources.OutputFolder{currFile},'\',vidSources.OutputFileName{currFile},'.mp4'];
    vidfile = VideoWriter(videoFileName,'MPEG-4');
%     vidfile.Quality = 80;
    open(vidfile);
    
    % Name the gif file
    gifFileName = ['C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Figures and tables\videos\',vidSources.OutputFolder{currFile},'\',vidSources.OutputFileName{currFile},'_gif.gif'];

    % Video settings
    numStepsPerUpdate = 10;
    
    % How large do we want each agent to be
    agentLength = 1;
    arrowheadSize = 7;
    semiAgentSize = agentLength/2;

    figHandle = figure(5);
    % axes('Position',[0,0,1.2,1.2])
    % plot(destinationList(:,1), destinationList(:,2), 'bo','MarkerFaceColor','g') 
    plot(obstacleLocations(1:20:end,1), obstacleLocations(1:20:end,2), 'k-','MarkerFaceColor','k')
    hold on
    plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
    
    % draw regular agents
    currTimeIndex = 1;
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
    plot(obstacleLocations(1:20:end,1), obstacleLocations(1:20:end,2), 'k-','MarkerFaceColor','k') 
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
        plot(obstacleLocations(1:20:end,1), obstacleLocations(1:20:end,2), 'k-','MarkerFaceColor','k')
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
        title(vidSources.Title{currFile})%['Align weight = ', num2str(agentParameters(6))])
        text(0,0.95,sprintf('t = %3.1f s',agent.timeList(currTimeIndex)),'units','normalized','HorizontalAlignment', 'left','FontSize',10)
        set(gca, 'visible','off')
        set(findall(gca, 'type', 'text'), 'visible', 'on')
    
        hold off
        set(figHandle,'units','normalized','outerposition',[0.2 0.2 0.6 0.6])

        pause(0.01);
    %     pause(0.01);
        
        % Save the frame
        F = getframe(figHandle);
        % Write the frame to the video file
        writeVideo(vidfile,F);

        % Convert Frame to im for gif
        im = frame2im(F);
        [imind, cm] = rgb2ind(im, 256);
        
        % Write the frame to the gif file
        if currTimeIndex == 1 
            imwrite(imind,cm,gifFileName,'gif','DelayTime',0, 'Loopcount',inf); 
        else 
            imwrite(imind,cm,gifFileName,'gif','DelayTime',0,'WriteMode','append'); 
        end 
    end

    % close the video maker to make the file
    close(vidfile)
    
end