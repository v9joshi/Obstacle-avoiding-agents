# Obstacle-avoiding-agents
### Simulations of agents navigating an environment while trying to avoid obstacles.

This project started as a part of the 
[2018 MBI workshop on collective behaviour and emergent phenomena in biology.](https://mbi.osu.edu/events/collective-behavior-and-emergent-phenomena-biology)

#### Project structure:
+ The simulateAgents is the main file of the simulation. It contains all the simulation parameters and can be run to generate data.
+ The obstArc, obstLine, and obstBox files generate the obstacles.
+ The agentPerception file runs the perception update step for an agent, i.e. it detects where environment features and 
  other agents are located relative to each agent.
+ The agentDecision and agentDecisionContin files runs the decision step and determines the direction each agent wants to move in.
+ The agentAction file runs a single time-step of the simulation and updates the positions and orientations of all agents in the environment.

#### Project members: 
[Helen McCreery](https://www.helenmccreery.com/), [Justin Werfel](http://people.seas.harvard.edu/~jkwerfel/), [Stefan Popp](https://eeb.arizona.edu/person/stefan-popp) and [Varun Joshi](https://www.varun-joshi.com).
