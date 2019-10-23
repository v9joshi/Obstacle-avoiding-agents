% Root Mean Distance between 10 random pairs of grp members as measure of
% grp dispersion (inverse of cohesion).
% 1) Pick rnd pairs at a t, 2) measure distance, take root, 3) take mean of
% root distances of all pairs, 4) repeat over all t.
% Inputs: agentParameters, 2 lists in agent, as arrays
% Output: list of RMPDs by time
function rootMeanPairDist = groupSpread(agentParameters, agentStatesList, agentTimeList)
rootMeanPairDist = zeros(size(agentTimeList,2),1);
for t = 1:size(agentTimeList,2)
    scrambled = randperm(agentParameters(1));
    dist = 0;
    for i = 1:agentParameters(1) % sum of root dists of all agents at a t
        dist = dist + sqrt(norm([agentStatesList(i,t) - agentStatesList(scrambled(i),t),...
            agentStatesList(agentParameters(1)+i,t) - agentStatesList(agentParameters(1)+scrambled(i),t)]));
    end
    rootMeanPairDist(t) = dist;
end
rootMeanPairDist = rootMeanPairDist/agentParameters(1); % average of grp, summing over all times