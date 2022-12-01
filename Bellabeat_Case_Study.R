#Prepare for Analysis

##Install packages

install.packages("tidyverse")
install.packages("readr")
install.packages("tidyr")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("lubridate")

library(tidyverse)
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(lubridate)

##Importing datasets

activity <- read_csv("Fitbit_dataset/dailyActivity_merged.csv")
calories <- read_csv("Fitbit_dataset/hourlyCalories_merged.csv")
intensities <- read_csv("Fitbit_dataset/hourlyIntensities_merged.csv")
sleep <- read_csv("Fitbit_dataset/sleepDay_merged.csv")
weight <- read.csv("Fitbit_dataset/weightLogInfo_merged.csv")

##Confirming data imported correctly

head(activity)
head(calories)
head(intensities)
head(sleep)
head(weight)


##Correcting the formatting


####activity
activity$ActivityDate=as.POSIXct(activity$ActivityDate, format="%m/%d/%Y", tz=Sys.timezone())
activity$date <- format(activity$ActivityDate, format = "%m/%d/%y")

####Calories
calories$ActivityHour=as.POSIXct(calories$ActivityHour, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())
calories$time <- format(calories$ActivityHour, format = "%H:%M:%S")
calories$date <- format(calories$ActivityHour, format = "%m/%d/%y")

####intensities
intensities$ActivityHour=as.POSIXct(intensities$ActivityHour, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())
intensities$time <- format(intensities$ActivityHour, format = "%H:%M:%S")
intensities$date <- format(intensities$ActivityHour, format = "%m/%d/%y")

####sleep
sleep$SleepDay=as.POSIXct(sleep$SleepDay, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())
sleep$date <- format(sleep$SleepDay, format = "%m/%d/%y")

##Explore data

n_distinct(activity$Id)
n_distinct(calories$Id)
n_distinct(intensities$Id)
n_distinct(sleep$Id)
n_distinct(weight$Id)

####activity
activity %>%
  select(TotalSteps, TotalDistance, SedentaryMinutes, Calories) %>%
  summary()

####active minutes per category
activity %>%
  select(VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes) %>%
  summary()

####calories
calories %>%
  select(Calories) %>%
  summary()

####sleep
sleep %>%
  select(TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed) %>%
  summary()

####weight
weight %>%
  select(WeightKg, BMI) %>%
  summary()

#Merge data
merged_df <- merge(sleep, activity, by=c('Id', 'date'))
head(merged_df)

#Visualize

####Steps vs. Calories
ggplot(data=activity, aes(x=TotalSteps, y=Calories)) + 
  geom_point() + geom_smooth() + labs(title="Total Steps vs. Calories")

####Time asleep vs. Time in bed
ggplot(data=sleep, aes(x=TotalMinutesAsleep, y=TotalTimeInBed)) + 
  geom_point()+ labs(title="Total Minutes Asleep vs. Total Time in Bed")

####mean total intensity throughout the day
intensities_2 <- intensities %>%
  group_by(time) %>%
  drop_na() %>%
  summarise(mean_total_intensities = mean(TotalIntensity))

ggplot(data=intensities_2, aes(x=time, y=mean_total_intensities)) + geom_histogram(stat = "identity", fill='darkred') +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title="Average Total Intensity vs. Time")


####Minutes asleep vs. Minutes sedentary
ggplot(data=merged_df, aes(x=TotalMinutesAsleep, y=SedentaryMinutes)) + 
  geom_point(color='purple') + geom_smooth() +
  labs(title="Minutes Asleep vs. Sedentary Minutes")