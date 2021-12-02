
-- 1. Show data in two tables


declare @n as bigint = 5
select top (@n)* from test..disaster1 
order by 1,2


select * from test..disaster2
order by 1,2
offset 50 rows fetch next 10 rows only --offset used to show data from 60 rows to 69 rows


-- 2. look at the total deaths vs. total affected
-- shows the death rate of each countries

select dis_no,total_deaths, total_affected, round((total_deaths/total_affected)*100,3) as death_rate
from test..disaster2
order by dis_no


--3. aggregate the number_of_country based on continent and region

select country, region, continent, location  
from test..disaster1

select continent, region, count(country) as number_of_country
from test..disaster1
group by continent, region
order by continent


--4. Calculate the number_of_country, total deaths based on continent, region
select a.continent, a.region, count(a.country) as number_of_country, sum(b.total_deaths) as total_deaths
from test..disaster1 a
join test..disaster2 b
on a.Dis_No = b.Dis_No
group by a.continent, a.region


--5. looking for the total_deaths, total_affected in the United States
select a.continent, a.country, sum(b.total_deaths) as total_deaths, sum(b.total_affected) as total_affected
from test..disaster1 a
join test..disaster2 b
on a.Dis_No = b.Dis_No
where country like '%states%'
group by a.continent, a.country


--6. Shows disaster group and total deaths based on countries
select a.country, a.Disaster_Subgroup, sum(b.total_deaths) as total_deaths
from test..disaster1 a
join test..disaster2 b
on a.Dis_No = b.Dis_No
group by a.country, a.Disaster_Subgroup
order by a.country


--7. Sum up the total damages which was caused by flood
select sum(Total_Deaths)
from test..disaster2 
where dis_no in 
     (select dis_no 
	  from test..disaster1 
	  where Disaster_Type = 'flood')


--8. Sum up the total damages(US$), total deaths, total affected based on different regions in Ameicas

select distinct a.continent, a.region, sum(b.[Total_Damages(US$)]) over (partition by a.region order by a.region) as total_damages,
sum(b.[Total_deaths]) over (partition by a.region) as total_damages,
sum(b.[Total_Affected]) over (partition by a.region) as total_damages
from test..disaster1 a
join test..disaster2 b
on a.Dis_No = b.Dis_No
where a.continent = 'Americas'
order by a.region


--9. 

With C(continent, region, total_damages, total_deaths, total_affected)
As 
(
select distinct a.continent, a.region, sum(b.[Total_Damages(US$)]) over (partition by a.region order by a.region) as total_damages,
sum(b.[Total_deaths]) over (partition by a.region) as total_deaths,
sum(b.[Total_Affected]) over (partition by a.region) as total_affected
from test..disaster1 a
inner join test..disaster2 b
on a.Dis_No = b.Dis_No
where a.continent = 'Americas')
select * 
from C


--10. create table to save total damages, total deaths and total affected in Americas

Drop table if exists AmericasData
create table AmericasData(
Continent nvarchar(255),
Region nvarchar(255),
Damages numeric,
Deaths numeric,
Affected numeric)

insert into AmericasData
select distinct a.continent, a.region, sum(b.[Total_Damages(US$)]) over (partition by a.region order by a.region) as total_damages,
sum(b.[Total_deaths]) over (partition by a.region) as total_deaths,
sum(b.[Total_Affected]) over (partition by a.region) as total_affected
from test..disaster1 a
inner join test..disaster2 b
on a.Dis_No = b.Dis_No
where a.continent = 'Americas'

select * from AmericasData


--11. Create view to store total damages, total deaths and total affected in Americas

drop view if exists V_AmericasData;
go
create view V_AmericasData as 
select distinct a.continent, a.region, sum(b.[Total_Damages(US$)]) over (partition by a.region order by a.region) as total_damages,
sum(b.[Total_deaths]) over (partition by a.region) as total_deaths,
sum(b.[Total_Affected]) over (partition by a.region) as total_affected
from test..disaster1 a
inner join test..disaster2 b
on a.Dis_No = b.Dis_No
where a.continent = 'Americas'