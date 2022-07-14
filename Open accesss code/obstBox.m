% obstBox:
% Creates a straight-line obstacle from (x1,y1) to (x2,y1) and vertical
% walls of half this length at the end-points.
% Distance between successive pointsis obstacleSpacing.
function obstacleLocations = obstBox(x1,y1,x2,obstacleSpacing, gapSize)    
    % Make horizontal base
    baseX = x1:obstacleSpacing:x2;
    baseLocations = [baseX' y1*ones(size(baseX'))];
    
    % Make vertical walls
    wallSz = (x2-x1)/2;
    y2 = y1-wallSz;
    wallY = y2:xSpacing:y1;
    wallLX = x1*ones(size(wallY));
    wallRX = x2*ones(size(wallY));
    wallLocations = [wallLX' wallY'; wallRX' wallY'];
    
    % Store all the points on the obstacle
    obstacleLocations = [baseLocations; wallLocations];
    
    % Locate the gap in the wall
    gapNumber = round((gapSize*(1/obstacleSpacing))/2);
    
    % Place the gap in the obstacle
    obstacleLocations(round(end/2)-gapNumber:round(end/2)+gapNumber, :) = [];
end