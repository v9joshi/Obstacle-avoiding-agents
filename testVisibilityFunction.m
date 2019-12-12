% Test the visibility function
clc; clear all; close all;

% Step 1. Pick an observing agent
observingAgent = [-5, 20];

% Step 2. Make an obstacle
obstacleType = 1;    % convex arc = 1, wall = 2, or concave arc = 3, otherwise nothing
obstacleScale = 15;  % length scale of obstacle
arcAngle = pi;       % how many radians should arc obstacles cover?
gapSize = 0;         % size of gap in the middle of the wall
agentLength = 1;     % How large is an agent

obstacleLocation = [0,20]; % The center for the obstacle

obstacleSpacing = 1/20; % Distance between two points on the obstacle

obstacleX = [];
obstacleY = [];

switch obstacleType
    % make convex arc obstacle
    case 1
        arcRadius = obstacleScale/2;
        obstacleLocation = [obstacleLocation(1), obstacleLocation(2) + ...
                             arcRadius/2];
        obstacle = obstArc(obstacleLocation(1),obstacleLocation(2),...
                           arcRadius,(pi/2)+(arcAngle/2),(pi/2)-(arcAngle/2),obstacleSpacing);
    % make wall obstacle
    case 2
        x1 = obstacleLocation(1) - obstacleScale/2;
        y1 = obstacleLocation(2);
        x2 = obstacleLocation(1) + obstacleScale/2;
        y2 = obstacleLocation(2);
        obstacle = obstLine(x1, y1, x2, y2, obstacleSpacing, gapSize);
    % make concave arc obstacle
    case 3
        arcRadius = obstacleScale/2;
        obstacleLocation = [obstacleLocation(1), obstacleLocation(2) - ...
                            arcRadius/2];
        obstacle = obstArc(obstacleLocation(1),obstacleLocation(2),...
                           arcRadius,(pi/2)-(arcAngle/2),(pi/2)+(arcAngle/2),obstacleSpacing);
    otherwise
        obstacle = [];
end

if ~isempty(obstacle)
    obstacleX = obstacle(:,1);
    obstacleY = obstacle(:,2);
end

obstacleLocations = [obstacleX(:), obstacleY(:)];

% Step 3. Define a region to look at
limitsX = [-20, 20];
limitsY = [-10, 30];

% Shift the origin to the observing agent
obstacleLocations = [obstacleLocations(:,1) - observingAgent(1), obstacleLocations(:,2) - observingAgent(2)];

% Step 4. Loop through the entire region and determine visibility
%         green mark for visible, red mark for not visible
listR = linspace(0, 10, 1000);
listTheta = linspace(0,2*pi, 1000);

obstacleDistance = sqrt(obstacleLocations(:, 1).^2 + obstacleLocations(:, 2).^2);

for indexR = 1:length(listR)
    for indexTheta = 1:length(listTheta)
        listX(indexR, indexTheta) = listR(indexR)*cos(listTheta(indexTheta));
        listY(indexR, indexTheta) = listR(indexR)*sin(listTheta(indexTheta));

        observedAgent = [listX(indexR, indexTheta), listY(indexR, indexTheta)];
        agentDistance = sqrt(observedAgent(:, 1).^2 + observedAgent(:, 2).^2);
        
        visibility(indexR, indexTheta) = -1 -isAgentVisible([0,0], observedAgent, obstacleLocations, agentLength);      
        visibility2(indexR, indexTheta) = -1 -isAgentVisible2(observedAgent, obstacleLocations, agentDistance, obstacleDistance, agentLength);       
        visibility3(indexR, indexTheta) = -1 -isAgentVisible3(observedAgent, obstacleLocations, agentDistance, obstacleDistance, obstacleSpacing);       

    end
end

% Plot the colormap
figure(1)
hold on
surface(listX, listY, visibility, 'edgecolor','interp')
% Locate the obstacle
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx')
plot(0, 0, 'ro','markerfacecolor','r')
axis 'equal'
title('Visibility function 1')

figure(2)
hold on
surface(listX, listY, visibility2, 'edgecolor','interp')
% Locate the obstacle
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx')
plot(0, 0, 'ro','markerfacecolor','r')
axis 'equal'
title('Visibility function 2')

figure(3)
hold on
surface(listX, listY, visibility3, 'edgecolor','interp')
% Locate the obstacle
plot(obstacleLocations(:,1), obstacleLocations(:,2), 'kx')
plot(0, 0, 'ro','markerfacecolor','r')
axis 'equal'
title('Visibility function 3')

