SELECT 
    pivot_table.month,
    pivot_table.member_count,
    pivot_table.casual_count,
    pivot_table.total_rides,
    pivot_table.classic_bike_count,
    pivot_table.electric_bike_count,
    pivot_table.docked_bike_count,
    pivot_table.average_ride_length,
    casual.average_ride_length_casual,
    casual.casual_classic_bike_count,
    casual.casual_electric_bike_count,
    casual.casual_docked_bike_count,
    member.average_ride_length_member,
    member.member_classic_bike_count,
    member.member_electric_bike_count,
    member.member_docked_bike_count
FROM 
    `ultra-sunset-341916.google_rideshare.pivot_table` AS pivot_table
    INNER JOIN 
    `ultra-sunset-341916.google_rideshare.pivot_casual` AS casual
    ON
        pivot_table.month = casual.month
    INNER JOIN 
    `ultra-sunset-341916.google_rideshare.pivot_member` AS member
    ON 
        pivot_table.month = member.month
