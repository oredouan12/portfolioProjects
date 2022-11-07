--select * from portfolio.dbo.covidvaccination
--ORDER BY 3, 4

select * from portfolio.dbo.covideaths
ORDER BY 3, 4

-- Select the Data that we are going to be using

select location, date, total_cases, total_deaths, population
from portfolio.dbo.covideaths
order by 1, 2

-- removing all data with no location

delete from portfolio.dbo.covideaths
WHERE location IS NULL;

-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_percentage
FROM portfolio.dbo.covideaths
ORDER BY 1, 2

-- shows likelihood od dying if you contract covid in united state

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_percentage
FROM portfolio.dbo.covideaths
WHERE location like'%state%'
ORDER BY 1, 2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid

SELECT location, date,  population, total_cases, (total_cases/population)*100 as Deaths_percentage
FROM portfolio.dbo.covideaths
WHERE location like'%state%'
ORDER BY 1, 2




-- Looking at Countries With highest infection rate compared to population

SELECT location,  population, max(total_cases) as highestinfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio.dbo.covideaths
--WHERE location like'%state%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing the Countries With the Highest Death Count per Population

SELECT location,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio.dbo.covideaths
--WHERE location like'%state%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio.dbo.covideaths
--WHERE location like'%state%'
WHERE continent is NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC



-- Showing the continent with the highest death count per population

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolio.dbo.covideaths
--WHERE location like'%state%'
WHERE continent is NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_New_cases, SUM(cast(new_deaths as int)) AS total_new_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM portfolio.dbo.covideaths
--WHERE location like'%state%'
WHERE continent is NOT NULL
GROUP BY  date
ORDER BY 1, 2


SELECT SUM(new_cases) AS total_New_cases, SUM(cast(new_deaths as int)) AS total_new_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM portfolio.dbo.covideaths
--WHERE location like'%state%'
WHERE continent is NOT NULL
--GROUP BY  date
ORDER BY 1, 2


-- Looking at total population Vs Vaccination
-- USE CTE

WITH PopVsvac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolio.dbo.covideaths AS dea
join portfolio.dbo.covidvaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3 
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsvac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolio.dbo.covideaths AS dea
join portfolio.dbo.covidvaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
DROP VIEW if exists PercentPopulationVaccinated 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- , SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from portfolio.dbo.covideaths AS dea
join portfolio.dbo.covidvaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3 