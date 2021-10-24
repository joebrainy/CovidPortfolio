select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at the total cases vs total deaths
-- shows likelihood of dying if you contract 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
and location like '%Ghana%'
order by 1,2

-- Looking at total cases vs population
-- Percentage of population that got covid
select location, date, population, total_cases, (total_cases/ population)*100 as CovidIncfectedPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Ghana%'
order by 1,2


--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighesInfectionCount, max((total_cases/ population))*100 as CovidInfectedPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Ghana%'
Group by location, population
order by 4 desc


--Looking at countries with highest death rate compared to population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Ghana%'
Group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
--Right Way
--select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths$
--where continent is null
--and location not like '%World%'
--and location not like '%International%'
----where location like '%Ghana%'
--Group by location
--order by TotalDeathCount desc

-- Continent with the Highest Death Count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Ghana%'
Group by continent
order by TotalDeathCount desc


-- Global Numbers
--Total Cases
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
-- location like '%Ghana%'
--group by date
order by 1,2

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
-- location like '%Ghana%'
group by date
order by 1,2

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date


	--Looking at Total Population vs vaccinations

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- location like '%Ghana%'
--group by date
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
-- location like '%Ghana%'
--group by date
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating View to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- location like '%Ghana%'
--group by date
--order by 2,3

select *
from PercentPopulationVaccinated