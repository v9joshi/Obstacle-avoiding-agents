function obstacleLocations = obstLine(x1,y1,x2,y2,obstacleSpacing)
% Creates a straight-line obstacle from (x1,y1) to (x2,y2) with distance obstacleSpacing between successive points.

xSpacing = obstacleSpacing*(x2-x1)/sqrt((x1-x2)^2+(y1-y2)^2);
ySpacing = obstacleSpacing*(y2-y1)/sqrt((x1-x2)^2+(y1-y2)^2);
listX = x1:xSpacing:x2; listY = y1:ySpacing:y2;
if isnan(listX) & isnan(listY)  % start and end points coincide
  obstacleLocations = [x1 y1];
elseif length(listX)==length(listY)  % the obstacle is either a single point or a diagonal line
  obstacleLocations = [listX' listY'];
elseif length(listY)==0  % horizontal line
  obstacleLocations = [listX' y1*ones(size(listX'))];
elseif length(listX)==0  % vertical line
  obstacleLocations = [x1*ones(size(listY')) listY'];
else  % I don't know how another possibility could occur, but let's put this in in case
  disp('obstLine: unknown error')
end

