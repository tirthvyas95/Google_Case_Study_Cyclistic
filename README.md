# Google Case Study on Cyclistic

## Introduction

Welcome to the Google Data Analytics case study for Cyclistic, Chicago. I developed this project as a part of Google's data analytics course on Coursera in the final course of a eight part course series. This is the analysis of data from a fictional company called Cyclistic based in Chicago where the main objective is to find out how differently users use the bike sharing service.

We are going to use Excel, BigQuery, RStudio, Google Cloud and Python to tackle this case study.

## Case Study

### Scenario

You are a junior data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, your team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve your recommendations, so they must be backed up with compelling data insights and professional data visualizations.

Cyclistic's finance analysts have concluded that annual members are much more profitable that casual riders. Although the pricing flexibility helps Cyclistic attract more customers, out director of marketing believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, the director believes there is a very good chance to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.

The director has set a clear goal: Design marketing strategies aims at converting casual riders into annual members. In order to do that, however, the marketing analyst team needs to better understand how annual members and casual riders differ, why casual riders would buy a membership, and how digital media could affect their marketing tactics. The director and their team are interested in analyzing the Cyclistic historical bike trip data to identify trends.

### Ask

Three questions that will guide this program:
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

The director has assigned us with the first question to answer: How do annual members and casual riders use Cyclistic bikes differently?

### Prepare

Before, we process the data we will take a look at the data and lay down some facts we know. This fictional company is based on a real company called Divvy bicycle sharing service from Chicago, this company is operated by Lyft Bikes and Scooters, LLC. They have a total of 865 stations as of today throughout Chicago, as for bikes they have Mechanical bikes and Electric bikes and they can be picked from any station and returned to any station. For pricing the company has three plans namely single ride, day pass and annual membership. The single ride costs $3.30 per ride with maximum trip duration of 30 minutes, day pass costs $15 with unlimited 3 hour rides for 24 hours and annual membership costs $9 per month with $108 paid upfront which grants unlimited 45 minute rides.

Now, let us look at the data. The data is provided by Lyft Bikes and Scooters, LLC("Bikeshare"). We will use data from last 12 months which for time I did this case study is from February, 2021 to January, 2022. You can access the data here. There are 12 .csv files containing data pertaining to each month.

The .csv files have 13 columns and the observations are the rides taken in that month.
![image](https://user-images.githubusercontent.com/89932233/159140616-d07420f9-68ed-44b4-9b7e-81e82055bf7b.png)

1. ride_id: Unique ride ID for each ride
2. rideable_type: Type of bike:
   * docked_bike = Older version of mechanical bikes
   * classic_bike = New version of mechanical bikes
   * electric_bike = Electric bikes
4. started_at: Time and Date in CT(Central Time) when the ride started or a bike picked from a station
5. ended_at: Time and Date in CT(Central Time) when the ride ended or a bike returned to a station
6. start_station_name: Name of the start station
7. start_station_id: Unique ID of the station
8. end_station_name: Name of the end station
10. end_station_id: Unique ID of the station	
11. start_lat: Latitude of the start station
12. start_lng: Longitude of hte end station
13. end_lat: Latitude of the end station
14. end_lng: Longitude of the end station
15. member_casual:
    * member = Annual member
    * casual = Rider with Single Ride plan or Day Pass plan

The .csv files are compressed in .zip files so extract them into the workspace directory.

### Process

We will work on the data in Excel first where we will clean and validate the data. We will also add 2 columns which will help us in data analysis.

Follow these steps:
1. Open excel and open the first .csv file, if excel prompts you to save it in .xlsx go ahead and do it. Just save it as .csv after the cleaning and validating.
2. First we will check if there are any blank rows start by selecting ride_id, go to Find & Select > Go To Special > Blanks and delete the cells that are highlighted. Repeat this process for each column. You can also do this with R by using 'drop_na()' function.
3. Now, we will remove duplicates start by selecting ride_id again, go to Conditional Formatting > Highlight Cells Rule > Duplicate Values and delete any highlighted cells. Repeat this process for each column.
4. Lets add a column with ride duration in it, add a column on right of ended_at, name it ride_length, in the first cell enter this formula '=D2-C2' that is ended_at minus started_at, auto-fill for the rest of the rows. Set the formatting as HH:MM:SS.
5. Add one more column on the right of ride_length, name it day_of_week, in the first cell enter this formula '=WEEKDAY(C2, 1)' that is day of week of started_at, auto-fill for the rest of the rows, also set the column formatting as whole numbers.
6. Repeat these steps for all the files and save them as .csv. You should have 12 cleaned and validated files.

After completing these steps the sheet should look like this:
![image](https://user-images.githubusercontent.com/89932233/159141113-1963455d-f255-4345-89ef-b43eb5b571eb.png)

Now, we need to merge all the files into a single .csv file. Excel cannot handle this much data at once, you could do it with R but I ran into some problems so I used a text editor instead. Open the files in a text editor copy and paste the observations in a single file and add a header with the names of the columns and save the file as 'full_frame.csv' and you should have a file with a size around 1GB. We will import this file as a data frame and use python to expand more on the data by adding two more rows.

We will also add 2 more columns namely member and casual with boolean values which will be useful when we make pivot tables in BigQuery. Use this code snippet:
```R
insatll.packages('tidyverse')
library(tidyverse)

full_frame <- read_csv("full_frame.csv")

full_frame$member = ifelse(full_frame$member_casual == "member", TRUE, FALSE)
full_frame$casual = ifelse(full_frame$member_casual == "casual", TRUE, FALSE)

write.csv(full_frame, file = "full_frame_sample.csv", row.names = FALSE)
```

People use the bikes for leisure riding as well so we need to find how many rides we used for leisure, we will use Google Maps Distance Matrix API for this job. It will enable us to find the distance between stations and how much time it takes for a bicycle rider to travel for each observation. Since Distance Matrix API is paid service we will take a sample representing the populous. We will take 2000 observation from each month which will keep the cost low and should retain the diversity in the data. Let's use R to take a sample and python to access the API and add rows.

Use the following steps:
1. Open RStudio and use this code to make a sample of the entire data:
   ```R
   library(tidyverse)
   
   full_frame <- read_csv("full_frame.csv")
   
   sam_2 <- filter(full_frame, month == 2)
   sam_2 <- sam_2[sample(nrow(sam_2), 1000), ]

   sam_3 <- filter(full_frame, month == 3)
   sam_3 <- sam_3[sample(nrow(sam_3), 1000), ]

   sam_4 <- filter(full_frame, month == 4)
   sam_4 <- sam_4[sample(nrow(sam_4), 1000), ]

   sam_5 <- filter(full_frame, month == 5)
   sam_5 <- sam_5[sample(nrow(sam_5), 1000), ]

   sam_6 <- filter(full_frame, month == 6)
   sam_6 <- sam_6[sample(nrow(sam_6), 1000), ]

   sam_7 <- filter(full_frame, month == 7)
   sam_7 <- sam_7[sample(nrow(sam_7), 1000), ]

   sam_8 <- filter(full_frame, month == 8)
   sam_8 <- sam_8[sample(nrow(sam_8), 1000), ]

   sam_9 <- filter(full_frame, month == 9)
   sam_9 <- sam_9[sample(nrow(sam_9), 1000), ]

   sam_10 <- filter(full_frame, month == 10)
   sam_10 <- sam_10[sample(nrow(sam_10), 1000), ]

   sam_11 <- filter(full_frame, month == 11)
   sam_11 <- sam_11[sample(nrow(sam_11), 1000), ]

   sam_12 <- filter(full_frame, month == 12)
   sam_12 <- sam_12[sample(nrow(sam_12), 1000), ]

   sam_1 <- filter(full_frame, month == 1)
   sam_1 <- sam_1[sample(nrow(sam_1), 1000), ]


   comb <- rbind(sam_2, sam_3, sam_4, sam_5, sam_6, sam_7, sam_8, sam_9, sam_10, sam_11, sam_12, sam_1)

   write.csv(comb, file = "full_frame_sample.csv", row.names = FALSE)
   ```
2. Before we run the python script, we will need to enter the API key into the script. Just copy and paste the key in place of YOUR_KEY in 'api_key = YOUR_KEY' line. You can get the key from Credential Manager in API and Services section in Google Cloud, you'll need to activate your free trial or payment set up to use it.
3. We will use Anaconda Command Prompt to run the python script, use this code snippet:
   ```CLI
   cd PATH\workspace
   python distance_matrix_api
   ```
   This should generate 'output.csv' file, we shall use it in our analysis.

### Analyze

Lets work on the best part of the project where we will analyze the data using SQL, Tableu and RStudio. To analyze the data first we need to know what are we looking for in the data, we have essentially a list of rides taken in last year, we know what time they started and what time they ended, we know where they started and where they ended, we know what kind of bike was used and we know if a ride was taken by a member. We need to find how differently members and casual riders use the service.

We will divide this question in small questions and try to answer it one by one, this will lead us to the answer of the first questions:
1. How many rides people take each month, how many are casuals and how many are members?
2. How what is the ride length of casuals and members and how does it differ throughout the year?
3. Does weather conditions have any effect on the total number of riders?
4. What do members use their ride for and casuals for that matter?
5. What type of bikes people prefer? What kind of bike casuals prefer and members for that matter?
6. Does the surroundings of a station have effect on how busy it is?
7. Is there any relationship between day of the week and number of rides?

We will make a pivot table to answer some of these questions. We will use SQL for this task. We are going to use BigQuery to write queries in SQL and query the full_frame table. Follow these steps:
1. First, we need to upload the 'full_frame.csv' file and store it in a table to query it in BigQuery. BigQuery cannot take .csv files larger than 200MB directly from your computer so you will need to use Google Cloud storage, it is also included in the free trial.
2. Log on to BigQuery, if you dont have your payment set and need to take a free trial use this [guide](https://cloud.google.com/bigquery/docs/quickstarts/query-public-dataset-console). Make a new project you will need to make a project first for the free trial to be activated.
3. Go to cloud storage from the drop-down menu on the left top side, create a bucket and upload the 'full_fram.csv'.
4. Navigate back to BigQuery and create a dataset.
5. Now create a table, select Google Cloud Storage option and that will let you navigate to your bucket where you can select the dataset.
6. Enter a name for the table in my case it was full_frame, Check the auto-detect schema checkbox and BigQuery will add the dataset to a table.
   * Run this Query to check if everything is working:
     ```SQL
     SELECT 
      rideable_type,
      SUM(CASE WHEN member=TRUE THEN 1 ELSE 0 END) AS member_count,
      SUM(CASE WHEN casual=TRUE THEN 1 ELSE 0 END) AS casual_count,
      COUNT(member_casual) AS total_count
     FROM 
      `ultra-sunset-341916.google_rideshare.full_frame` 
     GROUP BY 
      rideable_type
     ```
     You should get a result like this:
     
     ![Capture2](https://user-images.githubusercontent.com/89932233/159177857-dfbb359d-8a33-46e9-bcf6-d3e3b9f32a4a.PNG)
     
7. Copy the Query from Query_1.sql and paste it in Query editor, run it and it will create 3 tables, after that run the Query in Query_2.sql and pivot_month will be generated.
8. Finally, copy the query from Query_3.sql file and run it followed by the query in Query_4.sql and that should generate pivot_month_day table.
9. You should have 2 pivot tables if you did everything correctly, download them as .csv files we will make some visualizations in RStudio to analyse them.

Description of pivot_month_day table:
1. month: Month
2. day_of_week: Day of the week	
3. member_count: Number of members rides
4. casual_count: Number of casual rides	
5. total_rides: Total rides
6. classic_bike_count: Number of classic bikes used
7. electric_bike_count: Number of electric bikes used
8. docked_bike_count: Number of docked bikes used
9. average_ride_length: Average ride length
10. average_ride_length_casual: Average ride length of casual rides
11. casual_classic_bike_count: Number of casuals that used classic bikes
12. casual_electric_bike_count: Number of casuals that used electric bikes
13. casual_docked_bike_count: Number of casuals that used docked bikes
14. average_ride_length_member: Average ride length of members
15. member_classic_bike_count: Number of members that used classic bikes
16. member_electric_bike_count: Number of members that used electric bikes
17. member_docked_bike_count: Number of members that used docked bikes

![image](https://user-images.githubusercontent.com/89932233/159176885-c7b7b2da-58ea-4e23-bbd3-2bc5857b7911.png)

The pivot_month table is grouped only by months so there is no day_of_week column, the rest is same.

Now, lets make some charts from the pivot tables and note down any observations so that we can see if there are any trends:
1. Open RStudio, install and load the packages:
   ```R
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
   ```
2. Import the pivot tables:
   ```R
   pivot_month <- read_csv("pivot_month_day.csv")

   pivot <- read_csv("pivot_month.csv")
   ```
3. Examine how total number of rides vary with month:
   ```R
   rides_by_month <- ggplot(data = pivot, aes(x = factor(month), y = total_rides))
   rides_by_month + geom_bar(stat = "identity", fill = "#5696e9") + geom_text(aes(label = total_rides), vjust = -0.5) + labs(x = "Month", y = "Total Rides", title = "Total Rides Per Month")
   ```
   ![total_rides_per_month](https://user-images.githubusercontent.com/89932233/159203903-85fe2e09-af3b-48c2-9f45-67d57b6fa758.png)

   The number of rides are lowest in January, February and December but they start climbing up from May to highest in July. There could be a correlation with weather since January, February and December are the coldest in Chicago.

4. See how number of member rides and casual rides vary with months:
   ```R
   member_df <- data.frame(pivot$month, pivot$member_count, pivot$casual_count, pivot$total_rides)

   member_df2 <- melt(member_df, id.vars = 'pivot.month')

   ggplot(member_df2, aes(x = factor(pivot.month), y = value, fill = variable)) + 
    geom_bar(stat = 'identity', position = 'dodge') + labs(x = "Month", y = "Value", title = "Membership vs Month")
   ```
   ![Membership vs Month](https://user-images.githubusercontent.com/89932233/159336334-0e2a6186-c7c7-4403-b9cd-bd0916524d96.png)

   Let's calculate the difference between member rides and casual rides and plot it:
   ```R
   member_df3 <- data.frame(pivot$month, member_diff = pivot$member_count - pivot$casual_count)

   ggplot(member_df3, aes(x = factor(pivot.month), y = member_diff, fill = variable)) +
    geom_bar(stat = 'identity', fill = '#5696e9') + 
      labs(x = "Month", y = "Member Count - Casual Count", title = "Membership Difference vs Month")
   ```
   ![Membership Difference vs Month](https://user-images.githubusercontent.com/89932233/159338579-8118f136-3cdf-4399-a4ed-aaf6fb7346b9.png)
   
   As you can see in the charts, rides taken by casual users drastically increases in May to September. Maybe weather pattern has any coorelation with this. Let's see ckeck weather patterns in Chicago.
   
   Figure depicts weather in Chicago by month:
   
   ![Climate in Chicago](https://user-images.githubusercontent.com/89932233/159584453-f3fdb317-6cf0-4dbe-87f8-7cf6fa151385.png)
   
   Figure depicts the average snowfall by month:
  
   ![Average Monthly Snowfall in Chicago](https://user-images.githubusercontent.com/89932233/159584507-622744a4-c704-4798-ba29-65f3dfd03304.png)
   
   The weather starts getting warm from the start of May and starts cooling from the start of October. Also, substantial snowfalls only occur in January, February and December. probably the warm weather encourages people to take leisure rides, we need more evidence to justify the theory.
   
5. Now, let's look at what type of bikes people use by month:
      ```R
      bike_df <- data.frame(pivot$month, pivot$classic_bike_count, pivot$docked_bike_count, pivot$electric_bike_count)

      bike_df2 <- melt(bike_df, id.vars = 'pivot.month')

      ggplot(bike_df2, aes(x = factor(pivot.month), y = value, fill = variable)) +
        geom_bar(stat = 'identity', position = 'dodge') +
        labs(x = "Month", y = "Bikes Used", title = "Bikes Used by Month")
      ```
      ![Bikes Used by Month](https://user-images.githubusercontent.com/89932233/159587333-0fa27da6-4755-4827-8c66-345f8e34b31d.png)
      
      Most of people use the Classic bikes, classic bike usage scales with the overall rides taken each month, so classic bikes are the bike of choice for users. Docked bikes are older version of classic bikes, they both are mechanical so there is little difference between them. Electric bike usage trends a bit differently most notable in October, can it be a anomaly? More evidence is needed.
      
6. Moving forward we will see what bikes members and casuals use by month:
   ```R
   bike_member_df <- data.frame(pivot$month, pivot$casual_classic_bike_count, 
                             pivot$casual_electric_bike_count, pivot$casual_docked_bike_count,
                             pivot$member_classic_bike_count, pivot$member_electric_bike_count)

   bike_member_df2 <- melt(bike_member_df, id.vars = 'pivot.month')

   ggplot(bike_member_df2, aes(x = factor(pivot.month), y = value, fill = variable)) +
    geom_bar(stat = 'identity', position = 'dodge') +
    labs(x = "Month", y = "Count", title = "Bikes Used between Members and Casuals by Month")
   ```
   ![Bikes Used between Members and Casuals by Month](https://user-images.githubusercontent.com/89932233/159589850-c38dc31c-092f-46be-a6f8-5495a388703b.png)
   
   Again this charts shows that classic bike usage dominate others, additionally classic bikes used by casuals starts dropping from August though members keep using the bikes until October. Important observation to note is that electric bike usage by members goes up inexplicably in October. There should be reason behind this, more examination is required.
   
   One more important point to note is docked bike counts for members is zero for all months. Did some kind of problem occur while gathering the data? For this analysis it is safe to assume that classic bikes and docked bikes are same since they are both mechanically operated.

7. Examine the average ride length by month:
   ```R
   ride_length_member_df <- data.frame(pivot$month, pivot$average_ride_length, 
                             pivot$average_ride_length_casual, pivot$average_ride_length_member)

   ride_length_member_df2 <- melt(ride_length_member_df, id.vars = 'pivot.month')

   ggplot(ride_length_member_df2, aes(x = factor(pivot.month), y = value, fill = variable)) +
    geom_bar(stat = 'identity', position = 'dodge') +
    labs(x = "Month", y = "Ride Lenght in Seconds", title = "Average Ride Lenght by Month")
   ```
   ![Average Ride Length by Month](https://user-images.githubusercontent.com/89932233/159604169-5c1695c2-fac8-4b5a-aeda-6bd1cef737dd.png)

   The average ride length of members is quite constant throughout out the year indicating that members may be using the rides for commute, the ride length for casuals is higher in February, March and May, then it starts decreasing from June to December. 
   
8. Now, we will examine how days of a week affect number of rides in a month:
   ```R
   member_day_df <- data.frame(pivot_month$day_of_week, pivot_month$member_count, pivot_month$casual_count, 
                            pivot_month$total_rides)

   member_day_df2 <- melt(member_day_df, id.vars = 'pivot_month.day_of_week')

   member_day_df2$month = pivot_month$month

   ggplot(member_day_df2, aes(x = factor(pivot_month.day_of_week), y = value, fill = variable)) +
    geom_bar(stat = 'identity', position = 'dodge') + facet_wrap(~month) +
    labs(x = "Day of Week", y = "Number of Rides", title = "Number of Rides by Day of Week")
   ```
   ![Number of Rides by Day of Week](https://user-images.githubusercontent.com/89932233/159604371-2bc91489-8961-452a-8d91-93cf9a9b0901.png)
   
   The total number of rides in May to September on Saturday and Sunday more than weekdays, indicating these rides were probably used for leisure. Moreover the number of casual rides is consistently higher on weekends compared to weekdays. On the other hand number of member rides are consistent throughout the week, sometimes higher on Tuesdays, Wednesdays and Thursdays.
   
   The difference between member count and casual count is much more apparent in the following graph:
   
   ![Number of Rides by Day of Week 2](https://user-images.githubusercontent.com/89932233/159606053-da58a043-9d55-4e4d-bf53-16ce460a9441.png)
   
9. Let's see how busy the stations are. We will need a SQL query for this so run this first in BigQuery and download it as .csv:
    ```SQL
    SELECT
        COUNT(ride_id) AS total_rides,
        start_station_name,
        AVG(start_lng) AS lng,
        AVG(start_lat) AS lat
    FROM 
        `ultra-sunset-341916.google_rideshare.full_frame`
    GROUP BY 
        start_station_name
    ORDER BY
        total_rides DESC
    ```
   Run this in RStudio, and this should generate a map with stations with color intensity depending on the ride count:
    ```R
    station_count <- read_csv("station_count.csv")

    chicago_map <- get_stamenmap(
      bbox = c(left = -87.84, bottom = 41.64, right = -87.50, top = 42.07),
      maptype = "terrain",
      zoom = 10
    )

    ggmap(chicago_map) +
      geom_point(data = station_count,
                 aes(x = lng, y = lat, color = total_rides),
                 size = 1) +
      scale_color_viridis_c(option = "plasma") +
      theme_map() + labs(title = "Station Map by Number of Rides")
    ```
    ![Station Map by Number of Rides](https://user-images.githubusercontent.com/89932233/159622885-b8d69abb-09df-4675-a92d-a1b5263fa2ea.png)
    
    You can see in the map the stations that are along the coastline are especially busy for the year, this is because of the high volume of people riding in summer. You can see the difference better in [this](https://public.tableau.com/app/profile/tirth.vyas/viz/GoogleCyclistcCaseStudy/Sheet1) tableu dashboard.

10. Finally examine the results from Distance Matrix API, they are saved in output.csv. Run this snippet below:
    ```R
    sample_dmatrix <- read_csv("output.csv")

    sample_test_pivot <- sample_dmatrix %>% drop_na() %>% group_by(member_casual) %>% summarize(member_idff = mean(ride_length_sec - ideal_time))

    sample_dmatrix$time_diff = sample_dmatrix$ride_length_sec - sample_dmatrix$ideal_time

    sample_dmatrix$time_mthen_10 =  sample_dmatrix$time_diff > 600

    dmatrix_pivot <- sample_dmatrix %>% group_by(month,day_of_week) %>% summarize(ride_count = n_distinct(ride_id), 
                                                                                  casual_count = sum(casual == TRUE), 
                                                                                  member_count = sum(member == TRUE), 
                                                                                  casual_leisure = sum(casual == TRUE & time_mthen_10 == TRUE),
                                                                                  member_leisure = sum(member == TRUE & time_mthen_10 == TRUE))

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
    ```
    ![Percentage of Leisure Rides by Month](https://user-images.githubusercontent.com/89932233/159809334-fb526f9f-4531-4eeb-b687-cd0786d629b5.png)
    
    We will assume that ride lengths that are 10 minutes higher than the ideal ride time between start station and end station as leisure rides. As you can see in the figure casual rides are mostly used as leisure rides, the disparity between member leisure percent and casual leisure percent is because of high volume of leisure rides taken by casuals in the summer.
    
    Take a look at this figure:
    ```R
    dmatrix_pivot$casual_leisure_per = (dmatrix_pivot$casual_leisure / dmatrix_pivot$casual_count) * 100

    dmatrix_pivot$member_leisure_per = (dmatrix_pivot$member_leisure / dmatrix_pivot$member_count) * 100

    dmatrix_pivot_df <- data.frame(dmatrix_pivot$day_of_week, dmatrix_pivot$member_leisure_per, dmatrix_pivot$casual_leisure_per)

    dmatrix_pivot_df2 <- melt(dmatrix_pivot_df, id.vars = 'dmatrix_pivot.day_of_week')

    dmatrix_pivot_df2$month = dmatrix_pivot$month

    ggplot(dmatrix_pivot_df2, aes(x = factor(dmatrix_pivot.day_of_week), y = value, fill = variable)) +
      geom_bar(stat = 'identity', position = 'dodge') + facet_wrap(~month) +
      labs(x = "Day of Week", y = "Leisure Rides(%)", title = "Percentage of Leisure Rides")
    ```
    ![Percentage of Leisure Rides](https://user-images.githubusercontent.com/89932233/159810852-2d94ac41-32b6-472a-b44c-8256ae2d1810.png)

    As you can see, in summers casuals tend to take casual rides a lot more often. And casual riders are consistently using the bikes for leisure purposes compared to members. Check out one more chart that shows leisure percentage by days of a week.
    ```R
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
    ```
    ![Percentage of Leisure Rides by Day of Week](https://user-images.githubusercontent.com/89932233/159811996-cb0a27b9-1daf-4c6c-80ed-9b029b8cccc1.png)
    
    The casual leisure percentages for weekends are higher than weekdays indicating that casuals take a lot leisure rides on weekends. Even if we call ride time 15 minutes more than ideal ride time leisure ride, the result is unchanged hence out assumption is correct that these are leisure rides.
    
We have done all the examinations of data, we shall conclude with the recommendations in the next phase.

### Share

We partitioned this case study in 6 Phases according to the Google's Data Analysis model, we went from Ask, Prepare, Process, Analyze to Share. Here I shall state all the key findings in this analysis and give my top three recommendations.

Here is what we discovered:
1. The number of rides are lowest in January, February and December but they start climbing up from May to highest in July. There could be a corelation with weather since January, Febuary and December are the coldest in Chicago.
2. Rides taken by casual users drastically increases in May to September. Maybe weather pattern has any correlation with this. Probably the warm weather encourages people to take leisure rides.
3. Most of people use the Classic bikes, classic bike usage scales with the overall rides taken each month, so classic bikes are the bike of choice for users.
4. Classic bikes used by casuals starts dropping from August though members keep using the bikes until October.
5. The average ride length of members is quite constant throughout out the year indicating that members may be using the rides for commute, the ride length for casuals is higher in February, March and May, then it starts decreasing from June to December.
6. The total number of rides in May to September on Saturday and Sunday more than weekdays, indicating these rides were probably used for leisure. Moreover, the number of casual rides is consistently higher on weekends compared to weekdays. On the other hand, number of member rides are consistent throughout the week, sometimes higher on Tuesdays, Wednesdays and Thursdays.
7. You can see in the map the stations that are along the coastline are especially busy for the year, this is because of the high volume of people riding in summer.
8. Casual rides are mostly used as leisure rides, the disparity between member leisure percent and casual leisure percent is because of high volume of leisure rides taken by casuals in the summer. Casual riders are consistently using the bikes for leisure purposes compared to members.

Now, let me state my top three recommendations:
1. As you move away from the coastline westwards the bike usage starts decreasing with average numbers as low as two or three rides, this is a big problem people outside the Chicago downtown do not use this service at all. We need to fix this by targeting customers in those areas. Simple billboards on highways can help since people tend to drive more often in these parts of the city.
2. The stations around the Chicago coastline get especially busy in summer and parks and public places are also near, therefore these areas are a good spot to advertise the service.
3. Since most of the casual riders use the service for leisure rides in summer they do not buy the yearly membership, also marketing to convert casuals into members has been going on for a while so it is probably time to add one more plan as in the fourth plan. I would suggest that they add a 3 month subscription plan to the service, allowing casual leisure riders to pay for what they can use. Moreover, the rides taken on weekends is high therefore a opportunity to pull more riders by giving some kind of seasonal discount on these days.

Additional recommendations:
* Electric bikes clearly do not see much action meaning the usage number is very low compared to classic bikes throughout the year, this can be because of number of several reasons like low availability, low range and long charging time hence impact to availability. This is the time to work on them.
* Since we do not have any data on age of the riders so we cannot be sure, but I presume usage by young demographic is low. Therefore, advertising of social media platform which are popular to youth is a good starting point. More data required to solidify the recommendation.
* Finally, I did encounter a anomaly in where electric bike usage went inexplicably up in October especially for members. Is because of any external factor? Can we use it to our advantage? More examination and more data required.

As for the Act phase, it is out of our scope since we are only assigned to answer the question as to how differently casual riders and annual members use Cyclistic bikes.

## References

1. D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R Journal, 5(1), 144-161. URL
  http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf  
2. Divvy Bikes Chicago. Divvy. (n.d.). Retrieved March 24, 2022, from https://divvybikes.com/ 
3. Weatherspark.com. Chicago Climate, Weather By Month, Average Temperature (Illinois, United States) - Weather Spark. (n.d.). Retrieved March 24, 2022, from https://weatherspark.com/y/14091/Average-Weather-in-Chicago-Illinois-United-States-Year-Round#:~:text=In%20Chicago%2C%20the%20summers%20are,or%20above%2091%C2%B0F. 
