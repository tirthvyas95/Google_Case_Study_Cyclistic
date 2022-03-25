# Author - Tirth Vyas
# Date - 2022/03/24

install.packages("tidyverse")
install.packages("dplyr")
install.packages("janitor")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("reshape2")
install.packages("maps")
install.packages("ggmap")
install.packages("ggthemes")

library(tidyverse)
library(dplyr)
library(janitor)
library(lubridate)
library(ggplot2)
library(reshape2)
library(maps)
library(ggmap)
library(ggthemes)
library(skimr)


full_frame <- read_csv("full_frame.csv")

pivot_month <- read_csv("Pivot_Month_Day.csv")

pivot <- read_csv("Pivot_Month.csv")

#######################################################################

rides_by_month <- ggplot(data = pivot, aes(x = factor(month), y = total_rides))

rides_by_month + geom_bar(stat = "identity", fill = "#5696e9") + geom_text(aes(label = total_rides), vjust = -0.5) + 
  labs(x = "Month", y = "Total Rides", title = "Total Rides Per Month")

##################################################################

member_df <- data.frame(pivot$month, pivot$member_count, pivot$casual_count, pivot$total_rides)

member_df2 <- melt(member_df, id.vars = 'pivot.month')

ggplot(member_df2, aes(x = factor(pivot.month), y = value, fill = variable)) + 
  geom_bar(stat = 'identity', position = 'dodge') + labs(x = "Month", y = "Value", title = "Membership vs Month")

member_df3 <- data.frame(pivot$month, member_diff = pivot$member_count - pivot$casual_count)

ggplot(member_df3, aes(x = factor(pivot.month), y = member_diff, fill = variable)) +
  geom_bar(stat = 'identity', fill = '#5696e9') + 
  labs(x = "Month", y = "Member Count - Casual Count", title = "Membership Difference vs Month")

#############################################################################

bike_df <- data.frame(pivot$month, pivot$classic_bike_count, pivot$docked_bike_count, pivot$electric_bike_count)

bike_df2 <- melt(bike_df, id.vars = 'pivot.month')

ggplot(bike_df2, aes(x = factor(pivot.month), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  labs(x = "Month", y = "Bikes Used", title = "Bikes Used by Month")

#############################################################################

bike_member_df <- data.frame(pivot$month, pivot$casual_classic_bike_count, 
                             pivot$casual_electric_bike_count, pivot$casual_docked_bike_count,
                             pivot$member_classic_bike_count, pivot$member_electric_bike_count)

bike_member_df2 <- melt(bike_member_df, id.vars = 'pivot.month')

ggplot(bike_member_df2, aes(x = factor(pivot.month), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  labs(x = "Month", y = "Count", title = "Bikes Used between Members and Casuals by Month")

################################################################################

ride_length_member_df <- data.frame(pivot$month, pivot$average_ride_length, 
                                    pivot$average_ride_length_casual, pivot$average_ride_length_member)

ride_length_member_df2 <- melt(ride_length_member_df, id.vars = 'pivot.month')

ggplot(ride_length_member_df2, aes(x = factor(pivot.month), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  labs(x = "Month", y = "Ride Length in Seconds", title = "Average Ride Length by Month")

################################################################################

member_day_df <- data.frame(pivot_month$day_of_week, pivot_month$member_count, pivot_month$casual_count, 
                            pivot_month$total_rides)

member_day_df2 <- melt(member_day_df, id.vars = 'pivot_month.day_of_week')

member_day_df2$month = pivot_month$month

ggplot(member_day_df2, aes(x = factor(pivot_month.day_of_week), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') + facet_wrap(~month) +
  labs(x = "Day of Week", y = "Number of Rides", title = "Number of Rides by Day of Week")

################################################################################


member_day_wot_df <- data.frame(pivot_month$day_of_week, pivot_month$member_count, pivot_month$casual_count)

member_day_wot_df2 <- melt(member_day_wot_df, id.vars = 'pivot_month.day_of_week')

member_day_wot_df2$month = pivot_month$month

ggplot(member_day_wot_df2, aes(x = factor(pivot_month.day_of_week), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') + facet_wrap(~month) +
  labs(x = "Day of Week", y = "Number of Rides", title = "Number of Rides by Day of Week 2")

################################################################################

bike_day_df <- data.frame(pivot_month$day_of_week, pivot_month$classic_bike_count, pivot_month$electric_bike_count, 
                          pivot_month$docked_bike_count)

bike_day_df2 <- melt(bike_day_df, id.vars = 'pivot_month.day_of_week')

bike_day_df2$month = pivot_month$month

ggplot(bike_day_df2, aes(x = factor(pivot_month.day_of_week), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') + facet_wrap(~month)

################################################################################

chicago_map <- get_stamenmap(
  bbox = c(left = -87.84, bottom = 41.64, right = -87.50, top = 42.07),
  maptype = "terrain",
  zoom = 10
)

station_count <- read_csv("station_count.csv")

ggmap(chicago_map) +
  geom_point(data = station_count,
             aes(x = lng, y = lat, color = total_rides),
             size = 1) +
  scale_color_viridis_c(option = "plasma") +
  theme_map() + labs(title = "Station Map by Number of Rides")

################################################################################

sample_dmatrix <- read_csv("output.csv")

sample_test_pivot <- sample_dmatrix %>% drop_na() %>% group_by(member_casual) %>% summarize(member_idff = mean(ride_length_sec - ideal_time))

sample_dmatrix$time_diff = sample_dmatrix$ride_length_sec - sample_dmatrix$ideal_time

sample_dmatrix$time_mthen_10 =  sample_dmatrix$time_diff > 900

dmatrix_pivot <- sample_dmatrix %>% group_by(month,day_of_week) %>% summarize(ride_count = n_distinct(ride_id), 
                                                                              casual_count = sum(casual == TRUE), 
                                                                              member_count = sum(member == TRUE), 
                                                                              casual_leisure = sum(casual == TRUE & time_mthen_10 == TRUE),
                                                                              member_leisure = sum(member == TRUE & time_mthen_10 == TRUE))

dmatrix_pivot$casual_leisure_per = (dmatrix_pivot$casual_leisure / dmatrix_pivot$casual_count) * 100

dmatrix_pivot$member_leisure_per = (dmatrix_pivot$member_leisure / dmatrix_pivot$member_count) * 100

dmatrix_pivot_df <- data.frame(dmatrix_pivot$day_of_week, dmatrix_pivot$member_leisure_per, dmatrix_pivot$casual_leisure_per)

dmatrix_pivot_df2 <- melt(dmatrix_pivot_df, id.vars = 'dmatrix_pivot.day_of_week')

dmatrix_pivot_df2$month = dmatrix_pivot$month

ggplot(dmatrix_pivot_df2, aes(x = factor(dmatrix_pivot.day_of_week), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') + facet_wrap(~month) +
  labs(x = "Day of Week", y = "Leisure Rides(%)", title = "Percentage of Leisure Rides")

################################################################################

dmatrix_pivot_jmonth <- dmatrix_pivot %>% group_by(month) %>% summarize(ride_count = sum(ride_count), casual_count = sum(casual_count),
                                                                        member_count = sum(member_count),
                                                                        casual_leisure = sum(casual_leisure),
                                                                        member_leisure = sum(member_leisure))

dmatrix_pivot_jmonth$casual_leisure_per = (dmatrix_pivot_jmonth$casual_leisure / dmatrix_pivot_jmonth$casual_count) * 100

dmatrix_pivot_jmonth$member_leisure_per = (dmatrix_pivot_jmonth$member_leisure / dmatrix_pivot_jmonth$member_count) * 100

dmatrix_pivot_jmonth_df <- data.frame(dmatrix_pivot_jmonth$month, dmatrix_pivot_jmonth$member_leisure_per, dmatrix_pivot_jmonth$casual_leisure_per)

dmatrix_pivot_jmonth_df2 <- melt(dmatrix_pivot_jmonth_df, id.vars = 'dmatrix_pivot_jmonth.month')

ggplot(dmatrix_pivot_jmonth_df2, aes(x = factor(dmatrix_pivot_jmonth.month), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  labs(x = "Month", y = "Leisure Rides(%)", title = "Percentage of Leisure Rides by Month")

################################################################################

dmatrix_pivot_jday <- dmatrix_pivot %>% group_by(day_of_week) %>% summarize(ride_count = sum(ride_count), casual_count = sum(casual_count),
                                                                            member_count = sum(member_count),
                                                                            casual_leisure = sum(casual_leisure),
                                                                            member_leisure = sum(member_leisure))

dmatrix_pivot_jday$casual_leisure_per = (dmatrix_pivot_jday$casual_leisure / dmatrix_pivot_jday$casual_count) * 100

dmatrix_pivot_jday$member_leisure_per = (dmatrix_pivot_jday$member_leisure / dmatrix_pivot_jday$member_count) * 100

dmatrix_pivot_jday_df <- data.frame(dmatrix_pivot_jday$day_of_week, dmatrix_pivot_jday$member_leisure_per, dmatrix_pivot_jday$casual_leisure_per)

dmatrix_pivot_jday_df2 <- melt(dmatrix_pivot_jday_df, id.vars = 'dmatrix_pivot_jday.day_of_week')

ggplot(dmatrix_pivot_jday_df2, aes(x = factor(dmatrix_pivot_jday.day_of_week), y = value, fill = variable)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  labs(x = "Days of Week", y = "Leisure Rides(%)", title = "Percentage of Leisure Rides by Day of Week")
