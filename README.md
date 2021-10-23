# NSW Public Transport Passenger Trips 2016-2021

The database counts real every passenger trips that occured for each mode of public transport within the state of New South Wales (NSW, Australia) per month and per year from July 2016 to July 2021.

## How to Install

1. Create a new blank database in Postgres.  
	`CREATE DATABASE nsw_transport;`

2. Run the code in the **CREATE_TABLE.sql** file to create the table in the database.

3. Run the code in the **INSERT_DATA.sql** file to insert data in the table. 

4. Have fun querying real world data. 






## Case Scenarios


### How did covid impact passenger numbers public transport?
I created the CTE below to show that covid caused a huge decline in passenger numbers.
Results show the Ferry service had the biggest drop during covid with 56.39% less passengers compared to prior covid years. 

| Bus    | Ferry  | Train  |
| -------|:------:| ------:|
| 43.22% | 56.39% | 48.75% |



``` 
WITH cte_before AS (
SELECT 
CAST(EXTRACT(YEAR FROM transport_month) AS INTEGER) as pick_year, SUM(bus) as old_Bus, SUM(ferry) as old_Ferry, SUM(train) as old_Train
FROM transport_modes
WHERE CAST(EXTRACT(YEAR FROM transport_month) AS INTEGER) = 2019
GROUP BY pick_year
),
    cte_covid AS (
    SELECT 
    CAST(EXTRACT(YEAR FROM transport_month) AS INTEGER) as pick_year, SUM(bus) as covid_Bus, SUM(ferry) as covid_Ferry, SUM(train) as covid_Train
    FROM transport_modes
    WHERE CAST(EXTRACT(YEAR FROM transport_month) AS INTEGER) = 2020
    GROUP BY pick_year
)
select  round((SUM(old_Bus) - SUM(covid_Bus)) / SUM(old_Bus) * 100, 2) as Bus,
        round((SUM(old_Ferry) - SUM(covid_Ferry)) / SUM(old_Ferry) * 100, 2) as Ferry,
        round((SUM(old_Train) - SUM(covid_Train)) / SUM(old_Train) * 100, 2) as Train 
from cte_before
FULL join cte_covid on cte_covid.pick_year = cte_before.pick_year;
```

### What were the busiest months of the year for NSW Buses from 2016 to 2021?
The code i created adds all the trips per month in order from busiest to the quietest month. 
Results show March was the busiest month while April was the quietest month to travel on NSW Buses. 

```
SELECT EXTRACT(MONTH FROM transport_month) months, SUM (bus) as trips
FROM transport_modes
GROUP BY months
ORDER BY trips DESC;
```

| Months |  Trips    |
|--------|:---------:|
| 3.0	 | 118837705 |
| 11.0	 | 117802749 |
| 8.0	 | 117792589 |
| 10.0	 | 113467188 |
| 2.0	 | 112234587 |
| 7.0	 | 110433013 |
| 9.0	 | 109928871 |
| 5.0	 | 107127168 |
| 12.0	 | 100960483 |
| 6.0	 | 96682791  |
| 1.0	 | 96065270  |
| 4.0	 | 89206193  |

### What would be the peak month for NSW Trains from 2016 to 2021?
The CTE that i created shows August would be considered the peak month for NSW Trains with 151,706,197 passenger trips. 
| peak_month |  train_trips    |
|------------|:---------------:|
| 8.0	     | 151706197       |

```
WITH cte_peak_month AS (
                SELECT EXTRACT(MONTH FROM transport_month) peak_month, SUM (train) as train_trips
                FROM transport_modes
                GROUP BY peak_month)
                            SELECT peak_month, train_trips
                            from cte_peak_month
                            where train_trips = (select max(train_trips)  from cte_peak_month);
```
### Can you create a function that finds the specific amount of Ferry trips for that particular month?
The select statement below uses the function to show 609,963 passengers travelled in March 2021.
```
create or replace function get_trips_count(transport_date date)
    returns table (
        	ferry_trips_total int
    ) 
    language plpgsql
as $$
	begin
	    return query 
	    select ferry from transport_modes
	    where transport_month = transport_date;
	end;
$$;
```
`select get_trips_count ('2021-03-01');
`
| get_trips_count | 
|-----------------|
| 609963	  | 
### Can you create a function that selects a mode of transport and finds passenger trips for a particular month?
The select statement below uses the function to show 17,765,453 passengers travelled on NSW Trains in February 2021.
```
CREATE OR REPLACE FUNCTION get_trips_count(transport_date date, p_column text) 
  RETURNS INT 
AS
$$
declare 
  l_result INT;
	begin
	  execute format('SELECT %I FROM transport_modes WHERE transport_month = $1', p_column) 
	     using transport_date
	     into l_result;
	  return l_result;
	end;     
$$
LANGUAGE plpgsql;
```
`select get_trips_count ('2021-02-01', 'train');
`
| get_trips_count | 
|-----------------|
| 17765453	  | 


***

Thanks to NSW Government for publishing the data in public and allowing us to query the data.


