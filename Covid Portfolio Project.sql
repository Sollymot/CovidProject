use [Covid Portfolio Project]


select * from dbo.CovidDeaths
order by 3,4

select * from dbo.CovidVaccinations
order by 3,4

-- Select Data to be used
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood of dying through Covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Lokking at the total cases vs the population
-- shows what percentage of population got covid
select location, date,  population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from dbo.CovidDeaths
--where location like '%nigeria%'
where continent is not null
order by 1,2


--Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
from dbo.CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by population, location
order by PercentPopulationInfected desc


-- Let's break things down by continent


-- Showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(total_cases) * 100 as 
DeathPercentage
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total population vs Vaccination

--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccination/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac



-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccination/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Create View to store data for later visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccination/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated