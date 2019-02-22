% This script generates the obstacles for the agent simulation
function obstaclePose = generateObstacles(avoidDistance, groupDiameter)


wallObstacleA.Y = []; %10:avoidDistance/5:15;
wallObstacleA.X = []; %-15*ones(length(wallObstacleA.Y),1);
wallObstacleA.Theta = []; % pi/2


wallObstacleB.X = -15:avoidDistance/30:(-15 + 2*groupDiameter);
wallObstacleB.Y = 15*ones(length(wallObstacleB.X),1);
wallObstacleB.Theta = pi/2 + pi/2*sign(linspace(-1,1,length(wallObstacleB.X))); % either pi or 0 depending on which half of the wall it is

obstaclePose = [wallObstacleA.X(:), wallObstacleA.Y(:), wallObstacleA.Theta(:);
                wallObstacleB.X(:), wallObstacleB.Y(:), wallObstacleB.Theta(:)];

end
