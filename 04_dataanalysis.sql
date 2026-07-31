-- Angle 1: Volume & duration by rider type

SELECT
  member_casual,
  COUNT(*) AS rides,
  ROUND(AVG(ride_length_min), 1) AS mean_min,
  ROUND(APPROX_QUANTILES(ride_length_min,100)[OFFSET(50)],1) AS median_min

  FROM cyclistic.trips_clean
  GROUP BY member_casual

--Angle 2: Breakdown of rides by day per week

SELECT
  member_casual,
  day_num,
  day_of_week,
  COUNT(*) AS rides

  FROM cyclistic.trips_clean
  GROUP BY member_casual, day_num, day_of_week
  ORDER BY member_casual, day_num

--Angle 3: Rider by hour of day

SELECT
  member_casual,
  start_hour,
  COUNT(*) AS rides

  FROM cyclistic.trips_clean
  GROUP BY member_casual, start_hour
  ORDER BY member_casual, start_hour


-- Angle 4: Seasonality 
  
SELECT
  member_casual,
  month_num,
  month_name,
  COUNT(*) AS rides

  FROM cyclistic.trips_clean
  GROUP BY member_casual, month_num, month_name
  ORDER BY member_casual, month_num

-- Angle 5: Bike Type

SELECT
  member_casual,
  rideable_type,
  COUNT(*) AS rides

  FROM cyclistic.trips_clean
  GROUP BY member_casual, rideable_type
  ORDER BY member_casual, rideable_type

-- Angle 6: Geography

SELECT
  start_station_name,
  COUNTIF(member_casual = 'casual') AS casual_rides,
  COUNTIF(member_casual = 'member') AS member_rides, 
  COUNT(*) AS total_rides,
  ROUND(COUNTIF(member_casual = 'casual') / COUNT(*), 3) AS casual_share

  FROM cyclistic.trips_clean
  WHERE start_station_name IS NOT NULL
  GROUP BY start_station_name
  HAVING COUNT(*) > 1000
  ORDER BY casual_share DESC
  LIMIT 25;
