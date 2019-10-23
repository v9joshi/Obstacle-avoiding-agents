function moveMetrics = moveMetricsMaker(simParameters, agentParameters, agentStatesList, agentTimeList)
% Makes cell (cell2mat makes array) of all fixes in rows & the columns:
% 1 x in mm now
% 2 y in mm now
% 3 t in s now
% 4 ID
% 5 s (step-length, = inter-point distance [mm])
% 6 dFrames (#of frames between points)
% 7 v (speed between points [mm/s])
% 8 disp (displacement, = euclidean distance from start of track until then)
% 9 theta (angle in space)
% 10 alpha (turning angle between last 3 points)
% 11 Sin (sine of alpha)
% 12 Cos (cos of alpha)
% 13 av (angular velocity = turning angle/time)
% 14 adist (angular distance = turning angle/distance, aka curvature)

agentStatesList = agentStatesList';
agentsStatesCell = cell(agentParameters(1),1); % Preallocation
for id = 1:agentParameters(1)
    agentsStatesCell{id,1} = [agentStatesList(:,id) agentStatesList(:,agentParameters(1)+id)...
        agentTimeList' repmat(id,size(agentStatesList,1),1)];
end

moveMetrics{:,:} = zeros(size(agentParameters(1),1),1);    
for tr = 1:agentParameters(1)
    SI = [agentsStatesCell{tr,1}(:,1) agentsStatesCell{tr,1}(:,2)...
        agentsStatesCell{tr,1}(:,3) agentsStatesCell{tr,1}(:,4)];
    % Preallocations
    s = zeros(size(agentsStatesCell{tr,1},1),1); % distance between points
    s(1,1) = NaN;
    dFrames = zeros(size(agentsStatesCell{tr,1},1),1);
    dFrames(1,1) = NaN;
    v = zeros(size(agentsStatesCell{tr,1},1),1); % speed
    v(1,1) = NaN; % no speed at first point
    disp = zeros(size(agentsStatesCell{tr,1},1),1);
    theta = zeros(size(agentsStatesCell{tr,1},1),1); % angle in space
    theta (1,1) = NaN;
    alpha = zeros(size(agentsStatesCell{tr,1},1),1);
    alpha(1,1) = NaN; % no angle between first two points
    av = zeros(size(agentsStatesCell{tr,1},1),1);
    av(1,1) = NaN; % see alpha
    adist = zeros(size(agentsStatesCell{tr,1},1),1);
    adist(1,1) = NaN; % see alpha

    for i = 2:size(agentsStatesCell{tr,1},1)
        s(i,1) = norm(SI(i,1:2)-SI(i-1,1:2)); % norm calcs distance between 2 points
        dFrames(i,1) = agentsStatesCell{tr,1}(i,3)-agentsStatesCell{tr,1}(i-1,3); % #of frames between points
        v(i,1) = s(i,1)/(dFrames(i,1)*simParameters(3));
        disp(i,1) = norm(SI(i,1:2)-SI(1,1:2));
        theta(i,1) = atan2d(SI(i,2)-SI(i-1,2),SI(i,1)-SI(i-1,1));
    end % d (distance between points), v (velocity between last and current point), Theta (angle in space)
    % * only slope from -90 to 90, no x-directionality.
    for i = 2:size(agentsStatesCell{tr,1},1)-1
        P1 = agentsStatesCell{tr,1}(i,1:2)-agentsStatesCell{tr,1}(i-1,1:2);
        P2 = agentsStatesCell{tr,1}(i,1:2)-agentsStatesCell{tr,1}(i+1,1:2);
        alpha(i,1) = atan2d(P1(1,1)*P2(1,2)-P1(1,2)*P2(1,1), P1(1,1)*P2(1,1)+P1(1,2)*P2(1,2));
        if alpha(i,1) > 0
            alpha(i,1) = 180-alpha(i,1);
        else
            alpha(i,1) = -180-alpha(i,1);
        end
    end % turning angle
    alpha(size(agentsStatesCell{tr,1},1),1) = NaN; % no angle at last point
    Sin = sin(deg2rad(alpha)); % sine of turning angle
    Cos = cos(deg2rad(alpha)); % cosine of turning angle
    av = alpha./SI(:,3); % angular velocity
    adist = alpha./s(:,1); % angular distance (= curvature)
    moveMetrics{tr,1} = [SI s dFrames v disp theta alpha Sin Cos av adist];
end
end