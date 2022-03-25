CREATE TABLE google_rideshare.pivot_table AS (
    SELECT 
        month,
        SUM(CASE WHEN member=TRUE THEN 1 ELSE 0 END) AS member_count,
        SUM(CASE WHEN casual=TRUE THEN 1 ELSE 0 END) AS casual_count,
        COUNT(ride_id) AS total_rides,
        SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS classic_bike_count,
        SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS electric_bike_count,
        SUM(CASE WHEN rideable_type = 'docked_bike' THEN 1 ELSE 0 END) AS docked_bike_count,
        AVG(ride_length_sec) AS average_ride_length
    FROM 
        `ultra-sunset-341916.google_rideshare.full_frame` 
    GROUP BY 
        month
    ORDER BY 
        month
);

CREATE TABLE google_rideshare.pivot_member AS ( 
    SELECT 
        month,
        AVG(ride_length_sec) AS average_ride_length_member,
        SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS member_classic_bike_count,
        SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS member_electric_bike_count,
        SUM(CASE WHEN rideable_type = 'docked_bike' THEN 1 ELSE 0 END) AS member_docked_bike_count
    FROM 
        `ultra-sunset-341916.google_rideshare.full_frame`
    WHERE 
        member = TRUE
    GROUP BY 
        month
);

CREATE TABLE google_rideshare.pivot_casual AS ( 
    SELECT 
        month,
        AVG(ride_length_sec) AS average_ride_length_casual,
        SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS casual_classic_bike_count,
        SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS casual_electric_bike_count,
        SUM(CASE WHEN rideable_type = 'docked_bike' THEN 1 ELSE 0 END) AS casual_docked_bike_count
    FROM 
        `ultra-sunset-341916.google_rideshare.full_frame`
    WHERE 
        casual = TRUE
    GROUP BY 
        month
);

