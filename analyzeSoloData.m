close all; clear all;

% Set file and directory names
topDir = 'C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Data8';
paramList = readtable('parameters20211019.csv');
metaData  = readtable('results/paramMetaData20211019.csv');

colorA = [27, 158, 119]/256;
colorB = [217, 95, 2]/256;

% Initialize storage
summaryTable = table;

% Unpack the metadata
for currParam = 1:size(metaData,1)
    paramIndex(metaData.firstSet(currParam):metaData.lastSet(currParam)) = currParam;
    whichParam(metaData.firstSet(currParam):metaData.lastSet(currParam)) = metaData.parameter(currParam);
end

% Load files from the list
for currRow = 1:size(paramList,1)
    tempTable = table;
    successCount = 0;
    for repNum = 1:50
        fileName = [topDir, '\ParameterSet', num2str(currRow),'\Rep',num2str(repNum),'.mat'];
        load(fileName)
        if isnan(goalReachTime)
            successCount = successCount + 0;
        else
            successCount = successCount + 1;
        end
    end
    tempTable.whichParam = whichParam(currRow);
    tempTable.paramVal   = paramList.(whichParam{currRow})(currRow);
    tempTable.successVal = successCount/50;
    
    summaryTable = [summaryTable; tempTable];    
end

summaryTable.whichParam = categorical(summaryTable.whichParam);
%% Plot the data
figure(1)
subplot(2,2,1)
plot(summaryTable.paramVal(summaryTable.whichParam == 'obstacleDistance'),summaryTable.successVal(summaryTable.whichParam == 'obstacleDistance'),'o-','color',colorB);
xlabel('Obstacle Distance');
ylabel('Success Rate');
grid 'on'
ylim([-0.2,1.2])

subplot(2,2,2)
plot(summaryTable.paramVal(summaryTable.whichParam == 'obstacleWeight'),summaryTable.successVal(summaryTable.whichParam == 'obstacleWeight'),'o-','color',colorB);
xlabel('Obstacle Weight');
ylabel('Success Rate');
grid 'on'
ylim([-0.2,1.2])

subplot(2,2,3)
plot(summaryTable.paramVal(summaryTable.whichParam == 'agentStepTime'),summaryTable.successVal(summaryTable.whichParam == 'agentStepTime'),'o-','color',colorB);
xlabel('Agent Step Time');
ylabel('Success Rate');
grid 'on'
ylim([-0.2,1.2])

subplot(2,2,4)
plot(summaryTable.paramVal(summaryTable.whichParam == 'turnRate'),summaryTable.successVal(summaryTable.whichParam == 'turnRate'),'o-','color',colorB);
xlabel('Turn Rate');
ylabel('Success Rate');
grid 'on'
ylim([-0.2,1.2])
set(gcf,'color','w')