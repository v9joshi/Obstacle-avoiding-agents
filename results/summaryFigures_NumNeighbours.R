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


data <- read.csv ("processedData20220408.csv")

summaryData <- group_by (data, RealSetNum) %>%
  summarize (., AgentStepTime = AgentStepTime[1], NumAgents = NumAgents[1],
             ObstacleType = ObstacleType[1],
             NumberOfNeighbors = Neighbors[1], FractionInformed = FractionInformed[1],
             AvoidRadius = AvoidRadius[1], AlignRadius = AlignRadius[1], 
             AttractRadius = AttractRadius[1], ObstacleRadius = ObstacleRadius[1],
             TurnRate = TurnRate[1], AvoidWeight = AvoidWeight[1], 
             AlignWeight = AlignWeight[1], AttractWeight = AttractWeight[1],
             ObstacleWeight = ObstacleWeight[1],
             NoiseDegree = NoiseDegree[1],
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

summaryData2 <- filter(summaryData, NoiseDegree == 0 & AttractWeight == 1)
summaryData3 <- filter(summaryData, NoiseDegree == 0 & NumberOfNeighbors == 70)

data <- filter(data, NoiseDegree == 0)

# ___________________________
# Proportion figures

# Adding a column that shows the current value of the varying parameter, as a
# proportion of the total range of that parameter
summaryData2$xRangeProp <- rep (NA)
summaryData2$xValue <- rep (NA)

for (i in 1:dim(summaryData2)[1]) {
  currParam <- summaryData2$whichParam[i]
  currColumn <- which (colnames(summaryData2) == currParam)
  
  currValue <- summaryData2[i, currColumn]
  currValueProp <- summaryData2[i, currColumn] # - minParam) / (maxParam - minParam)
  
  if (currValueProp == 7){
    currValueProp <- 1
  } else{
    currValueProp <- 2
  }
  
  if (summaryData2$AttractWeight < 1){
    currValueProp <- 3
  }
  
  summaryData2$xValue[i] <- pull(currValue)
  summaryData2$xRangeProp[i] <- currValueProp
}

p1 <- ggplot (summaryData2, aes (x = xRangeProp, y = propFlockEscape, 
                                 fill = factor(NumAgents))) +
  geom_col(width = 0.8, position = position_dodge(width = 0.9), 
           fill = "#FFFFFF", size = 1,
           aes(x = xRangeProp, y = 1, color = factor(NumAgents)))+
  geom_col(width = 0.8, position = position_dodge(width = 0.9))+
  
  scale_color_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Number of Agents",
                      guide = "none") +
  scale_fill_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Number of Agents",
                     guide = "legend") +
  scale_x_discrete(limits = c("7", "N"))+
  labs (x = "Number of neighbors", 
        y = "proportion of simulations with flocking escapes") +
  ylim(0, 1)+
  figTheme

p2<- ggplot(summaryData2, aes(x=factor(xRangeProp, labels = c("7", "N")), y = medianGoalTime, 
                      color = factor(NumAgents))) +
  geom_errorbar(data = summaryData2, aes(ymin=meanGoalTime - seGoalTime, ymax=meanGoalTime + seGoalTime),
                width=0.9, size = 1,position = "dodge2")+
  scale_color_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Number of Agents",
                      guide = "legend") +
  scale_fill_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Number of Agents",
                     guide = "legend") +
  scale_x_discrete(limits = c("7", "N"))+
  coord_cartesian(ylim=c(0, 300)) +
  labs (x = "Number of neighbors", 
        y = "mean time to reach the goal")+
  figTheme

grid.arrange(p1,p2, nrow = 1)

figTheme$legend.position = "none"

p1 <- ggplot (summaryData3, aes (x = AttractWeight, y = propFlockEscape,
                                 color = factor(AlignWeight))) +
  geom_line (linetype="solid", size=1) +
  geom_point (size = 2, alpha = 1,fill = c("white"), shape=21) +
  scale_x_continuous(trans='log10')+
  labs (x = "Attract Weight",
        y = "proportion of simulations with flocking escapes") +
  ylim(0, 1)+
  figTheme

p2 <- ggplot (summaryData3, aes (x = AttractWeight, y = successRate,
                                 color = factor(AlignWeight))) +
  geom_line (linetype="solid", size=1) +
  geom_point (size = 2, alpha = 1, fill = c("white"), shape=21) +
  scale_x_continuous(trans='log10')+
  labs (x = "Attract Weight", 
        y = "success rate") +
  ylim(0, 1)+
  figTheme

p3 <- ggplot (summaryData3, aes (x = AttractWeight, y = meanGoalTime,
                                 color = factor(AlignWeight))) +
  geom_line (linetype="solid", size=1) +
  geom_point (size = 2, alpha = 1,fill = c("white"), shape=21) +
  scale_x_continuous(trans='log10')+
  labs (x = "Attract Weight", 
        y = "mean time to reach the goal") +
  ylim(0, 300)+
  figTheme

grid.arrange(p1,p2,p3, nrow = 1)

