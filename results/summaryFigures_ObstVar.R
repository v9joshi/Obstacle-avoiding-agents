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

summaryData2 <- filter(summaryData, ObstacleType != 2)

data <- filter(data, ObstacleType != 2)  

# ___________________________
# Proportion figures

# Adding a column that shows the current value of the varying parameter, as a
# proportion of the total range of that parameter
summaryData2$xRangeProp <- rep (NA)
summaryData2$xValue <- rep (NA)

for (i in 1:dim(summaryData2)[1]) {
  currParam <- summaryData2$whichParam[i]
  currColumn <- which (colnames(summaryData2) == currParam)

  minParam <- min (summaryData2[ , currColumn])
  maxParam <- max (summaryData2[ , currColumn])

  currValue <- summaryData2[i, currColumn]
  currValueProp <- summaryData2[i, currColumn] # - minParam) / (maxParam - minParam)
  if(currParam == "ObstacleType"){
    if(currValueProp > 1){
      currValueProp = currValueProp - 1
    }
  }

  summaryData2$xValue[i] <- pull(currValue)
  summaryData2$xRangeProp[i] <- pull(currValueProp)
}

p1 <- ggplot (summaryData2, aes (x = xRangeProp, y = propFlockEscape, 
                           fill = factor(AlignWeight))) +
geom_col(width = 0.8, position = position_dodge(width = 0.9), 
         fill = "#FFFFFF", size = 1,
         aes(x = xRangeProp, y = 1, color = factor(AlignWeight)))+
geom_col(width = 0.8, position = position_dodge(width = 0.9))+
  
scale_color_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Align weight",
                     guide = "none") +
scale_fill_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Align weight",
                   guide = "legend") +

scale_x_discrete(limits = c("Box", "Arc","Arrow"))+
  
labs (x = "obstacle type", 
      y = "proportion of simulations with flocking escapes") +
ylim(0, 1)+
figTheme

p2 <- ggplot (summaryData2, aes (x = xRangeProp, y = meanGoalTime, 
                           fill = factor(AlignWeight))) +
geom_col(position = position_dodge(width = 0.9), size = 1, width = 0.8,
         aes(color = factor(AlignWeight)))+
geom_errorbar(aes(x = xRangeProp, 
              ymin=meanGoalTime - seGoalTime, ymax=meanGoalTime + seGoalTime),
              colour="black", size = 1, width = 0.2, 
              position = position_dodge(width = 0.9)) +
scale_color_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Align weight",
                    guide = "none") +
scale_fill_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Align weight",
                   guide = "legend") +
scale_x_discrete(limits = c("Box", "Arc","Arrow"))+
labs (x = "obstacle type", 
      y = "mean time to reach the goal") +
ylim(0, 300)+
figTheme


data$MeanGoalTime[is.na(data$MeanGoalTime)]<-500

#data$ObstacleType[data$ObstacleType == 1]<-"Box"
data$ObstacleType[data$ObstacleType == 3]<-2
data$ObstacleType[data$ObstacleType == 4]<-3

#data$ObstacleType <- factor(ObstacleType, labels = c("Box", "Arc","Arrow"))


p3<- ggplot(data, aes(x=factor(ObstacleType, labels = c("Box", "Arc","Arrow")), y = MeanGoalTime, 
       color = factor(AlignWeight))) +
geom_boxplot(position = "dodge2", fill= "#FFFFFF")+
scale_color_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Align weight",
                      guide = "legend") +
scale_fill_manual (values = c("#1b9e77", "#d95f02", "#7570b3"), name = "Align weight",
                   guide = "legend") +
coord_cartesian(ylim=c(0, 300)) +
labs (x = "obstacle type", 
      y = "mean time to reach the goal")+
figTheme

grid.arrange(p1,p3, nrow = 1)
