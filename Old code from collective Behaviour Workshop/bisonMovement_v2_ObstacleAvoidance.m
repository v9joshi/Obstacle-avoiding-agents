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
limitsX = [-50, 50];
limitsY = [-50, 50];

% What are the initial states of the Bison?
initialPositionX = zeros(numberOfBison, 1);%0.2*(1:1:numberOfBison)';
initialPositionY = 0.5*(1:1:numberOfBison)';%zeros(numberOfBison, 1);

initialSpeed = 1*ones(numberOfBison, 1);

initialOrientation = zeros(numberOfBison, 1);

% Dynamics parameters
avoidDistance = 1; % avoid anything closer than this
alignDistance = 6; % align with anything closer than this
attractDistance = 20; % move towards anything closer than this

turnRate = 2; % units of radians per second
timeStep = 0.1; % units of seconds

% How many Bison know the destination?
fractionInformed = 0.3;
informedBison = round(fractionInformed*numberOfBison);
bisonGains = zeros(numberOfBison, 1);
listOfInformedBison = randsample(numberOfBison, informedBison);
bisonGains(listOfInformedBison) = 10;

% Global attractors
waterSourceLocations = [-20, 20];

% Global repellors
wallObstacleA.Y = 10:avoidDistance/5:15;
wallObstacleA.X = -15*ones(length(wallObstacleA.Y),1);

wallObstacleB.X = -15:avoidDistance/5:-10;
wallObstacleB.Y = 15*ones(length(wallObstacleB.X),1);

obstacleLocations = [wallObstacleA.X(:), wallObstacleA.Y(:);
                     wallObstacleB.X(:), wallObstacleB.Y(:)];
    
% How long are we simulating for?
maxTime = 100;
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
    
    % How far are the Bison from the destination?
    meanBisonX = mean(statesOutCurrBout(:,1:numberOfBison), 2);
    meanBisonY = mean(statesOutCurrBout(:,numberOfBison + 1: 2*numberOfBison), 2);
    distanceToGoal = sqrt((meanBisonX -  destination(1)).^2 + (meanBisonY - destination(2)).^2);
         
    if min(distanceToGoal) < 2
        % Truncate the states list, i.e. Bison stop when they reach the
        % destination?
%         firstIndexOfSuccess = find(distanceToGoal - 2 < 0, 1, 'first');
%         statesOutCurrBout = statesOutCurrBout(1:firstIndexOfSuccess, :); 
%         timeList = timeList(1:firstIndexOfSuccess);

        % Bison were successful
        destinationReached = 1;
    else
        display('Turning')
        changeInDistance = diff(distanceToGoal(200:end)); %Ignore the first 100 entries
        smoothedChangeInDistance = smooth(changeInDistance, 10, 'moving'); % find out whether distance to goal is increasing or decreasing
        
        % When do the Bison get stuck?
        firstIndexOfFailure = 200 + find(smoothedChangeInDistance > 0, 1, 'first');
        
        % Truncate output at that point
        statesOutCurrBout = statesOutCurrBout(1:firstIndexOfFailure, :); 
        timeList = timeList(1:firstIndexOfFailure);
        
        % Make a decision
        bisonOrientation = statesOutCurrBout(end, 3*numberOfBison + 1:end);
        directionOfGoal = atan2(destination(2) - meanBisonY(firstIndexOfFailure), destination(1) - meanBisonX(firstIndexOfFailure));
        bisonOrientation(listOfInformedBison) = 0; %pi/2;%(directionOfGoal  + pi/2);
        
        % store the decision
        statesOutCurrBout(end,3*numberOfBison + 1:end) = bisonOrientation;
    end
    
    if timeList(end) >= 200
        destinationReached = 1;
        display('Did not reach the destination but ran out of time')
    end
    
    % Store the states and the time
    statesOut = [statesOut; statesOutCurrBout];
    timeOut = [timeOut(:); timeList(:)];
        
    % Reset initial states and time and increase bout counter
    numberOfBouts = numberOfBouts + 1;
    startTime = timeList(end);
    initialStates = statesOut(end,:);    
end

% Unpack output states
bisonXOut = statesOut(:,1:numberOfBison);
bisonYOut = statesOut(:,numberOfBison + 1: 2*numberOfBison);
bisonSpeedOut = statesOut(:,2*numberOfBison + 1: 3*numberOfBison);
bisonOrientationOut = statesOut(:,3*numberOfBison + 1 :end);

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

for currTimeIndex = 1:2:length(timeOut)
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
