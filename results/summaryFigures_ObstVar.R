# Summary figures
# Process the obstacle variation data
setwd ("C:/Users/Varun/Documents/GitHub/Obstacle-avoiding-agents/results")
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
                  legend.position = "top") 

data <- read.csv ("processedData20201204.csv")

summaryData <- group_by (data, RealSetNum) %>%
  summarize (., AgentStepTime = AgentStepTime[1], NumAgents = NumAgents[1],
             ObstacleType = ObstacleType[1],
             Neighbors = Neighbors[1], FractionInformed = FractionInformed[1],
             AvoidRadius = AvoidRadius[1], AlignRadius = AlignRadius[1], 
             AttractRadius = AttractRadius[1], ObstacleRadius = ObstacleRadius[1],
             TurnRate = TurnRate[1], AvoidWeight = AvoidWeight[1], 
             AlignWeight = AlignWeight[1], AttractWeight = AttractWeight[1],
             ObstacleWeight = ObstacleWeight[1], 
             numCaught = mean(numCaught), 
             meanGoalTime = mean(MeanGoalTime, na.rm = T),
             sdGoalTime = sd(MeanGoalTime, na.rm = T),
             seGoalTime = sd(MeanGoalTime, na.rm = T)/sqrt(50),
             medianGoalTime = mean(MedianGoalTime, na.rm = T),
             numSucceed = mean(NumSucceed), 
             successRate = mean(SuccessRate, na.rm = T),
             meanPersY = mean(meanPersY, na.rm = T),
             meanPersX = mean(meanPersX, na.rm = T),
             propFlockEscape = mean(flockingEscape, na.rm = T),
             sdFlockEscape = sd(flockingEscape, na.rm = T),
             seFlockEscape = sd(flockingEscape, na.rm = T)/sqrt(50),
             whichParam = whichParam[1])


# ___________________________
# Quick summary statistics
mean (filter(data, AlignWeight == 1)$flockingEscape, na.rm = T)
mean (filter(data, AlignWeight == 10)$flockingEscape, na.rm = T)

mean (filter(data, NumAgents == 1)$flockingEscape, na.rm = T)
mean (filter(data, NumAgents > 1)$flockingEscape, na.rm = T)

summaryData4 <- filter(summaryData, whichParam != "AlignWeight")

# ___________________________
# Proportion figures

# Adding a column that shows the current value of the varying parameter, as a
# proportion of the total range of that parameter
summaryData4$xRangeProp <- rep (NA)
summaryData4$xValue <- rep (NA)

for (i in 1:dim(summaryData4)[1]) {
  currParam <- summaryData4$whichParam[i]
  currColumn <- which (colnames(summaryData4) == currParam)

  minParam <- min (summaryData4[ , currColumn])
  maxParam <- max (summaryData4[ , currColumn])

  currValue <- summaryData4[i, currColumn]
  currValueProp <- (summaryData4[i, currColumn] - minParam) / (maxParam - minParam)

  summaryData4$xValue[i] <- pull(currValue)
  summaryData4$xRangeProp[i] <- pull(currValueProp)
}

ggplot (summaryData4, aes (x = xRangeProp, y = propFlockEscape, 
                           color = factor(AlignWeight))) +
geom_point (size = 2, alpha = 1) +
geom_line (linetype="dashed", size = 1) +
facet_wrap (~ whichParam, scales = "free_x", ncol = 3) +
scale_color_manual (values = c("#1b9e77", "#d95f02"), guide = "legend") +
labs (x = "varying obstacle type", 
      y = "proportion of simulations with flocking escapes") +
figTheme

ggplot (summaryData4, aes (x = xRangeProp, y = meanGoalTime, 
                           color = factor(AlignWeight))) +
  geom_point (size = 2, alpha = 1) +
  geom_line (linetype="dashed", size = 1) +
  facet_wrap (~ whichParam, scales = "free_x", ncol = 3) +
  scale_color_manual (values = c("#1b9e77", "#d95f02"), guide = "legend") +
  labs (x = "varying obstacle type", 
        y = "mean time to reach the goal") +
  figTheme

ggplot (summaryData4, aes (x = xRangeProp, y = meanGoalTime, 
                           color = factor(AlignWeight))) +
  geom_line (linetype="dashed", size=1) +
  geom_errorbar(aes(ymin=meanGoalTime - seGoalTime, 
                    ymax=meanGoalTime + seGoalTime),
                colour="black", width=0.01, size = 1) +
  geom_point (size = 2, alpha = 1) +
  facet_wrap (~ whichParam, scales = "free_x", ncol = 3) +
  scale_color_manual (values = c("#1b9e77", "#d95f02"), guide = "legend") +
  labs (x = "varying obstacle type", 
        y = "mean time to reach the goal") +
  ylim(0, 300)+
  figTheme