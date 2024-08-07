
use ProjectPortfolio;

select * from dbo.Covid_Deaths
order by 3,4;

--select * from dbo.Covid_Vaccinations
--order by 3,4;

select
	location, date , total_cases, new_cases, total_deaths, population
from dbo.Covid_Deaths
where continent is not null
order by location, date;

-- total  cases vs total deaths
-- shows likelihood of dying if you contract covid in Canada
-- keep in mind this is reported cases, so there is probably a lower death pct than shown.
select
	location, date , total_cases, total_deaths, 
	case
		when total_cases = 0 then 0
		else round((total_deaths/total_cases)*100,2) 
	end as Death_Pct 
from dbo.Covid_Deaths
where location = 'Canada'
order by location, date;


-- Total cases vs population

select
	location, date , total_cases, population, 
	case
		when total_cases = 0 then 0
		else round((total_cases/population)*100,2) 
	end as infection_pct
from dbo.Covid_Deaths
where location = 'Canada'
order by location, date;


-- Countries with highest infection rate

select
	location, population, max(total_cases) as highest_infection_count, round(max((total_cases/population)*100),2) as infection_pct
from dbo.Covid_Deaths
group by location, population
order by infection_pct desc
;


-- countries with highest death_pct

select location, max(cast(total_deaths as int)) as total_death_count
from dbo.Covid_Deaths
where continent is not null
group by location
order by total_death_count desc;

-- continents with highest death counts
select continent, max(cast(total_deaths as int)) as total_death_count
from dbo.Covid_Deaths
where continent is not null
group by continent
order by total_death_count desc;


-- Global numbers

select
	sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	case
		when sum(new_cases) = 0 then 0
		else round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) 
	end as Death_Pct 
from dbo.Covid_Deaths
where continent is not null
order by 1,2;

-- Total population vs vaccination

select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(coalesce(vac.new_vaccinations,0) as bigint)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from dbo.Covid_Deaths Dea
join dbo.Covid_Vaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null
order by 2,3;


-- use CTE
with Pop_vs_Vac as(
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(coalesce(vac.new_vaccinations,0) as bigint)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from dbo.Covid_Deaths Dea
join dbo.Covid_Vaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null)
select 
	*, round((rolling_people_vaccinated/population) * 100,3) as vac_pct
from Pop_vs_Vac
order by 2,3;


-- Create view to store data for later visualizations
create view Pct_Population_vaccinated as
(select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(coalesce(vac.new_vaccinations,0) as bigint)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from dbo.Covid_Deaths Dea
join dbo.Covid_Vaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null)

create view Peak_infection_rate_by_country as
select
	location, population, max(total_cases) as highest_infection_count, round(max((total_cases/population)*100),2) as infection_pct
from dbo.Covid_Deaths
group by location, population
;


create view Death_count_by_country as
select location, max(cast(total_deaths as int)) as total_death_count
from dbo.Covid_Deaths
where continent is not null
group by location;

create view Death_count_by_continent as 
select continent, max(cast(total_deaths as int)) as total_death_count
from dbo.Covid_Deaths
where continent is not null
group by continent;
























