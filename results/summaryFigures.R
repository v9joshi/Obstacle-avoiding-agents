# Summary figures
# September 2020
setwd ("C:/Users/Varun/Documents/GitHub/Obstacle-avoiding-agents/results")
library (tidyverse)
library (gridExtra)
library (see)

figTheme <- theme(panel.background=element_rect(fill="white"), 
                  panel.border=element_rect(colour="black", size=1, fill=NA),
                  axis.text=element_text(colour="black", size=12),
                  axis.title.x=element_text(size=14, vjust = -0.5),
                  axis.title.y=element_text(size=14, vjust = 1.5),
                  strip.text.x = element_text(size = 12),
                  legend.text=element_text(size=10), 
                  legend.title=element_text(size=10),
                  legend.position = "top") 
                  #panel.grid.major = element_line(colour = "grey", size = 0.25),
                  #panel.grid.minor = element_line(colour = "grey", size = 0.1))


#data <- read.csv ("processedData20200812.csv")
data <- read.csv ("processedData20201118.csv")
#data <- read.csv ("processedData20201204.csv")
#data <- read.csv ("processedData20210202.csv")
#data <- read.csv ("processedData20210203.csv")


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

summaryData3 <- filter(summaryData, whichParam == "AlignWeight")
summaryData2 <- filter(summaryData, whichParam != "AlignWeight")

data <- filter(data, whichParam == "AlignWeight")


# Why is high avoid weight, low align weight, always exactly 0.26 proportion flocking escapes??

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
  currValueProp <- (summaryData2[i, currColumn] - minParam) / (maxParam - minParam)
  
  summaryData2$xValue[i] <- pull(currValue)
  summaryData2$xRangeProp[i] <- pull(currValueProp)
}

summaryData3$xRangeProp <- rep (NA)
summaryData3$xValue <- rep (NA)
for (i in 1:dim(summaryData3)[1]) {
  currParam <- summaryData3$whichParam[i]
  currColumn <- which (colnames(summaryData3) == currParam)
  
  minParam <- min (summaryData3[ , currColumn])
  maxParam <- max (summaryData3[ , currColumn])
  
  currValue <- summaryData3[i, currColumn]
  currValueProp <- (summaryData3[i, currColumn] - minParam) / (maxParam - minParam)
  
  summaryData3$xValue[i] <- pull(currValue)
  summaryData3$xRangeProp[i] <- pull(currValueProp)
}


# test <- filter (summaryData, whichParam == "AgentStepTime")
# ggplot (test, aes (x = AgentStepTime, y = xRangeProp)) + geom_point()

ggplot (summaryData2, aes (x = xValue, y = propFlockEscape, 
                           color = factor(AlignWeight))) +
  geom_point (size = 2, alpha = 1) +
  geom_line (linetype="dashed", size = 1) +
  facet_wrap (~ whichParam, scales = "free_x", ncol = 4) +
  scale_color_manual (values = c("#1b9e77", "#d95f02"), guide = "legend") +
  labs (x = "varying parameter", 
        y = "proportion of simulations with flocking escapes") +
  figTheme


p1 <- ggplot (summaryData3, aes (x = xValue, y = propFlockEscape)) +
  geom_line (linetype="dashed", size=1, color = "#d95f02") +
  geom_point (size = 2, alpha = 1, color = "#d95f02") +
  labs (x = "align weight",
        y = "proportion of simulations with flocking escapes") +
  figTheme
p2 <- ggplot (summaryData3, aes (x = xValue, y = meanGoalTime)) +
  geom_line (linetype="dashed", size=1, color = "#d95f02") +
  geom_errorbar(aes(ymin=meanGoalTime - seGoalTime, 
                    ymax=meanGoalTime + seGoalTime),
                    colour="black", width=2, size = 1) +
  geom_point (size = 2, alpha = 1, color = "#d95f02") +
  geom_jitter(data, aes(x = AlignWeight, y=MeanGoalTime), color="black", size=0.4, alpha=0.9) +
  labs (x = "align weight", 
        y = "mean time to reach the goal") +
  ylim(0, 300)+
  figTheme

grid.arrange(p1, p2, nrow = 1)


p3 <- ggplot (summaryData3, aes (x = xValue, y = propFlockEscape)) +
              geom_point (size = 2, alpha = 1, color = "#d95f02") +
              geom_line (linetype="dashed", size=1, color = "#d95f02") +
              labs (x = "align weight",
                    y = "proportion of simulations with flocking escapes") +
              scale_x_continuous(trans='log10')+
              figTheme
p4 <- ggplot (summaryData3, aes (x = xValue, y = meanGoalTime)) +
              geom_line (linetype="dashed", size=1, color = "#d95f02") +
              labs (x = "align weight", 
                    y = "mean time to reach the goal") +
              
              geom_errorbar(aes(ymin=meanGoalTime - seGoalTime, 
                                              ymax=meanGoalTime + seGoalTime),
                                  colour="black", width=.1,size = 1.2) +
              geom_point (size = 2, alpha = 1, color = "#d95f02") +
              scale_x_continuous(trans='log10')+
              ylim(0, 300)+
              figTheme

grid.arrange(p3, p4, nrow = 1)

#data$MeanGoalTime[is.na(data$MeanGoalTime)]<-500



p1 <- ggplot (summaryData3, aes (x = xValue, y = propFlockEscape)) +
  geom_line (linetype="dashed", size=1, color = "#d95f02") +
  geom_point (size = 2, alpha = 1, color = "#d95f02") +
  labs (x = "align weight",
        y = "proportion of simulations with flocking escapes") +
  figTheme

p2 <- ggplot (summaryData3, aes (x = xValue, y = meanGoalTime)) +
  geom_line (linetype="dashed", size=1, color = "#d95f02") +
  geom_errorbar(aes(ymin=meanGoalTime - seGoalTime, 
                    ymax=meanGoalTime + seGoalTime),
                colour="black", width=2, size = 1) +
  geom_point (size = 2, alpha = 1, color = "#d95f02") +
  geom_jitter(data = data, aes(x = AlignWeight, y=MeanGoalTime), color="black", size=1, alpha=0.9) +
  labs (x = "align weight", 
        y = "mean time to reach the goal") +
  ylim(0, 300)+
  figTheme

grid.arrange(p1, p2, nrow = 1)

#data$MeanGoalTime[is.na(data$MeanGoalTime)]<-500


p5 <- ggplot() +
  #geom_violin(data = data, aes(x=AlignWeight, y = MeanGoalTime, group = AlignWeight),
  #                size = 0.1, fill = "#555555")+
  geom_errorbar(data = summaryData3, aes(x = AlignWeight, ymin=meanGoalTime - seGoalTime, ymax=meanGoalTime + seGoalTime),
                    colour="black", width=2, size = 1) +
  geom_line (data = summaryData3, aes (x = xValue, y = meanGoalTime), linetype="dashed", size=1, color = "#d95f02") +
  geom_point (data = summaryData3,aes (x = xValue, y = meanGoalTime), size = 5, alpha = 1, color = "#d95f02") +
  geom_jitter(data = data, aes(x=AlignWeight, y = MeanGoalTime), 
              size=1, width = 0.5, fill="#1b9e77", color="#1b9e77") +
  labs (x = "Align Weight", 
        y = "mean time to reach the goal")+
  ylim(0, 300) +
  figTheme

grid.arrange(p1, p5, nrow = 1)
