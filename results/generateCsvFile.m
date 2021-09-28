% Read the parameters sweep data, and generate tables with the processed
% information.
% Where is the data located?
topDir = 'C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Data7';

% Find all the folders
folderList = dir([topDir,'/Parameter*']);

% Initialize the data table
dataTable = table;
goalReachTimeTable = table;

% Initialize processing parameters
% Want to record the number of agents that get below a certain
% y value (sufficiently below obstacle) AFTER the group has
% hit the obstacle.
% The y-midpoint of the obstacle is around 20, and the lowest
% points are around 15. Have chosen 12 as the y threshold. This
% seems to capture the majority of backwards movements, but there
% is a tradeoff btw false positives and false negatives.
% After the group hits the obstacle, any agents that get below
% y = 13 have gone backwards. 
% Should do a manual spotcheck to classify simulations with
% high avoid radius, as these are still prone to classification
% errors.
yThresholdLow = 12;
yThresholdHigh = 25;

% The group always hits the obstacle around timepoint 2,000.
% Making the threshold 2,800 instead of less reduces chance agents
% will still be lower than y threshold, seems to just be an 
% issue for high avoid radius.
timeThreshold = 2800;

% Loop through the folders
for paramSet = 1:length(folderList)
    % Select the current folder
    currFolder = [folderList(paramSet).folder,'/',folderList(paramSet).name];    
    
    % Find all the repetitions
    fileList = dir([currFolder,'/Rep*.mat']);
    
    % Loop through the repetitions
    for currRep = 1:length(fileList) 
        
        % Select the current file
        currFile = [fileList(currRep).folder,'/',fileList(currRep).name]; 
       
        % Load the file
        load(currFile);
        
        % Unpack location data
        agentStatesList = agent.statesList;
        numberOfAgents = size(agentStatesList, 1)/4;
        xList = agentStatesList(1:numberOfAgents,:);
        yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);
        obstacles = environment.obstacleLocations;
        
        yAfterObstacle = yList(:,timeThreshold:length(yList));
        xAfterObstacle = xList(:,timeThreshold:length(xList));
        
        numBackwards = 0;
        numEscaped = 0;
        minimumYs = repelem(nan, numberOfAgents)';
        maximumYs = repelem(nan, numberOfAgents)';
        extremeXs = repelem(nan, numberOfAgents)';
        for currAgent = 1:numberOfAgents
            minimumYs(currAgent) = min(yAfterObstacle(currAgent,:));
            maximumYs(currAgent) = max(yAfterObstacle(currAgent,:));
            extremeXs(currAgent) = max(abs(xAfterObstacle(currAgent,:)));
           if min(yAfterObstacle(currAgent,:)) < yThresholdLow
               numBackwards = numBackwards + 1;
           end
           if max(yAfterObstacle(currAgent,:)) > yThresholdHigh
                numEscaped = numEscaped + 1;
           end
        end
        
        % Put things in a local table
        currTable = table;
        currGoalReachTimes = table;
        
        % Store the table information
        currTable.FileName = {currFile};
        currTable.SetNum = paramSet;
        currTable.RepNum = currRep;
        
        currGoalReachTimes.FileName = repelem({currFile},agentParameters(1))';
        currGoalReachTimes.SetNum = repelem(paramSet, agentParameters(1))';
        currGoalReachTimes.RepNum = repelem(currRep, agentParameters(1))';
        
        % currTable.GoalTimes = goalReachTime(:)';
        currTable.Model = simParameters(1);
        currTable.ObstacleType = obstacleParameters(1);
        currTable.AgentStepTime = simParameters(4);
        currTable.NumAgents = agentParameters(1);
        currTable.Neighbors = agentParameters(2);
        currTable.FractionInformed = agentParameters(3); 
        currTable.AvoidRadius = agentParameters(4); 
        currTable.AlignRadius = agentParameters(5); 
        currTable.AttractRadius = agentParameters(6); 
        currTable.AlignYIntercept = agentParameters(7); 
        currTable.ObstacleRadius = agentParameters(8); 
        currTable.ObsVisibility = agentParameters(9); 
        currTable.TurnRate = agentParameters(10); 
        currTable.AvoidWeight = agentParameters(11); 
        currTable.AlignWeight = agentParameters(12); 
        currTable.AttractWeight = agentParameters(13); 
        currTable.ObstacleWeight = agentParameters(14); 
        currTable.MeanGoalTime = nanmean(goalReachTime);
        currTable.MedianGoalTime = nanmedian(goalReachTime);
        currTable.NumSucceed = sum(~isnan(goalReachTime));
        currTable.SuccessRate = sum(~isnan(goalReachTime))/length(goalReachTime);
        currTable.NumMovedBackwards = numBackwards;
        currTable.NumEscaped = numEscaped;
                
        currGoalReachTimes.Model = repelem(simParameters(1),agentParameters(1))';
        currGoalReachTimes.AgentStepTime = repelem(simParameters(4), agentParameters(1))';
        currGoalReachTimes.ObstacleType = repelem(obstacleParameters(1),agentParameters(1))';
        currGoalReachTimes.NumAgents = repelem(agentParameters(1), agentParameters(1))';
        currGoalReachTimes.Neighbors = repelem(agentParameters(2), agentParameters(1))';
        currGoalReachTimes.FractionInformed = repelem(agentParameters(3), agentParameters(1))'; 
        currGoalReachTimes.AvoidRadius = repelem(agentParameters(4), agentParameters(1))'; 
        currGoalReachTimes.AlignRadius = repelem(agentParameters(5), agentParameters(1))'; 
        currGoalReachTimes.AttractRadius = repelem(agentParameters(6), agentParameters(1))'; 
        currGoalReachTimes.AlignYIntercept = repelem(agentParameters(7), agentParameters(1))'; 
        currGoalReachTimes.ObstacleRadius = repelem(agentParameters(8), agentParameters(1))'; 
        currGoalReachTimes.ObsVisibility = repelem(agentParameters(9), agentParameters(1))'; 
        currGoalReachTimes.TurnRate = repelem(agentParameters(10), agentParameters(1))'; 
        currGoalReachTimes.AvoidWeight = repelem(agentParameters(11), agentParameters(1))'; 
        currGoalReachTimes.AlignWeight = repelem(agentParameters(12), agentParameters(1))'; 
        currGoalReachTimes.AttractWeight = repelem(agentParameters(13), agentParameters(1))'; 
        currGoalReachTimes.ObstacleWeight = repelem(agentParameters(14), agentParameters(1))';
        currGoalReachTimes.Agent = (1:agentParameters(1))';
        currGoalReachTimes.GoalReachTimes = goalReachTime;
        currGoalReachTimes.minimumYs = minimumYs;
        currGoalReachTimes.extremeXs = extremeXs; 
        currGoalReachTimes.maximumYs = maximumYs;
        
        % Append the current table to the big list
        dataTable = [dataTable; currTable];  
        goalReachTimeTable = [goalReachTimeTable; currGoalReachTimes];
    end
end

%% Write table to file
filename = 'summaryData20210203.csv';
writetable(dataTable,filename);

filename2 = 'goalTimesData20210203.csv';
writetable(goalReachTimeTable,filename2);

%% Separately make an image of each simulation's trajectories
% % Where is the data located?
% topDir = '/Users/helen/Documents/JSMFpostdoc/projects/collectiveMovementAndObstacles/Obstacle-avoiding-agents/data/data20201020';
% 
% % Find all the folders
% folderList = dir([topDir,'/Parameter*']);
% 
% 
% % Loop through the folders
% for paramSet = 1:length(folderList)
%     % Select the current folder
%     currFolder = [folderList(paramSet).folder,'/',folderList(paramSet).name];    
%     
%     % Find all the repetitions
%     fileList = dir([currFolder,'/Rep*.mat']);
%     
%     % Loop through the repetitions
%     for currRep = 1:length(fileList) 
%         
%         % Select the current file
%         currFile = [fileList(currRep).folder,'/',fileList(currRep).name]; 
%        
%         % Load the file
%         load(currFile);
%         
%         % Name the path for the image to be saved
%         imageFilename = [fileList(currRep).folder,'/figs/Rep',num2str(currRep),'.png'];
% 
%         
%         numberOfAgents = agentParameters(1);
% 
%         figure('visible','off')
% 
%         agentsXOut = agent.statesList(1:numberOfAgents,:)';
%         agentsYOut = agent.statesList(numberOfAgents + 1: 2*numberOfAgents,:)';
%         agentsSpeedOut = agent.statesList(2*numberOfAgents + 1: 3*numberOfAgents,:)';
%         agentsOrientationOut = agent.statesList(3*numberOfAgents + 1 :end,:)';
% 
%         plot(agentsXOut, agentsYOut);
%         hold on
%         plot(environment.obstacleLocations(:,1), environment.obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
%         %plot(environment.goalLocations(:,1), environment.goalLocations(:,2), 'bo','MarkerFaceColor','b') 
%         plot([-50,50], [environment.goalLocations(:,2) - 1000,environment.goalLocations(:,2) - 1000] , 'b-')
%         hold off
% 
%         xlabel('Agent x position')
%         ylabel('Agent y position')
%         title('Agent world')
% 
%         axis equal
%         axisLimits.X = get(gca, 'xlim');
%         axisLimits.Y = get(gca, 'ylim');
%         saveas(gcf,imageFilename)       
%     end
% end
