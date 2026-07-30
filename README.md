# Cyclistic Case Study

### Background
Cyclistic is a bike-share company in Chicago with a programme that features more than 5,800 bicycles and 600 docking stations. Cyclistic sets itself
apart by also offering reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike.

I, as a junior data analyst within the marketing analyst team, am tasked with analysing user data to assist in creating marketing strategies to convert casual members to sign up for annual membership. Data insights and visualisations will be created and used to support recommendations.  

Note: Cyclistic is a fictional bike-share company used for this case study. As it has no real data, the analysis uses public trip data from Divvy, a real Chicago bike-share service, as a stand-in.

## Approach

### 1. Ask
#### Business Task
Identifying and analysing Cyclistic casual and annual member user trends to inform strategies for converting casual riders into annual members.

### 2. Prepare

Data source: 
[Divvy Trip History Data](https://divvy-tripdata.s3.amazonaws.com/index.html)
Note: Data owned by the City of Chicago and made publicly available by Lyft Bikes and Scooters, LLC under the [Divvy Data License Agreement](https://divvybikes.com/data-license-agreement). Please also note that Divvy pre-processes this data before release, removing staff service/inspection trips and trips under 60 seconds, so those are already absent from the raw files.

Tools used: 
BigQuery - Utilising SQL for data processing & cleansing
Tableau - Data visualisation

Data prep:
1. [Data Loading](dataload.sql)
Downloaded files from 2025-01 to 2025-12 and converted them to gzips in order to be able to load them smoothly without worrying about file size.  
Created a new raw table and loaded all the files in one go using wildcard (*.csv.gz)

3. [Data Quality Check](dataquality.sql)
Sanity check of data, ensuring all file data were successfully loaded.  
 a. Overall: 
 
![T](/Assets/Prepresults_overall.png)
 _Combined data consists of 5,552,994 rows. Noted that the earliest dates were in 2024 and 13 distinct months detected (the extra being a small number of Dec 2024 strays, addressed below)_

 b. Monthly breakdown:

![](/Assets/Prepresults_monthly.png)  
_Caught 53 rides from 2024-12 that were captured into 2025-01 file which will be excluded during cleaning._

 c. Pre-clean check:  
   i. _non_positive_duration_ - **0.033%** - Number of rides that ended at or before they started - Likely system errors as not quite possible to be 0 even if you were to end the ride as soon as you started, that would still at least count a few seconds. Negative second rides are impossible.  
  ii. _over_24_hours_ - **0.1%** - Number of trips longer than 24 hours - Could be bikes not docked properly/users not properly ending their ride on the app or system not registering the end of the ride.  
 iii. _bad_rider_type_ - **0%** - Only two types of members so flags any rides that don't fall under these types. Clean  
  iv. _null_start_station_ - **21.3%** - Just to identify how many started not from a dock. A good to know. Kept these rows in as they are likely predominantly dockless e-bike trips and removing them would bias the member-vs-casual comparison. These rows can, however, be excluded from station-specific analysis where a named start station is required.  
   v. _duplicate_ride_ids_ - **0%** - each ride should have a unique id, flags any potential duplicates which could be bad data. Clean    

  
### 3. Process

