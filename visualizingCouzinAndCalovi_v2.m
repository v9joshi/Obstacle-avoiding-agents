% Visualizing Couzin vs Calovi models
close all;
% Define some agents
agentDistance = 0:0.01:30;

% Where is the other agent looking? (alignment)
absoluteAgentAngle = pi/2;
absoluteAgentOrientation = [cos(absoluteAgentAngle); sin(absoluteAgentAngle)];

% Where is the other agent located in space relative to this agent? (attraction/repulsion)
relativeAgentAngle = pi/2;
relativeAgentOrientation = [cos(relativeAgentAngle); sin(relativeAgentAngle)];

% What are the constants being used
avoidDistance = 5;
alignDistance = 5;
attractDistance = 10;
alignYintercept = 0.6;

agentWeights.Avoidance = 1;
agentWeights.Attraction = 1;
agentWeights.Alignment = 1;%36.3;

% How does attraction change?
% Couzin on off switch
attractionCouzin = ones(length(agentDistance),1)*agentWeights.Attraction;
% attractionCouzin(agentDistance <= alignDistance & agentDistance >= avoidDistance) = 0;
attractionCouzin(agentDistance > attractDistance) = 0;
attractionCouzin(agentDistance < avoidDistance) = -1*agentWeights.Avoidance;

alignmentCouzin = zeros(length(agentDistance),1);
alignmentCouzin(agentDistance <= alignDistance & agentDistance >= avoidDistance) = agentWeights.Alignment;

for currDist = 1:length(agentDistance)
    summedUnitVectors = attractionCouzin(currDist)*relativeAgentOrientation + alignmentCouzin(currDist)*absoluteAgentOrientation;

    if sqrt(sum(summedUnitVectors.^2)) == 0
        normalizedSum = [0, 0];
    else
        normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
    end

    changeInOrientationCouzin(currDist) = atan2(normalizedSum(2), normalizedSum(1));
end

% Calovi non-linear model
attractionCalovi = (agentDistance - avoidDistance)./(1+(agentDistance/attractDistance).^2);
attractionCalovi = agentWeights.Attraction*attractionCalovi;%(attractDistance - avoidDistance);

alignmentCalovi = (alignYintercept + agentDistance).*exp(-(agentDistance/alignDistance).^2);
alignmentCalovi = agentWeights.Alignment*alignmentCalovi;%/(alignDistance + alignYintercept);

for currDist = 1:length(agentDistance)
    summedUnitVectors = attractionCalovi(currDist)*relativeAgentOrientation + alignmentCalovi(currDist)*absoluteAgentOrientation;

    if sqrt(sum(summedUnitVectors.^2)) == 0
        normalizedSum = [0, 0];
    else
        normalizedSum = summedUnitVectors/sqrt(sum(summedUnitVectors.^2));
    end

    changeInOrientationCalovi(currDist) = atan2(normalizedSum(2), normalizedSum(1));
end

% plot these
figure(1)
subplot(1,2,1)
agentLength = 1;
testDistance = [avoidDistance,alignDistance,attractDistance];
arrowheadSize = 5;
plot(0,0)
xlim([-30,30])
ylim([-30,30])
arrow([0 - 0.5*agentLength, 0], [ 0 + 0.5*agentLength, 0], arrowheadSize, 'color', 'k');
hold on

otherAgentCenter = testDistance'.*relativeAgentOrientation';
arrow([otherAgentCenter(:,1) - 0.5*agentLength*absoluteAgentOrientation(1), otherAgentCenter(:,2) - 0.5*agentLength*absoluteAgentOrientation(2)],...
      [otherAgentCenter(:,1) + 0.5*agentLength*absoluteAgentOrientation(1), otherAgentCenter(:,2) + 0.5*agentLength*absoluteAgentOrientation(2)],...
      arrowheadSize, 'color', 'r');

title('Agent placement')
subplot(1,2,2)
plot(agentDistance,changeInOrientationCouzin*180/pi, 'k');
hold on
plot(agentDistance,changeInOrientationCalovi*180/pi, 'r');
xlimitVal = get(gca, 'xlim');
ylimitVal = get(gca, 'ylim');
line([avoidDistance, avoidDistance],ylimitVal ,'color','k','linestyle','--','linewidth',3);
text(avoidDistance + 0.2, -5, 'avoid distance')
line([alignDistance, alignDistance], ylimitVal,'color','k','linestyle','--','linewidth',3);
text(alignDistance+ 0.2, -5, 'align distance')
line([attractDistance, attractDistance], ylimitVal, 'color','k','linestyle','--','linewidth',3);
text(attractDistance+ 0.2, -5, 'attract distance')
xlim(xlimitVal);
ylim(ylimitVal);
ylabel(['Desired new orientation (', char(176) ,')'])
xlabel('Distance from other agent')
title('Agent desired orientation')