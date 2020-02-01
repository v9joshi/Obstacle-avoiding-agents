% Visualizing Couzin vs Calovi models
close all;
% Define some agents
agentDistance = 0:0.01:30;
absoluteAgentOrientation = pi;
relativeAgentOrientation = pi;

% What are the constants being used
avoidDistance = 5;
alignDistance = 10;
attractDistance = 20;
alignYintercept = 0.6;

% How does attraction change?
% Couzin on off switch
attractionCouzin = ones(length(agentDistance),1);
% attractionCouzin(agentDistance <= alignDistance & agentDistance >= avoidDistance) = 0;
attractionCouzin(agentDistance > attractDistance) = 0;
attractionCouzin(agentDistance < avoidDistance) = -1;

alignmentCouzin = zeros(length(agentDistance),1);
alignmentCouzin(agentDistance <= alignDistance & agentDistance >= avoidDistance) = 1;
changeInOrientationCouzin = 0.5*(attractionCouzin.*relativeAgentOrientation + alignmentCouzin.*absoluteAgentOrientation);

% Calovi non-linear model
attractionCalovi = (agentDistance - avoidDistance)./(1+(agentDistance/attractDistance).^2);
attractionCalovi = attractionCalovi/(attractDistance - avoidDistance);

alignmentCalovi = (alignYintercept + agentDistance).*exp(-(agentDistance/alignDistance).^2);
alignmentCalovi = alignmentCalovi/(alignDistance + alignYintercept);
changeInOrientationCalovi = 0.5*(relativeAgentOrientation.*attractionCalovi + absoluteAgentOrientation.*alignmentCalovi);

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
otherAgentCenter = testDistance'.*[cos(relativeAgentOrientation), sin(relativeAgentOrientation)];
arrow([otherAgentCenter(:,1) - 0.5*agentLength*cos(absoluteAgentOrientation), otherAgentCenter(:,2) - 0.5*agentLength*sin(absoluteAgentOrientation)],...
      [otherAgentCenter(:,1) + 0.5*agentLength*cos(absoluteAgentOrientation), otherAgentCenter(:,2) + 0.5*agentLength*sin(absoluteAgentOrientation)],...
      arrowheadSize, 'color', 'r');

title('Agent placement')

subplot(1,2,2)
plot(agentDistance,changeInOrientationCouzin*180/pi);
hold on
plot(agentDistance,changeInOrientationCalovi*180/pi);

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