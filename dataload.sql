-- Created raw table with explicit schema. Station IDs are forced to STRING because their type is inconsistent across monthly files.
-- Note:   Dataset and bucket are both in the EU multi-region. Run these queries with processing location = EU.

CREATE TABLE cyclistic.trips_raw (
  ride_id            STRING,
  rideable_type      STRING,
  started_at         TIMESTAMP,
  ended_at           TIMESTAMP,
  start_station_name STRING,
  start_station_id   STRING,
  end_station_name   STRING,
  end_station_id     STRING,
  start_lat          FLOAT64,
  start_lng          FLOAT64,
  end_lat            FLOAT64,
  end_lng            FLOAT64,
  member_casual      STRING
);

-- Gzipped all monthly csv files prior. Loaded them in one go using wildcard (*.csv.gz).

LOAD DATA INTO cyclistic.trips_raw
FROM FILES (
  format = 'CSV',
  uris = ['gs://cyclistic-2025-cs/*.csv.gz'],
  skip_leading_rows = 1,
  compression = 'GZIP'
);
