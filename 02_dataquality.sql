-- Data quality checks on trips_raw, run after loading.
-- This is to ensure the load was sucessfuland quantify issues that the cleaning step will remove.
-- Run these before trusting downstream analysis.

-- 1. Overall shape: did all 12 months load, within window?
--    Expect ~5.5M rows, 12 distinct months, dates in 2025.

SELECT
  COUNT(*)                                              AS total_rows,
  MIN(started_at)                                       AS earliest,
  MAX(started_at)                                       AS latest,
  COUNT(DISTINCT FORMAT_TIMESTAMP('%Y-%m', started_at)) AS distinct_months
FROM cyclistic.trips_raw;

-- 2. Rides per month: catches missing files, partial loads,
--    and out-of-window strays.

SELECT
  FORMAT_TIMESTAMP('%Y-%m', started_at) AS month,
  COUNT(*)                              AS rides
FROM cyclistic.trips_raw
GROUP BY month
ORDER BY month;


-- 3. Issues the cleaning step will remove, each counted so the
--    process log can cite exact numbers and percentages rather
--    than saying "cleaned the data".

SELECT
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 0)    AS non_positive_duration,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) BETWEEN 1 AND 59) AS very_short_trips,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 86400) AS over_24_hours,
  COUNTIF(member_casual NOT IN ('member', 'casual'))            AS bad_rider_type,
  COUNTIF(start_station_name IS NULL)                           AS null_start_station,
  COUNT(*) - COUNT(DISTINCT ride_id)                            AS duplicate_ride_ids,
  COUNT(*)                                                      AS total_rows
FROM cyclistic.trips_raw;

-- 4. To breakdown very_short_trips and see if any are system errors/false starts
--    or actually very short trips. 

SELECT
  COUNTIF(start_station_name = end_station_name) AS same_station,
  COUNTIF(start_station_name != end_station_name) AS different_station,
  COUNTIF(start_station_name IS NULL OR end_station_name IS NULL) AS null_station,
  COUNT(*) AS total
FROM cyclistic.trips_raw
WHERE TIMESTAMP_DIFF(ended_at, started_at, SECOND) BETWEEN 1 AND 59;


-- 5. Check if data includes internal stations incl. test, maintenance, repair sites

SELECT
  start_station_name,
  COUNT(*) AS rides
FROM cyclistic.trips_raw
WHERE LOWER(start_station_name) LIKE '%warehouse%'
   OR LOWER(start_station_name) LIKE '%test%'
   OR LOWER(start_station_name) LIKE '%repair%'
   OR LOWER(start_station_name) LIKE '%maintenance%'
   OR LOWER(start_station_name) LIKE '%hq%'
   OR LOWER(start_station_name) LIKE '%divvy%'
GROUP BY start_station_name
ORDER BY rides DESC;
