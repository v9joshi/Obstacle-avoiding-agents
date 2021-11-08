% Run the curvature loop
clear all; clc;
% alignWeightList = 0.1:0.1:20;
fractionInformedList = [0.1, 0.3, 0.5, 0.7, 0.9, 1]; 
% turnRateList = [0.2, 0.5, 1, 2, 4, 6.28];
% alignWeightList = [0.1, 0.5, 1, 2, 5, 10, 20, 50];

% for i = 1:length(alignWeightList)
%     currWeight = alignWeightList(i);
%     fractionInformed = 1;
%     turnRate = 2;
%     [turnRadius(i), turnCurvature(i)] = rootFile_dev(currWeight, fractionInformed, turnRate);
% end

turnRadius = zeros(length(fractionInformedList),1);
turnCurvature = zeros(length(fractionInformedList),1);

reps = 30;
for j = 1:reps
    for i = 1:length(fractionInformedList)
        alignWeight = 1;
        turnRate = 2;
        currFrac = fractionInformedList(i);
        [tempRad, tempCurv] = rootFile_dev(alignWeight, currFrac, turnRate);
        turnRadius(i) = turnRadius(i) + tempRad;
        turnCurvature(i) = turnCurvature(i) + tempCurv;
    end
end 

turnRadius = turnRadius/reps;
turnCurvature = turnCurvature/reps;

% for i = 1:length(turnRateList)
%     alignWeight = 1;
%     fractionInformed = 1;
%     currRate = turnRateList(i);
%     [turnRadius(i), turnCurvature(i)] = rootFile_dev(alignWeight, fractionInformed, currRate);
% end

%%
% legend(strcat('N=',string(num2cell(alignWeightList))))
% 
% figure
% subplot(1,2,1)
% plot(alignWeightList, turnRadius)
% xlabel('Agent alignment weight')
% ylabel('Turn radius')
% ylim([0,14]);
% 
% subplot(1,2,2)
% plot(alignWeightList, turnCurvature)
% xlabel('Agent alignment weight')
% ylabel('Turn curvature')
% ylim([0,2.5])

legend(strcat('N=',string(num2cell(fractionInformedList))))

figure
subplot(1,2,1)
plot(fractionInformedList, turnRadius)
xlabel('Fraction informed')
ylabel('Turn radius')
ylim([0,14]);

subplot(1,2,2)
plot(fractionInformedList, turnCurvature)
xlabel('Fraction informed')
ylabel('Turn curvature')
ylim([0,2.5])

% legend(strcat('N=',string(num2cell(turnRateList))))
% 
% figure
% subplot(1,2,1)
% plot(turnRateList, turnRadius)
% xlabel('Turn Rate')
% ylabel('Turn radius')
% ylim([0,14]);
% 
% subplot(1,2,2)
% plot(turnRateList, turnCurvature)
% xlabel('Turn Rate')
% ylabel('Turn curvature')
% ylim([0,2.5])
