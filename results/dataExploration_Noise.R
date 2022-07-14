# Exploring initial mini-sweep of parameters
# April 2020

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
                  panel.grid.major = element_line(colour = "grey", size = 0.25),
                  panel.grid.minor = element_line(colour = "grey", size = 0.1))


data <- read.csv ("summaryData20220408.csv",fileEncoding="UTF-8-BOM")
paramMetaData <- read.csv ("paramMetaData20220408.csv",fileEncoding="UTF-8-BOM")
goalTimesData <- read.csv ("goalTimesData20220408.csv",fileEncoding="UTF-8-BOM")

data <- mutate (data, 
                RealSetNum = 
                  substring(str_extract(FileName,"Set\\d+"),4),
                RealRepNum = 
                  substring(str_extract(FileName,"Rep\\d+"),4))

data$sweepParameter <- rep(NA)
for (i in 1:dim(data)[1]) {
  currSetNum <- as.numeric (data$RealSetNum[i])
  data$sweepParameter[i] <- paste0 (paramMetaData[paramMetaData[ , 2] <= 
                                                    currSetNum &
                                                    paramMetaData[ , 3] >= currSetNum, 1])
}


goalTimesData <- mutate (goalTimesData, 
                         RealSetNum = 
                           substring(str_extract(FileName,"Set\\d+"),4),
                         RealRepNum = 
                           substring(str_extract(FileName,"Rep\\d+"),4),
                         persistenceY = 20 - minimumYs) %>%
  mutate (., wasCaught = ifelse (is.finite(GoalReachTimes) == FALSE, 1,
                                 ifelse(GoalReachTimes <= 65, 0,
                                        ifelse (persistenceY-ObstacleRadius <= 3, 0, 1))) )

ggplot(goalTimesData, aes(x = GoalReachTimes, fill = factor(wasCaught))) +
  geom_histogram (bins = 100) +
  geom_vline(xintercept = 65, lty = 2, color = "black")

ggplot(goalTimesData, aes(x = persistenceY-ObstacleRadius)) +
  geom_histogram (bins = 100) +
  geom_vline(xintercept = 3, lty = 2, color = "red") 

ggplot(goalTimesData, 
       aes (x = GoalReachTimes, y = persistenceY-ObstacleRadius, 
            color = factor(wasCaught))) +
  geom_point (alpha = 0.15) +
  geom_vline(xintercept = 65, lty = 2, color = "black") +
  geom_hline(yintercept = 3, lty = 2, color = "black") 
# ggplot(goalTimesData, 
#        aes (x = GoalReachTimes, y = persistenceY-ObstacleRadius, 
#             color = factor(wasCaught))) +
#   geom_point (alpha = 0.1) +
#   lims (x = c(50, 100), y = c (0, 7)) +
#   geom_text (aes (label = paste0(RealSetNum,", ", RepNum)),
#              check_overlap = TRUE, nudge_x = 2.5, size = 3) 
# ggplot(filter(goalTimesData, wasCaught == 0), 
#        aes (x = GoalReachTimes, y = persistenceY-ObstacleRadius, 
#             color = factor(wasCaught))) +
#   geom_point (alpha = 0.5) +
#   geom_text (aes (label = paste0(RealSetNum,", ", RepNum)),
#              check_overlap = TRUE, nudge_x = 2.5, size = 3) 
# ggplot(filter(goalTimesData, RealSetNum == 40, RepNum == 31), 
#        aes (x = GoalReachTimes, y = persistenceY-ObstacleRadius, 
#             color = factor(wasCaught))) +
#   geom_point ()


dataMeans <- group_by(data, SetNum) %>%
  summarize (., RealSetNum = RealSetNum[1], RealRepNum = RealRepNum[1],
             Model = Model[1], AgentStepTime = AgentStepTime[1],
             ObstacleType = ObstacleType[1],
             NumAgents = NumAgents[1], Neighbors = Neighbors[1], 
             FractionInformed = FractionInformed[1], 
             AvoidRadius = AvoidRadius[1], AlignRadius = AlignRadius[1],
             AttractRadius = AttractRadius[1], 
             AlignYIntercept = AlignYIntercept[1], ObstacleRadius = ObstacleRadius[1], 
             ObsVisibility = ObsVisibility[1], TurnRate = TurnRate[1], 
             AvoidWeight = AvoidWeight[1], AlignWeight = AlignWeight[1], 
             AttractWeight = AttractWeight[1], ObstacleWeight = ObstacleWeight[1],
             NoiseDegree = NoiseDegree[1],
             MeanGoalTime = mean(MeanGoalTime, na.rm = T), 
             MedianGoalTime = mean(MedianGoalTime, na.rm = T), 
             NumSucceed = mean(NumSucceed, na.rm = T), 
             SuccessRate = mean(SuccessRate, na.rm = T))

persistenceData <- 
  group_by (goalTimesData, RealSetNum, RealRepNum) %>%
  summarize (., RepNum = RepNum[1], Model = Model[1], AgentStepTime = AgentStepTime[1],
             ObstacleType = ObstacleType[1],
             NumAgents = NumAgents[1], Neighbors = Neighbors[1], 
             FractionInformed = FractionInformed[1], 
             AvoidRadius = AvoidRadius[1], AlignRadius = AlignRadius[1],
             AttractRadius = AttractRadius[1], 
             AlignYIntercept = AlignYIntercept[1], ObstacleRadius = ObstacleRadius[1], 
             ObsVisibility = ObsVisibility[1], TurnRate = TurnRate[1], 
             AvoidWeight = AvoidWeight[1], AlignWeight = AlignWeight[1], 
             AttractWeight = AttractWeight[1], ObstacleWeight = ObstacleWeight[1],
             NoiseDegree = NoiseDegree[1],
             numCaught = sum(wasCaught), 
             MeanGoalTime = mean(GoalReachTimes[wasCaught == 1], na.rm = T),
             MedianGoalTime = median(GoalReachTimes[wasCaught == 1], na.rm = T),
             NumSucceed = sum(maximumYs[wasCaught == 1] >= 25),
             SuccessRate = sum(maximumYs[wasCaught == 1] >= 25)/sum(wasCaught),
             meanPersY = mean(persistenceY[wasCaught == 1]), 
             meanPersX = mean(extremeXs[wasCaught == 1]))

persistenceMeans <- group_by(persistenceData, RealSetNum) %>%
  summarize (., Model = Model[1], AgentStepTime = AgentStepTime[1],
             ObstacleType = ObstacleType[1],
             NumAgents = NumAgents[1], Neighbors = Neighbors[1], 
             FractionInformed = FractionInformed[1], 
             AvoidRadius = AvoidRadius[1], AlignRadius = AlignRadius[1],
             AttractRadius = AttractRadius[1], 
             AlignYIntercept = AlignYIntercept[1], ObstacleRadius = ObstacleRadius[1], 
             ObsVisibility = ObsVisibility[1], TurnRate = TurnRate[1], 
             AvoidWeight = AvoidWeight[1], AlignWeight = AlignWeight[1], 
             AttractWeight = AttractWeight[1], ObstacleWeight = ObstacleWeight[1],
             NoiseDegree = NoiseDegree[1],
             numCaught = mean(numCaught, na.rm = T),
             MeanGoalTime = mean(MeanGoalTime, na.rm = T), 
             MedianGoalTime = mean(MedianGoalTime, na.rm = T),
             StdGoalTime = NaN,
             NumSucceed = mean(NumSucceed, na.rm = T), 
             SuccessRate = mean(SuccessRate, na.rm = T),
             meanPersY = mean(meanPersY, na.rm = T), 
             meanPersX = mean(meanPersX, na.rm = T))


# ________________________________________________________________________________
# Some data processing

# Automatically categorizing simulations, where possible

# The agents can no longer go through the obstacle. When obstacle radius is high,
# they still stay low the whole time, so need to account for this. Should do this
# by subtracting the obstacle radius from the mean persistence Y value. 

# The possible outcomes are:
# - One or more agents avoid the obstacle altogether, in which case they would
#   not have moved backwards
# - Agents are stuck in the obstacle. Normally, they would not move backwards
#   and would not succeed. One or two may eke around the edges, if it's just
#   1 or 2 this probably shouldn't count as an escape. 
# - There is a flocking escape. The most convincing versions of which you would
#   see most of the agents move backwards, and most succeed. 

persistenceMeans$whichParam <- rep(NA)

for (i in 1:dim(persistenceMeans)[1]) {
  paramSet <- as.numeric(persistenceMeans$RealSetNum[i])
  # Which parameter was this part of the sweep for?
  tempMetaData <- filter (paramMetaData, firstSet <= paramSet,
                          lastSet >= paramSet)
  persistenceMeans$whichParam[i] <- as.character(tempMetaData$parameter[1])
}

persistenceData$whichParam <- rep(NA)
for (i in 1:dim(persistenceData)[1]) {
  paramSet <- as.numeric(persistenceData$RealSetNum[i])
  # Which parameter was this part of the sweep for?
  tempMetaData <- filter (paramMetaData, firstSet <= paramSet,
                          lastSet >= paramSet)
  persistenceData$whichParam[i] <- as.character(tempMetaData$parameter[1])
  
  #StdGoalTime = min(kmeans(GoalReachTimes[wasCaught == 1],2)$withinss)
  
  timesData <- goalTimesData$GoalReachTimes[goalTimesData$wasCaught == 1 &
                            goalTimesData$RealSetNum == persistenceData$RealSetNum[i] &
                            goalTimesData$RealRepNum == persistenceData$RealRepNum[i]]
  timesData_noNan <- na.omit(timesData)
  
  if (length(timesData_noNan) > 2) {
    clusteredTimes <- kmeans(timesData_noNan,2)
    persistenceData$StdGoalTime[i] = min(clusteredTimes$withinss)
  } else {
    persistenceData$StdGoalTime[i] = NaN
  }
  
  if (tempMetaData$parameter[1] != "NoiseDegree"){
    persistenceData$StdGoalTime[i] <- 0
  }
  
}

region1 <- data.frame (xmin=-Inf, xmax=5, ymin=0.66, ymax=1, label = 1)
region2 <- data.frame (xmin=5, xmax=15, ymin=0.66, ymax=1, label = 2)
region3 <- data.frame (xmin=15, xmax=Inf, ymin=0.66, ymax=1, label = 3)
region4 <- data.frame (xmin=-Inf, xmax=5, ymin=0.33, ymax=0.66, label = 4)
region5 <- data.frame (xmin=5, xmax=15, ymin=0.33, ymax=0.66, label = 5)
region6 <- data.frame (xmin=15, xmax=Inf, ymin=0.33, ymax=0.66, label = 6)
region7 <- data.frame (xmin=-Inf, xmax=5, ymin=0, ymax=0.33, label = 7)
region8 <- data.frame (xmin=5, xmax=15, ymin=0, ymax=0.33, label = 8)
region9 <- data.frame (xmin=15, xmax=Inf, ymin=0, ymax=0.33, label = 9)
regions <- rbind (region1, region2, region3,
                  region4, region5, region6,
                  region7, region8, region9)


ggplot (persistenceMeans, aes (x = meanPersY-ObstacleRadius, y = SuccessRate, color = whichParam)) +
  geom_rect (data = regions, aes (xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                                  fill = factor(label), alpha = factor(label)), inherit.aes = FALSE) +
  geom_point(size = 2, alpha = 0.5) +
  geom_vline(xintercept = c(5,15), lty = 2) +
  geom_hline(yintercept = c(0.33,0.66), lty = 2) +
  geom_text (aes (label = RealSetNum), 
             check_overlap = TRUE, nudge_x = 2, size = 3) +
  scale_fill_manual (values = c("green", "green", "green", "gray", "gray", "gray", 
                                "red", "red", "red"), guide = "none") +
  scale_alpha_manual (values = c(0.1, 0.3, 0.5, 0.1, 0.5, 0.1, 0.5, 0.3, 0.1), guide = "none") +
  figTheme

ggplot (persistenceData, aes (x = meanPersY-ObstacleRadius, y = SuccessRate, color = whichParam)) +
  # geom_rect (data = regions, aes (xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
  #                                 fill = factor(label), alpha = factor(label)), inherit.aes = FALSE) +
  geom_point(alpha = 0.5) +
  # geom_vline(xintercept = c(5,15), lty = 2) +
  geom_hline(yintercept = c(0.33,0.66), lty = 2) +
  geom_text (aes (label = paste0(RealSetNum, ", ", RepNum)),
             check_overlap = TRUE, size = 3, nudge_y = 0.01, angle = 90) +
  # scale_fill_manual (values = c("green", "green", "green", "gray", "gray", "gray", 
  #                               "red", "red", "red"), guide = "none") +
  # scale_alpha_manual (values = c(0.1, 0.3, 0.5, 0.1, 0.5, 0.1, 0.5, 0.3, 0.1), guide = "none") +
  lims (x = c (0, 200), y = c (0.29, 0.41)) +
  figTheme 
ggplot (persistenceData, aes (x = meanPersY-ObstacleRadius, y = NumSucceed, color = whichParam)) +
  geom_point(alpha = 0.1) +
  geom_hline(yintercept = c(3.5), lty = 2) +
  geom_vline(xintercept = c(10), lty = 2) +
  # geom_text (aes (label = paste0(RealSetNum, ", ", RepNum)),
  #            check_overlap = TRUE, size = 3, nudge_y = 0.01, angle = 90) +
  # lims (x = c (0, 20), y = c (2.9, 4.1)) +
  figTheme 

# For a particular simulation, we will use the # that succeeded 
# (having been caught) and the mean backwards movement to classify. 
# If at least 4 succeed, it is a flocking escape. 
# If fewer than 4 succeed, but the backwards movement is more than 
# 10, it's also a flocking escape.

# Note, this approach is somewhat conservative, in the sense
# that it errs on the side of not counting something as a flocking
# escape. It does, however, count it as a flocking escape if they
# have a large curvature and don't actually bend around to goal. 

# How many will need manual checking with these rules?
persCut <- 10
successCut <- 4
maxStdGRT <- 15

persistenceData$StdGoalTime[is.na(persistenceData$StdGoalTime)]<-500

persistenceData <- 
  mutate (persistenceData, flockingEscape = 
            ifelse(StdGoalTime <= maxStdGRT, 
            ifelse (NumSucceed >= successCut, 1, 
                    ifelse (meanPersY - ObstacleRadius >= persCut, 1, 0)), 0))


ggplot (persistenceData, aes (x = meanPersY-ObstacleRadius, y = NumSucceed, 
                              color = factor(flockingEscape))) +
  geom_jitter(alpha = 0.2) +
  geom_hline(yintercept = c(3.5), lty = 2) +
  geom_vline(xintercept = c(10), lty = 2) +
  # geom_text (aes (label = paste0(RealSetNum, ", ", RepNum)),
  #            check_overlap = TRUE, size = 3, nudge_y = 0.01, angle = 90) +
  # lims (x = c (0, 20), y = c (2.9, 4.1)) +
  figTheme 

write.table (persistenceData,
             file = paste0 ("processedData20220408.csv"),
             col.names=TRUE, row.names=FALSE,sep=",")

