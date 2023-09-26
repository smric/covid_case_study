-- for visualisation 
use PortfolioProjects
select sum(cast(new_cases as bigint)) as total_new_cases, sum(cast(new_deaths as bigint)) as total_new_deaths,
CASE
  when sum(cast(new_cases as bigint)) = 0 then NULL
  else (sum(cast(new_deaths as bigint))*100.0)/sum(cast(new_cases as bigint)) 
end as Death_percentage 
from CovidDeaths

select location,sum(cast(total_deaths as bigint))as total_death_count
From CovidDeaths
where continent is not null 
and location not in ('World','High income','Upper middle income','Lower middle income','Low income')
group by location
order by total_death_count desc 

select location,MAX(ntotal_cases)as highest_infection_count,npopulation,(MAX(ntotal_cases)*100.0)/npopulation as infected_percentage 
From CovidDeaths
group by location, npopulation 
order by infected_percentage desc 

select location,MAX(ntotal_cases)as highest_infection_count,npopulation,date, (MAX(ntotal_cases)*100.0)/npopulation as infected_percentage 
From CovidDeaths
group by location, npopulation, date 
order by infected_percentage desc 
