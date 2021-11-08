close all; clear all;
% processedData = readtable('processedData20201204.csv');
% processedData = readtable('processedData20210202.csv');
processedData = readtable('processedData20200812.csv');

for currRow = 1:height(processedData)
    
   currVal = processedData.flockingEscape(currRow);
   if contains(currVal,'NA')
       flockingEscape(currRow) = nan;
   elseif contains(currVal,'0')
       flockingEscape(currRow) = 0;
   else
       flockingEscape(currRow) = 1;
   end
   
   setVal = processedData.RealSetNum{currRow};
   repVal = processedData.RealRepNum{currRow};
   setNum(currRow) = str2double(setVal);
   repNum(currRow) = str2double(repVal);
end

% Tell me what files to check

allIndices = 1:height(processedData);
indexList = allIndices(processedData.AvoidWeight < 3); %& isnan(flockingEscape'));

pairedList = [setNum(indexList)', repNum(indexList)'];
% pairedList = [4*ones(50,1), (1:50)'];%; 10, 1];
    
% Load a file from the list
% topDir = 'C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Data5';
topDir = 'C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Data3';

%%
for currRow = 1:size(pairedList,1)
    figure(1)%processedData.ObstacleType(indexList(currRow)))
    hold on

    fileName = [topDir, '\ParameterSet', num2str(pairedList(currRow,1)),'\Rep',num2str(pairedList(currRow,2)),'.mat'];
    load(fileName)
    
    agentStatesList = agent.statesList;
    numberOfAgents = size(agentStatesList, 1)/4;
    xList = agentStatesList(1:numberOfAgents,:);
    yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);

    goalLocations = environment.goalLocations;
    obstacleLocations = environment.obstacleLocations;

    plot(xList', yList');
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
end

for i = 1:4
    if ishandle(i)
        figure(i)
        plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
        axisLimits.X = get(gca, 'xlim');
        axisLimits.Y = get(gca, 'ylim');
        axis equal
    end
end
