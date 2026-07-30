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

-- 3. Boundary strays: trips dated before the 2025 window.
--    These are end-of-2024 trips caught in the January file
--    cut. Cleaning excludes them; this counts them for the log.

SELECT COUNT(*) AS pre_2025_rides
FROM cyclistic.trips_raw
WHERE started_at < '2025-01-01';


-- 4. Issues the cleaning step will remove, each counted so the
--    process log can cite exact numbers and percentages rather
--    than saying "cleaned the data".

SELECT
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 0)    AS non_positive_duration,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 86400) AS over_24_hours,
  COUNTIF(member_casual NOT IN ('member', 'casual'))            AS bad_rider_type,
  COUNTIF(start_station_name IS NULL)                           AS null_start_station,
  COUNT(*) - COUNT(DISTINCT ride_id)                            AS duplicate_ride_ids,
  COUNT(*)                                                      AS total_rows
FROM cyclistic.trips_raw;
