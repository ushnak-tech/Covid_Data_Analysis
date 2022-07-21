show databases;
use portfolio_project;

/*getting to know our data*/

show tables;
select * from coviddeaths;
select count(*) from coviddeaths;  -- total rows 
select count(*) from covidvaccinations;
desc coviddeaths;

-- adding another column of date with date as a datatype cuz the previous date column was in text datatype 
alter table coviddeaths add column date_2 date;
 update coviddeaths
 set date_2= STR_TO_DATE(date, "%m/%d/%Y");

select * from coviddeaths
limit 20000;

desc covidvaccinations;
select * from covidvaccinations
limit 2000 ;

-- Analyzing data
select max(date_2) from coviddeaths;
-- we have data from 1st january 2020 to 30th April 2021

-- 1. total death ratio to total cases
select location, sum(new_cases) Total_cases , sum(new_deaths) Total_Deaths, concat(round(sum(new_deaths)/sum(new_cases)*100,2),'%') Death_Ratio
from coviddeaths
where continent!=''
group by location
order by Death_Ratio desc;

-- 2. let's see the death ratio for india and its neighbouring countries
select location,population, sum(new_cases) Total_cases , sum(new_deaths) Total_Deaths, concat(round(sum(new_deaths)/sum(new_cases)*100,2),'%') Death_Ratio
from coviddeaths
where location='India' 
or location='Pakistan'
or location='Bangladesh'
or location='China'
or location='Afghanistan'
or location='Sri Lanka'
or location='Nepal'
group by location
order by Death_Ratio desc;

-- 3. lets see in afghanistan
select location,date_2, total_cases , total_deaths, concat(round((total_deaths/total_cases)*100,2),'%') Death_Ratio
from coviddeaths
where location='Afghanistan'
order by date_2 asc, Death_Ratio desc; 

-- 4. total cases vs population 
select location, population, sum(new_cases),round((sum(new_cases)/population)*100,2) Infection_Ratio
from coviddeaths
where continent!=''
group by location
order by Infection_Ratio desc;

-- india
select location,date_2, population, total_cases , concat(round((total_cases/population)*100,5),'%') Infected_Ratio
from coviddeaths
where location='India'
order by date_2 asc, Infected_Ratio desc;

-- 5. countries with highest death percentage per population
select location, population, sum(new_deaths),round((sum(new_deaths)/population)*100,2) Death_percentage
from coviddeaths
where continent!=''
group by location
order by Death_percentage desc;

-- 6. lets break down by continents----------
select continent, sum(population), sum(new_deaths)
from coviddeaths
where continent!=''
group by continent;

-- 7. Let's see the weekly hospital admission in different location
select location, date_2, total_cases, weekly_hosp_admissions, total_deaths
from coviddeaths
where weekly_hosp_admissions!='';

-- 8. continents with highest death count per population-------
 select continent, sum(population) Total_Population, sum(new_deaths) Total_Deaths, sum(new_deaths)/sum(population) Death_Percentage
from coviddeaths
where continent!=''
group by continent;

-- 9. LOOKING AT GLOBAL NUMBERS
select date_2, sum(new_cases) Total_case, sum(new_deaths) Total_Deaths, (sum(new_deaths)/ sum(new_cases))*100 DeathPercentage
from coviddeaths
where continent!=''
group by date_2
order by date_2;

select * from covidvaccinations
limit 100;

-- adding another column of date with date as a datatype cuz the previous date column was in text datatype in covidvaccinations table
alter table covidvaccinations add column date_2 date;

 update covidvaccinations
 set date_2= STR_TO_DATE(date, "%m/%d/%Y");
 
 -- 10. joining both the tables for further analysis----------
-- creating a view 
 create or replace view covid_data
 as
 select d.iso_code,d.continent,d.location,d.population,d.date_2,d.new_cases,d.total_cases,d.new_deaths,d.total_deaths,
 v.new_tests,v.total_tests,v.total_vaccinations,v.people_vaccinated,v.people_fully_vaccinated,
 v.new_vaccinations,v.gdp_per_capita,v.extreme_poverty,v.human_development_index,v.female_smokers,v.male_smokers,v.cardiovasc_death_rate
 from coviddeaths d
 join covidvaccinations v on
d.location=v.location
and d.date_2=v.date_2
where d.continent!='';

-- 11. total vaccinations achieved by the end of 30th april 2021 by location---------
select location, population, date_2, new_vaccinations, sum(new_vaccinations) over (partition by location) Total_vaccinations
from covid_data;

-- 12. number of people got vaccinated by location---------
select location, population, date_2,people_vaccinated,people_fully_vaccinated, sum(new_vaccinations) over (partition by location order by location, date_2) Total_vaccinations
from covid_data; -- this is known as rolling count

-- 13. percentage of population got vaccinated by the end of April 2021----
select location,population, sum(new_vaccinations) Total_vaccinations,(sum(new_vaccinations)/population*100) Vaccination_rate
from covid_data
group by location
order by vaccination_rate desc;

-- there you see is a problem for some countries like afghanistan like we dont have any records 
-- for new vaccinations but there is total of 2 lakhs people who got vaccinated towards the end of april 2021
-- and total vaccinations is actually the sum of people vaccinated + people_fully_vaccinated 

-- There are certain countries whose total vaccination counts is higher than the population
-- 14. countries where total_vaccination has some count but people_vaccinated is 0
select location, max(cast(total_vaccinations as unsigned)) Total_vacinations, sum(people_vaccinated) People_vaccinated
from covid_data
group by location
having sum(people_vaccinated)=0 ;

-- 15. Countries with no vaccinations at all
select location, max(cast(total_vaccinations as unsigned)) Total_vacinations, sum(people_vaccinated) People_vaccinated, sum(new_vaccinations) Vaccinations
from covid_data
group by location
having max(cast(total_vaccinations as unsigned))=0;

-- 16.  gdp per capita vs total_vaccinations
select location, population,max(cast(total_vaccinations as unsigned)), max(gdp_per_capita),(max(cast(total_vaccinations as unsigned))/population)*100 Vaccination_rate
from covid_data
group by location
having (max(cast(total_vaccinations as unsigned))/population)*100<=100;



