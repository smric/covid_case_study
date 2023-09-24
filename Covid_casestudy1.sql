use PortfolioProjects
select *
from CovidDeaths
where continent is not null 
order by 3,4
--select *
--from CovidVaccinations
--order by 3,4

--select data to be used 
select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by location, date

-- looking at total cases vs total deaths in India 
alter table CovidDeaths 
add ntotal_cases int;
alter table CovidDeaths 
add ntotal_deaths int;
update CovidDeaths
set ntotal_cases=CAST(total_cases as int);
update CovidDeaths
set ntotal_deaths=CAST(total_deaths as int);
select location,date, ntotal_cases, ntotal_deaths,
CASE 
   when ntotal_cases = 0 then NULL 
   else (ntotal_deaths*100)/NULLIF(ntotal_cases, 0)
end as death_percentage 
From CovidDeaths
where location = 'India'
and continent is not null 

--looking at total cases vs population 
alter table CovidDeaths 
add npopulation bigint; 
update CovidDeaths
set npopulation = CAST(population as bigint);
--shows what percentage got covid 
select location,date, ntotal_cases, npopulation,(ntotal_cases*100.0)/npopulation as infected_percentage 
From CovidDeaths
where location = 'India'
and continent is not null 

--looking at countries with high infection rate compared to population 
select location,MAX(ntotal_cases)as highest_infection_count,npopulation,(MAX(ntotal_cases)*100.0)/npopulation as infected_percentage 
From CovidDeaths
group by location, npopulation 
order by infected_percentage desc 


--looking at the countries with highest death count 
select location,MAX(cast(total_deaths as int))as highest_death_count
From CovidDeaths
where continent is not null 
group by location
order by highest_death_count desc 

--continents with highest death rate 
select
    NULLIF(LTRIM(RTRIM(continent)), '') as continent,
    MAX(CAST(total_deaths as int)) as highest_death_count
from CovidDeaths
where continent IS NOT NULL AND LTRIM(RTRIM(continent)) <> ''
group by NULLIF(LTRIM(RTRIM(continent)), '')
order by highest_death_count desc 

-- Global Number by date 
select date,sum(cast(new_cases as int)) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths,
CASE
  when sum(cast(new_cases as int)) = 0 then NULL
  else (sum(cast(new_deaths as int))*100.0)/sum(cast(new_cases as int)) 
end as Death_percentage 
from CovidDeaths
group by date 
-- global number 
select sum(cast(new_cases as bigint)) as total_new_cases, sum(cast(new_deaths as bigint)) as total_new_deaths,
CASE
  when sum(cast(new_cases as bigint)) = 0 then NULL
  else (sum(cast(new_deaths as bigint))*100.0)/sum(cast(new_cases as bigint)) 
end as Death_percentage 
from CovidDeaths

--Temp table 
drop table if exists #percent_population_vaccinated 
create table #percent_population_vaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population numeric, 
new_vaccination numeric, 
rolling_people_vaccinated numeric
)
insert into #percent_population_vaccinated
select  NULLIF(LTRIM(RTRIM(dea.continent)), '') as continent, dea.location, dea.date, dea.npopulation, cast(vac.new_vaccinations as bigint) as new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from CovidDeaths dea 
join CovidVaccinations vac 
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL AND LTRIM(RTRIM(dea.continent)) <> ''

select*, (rolling_people_vaccinated*100.0)/population 
from #percent_population_vaccinated 

--creating view to store data 
create view percent_population_vaccinated as 
select  NULLIF(LTRIM(RTRIM(dea.continent)), '') as continent, dea.location, dea.date, dea.npopulation, cast(vac.new_vaccinations as bigint) as new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from CovidDeaths dea 
join CovidVaccinations vac 
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL AND LTRIM(RTRIM(dea.continent)) <> ''



