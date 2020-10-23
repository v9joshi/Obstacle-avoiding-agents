# Summary figures
# September 2020

setwd ("/Users/helen/Documents/JSMFpostdoc/projects/collectiveMovementAndObstacles/Obstacle-avoiding-agents/data")
library (tidyverse)
library (gridExtra)

figTheme <- theme(panel.background=element_rect(fill="white"), 
                  panel.border=element_rect(colour="black", size=1, fill=NA),
                  axis.text=element_text(colour="black", size=12),
                  axis.title.x=element_text(size=14, vjust = -0.5),
                  axis.title.y=element_text(size=14, vjust = 1.5),
                  strip.text.x = element_text(size = 12),
                  legend.text=element_text(size=10), 
                  legend.title=element_text(size=10), 
                  panel.grid.major = element_line(colour = "grey", size = 0.25),
                  panel.grid.minor = element_line(colour = "grey", size = 0.1))


data <- read.csv ("data20200812/processedData20200812.csv")

summaryData <- group_by (data, RealSetNum) %>%
  summarize (., AgentStepTime = AgentStepTime[1], NumAgents = NumAgents[1],
             Neighbors = Neighbors[1], FractionInformed = FractionInformed[1],
             AvoidRadius = AvoidRadius[1], AlignRadius = AlignRadius[1], 
             AttractRadius = AttractRadius[1], ObstacleRadius = ObstacleRadius[1],
             TurnRate = TurnRate[1], AvoidWeight = AvoidWeight[1], 
             AlignWeight = AlignWeight[1], AttractWeight = AttractWeight[1],
             ObstacleWeight = ObstacleWeight[1], 
             numCaught = mean(numCaught), 
             meanGoalTime = mean(MeanGoalTime, na.rm = T),
             medianGoalTime = mean(MedianGoalTime, na.rm = T),
             numSucceed = mean(NumSucceed), 
             successRate = mean(SuccessRate, na.rm = T),
             meanPersY = mean(meanPersY, na.rm = T),
             meanPersX = mean(meanPersX, na.rm = T),
             propFlockEscape = mean(flockingEscape, na.rm = T),
             whichParam = whichParam[1])


# ___________________________
# Quick summary statistics
mean (filter(data, AlignWeight == 1)$flockingEscape, na.rm = T)
mean (filter(data, AlignWeight == 10)$flockingEscape, na.rm = T)

mean (filter(data, NumAgents == 1)$flockingEscape, na.rm = T)
mean (filter(data, NumAgents > 1)$flockingEscape, na.rm = T)

test <- filter(summaryData, whichParam == "AvoidWeight")
# Why is high avoid weight, low align weight, always exactly 0.26 proportion flocking escapes??

# ___________________________
# Proportion figures

# Adding a column that shows the current value of the varying parameter, as a
# proportion of the total range of that parameter
summaryData$xRangeProp <- rep (NA)
summaryData$xValue <- rep (NA)
for (i in 1:dim(summaryData)[1]) {
  currParam <- summaryData$whichParam[i]
  currColumn <- which (colnames(summaryData) == currParam)
  
  minParam <- min (summaryData[ , currColumn])
  maxParam <- max (summaryData[ , currColumn])
  
  currValue <- summaryData[i, currColumn]
  currValueProp <- (summaryData[i, currColumn] - minParam) / (maxParam - minParam)
  
  summaryData$xValue[i] <- pull(currValue)
  summaryData$xRangeProp[i] <- pull(currValueProp)
}

# test <- filter (summaryData, whichParam == "AgentStepTime")
# ggplot (test, aes (x = AgentStepTime, y = xRangeProp)) + geom_point()

ggplot (summaryData, aes (x = xRangeProp, y = propFlockEscape, 
                          color = factor(AlignWeight))) +
  geom_point (size = 3, alpha = 0.5) +
  geom_line () +
  facet_wrap (~ whichParam) +
  scale_color_manual (values = c("#1b9e77", "#d95f02", "#1b9e77",
                                 "#1b9e77", "#7570b3", "#1b9e77",
                                 "#1b9e77"), guide = "none") +
  labs (x = "varying parameter as proporiton of range", 
        y = "proportion of simulations with flocking escapes") +
  figTheme

ggplot (summaryData, aes (x = xValue, y = propFlockEscape, 
                          color = factor(AlignWeight))) +
  geom_point (size = 3, alpha = 0.5) +
  geom_line () +
  facet_wrap (~ whichParam, scales = "free_x") +
  scale_color_manual (values = c("#1b9e77", "#d95f02", "#1b9e77",
                                 "#1b9e77", "#7570b3", "#1b9e77",
                                 "#1b9e77"), guide = "none") +
  labs (x = "varying parameter", 
        y = "proportion of simulations with flocking escapes") +
  figTheme


