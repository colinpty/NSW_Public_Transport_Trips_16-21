# NSW Public Transport Passenger Trips 2016-2021

The database counts real every passenger trips that occured for each mode of public transport within the state of New South Wales (NSW), Australia per month and per year from July 2016 to July 2021.

Thanks to NSW Government for publishing the data in public and allowing us to query the data. 


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

### What were the busiest months for NSW Buses from 2016 to 2021?
The code i created adds all the trips per month in order from busiest to the quietest month. 
Results show March was the busiest month while April was the quietest month to travel on NSW Buses. 

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

```
SELECT EXTRACT(MONTH FROM transport_month) months, SUM (bus) as trips
FROM transport_modes
GROUP BY months
ORDER BY trips DESC;
```



