
--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--

Select *
From PortofolioProject..CovidDeaths
Order By 3,4

Select *
From PortofolioProject..CovidDeaths
where continent is not null
Order By 3,4

--Select *
--From PortofolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if contract covid in the country

Select Location, date, total_cases, total_deaths, (cast (total_deaths as float)/cast (total_cases as float))*100 as death_percentage
From PortofolioProject..CovidDeaths
Where location='indonesia'
order by 1,2

Select Location, date, total_cases, total_deaths, (cast (total_deaths as float)/cast (total_cases as float))*100 as death_percentage
From PortofolioProject..CovidDeaths
Where location like '%south%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population got covid

Select Location, date, total_cases, population, (cast (total_cases as float)/cast (population as float))*100 as infected_percentage
From PortofolioProject..CovidDeaths
Where location='japan'
order by 1,2

-- Looking at countries with highest infection percentage rate

Select Location, population, MAX(total_cases) as highest_infection_count, MAX(cast (total_cases as float)/cast (population as float))*100 as infected_percentage
From PortofolioProject..CovidDeaths
Group by location, population
order by infected_percentage DESC

-- Looking at countries and continent with highest death count per population

Select Location, MAX(cast(total_deaths as float)) as total_death_count
From PortofolioProject..CovidDeaths
Group by location
order by total_death_count DESC

Select continent, MAX(cast(total_deaths as float)) as total_death_count
From PortofolioProject..CovidDeaths
Group by continent
order by total_death_count DESC

Select location, MAX(cast(total_deaths as float)) as total_death_count
From PortofolioProject..CovidDeaths
where continent is null
Group by location
order by total_death_count DESC

-- GLobal numbers & some country numbers for new case, new deaths and total case per days

Select date, SUM(cast (new_cases as float)) as total_cases
From PortofolioProject..CovidDeaths
where total_cases is not null
Group by date
order by date ASC

Select date, SUM(cast (total_cases as float)) as total_cases
From PortofolioProject..CovidDeaths
where total_cases is not null
Group by date
order by date ASC

Select date, SUM(cast (new_cases as float)) as new_cases, SUM(cast (new_deaths as float)) as new_deaths, sum(cast (total_cases as float)) as total_cases
From PortofolioProject..CovidDeaths
where total_cases is not null
and location='indonesia'
group by date
order by date ASC

-- Looking for death_percentage per days & recent count

Select date, SUM(cast (new_cases as float)) as new_cases, SUM(cast (new_deaths as float)) as new_deaths,
(SUM(cast (new_deaths as float))/SUM(cast (new_cases as float)))*100 as death_percentage
From PortofolioProject..CovidDeaths
Where continent is not null
Group by date
order by date

Select SUM(cast (new_cases as float)) as new_cases, SUM(cast (new_deaths as float)) as new_deaths,
(SUM(cast (new_deaths as float))/SUM(cast (new_cases as float)))*100 as death_percentage
From PortofolioProject..CovidDeaths
--Where continent is not null


--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--0--




-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations--,
--SUM(vac.new_vaccinations) OVER (partition by dea.location
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by date

-- Looking at total vaccinations in the world overall

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as float)) OVER () as Sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (float, vac.new_vaccinations)) OVER (partition by dea.location) as Sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3



-- 1. USE CTE

with population_vs_vac (continent, location, date, population, new_vaccinations, sum_vaccinations) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location, dea.date) as sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3
)
select *,
(sum_vaccinations/population)*100 as sum_vaccinations_percentage
from population_vs_vac
order by 2,3



-- 2. TEMP TABLE

DROP table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
Sum_vaccinations numeric
)

INSERT INTO #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (float, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null

select *,
(sum_vaccinations/population)*100 as sum_vaccinations_percentage
from #percent_population_vaccinated
order by 2,3



-- Creating view to store data for later visualizations (tableau)

create view percent_populations_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (float, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null

sp_refreshview percent_populations_vaccinated

drop view percent_populations_vaccinated

select top 10 * from percent_populations_vaccinated



-- now this data is for tableau
--- 1

create view avg_death_percentage as
select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths,
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as death_percentage
from PortofolioProject..CovidDeaths
where continent is not null
--order by 1,2

sp_refreshview avg_death_percentage



-- 2

create view total_death_count as
select location, sum(cast(new_deaths as float)) as total_death
from PortofolioProject..CovidDeaths
where continent is null
and location not in ('world', 'european union', 'international', 'upper middle income', 'high income', 'low income', 'lower middle income')
group by location
--order by total_death desc



-- 3

create view percentage_infected as
select location, population, max(cast(total_cases as float)) as highest_infection_count, max(cast(total_Cases as float)/population)*100 as percent_population_infected
from PortofolioProject..CovidDeaths
group by location, population
--order by percent_population_infected desc









