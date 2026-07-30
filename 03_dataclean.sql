-- 1. To not delete any data that we collected, create a new table with filters to not include data we decided to exclude during the Prep phase

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
  )
QUALIFY ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) = 1;

-- 2. Verify what you predicted

SELECT
  (SELECT COUNT(*) FROM cyclistic.trips_raw)   AS raw_rows,
  (SELECT COUNT(*) FROM cyclistic.trips_clean) AS clean_rows,
  (SELECT COUNT(*) FROM cyclistic.trips_raw) -
  (SELECT COUNT(*) FROM cyclistic.trips_clean) AS removed;
