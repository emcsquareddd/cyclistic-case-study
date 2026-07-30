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

 c. Pre-clean check:  
   i. _non_positive_duration_ - **0.033%** - Number of rides that ended at or before they started - Likely system errors as not quite possible to be 0 even if you were to end the ride as soon as you started, that would still at least count a few seconds. Negative second rides are impossible.  
  ii. _over_24_hours_ - **0.1%** - Number of trips longer 24 hours - Could be bikes not docked properly/users not properly ending their ride on the app or system not registering the end of the ride.  
 iii. _bad_rider_type_ - Only two types of members so flags any rides that don't fall under these types.  
  iv. _null_start_station_ - **21.3%** - Just to identify how many started not from a dock. A good to know.  
   v. _duplicate_ride_ids_ - each ride should have a unique id, flags any potential duplicates which could be bad data.  

  
### 3. Process

