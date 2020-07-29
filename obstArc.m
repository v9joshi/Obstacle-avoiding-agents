function obstacleLocations = obstArc(x,y,rad,theta1,theta2,obstacleSpacing)
% Creates an obstacle along an arc of a circle with center (x,y) 
% and radius rad, starting at angle theta1 and ending at theta2,
% with distance obstacleSpacing between successive points.
% Angles in radians, starting at 0 = due east, and going clockwise.
% Spacing between points is actually measured along the circle here,
% rather than in a straight line between points, but the difference should
% typically be very small.

% First wrap angles around the circle so that theta2>theta1:
while theta2<theta1
    theta2 = theta2+2*pi;
end

deltaTh = obstacleSpacing/rad;

if rad==0  % single point at center
    obstacleLocations = [x y];
elseif abs(theta1-theta2)<1e-8  % single point along edge
    obstacleLocations = [x+rad*cos(theta1) y+rad*sin(theta2)];
else
    obstacleLocations = [(x+rad*cos(theta1:deltaTh:theta2))' (y+rad*sin(theta1:deltaTh:theta2))'];
end

