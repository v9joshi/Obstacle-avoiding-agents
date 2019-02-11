% Some analysis
noneFiles = dir('bisonSimData_Nothing*');
successTime = [];
runTime = [];

for currFile = 1:length(noneFiles)
    load(noneFiles(currFile).name)
    if min(distanceToGoal) < 5
        runTime = [runTime; goalReachTime];
        successTime = [successTime; goalReachTime];
    else
        runTime = [runTime; timeList(end)];
    end 
end

meanSuccessTime(1) = mean(successTime);
successRate(1) = length(successTime)/length(runTime);

figure 
hist(runTime)
title('No obstacle times')

%% Wall
noneFiles = dir('bisonSimData_Wall*');
successTime = [];
runTime = [];

for currFile = 1:length(noneFiles)
    load(noneFiles(currFile).name)
    if min(distanceToGoal) < 5
        runTime = [runTime; goalReachTime];
        successTime = [successTime; goalReachTime];
    else
        runTime = [runTime; timeList(end)];
    end 
end

meanSuccessTime(2) = mean(successTime);
successRate(2) = length(successTime)/length(runTime);

figure 
hist(runTime)
title('Wall times')

%% Cul de sac
noneFiles = dir('bisonSimData_CulDeSac*');
successTime = [];
runTime = [];

for currFile = 1:length(noneFiles)
    load(noneFiles(currFile).name)
    if min(distanceToGoal) < 5
        runTime = [runTime; goalReachTime];
        successTime = [successTime; goalReachTime];
    else
        runTime = [runTime; timeList(end)];
    end 
end

meanSuccessTime(3) = mean(successTime);
successRate(3) = length(successTime)/length(runTime);

figure 
hist(runTime)
title('Cul De Sac times')

%% Some extra plotting
figure
plot(successRate, '-o')
xlabel('Increasing obstacle complexity')
ylabel('Success Rate')

set(gca, 'XTick',[ 1, 2, 3]);
set(gca, 'XTickLabel',{ 'No Obstacle', 'Wall', 'Cul De Sac'});

figure
plot(meanSuccessTime, '-o')
xlabel('Increasing obstacle complexity')
ylabel('Time to destination if success')

set(gca, 'XTick',[ 1, 2, 3]);
set(gca, 'XTickLabel',{ 'No Obstacle', 'Wall', 'Cul De Sac'});
