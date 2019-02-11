% Bison learning paths
% Dynamics requirements
% 1. Avoid closeby bisons, say within a radius r1
% 2. Orient with nearby bisons, say within a radius r2
% 3. Move towards far away bisons, say within radius r3
% 4. Ghost Bison, imaginary leader bison that determines your "ideal
%    direction", only attracts bison, bison can never catch up to it.
clear all; close all; clc;

% How many Bison are there?
numberOfBison = 10;

% What is the area where the Bison can roam?
limitsX = [-30, 30];
limitsY = [-30, 30];

% What are the initial states of the Bison?
initialPositionX = zeros(numberOfBison, 1);%0.2*(1:1:numberOfBison)';
initialPositionY = 0.5*(1:1:numberOfBison)';%zeros(numberOfBison, 1);

initialSpeed = 1*ones(numberOfBison, 1);

initialOrientation = zeros(numberOfBison, 1);

% Dynamics parameters
avoidDistance = 1; % avoid anything closer than this
alignDistance = 6; % align with anything closer than this
attractDistance = 10; % move towards anything closer than this

turnRate = 2; % units of radians per second
timeStep = 0.1; % units of seconds

% How many Bison know the destination?
fractionInformed = 0.3;
informedBison = round(fractionInformed*numberOfBison);
bisonGains = zeros(numberOfBison, 1);
listOfInformedBison = randsample(numberOfBison, informedBison);
bisonGains(listOfInformedBison) = 1;


% Global attractors
waterSourceLocations = [-20, 20];

% Global repellors
groupDiameter = numberOfBison*avoidDistance;

wallObstacleA.Y = [];%10:avoidDistance/10:15;
wallObstacleA.X = [];%(-15 + 2*groupDiameter)*ones(length(wallObstacleA.Y),1);

wallObstacleB.X = -15:avoidDistance/10:(-15 + 2*groupDiameter);
wallObstacleB.Y = 15*ones(length(wallObstacleB.X),1);

wallObstacleC.Y = [];%10:avoidDistance/10:15;
wallObstacleC.X = [];%-15*ones(length(wallObstacleC.Y),1);

wallObstacleD.X = [];%-15:avoidDistance/10:(-15 + 0.5*groupDiameter);
wallObstacleD.Y = [];%10*ones(length(wallObstacleD.X),1);

wallObstacleE.X = [];%(-15 + 1.5*groupDiameter):avoidDistance/10:(-15 + 2*groupDiameter);
wallObstacleE.Y = [];%10*ones(length(wallObstacleE.X),1);

obstacleLocations = [wallObstacleA.X(:), wallObstacleA.Y(:);
                     wallObstacleB.X(:), wallObstacleB.Y(:);
                     wallObstacleC.X(:), wallObstacleC.Y(:);
                     wallObstacleD.X(:), wallObstacleD.Y(:);
                     wallObstacleE.X(:), wallObstacleE.Y(:)];
    
% How long are we simulating for?
maxTime = 150;
% numPoints = 1000;

% Collect all the initial state together
initialStates = [initialPositionX; initialPositionY; initialSpeed; initialOrientation];

% Collect all the parameters
params.numberOfBison = numberOfBison;
params.avoidDistance = avoidDistance;
params.alignDistance = alignDistance;
params.attractDistance = attractDistance;

params.turnRate = turnRate;
params.timeStep = timeStep;

params.bisonGains = bisonGains;
params.waterSourceLocations = waterSourceLocations;
params.obstacleLocations = obstacleLocations;

% Simulate the Bison
destinationReached = 0;
startTime = 0;
statesOut = [];
timeOut = [];
destination = waterSourceLocations(1,:);
destinationList = waterSourceLocations;
numberOfBouts = 0;

% Bison run continuously for maxTime duration and if they haven't reached
% their destination they randomly change to a different destination
while ~destinationReached 
    timeList = startTime:timeStep:(startTime + maxTime); % linspace(0,maxTime,numPoints);
    options = [];
    
    % Variable step-size super slow
    % [tOut, statesOut] = ode45(@bisonODE, timeList, initialStates, options, params);

    % Constant step-size much faster
    odeTarget = @(t, states) bisonODE_DiscreteTime(t, states, params);
    statesOutCurrBout = ode4(odeTarget, timeList, initialStates(:));
    statesOut = [statesOut; statesOutCurrBout];
    timeOut = [timeOut(:); timeList(:)];
    numberOfBouts = numberOfBouts + 1;
    
    % Reset initial states and time
    startTime = timeList(end);
    initialStates = statesOut(end,:);
    
    % check if destination has been reached
    meanBisonX = mean(statesOutCurrBout(:,1:numberOfBison), 2);
    meanBisonY = mean(statesOutCurrBout(:,numberOfBison + 1: 2*numberOfBison), 2);
    
    distanceToGoal = sqrt((meanBisonX -  destination(1)).^2 + (meanBisonY - destination(2)).^2);
    if (min(distanceToGoal) < 5 && mod(numberOfBouts,2))
        destinationReached = 1;
        goalReachIndex = find(distanceToGoal < 5, 1, 'first');
        goalReachTime = timeList(goalReachIndex);
        
        display(['Reached destination at time t = ', num2str(goalReachTime)]);
    else
        if mod(numberOfBouts, 2) == 0
            destinationX = waterSourceLocations(1,1);
            destinationY = waterSourceLocations(1,2);
        else            
            destinationX = limitsX(1) + range(limitsX)*rand(1,1);
            destinationY = limitsY(1) + range(limitsY)*rand(1,1);
        end
        params.waterSourceLocations = [destinationX, destinationY];
        destinationList = [destinationList; destinationX, destinationY];
    end
    
    if (timeList(end) >= 400 && ~destinationReached)
        destinationReached = 1;
        display('Did not reach the destination but ran out of time')
    end
    
end

% Unpack output states
bisonXOut = statesOut(:,1:numberOfBison);
bisonYOut = statesOut(:,numberOfBison + 1: 2*numberOfBison);
bisonSpeedOut = statesOut(:,2*numberOfBison + 1: 3*numberOfBison);
bisonOrientationOut = statesOut(:,3*numberOfBison + 1 :end);

%% Save the data with given file name
% Define a generic file name
fileName = 'bisonSimData_Wall';
fileList = dir([fileName, '*']); % Determine the list of files with this name structure
fileNumber = length(fileList) + 1; % Find how many files we have already and increment the counter
save([fileName, num2str(fileNumber)]); % Save the data

%% Make a table and save as csv
bisonDataTable = table;

for currBison = 1:numberOfBison
    currBisonTable = table;
    currBisonTable.ID = currBison*ones(length(timeOut), 1);
    currBisonTable.Time = timeOut;
    currBisonTable.X = bisonXOut(:,currBison);
    currBisonTable.Y = bisonYOut(:,currBison);
    currBisonTable.Speed = bisonSpeedOut(:,currBison);
    currBisonTable.Orientation = bisonOrientationOut(:,currBison);  
    
    bisonDataTable = [bisonDataTable; currBisonTable];
end

writetable(bisonDataTable, ['CSV Files\', fileName, num2str(fileNumber)]);

%% Plot the motion
figure
plot(bisonXOut, bisonYOut);
hold on
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
plot(waterSourceLocations(:,1), waterSourceLocations(:,2), 'bo','MarkerFaceColor','b') 
hold off

xlabel('Bison x position')
ylabel('Bison y position')
title('Bison ranch')

axis equal

axisLimits.X = get(gca, 'xlim');
axisLimits.Y = get(gca, 'ylim');

%% Animate the motion
figure(2)

% How large do we want each bison to be
semiBisonSize = 0.5;

for currTimeIndex = 1:10:length(timeOut)
     plot([bisonXOut(currTimeIndex,:) - semiBisonSize*cos(bisonOrientationOut(currTimeIndex,:));...
          bisonXOut(currTimeIndex,:) + semiBisonSize*cos(bisonOrientationOut(currTimeIndex,:))],...
          [bisonYOut(currTimeIndex,:) - semiBisonSize*sin(bisonOrientationOut(currTimeIndex,:));...
          bisonYOut(currTimeIndex,:) + semiBisonSize*sin(bisonOrientationOut(currTimeIndex,:))] ,'-');
      
     hold on
     plot(bisonXOut(currTimeIndex,:) + semiBisonSize*cos(bisonOrientationOut(currTimeIndex,:)),...
          bisonYOut(currTimeIndex,:) + semiBisonSize*sin(bisonOrientationOut(currTimeIndex,:)) ,'v');
      
      
     plot(bisonXOut(currTimeIndex, listOfInformedBison) + semiBisonSize*cos(bisonOrientationOut(currTimeIndex,listOfInformedBison)),...
          bisonYOut(currTimeIndex, listOfInformedBison) + semiBisonSize*sin(bisonOrientationOut(currTimeIndex,listOfInformedBison)) ,'v', 'markerfacecolor','r');

      
     plot(bisonXOut(currTimeIndex,:) - semiBisonSize*cos(bisonOrientationOut(currTimeIndex,:)),...
          bisonYOut(currTimeIndex,:) - semiBisonSize*sin(bisonOrientationOut(currTimeIndex,:)) ,'*');
      
    plot(obstacleLocations(:,1), obstacleLocations(:,2), 'rx','MarkerFaceColor','r') 
    plot(destinationList(:,1), destinationList(:,2), 'ko','MarkerFaceColor','k') 
    plot(waterSourceLocations(:,1), waterSourceLocations(:,2), 'bo','MarkerFaceColor','b') 
    
      
     hold off

      
%     hold on
%     plot(bisonXOut, bisonYOut, '-');
%     hold off
    xlabel('Bison x position')
    ylabel('Bison y position')

    title('Bison ranch')
    axis equal    
    xlim(axisLimits.X)
    ylim(axisLimits.Y)
    pause(0.1);
end
