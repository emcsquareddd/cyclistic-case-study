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
Note: Data owned by the City of Chicago and made publicly available by Lyft Bikes and Scooters, LLC under the [Divvy Data License Agreement](https://divvybikes.com/data-license-agreement). Please also note that Divvy pre-processes this data before release, removing staff service/inspection trips and same-station trips under 60 seconds, so those are already absent from the raw files.

Tools used: 
BigQuery - Utilising SQL for data processing & cleansing  
Tableau - Data visualisation

Data prep:
1. [Data Loading](01_dataload.sql)
Downloaded files from 2025-01 to 2025-12 and converted them to gzips in order to be able to load them smoothly without worrying about file size.  
Created a new raw table and loaded all the files in one go using wildcard (*.csv.gz)

3. [Data Quality Check](02_dataquality.sql)
Sanity check of data, ensuring all file data were successfully loaded.  
 a. Overall: 
 
![T](/Assets/Prepresults_overall.png)
 _Combined data consists of 5,552,994 rows. Noted that the earliest dates were in 2024 and 13 distinct months detected (the extra being a small number of Dec 2024 strays, addressed below)_  

 b. Monthly breakdown:

![](/Assets/Prepresults_monthly.png)  
_Caught 53 rides from 2024-12 that were captured into 2025-01 file which will be excluded during cleaning._

 c. Pre-clean check:  

 ![](/Assets/Pre-check.png)  
 
   i. _non_positive_duration_ - **0.033%** - Number of rides that ended at or before they started - Likely system errors as not quite possible to be 0 even if you were to end the ride as soon as you started, that would still at least count a few seconds. Negative second rides are impossible. Will exclude during cleaning
   
  ii. _very_short_trips_ - **2.62%** - Number of rides that were sub-60 seconds. Looked into below
  
 iii. _over_24_hours_ - **0.1%** - Number of trips longer than 24 hours - Could be bikes not docked properly/users not properly ending their ride on the app or system not registering the end of the ride.  
 
  iv. _bad_rider_type_ - **0%** - Only two types of members so flags any rides that don't fall under these types. Clean  
  
   v. _null_start_station_ - **21.3%** - Just to identify how many started not from a dock. A good to know. Kept these rows in as they are likely predominantly dockless e-bike trips and removing them would bias the member-vs-casual comparison. These rows can, however, be excluded from station-specific analysis where a named start station is required.  
   
  vi. _duplicate_ride_ids_ - **0%** - each ride should have a unique id, flags any potential duplicates which could be bad data. Clean    
  

 Dived deeper into _very_short_trips_ for more information.   

 ![](/Assets/Sub60.png)   
 
   i. _same_station_ - **20% of sub-60 total** - Divvy's page states they remove sub-60-second false starts, yet 29,161 same-station sub-minute trips remain in the released data, so their upstream filter is either narrower or less complete than described. These are most certainly false starts or someone rejecting a faulty bike so I think it'd be reasonable to exclude during data cleaning.  
   
  ii. _different_station_ - **1.5% of sub-60 total** - likely actual short rides around the block thus will include these for analysis.  
  
 iii. _null_station_ - **78.5% of sub-60 total** - unable to classify whether these were false starts or actually short rides that the bikes weren't docked. As there's no positive reason to remove them, they will be included for analysis.  

Also checked for test/maintenance stations; none were present in the released data.  


Two exclusion rules carry into the cleaning phase: non-positive-duration rides, and same-station sub-60-second trips (false starts). Notably, null-start-station rides and different-station short trips are deliberately retained, as removing them would bias the member-versus-casual comparison.
 
  
### 3. Process  

[Data Clean](03_dataclean.sql):

During cleaning I ran a reconciliation check: the pre-clean counts predicted 36,636 removals, but the query removed 150,834. Investigating the ~114k gap, I found the same-station exclusion rule (start_station_name = end_station_name) was silently dropping null-station rows, because in SQL a comparison involving NULL evaluates to "unknown" rather than false, so those rows failed the WHERE clause against intent. I fixed it by adding AND start_station_name IS NOT NULL so the rule only fires on genuine same-station trips, then verified that 88,072 null-station short trips were correctly retained and the removal total reconciled fully.

**Before (buggy)**   
![](/Assets/before_query_bug.png)  

**After (fixed)**  
![](/Assets/after_query.png)  

In total, 62,762 rows were removed, leaving 5,490,232 clean rows ready for analysis.  

### 4. Analyse

For analysis, I looked into 6 angles:

1. How many rides, and how long, for each group? 
