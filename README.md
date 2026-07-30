# Cyclistic Case Study

### Background
Cyclistic is a bike-share company in Chicago with a programme that features more than 5,800 bicycles and 600 docking stations. Cyclistic sets itself
apart by also offering reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike.

## Approach

### 1. Ask
#### Business Task
Identifying and analysing Cyclistic casual and annual member user trends to provide strategy solutions in converting casual riders to annual members. 

### 2. Prepare

Data source: 
[Divvy Trip History Data](https://divvy-tripdata.s3.amazonaws.com/index.html)
Note: Data has been made available by Lyft under this [data license](https://divvybikes.com/data-license-agreement)

Tools used: 
BigQuery - Utilizing SQL for data processing & cleansing
Tableau - Data visualisation

Data prep:
1. [Data Loading](dataload.sql)
Downloaded files from 2025-01 to 2025-12 and converted them to gzips in order to be able to load them smoothly without worrying about file size.
Created a new raw table and loaded all the files in one go using wildcard (*.csv.gz)

3. [Data Quality Check](dataquality.sql)
Sanity check of data, ensuring all file data were successfully loaded.
 a. Overall:

 b. Monthly breakdown:
 
### 3. Process

