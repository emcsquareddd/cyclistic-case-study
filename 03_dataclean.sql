-- 1. To not delete any data that we collected, create a new table that keeps only the data we decided to include in the Prep phase.

CREATE OR REPLACE TABLE cyclistic.trips_clean AS
SELECT
  ride_id,
  rideable_type,
  started_at,
  ended_at,
  ROUND(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60, 2) AS ride_length_min,
  FORMAT_TIMESTAMP('%A', started_at)   AS day_of_week,
  EXTRACT(DAYOFWEEK FROM started_at)   AS day_num,
  EXTRACT(HOUR      FROM started_at)   AS start_hour,
  EXTRACT(MONTH     FROM started_at)   AS month_num,
  FORMAT_TIMESTAMP('%B', started_at)   AS month_name,
  start_station_name,
  end_station_name,
  start_lat, start_lng, end_lat, end_lng,
  member_casual
FROM cyclistic.trips_raw
WHERE ride_id IS NOT NULL
  AND member_casual IN ('member', 'casual')
  AND started_at >= '2025-01-01'
  AND started_at <  '2026-01-01'
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 0
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
  AND NOT (
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60
    AND start_station_name = end_station_name
    AND start_station_name IS NOT NULL
  )
QUALIFY ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) = 1;

-- 2. Verify what you predicted

SELECT
  (SELECT COUNT(*) FROM cyclistic.trips_raw)   AS raw_rows,
  (SELECT COUNT(*) FROM cyclistic.trips_clean) AS clean_rows,
  (SELECT COUNT(*) FROM cyclistic.trips_raw) -
  (SELECT COUNT(*) FROM cyclistic.trips_clean) AS removed;

-- 3. Breakdown of removed rows. NOTE: this shows the ORIGINAL result
--    before the null-station fix. The "other_UNEXPLAINED" bucket
--    (114,198 rows) is what flagged the bug. Kept here as the record
--    of how the issue was found.

SELECT
  CASE
    WHEN ride_id IS NULL THEN 'null_ride_id'
    WHEN member_casual IS NULL THEN 'null_rider_type'
    WHEN member_casual NOT IN ('member','casual') THEN 'bad_rider_type'
    WHEN started_at IS NULL OR ended_at IS NULL THEN 'null_timestamp'
    WHEN started_at < '2025-01-01' THEN 'pre_2025'
    WHEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 0 THEN 'non_positive'
    WHEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 86400 THEN 'over_24h'
    WHEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60
         AND start_station_name = end_station_name THEN 'same_station_sub60'
    ELSE 'other_UNEXPLAINED'
  END AS removal_reason,
  COUNT(*) AS rows_removed
FROM cyclistic.trips_raw
WHERE NOT COALESCE(
  ride_id IS NOT NULL
  AND member_casual IN ('member','casual')
  AND started_at >= '2025-01-01'
  AND started_at < '2026-01-01'
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 0
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
  AND NOT (TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60
           AND start_station_name = end_station_name)
, FALSE)
GROUP BY removal_reason
ORDER BY rows_removed DESC;

