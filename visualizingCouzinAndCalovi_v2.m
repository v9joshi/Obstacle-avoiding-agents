% Visualizing Couzin vs Calovi models
% close all;
% Define some agents
agentDistance = 0:0.01:30;

% Where is this agent looking?
agentAngle = pi/2;
agentOrientation = [cos(agentAngle); sin(agentAngle)];

% What is the goal orientation?
goalAngle = pi/2;
goalOrientation = [cos(goalAngle); sin(goalAngle)];

% Where is the other agent looking? (alignment)
absoluteAgentAngle = pi/4;
absoluteAgentOrientation = [cos(absoluteAgentAngle); sin(absoluteAgentAngle)];

% Where is the other agent located in space relative to this agent? (attraction/repulsion)
relativeAgentAngle = pi/2;
relativeAgentOrientation = [cos(relativeAgentAngle); sin(relativeAgentAngle)];

% What are the constants being used
avoidDistance = 5;
alignDistance = 10;
attractDistance = 20;
alignYintercept = 0.6;

agentWeights.Avoidance = 1;
agentWeights.Attraction = 1;
agentWeights.Alignment = 1;
agentWeights.Destination = 1;

% How does attraction change?
% Couzin on off switch
attractionCouzin = ones(length(agentDistance),1)*agentWeights.Attraction;
% attractionCouzin(agentDistance <= alignDistance & agentDistance >= avoidDistance) = 0;
attractionCouzin(agentDistance > attractDistance) = 0;
attractionCouzin(agentDistance < avoidDistance) = -1*agentWeights.Avoidance;

alignmentCouzin = zeros(length(agentDistance),1);
alignmentCouzin(agentDistance <= alignDistance & agentDistance >= avoidDistance) = agentWeights.Alignment;

destinationCouzin = agentWeights.Destination;

for currDist = 1:length(agentDistance)
    summedUnitVectors = attractionCouzin(currDist)*relativeAgentOrientation + alignmentCouzin(currDist)*absoluteAgentOrientation + destinationCouzin*goalOrientation;

    if sqrt(sum(summedUnitVectors.^2)) == 0
        normalizedSum = [0, 0];
    else
        normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
    end

    desiredOrientationCouzin(currDist) = atan2(normalizedSum(2), normalizedSum(1));
end

% Calovi non-linear model
attractionCalovi = (agentDistance - avoidDistance)./(1+(agentDistance/attractDistance).^2);
attractionCalovi = agentWeights.Attraction*attractionCalovi;%(attractDistance - avoidDistance);

alignmentCalovi = (alignYintercept + agentDistance).*exp(-(agentDistance/alignDistance).^2);
alignmentCalovi = agentWeights.Alignment*alignmentCalovi;%/(alignDistance + alignYintercept);

destinationCalovi =  agentWeights.Destination;

for currDist = 1:length(agentDistance)
    summedUnitVectors = attractionCalovi(currDist)*relativeAgentOrientation + alignmentCalovi(currDist)*absoluteAgentOrientation + destinationCalovi*goalOrientation;

    if sqrt(sum(summedUnitVectors.^2)) == 0
        normalizedSum = [0, 0];
    else
        normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
    end

    desiredOrientationCalovi(currDist) = atan2(normalizedSum(2), normalizedSum(1));
end

changeInOrientationCouzin = 0*agentAngle;
changeInOrientationCalovi = 0*agentAngle;

if abs(agentAngle) > pi
    agentAngle = mod(agentAngle + pi, 2*pi) - pi;
end
    
desiredChangeCouzin = desiredOrientationCouzin - agentAngle;
desiredChangeCalovi = desiredOrientationCalovi - agentAngle;

desiredChangeCouzin(abs(desiredChangeCouzin) > pi) = mod(desiredChangeCouzin(abs(desiredChangeCouzin) > pi) + pi, 2*pi) - pi;
desiredChangeCalovi(abs(desiredChangeCalovi) > pi) = mod(desiredChangeCalovi(abs(desiredChangeCalovi) > pi) + pi, 2*pi) - pi;

% plot these
figure(1)
subplot(1,2,1)
agentLength = 1;
testDistance = [avoidDistance,alignDistance,attractDistance];
arrowheadSize = 5;
plot(0,0)
xlim([-30,30])
ylim([-30,30])
arrow([0 - 0.5*agentLength*agentOrientation(1), 0 - 0.5*agentLength*agentOrientation(2)],...
      [0 + 0.5*agentLength*agentOrientation(1), 0 + 0.5*agentLength*agentOrientation(2)],...
      arrowheadSize, 'color', 'k');
hold on

otherAgentCenter = testDistance'.*relativeAgentOrientation';
arrow([otherAgentCenter(:,1) - 0.5*agentLength*absoluteAgentOrientation(1), otherAgentCenter(:,2) - 0.5*agentLength*absoluteAgentOrientation(2)],...
      [otherAgentCenter(:,1) + 0.5*agentLength*absoluteAgentOrientation(1), otherAgentCenter(:,2) + 0.5*agentLength*absoluteAgentOrientation(2)],...
      arrowheadSize, 'color', 'r');

plot(0 + 30*cos(goalAngle), 0 + 30*sin(goalAngle), 'bo','markerfacecolor','b')
  
title('Agent placement')

subplot(1,2,2)
hold on
plot(agentDistance,desiredChangeCouzin*180/pi, 'k','linewidth',4);
plot(agentDistance,desiredChangeCalovi*180/pi, 'r','linewidth',2);
xlimitVal = get(gca, 'xlim');
ylimitVal = get(gca, 'ylim');
line([avoidDistance, avoidDistance],ylimitVal ,'color',[0.8,0.8,0.8],'linestyle','--','linewidth',3);
text(avoidDistance + 0.2, -5, 'avoid distance')
line([alignDistance, alignDistance], ylimitVal,'color',[0.8,0.8,0.8],'linestyle','--','linewidth',3);
text(alignDistance+ 0.2, -5, 'align distance')
line([attractDistance, attractDistance], ylimitVal, 'color',[0.8,0.8,0.8],'linestyle','--','linewidth',3);
text(attractDistance+ 0.2, -5, 'attract distance')
xlim(xlimitVal);
ylim(ylimitVal);
ylabel(['Desired change in orientation (', char(176) ,')'])
xlabel('Distance from other agent')
title('Agent desired orientation')