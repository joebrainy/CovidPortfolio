Select *
From PortfolioProject2..CovidDeaths$
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject2..CovidVaccinations$
--Order by 3,4


--Select Data that we are going to use

Select location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths$
where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths (likelihood of you dying if you contract covid in your country)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths$
where continent is not null
--where location like '%canada%'
Order by 1,2


--Looking at Total Cases vs Popultation (What percentage of population got Covid)

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject2..CovidDeaths$
where continent is not null
--where location like '%canada%'
Order by 1,2


--Looking at countries with highest infection rate compared to infections

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject2..CovidDeaths$
where continent is not null
--where location like '%canada%'
Group by Location, Population
Order by PercentagePopulationInfected desc


--Countries with the highest death counts per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths$
where continent is not null
--where location like '%canada%'
Group by Location
Order by TotalDeathCount desc


--Breaking things down by continent


--Showing continent with the higest death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths$
where continent is not null
--where location like '%canada%'
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int))/ SUM(New_cases)*100 -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths$
Where continent is not null
--and location like '%canada%'
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations
--Rolling Numbers

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths$ dea
Join PortfolioProject2..CovidVaccinations$ vac
	on dea.location  = vac.location
	and dea.date  = vac.date
Where dea.continent is not null
Order by 2,3


--CTE (Temp Table)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths$ dea
Join PortfolioProject2..CovidVaccinations$ vac
	on dea.location  = vac.location
	and dea.date  = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac






--CTE (Temp Table) 2
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths$ dea
Join PortfolioProject2..CovidVaccinations$ vac
	on dea.location  = vac.location
	and dea.date  = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VIZ

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths$ dea
Join PortfolioProject2..CovidVaccinations$ vac
	on dea.location  = vac.location
	and dea.date  = vac.date
Where dea.continent is not null
--Order by 2,3

select *
From PercentPopulationVaccinated