SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4 

--select *
--from PortfolioProject..CovidVacciation
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, new_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population
SELECT Location, date, total_cases, Population, (Total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%korea%'
and continent is not null
order by 1,2

-- Countries with Hightest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) as HightestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

-- countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathsCount desc

--continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathsCount desc


--global numbers
SELECT SUM(new_cases) as total_cases, sum(convert(int, new_deaths)) as total_deaths, sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage--, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacciation vac
	on dea.location = vac.location
	and dea.date = vac.date

--total population vs total vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacciation vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--total population vs total vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacciation vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE

WITH PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacciation vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.Location order by dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacciation vac
	on dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacciation vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated