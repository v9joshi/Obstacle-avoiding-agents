To run a simulation please run simulateAgents.m in Matlab.

This program simulates multiple agents interacting with each other and
the environment. The agents have individual behaviour designed to 
    a) Move towards a goal.
    b) Avoid obstacles in the way.
    c) Interact with other agents so as to move in a group
    d) Avoid collisions with other agents.

Simulation Parameters can be changed by affecting the following variables - 
    1) modelSelection      - 0 = discrete zones of behavior; 1 = continuous variant; 2 = burst-and-coast modification of 0
    2) totalSimulationTime - Total simulation time in seconds
    3) simStepTime         - Step time for the simulation in seconds
    4) numStepsPerUpdate   - Number of simulation steps each agent takes before changing its desired heading. 
                            For e.g. if numStepsPerUpdate = 10 and simStepTime = 0.01s, then agents will change their desired heading every 0.1s

   Burst and coast model specific parameters
    1) burstTimeMean       - The mean time between bursts of motion for the agent.
    2) burstTimeStd        - The standard devision of burst times for the agent.

   When the burst and coast model is used, the burst time for each agent is also used as the time when it updates its heading.
	
Agent Parameters can be changed by affecting the following variables - 
    1) numberOfAgents     - How many agents are present in the simulation.
    2) numberOfNeighbors  - The maximum number of other agents each individual agent considers when updating its desired heading.
    3) fractionInformed   - The fraction of total agents that know where the destination is located.
                            For e.g. if there are 10 agents and fraction informed is 0.1 then only 1 agent will know where the destination is.
    4) avoidDistance      - Maximum distance between two agents where they will repel each other in the discrete model.
    5) alignDistance      - Maximum distance between two agents where they will align with each other in the discrete model.
    6) attractDistance    - Maximum distance between two agents where they will attract each other in the discrete model.
    7) obstacleDistance   - Maximum distance between an agent and an obstace where the agent will be repelled by the obstacle.

    8) obstacleVisibility - Maximum distacne at which the obstacle affects agent heading for the continuous variant.
    9) turnRate           - The maximum turn rate for each individual agent.
   10) agentSpeed         - The speed for each agent. This is the burst speed for the burst and coast model.
   11) avoidWeight        - The weight applied to the agent avoidance behavior when determining desired orientation.
   12) alignWeight        - The weight applied to the agent alignment behavior when determining desired orientation.
   13) attractWeight      - The weight applied to the agent attraction behavior when determining desired orientation.
   14) obstacleWeight     - The weight applied to the obstacle avoidance behavior when determining desired orientation.

   Note: Noise only works in the discrete zone model (modelSelection = 0).
   15) noiseDegree        - The standard deviation of a wrapped gaussian noise (von mises distribution) that is added to the desired heading direction for each agent.
   			    Non-zero values of noise degree are dependent on vmrand Matlab function developed by Dylan Muir.
                            https://www.mathworks.com/matlabcentral/fileexchange/37241-vmrand-fmu-fkappa-varargin

Obstacle parameters can be changed by affecting the following variables - 
   1) obstacleType        - 1 Convex, 2 Wall, 3 Concave
   2) obstacleScale       - The diameter/length of the obstacle
   3) obstacle arc        - The angular range of a convex/concave obstacle
   4) gapSize             - The size of the gap in the middle of the obstacle
   5) obstacleCenter      - The center of the obstacle
