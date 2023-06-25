use bellabeat_database;

-- checking count of distinct ids in each table------------------------------------------------------------

select *  from dailyactivity_merged;
select count(*) from heartrate_sec;

select count(distinct Id) from heartrate_sec; 

/* dailyactivity_merged: 33
   heartrate_sec: 14
   hourlycalories_merged: 33
   hourlysteps_merged: 33
   hourlyintensities_merged: 33
   met_min: 33
   sleepday_merged: 24
   weight_merged: 8
*/

/* checking tables with less users whether those user are
    same which were present in  dailyactivity_merged table*/


SELECT COUNT(DISTINCT dailyactivity_merged.id) 
FROM dailyactivity_merged
INNER JOIN weight_merged
ON dailyactivity_merged.id = weight_merged.id;
/*  heartrate_sec has same 14 users which are in dailyactivity)merged table.
    24 same for sleepday_merged
    8 same for weight_merged
*/



-- Checking Duplicates -----------------------------------------------------------------------------------------

SELECT ID, COUNT(*) 
FROM dailyactivity_merged
GROUP BY ID
HAVING COUNT(*) > 1;

SELECT ID, count(*)  
FROM dailyactivity_merged
GROUP BY ID, ActivityDate
HAVING COUNT(*) > 1;

/* no duplicates for this table, but we have found some 
   users don't use smart device for all 30 days. 
   So now check how many distict days categories we have.
*/


SELECT distinct(count(*)) As Logged_days
FROM dailyactivity_merged
GROUP BY ID;


SELECT distinct(count(*)) As Logged_days, id
FROM dailyactivity_merged
GROUP BY ID; 

/* from the above quries data we can find, 
how frequently people are using their devices
*/

create temporary table mytemp As (
SELECT distinct(count(*)) As Logged_days, id
FROM dailyactivity_merged
GROUP BY ID
);

select Logged_days, count(id) As people_count
from mytemp
Group by Logged_days;

-------------------------------------------------------

select count(*) from weight_merged;
select * from weight_merged;

-- checking duplicates for weight_merged table
SELECT ID, COUNT(LogId) 
FROM weight_merged
GROUP BY ID
HAVING COUNT(*) > 1;

/* This is suggesting that only two users have  
   significant entry in weight table which is 24 and 30 times in
   a month.
 */
 
SELECT id, count(*)
FROM weight_merged
GROUP BY ID, LogId
HAVING COUNT(*) > 1;

/* no items in the result. Hence, we can say that there
   are no duplicate rows in weight_merged table.  
*/
 
/*now there is a fat column in weight table which is almost
   empty, so we can conclude that fat feature is not being 
   used in the fitbit. only 2 out of 67 user use this feature. 
*/
select count(*) from weight_merged where fat!=""; 
-- --------------------------------------------------------

-- checking duplicacy for all the other tables

-- met_min
select ID, count(*)  
FROM met_min
GROUP BY ID, ActivityMinute
HAVING COUNT(*) > 1;
/* no duplicates */

-- ----------------------------------------------------------
-- sleepday_merged
select count(*) from sleepday_merged;
select * from sleepday_merged;
 
select *
from sleepday_merged
group by SleepDay,id, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
having count(*)>1;
 
/* there are 3 duplicate rows in above data, so now we need to 
   remove them
*/

-- Removing duplicate rows from the table

create table new_sleepday_merged 
AS
select distinct * from sleepday_merged;

drop table sleepday_merged;

alter table new_sleepday_merged rename to sleepday_merged;

-- now we can again confirm duplicacy by below code. 
select *
from sleepday_merged
group by SleepDay,id, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
having count(*)>1;

-- this time no duplicate rows for this table.
-- ---------------------------------------------------------------

-- now maybe we can merge three hourly tables into one. 
-- check tables first.

select count(*) from hourlysteps_merged;
/*   hourlycalories_merged = 22099 (count)
     hourlyintensities_merged = 22099 (count)
     hourlysteps_merged = 22099 (count)
*/

-- we are almost good to go.
-- but, first check for duplicay in each table.

select * from hourlycalories_merged;

select id, count(*) 
from hourlycalories_merged
group by Id, ActivityHour
having count(*)>1;

/* no values in the result. so there is no duplicay in the table. */

-- now we can go ahead and merge all 3 hourly tables. 
select * from hourlysteps_merged;
CREATE TABLE hourly_calories_intensities_steps AS
select hcm.id, hcm.activityhour, hcm.Calories, him.Totalintensity, 
	   him.averageIntensity, hsm.steptotal
from hourlycalories_merged as hcm
inner join hourlyintensities_merged as him
on hcm.id = him.id and hcm.activityhour = him.activityhour
inner join hourlysteps_merged as hsm
on him.id = hsm.id and him.activityhour = hsm.activityhour;

/* now the total number of rows should be same as individual tables. 
then  only we can say there were no missing values in all three 
tables and all 3 tables has same primary composite key which is
combination of id and activityhour. 
So, let's check total rows for this new table.
*/

select count(*)
from hourlycalories_merged as hcm
inner join hourlyintensities_merged as him
on hcm.id = him.id and hcm.activityhour = him.activityhour
inner join hourlysteps_merged as hsm
on him.id = hsm.id and him.activityhour = hsm.activityhour;

-- now it is 22099 which is same as individual tables. 
/* Hence, we can say that our merge is successful. Thus, we can
   create a new table now and then delete old hourly tables. 
*/

create table hourly_calories_itensity_steps
as
select count(*)
from hourlycalories_merged as hcm
inner join hourlyintensities_merged as him
on hcm.id = him.id and hcm.activityhour = him.activityhour
inner join hourlysteps_merged as hsm
on him.id = hsm.id and him.activityhour = hsm.activityhour;



drop table hourlycalories_merged;
drop table hourlyintensities_merged;
drop table hourlysteps_merged;

-- ----------------------------------------------------
-- Now checking for null or missing values

select * from dailyactivity_merged;

select * from dailyactivity_merged
where id is null;


-- -----------------------------------------------------------

select * from dailyactivity_merged;

-- check totalSteps column

select count(id), totalSteps
from dailyactivity_merged
where totalSteps=0;

select count(distinct id)
from dailyactivity_merged
where totalSteps=0;

/* there are total 15 distict users (almost half of the users)
   who do not use their device
   consistenlty for counting steps. because there are total 
   77 time when the Total steps taken by the user is 0. 
   Resons might be, their is not enough battery backup of device. 
   or long charging time or maybe some usere might not find this 
   accurate. 
   */
   
-- check LoggedActivitiesDistance 

select count(id)
from dailyactivity_merged
where LoggedActivitiesDistance!=0;

-- --------------------------------------------------------








   

   


