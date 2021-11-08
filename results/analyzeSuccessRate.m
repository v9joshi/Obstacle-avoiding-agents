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
%indexList = allIndices(processedData.AlignWeight > 0 & isnan(flockingEscape'));

% pairedList = [setNum(indexListFrac)', repNum(indexListFrac)'];
% pairedList = [4*ones(50,1), (1:50)'];%; 10, 1];
    
% Load a file from the list
% topDir = 'C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Data5';
topDir = 'C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\Data3';

%% Do some processing for align weight
indexListWeight = allIndices(strcmpi(processedData.whichParam, {'AlignWeight'}) == 1);

tableWeight = table;
tableWeight.alignWeight = double(processedData.AlignWeight(indexListWeight));
tableWeight.flockingEscape = flockingEscape(indexListWeight)';

alignWeightList = double(unique(tableWeight.alignWeight));
curvatureDataAW = load('C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\curvatureVsAlignWeight2.mat');

for currWeightIndex = 1:length(alignWeightList)
    meanEscapesAW(currWeightIndex) = nanmean(tableWeight.flockingEscape(tableWeight.alignWeight == alignWeightList(currWeightIndex)));
    turnRadiusAW(currWeightIndex) = curvatureDataAW.turnRadius(curvatureDataAW.alignWeightList == alignWeightList(currWeightIndex));
end

% figure
% plot(fracInformedList, meanEscapesFI,'ro-')
% xlim([0,max(fracInformedList)])
% ylim([0,1])


%% Do some processing for fraction informed
indexListFrac = allIndices(strcmpi(processedData.whichParam, {'fractionInformed'}) == 1 & processedData.AlignWeight == 1);

tableFrac = table;
tableFrac.fracInformed = double(processedData.FractionInformed(indexListFrac));
tableFrac.flockingEscape = flockingEscape(indexListFrac)';

fracInformedList = double(unique(tableFrac.fracInformed));
curvatureDataFI = load('C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\curvatureVsFractionInformed2.mat');

for currFracIndex = 1:length(fracInformedList)
    meanEscapesFI(currFracIndex) = nanmean(tableFrac.flockingEscape(tableFrac.fracInformed == fracInformedList(currFracIndex)));
    turnRadiusFI(currFracIndex) = curvatureDataFI.turnRadius(curvatureDataFI.fractionInformedList == fracInformedList(currFracIndex));
end

% figure
% plot(fracInformedList, meanEscapesFI,'ro-')
% xlim([0,max(fracInformedList)])
% ylim([0,1])


%% Do some processing for turn radius
indexListTurn = allIndices(strcmpi(processedData.whichParam, {'TurnRate'}) == 1 & processedData.AlignWeight == 1);

tableTurn = table;
tableTurn.turnRate = double(processedData.TurnRate(indexListTurn));
tableTurn.flockingEscape = flockingEscape(indexListTurn)';

turnRateList = unique(tableTurn.turnRate);
curvatureDataTR = load('C:\Users\Varun\Documents\GitHub\Obstacle-avoiding-agents\curvatureVsTurnRate.mat');

for currTurnIndex = 1:length(turnRateList)
    meanEscapesTR(currTurnIndex) = nanmean(tableTurn.flockingEscape(tableTurn.turnRate == turnRateList(currTurnIndex)));
    turnRadiusTR(currTurnIndex) = curvatureDataTR.turnRadius(curvatureDataTR.turnRateList == turnRateList(currTurnIndex));
end

% figure
% plot(turnRateList, meanEscapesTR,'ro-')
% xlim([0,max(turnRateList)])
% ylim([0,1])

%% Do some plotting
figure(3)
plot(turnRadiusFI, meanEscapesFI, 'o-');
hold on
plot(turnRadiusTR, meanEscapesTR, 'o-');
plot(turnRadiusAW, meanEscapesAW, 'o-');

xlim([0,5.2])
ylim([-0.1,1.1])

xlabel('Turn radius')
ylabel('Proportion of sims with succesful flocking escapes')

legend('Fraction informed','Turn Rate','Align Weight')
% for currRow = 1:size(pairedList,1)
%     figure(1)%processedData.ObstacleType(indexList(currRow)))
%     hold on
% 
%     fileName = [topDir, '\ParameterSet', num2str(pairedList(currRow,1)),'\Rep',num2str(pairedList(currRow,2)),'.mat'];
%     load(fileName)
%     
%     agentStatesList = agent.statesList;
%     numberOfAgents = size(agentStatesList, 1)/4;
%     xList = agentStatesList(1:numberOfAgents,:);
%     yList = agentStatesList(numberOfAgents+1:2*numberOfAgents,:);
% 
%     goalLocations = environment.goalLocations;
%     obstacleLocations = environment.obstacleLocations;
% 
%     plot(xList', yList');
%     plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx','MarkerFaceColor','k') 
% end
% 
% for i = 1:4
%     if ishandle(i)
%         figure(i)
%         plot([-50,50], [goalLocations(:,2) - 1000,goalLocations(:,2) - 1000] , 'b-')
%         axisLimits.X = get(gca, 'xlim');
%         axisLimits.Y = get(gca, 'ylim');
%         axis equal
%     end
% end
