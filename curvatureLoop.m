% Run the curvature loop
alignWeightList = 0.1:0.1:20;
% alignWeightList = [0.1, 0.5, 1, 2, 5, 10, 20, 50];

for i = 1:length(alignWeightList)
    currWeight = alignWeightList(i);
    [turnRadius(i), turnCurvature(i)] = rootFile_dev(currWeight);
end


%%
legend(strcat('N=',string(num2cell(alignWeightList))))

figure
subplot(1,2,1)
plot(alignWeightList, turnRadius)
xlabel('Agent alignment weight')
ylabel('Turn radius')
ylim([0,14]);

subplot(1,2,2)
plot(alignWeightList, turnCurvature)
xlabel('Agent alignment weight')
ylabel('Turn curvature')
ylim([0,2.5])
