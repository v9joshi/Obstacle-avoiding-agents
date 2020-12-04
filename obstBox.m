function obstacleLocations = obstBox(x1,y1,x2,y2,obstacleSpacing, gapSize)
% Creates a straight-line obstacle from (x1,y1) to (x2,y2) with distance
% obstacleSpacing between successive points.

% Use trig to find obstacle spacing along the axes
xSpacing = obstacleSpacing*(x2-x1)/sqrt((x1-x2)^2+(y1-y2)^2);

% Make horizontal base
baseX = x1:xSpacing:x2;
baseLocations = [baseX' y1*ones(size(baseX'))];

% Make vertical walls
wallSz = (x2-x1)/2;
y3 = y1-wallSz;
wallY = y3:xSpacing:y1;
wallLX = x1*ones(size(wallY));
wallRX = x2*ones(size(wallY));
wallLocations = [wallLX' wallY'; wallRX' wallY'];

obstacleLocations = [baseLocations; wallLocations];

% Locate the gap in the wall
gapNumber = round((gapSize*(1/obstacleSpacing))/2);

% Place the gap in the obstacle
obstacleLocations(round(end/2)-gapNumber:round(end/2)+gapNumber, :) = [];

end