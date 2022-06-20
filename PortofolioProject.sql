
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

-- Looking at 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (float, vac.new_vaccinations)) OVER (partition by dea.location) as Sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location, dea.date) as Sum_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3