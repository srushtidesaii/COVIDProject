SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccination
--ORDER BY 3,4

--SELECT THE DATA THAT WE ARE GOING TO BE USING
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES vs TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
AND Location = 'India'
ORDER BY 1,2

--LOOKING AT TOTAL CASES vs TOTAL POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT Location, date, Population, total_cases,(total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE Location = 'India'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'India'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--SHOWING THE COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'India'
WHERE continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount desc

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'India'
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE Location = 'India'
GROUP BY date 
ORDER BY 1,2 

--TOTAL DEATH PERCENTAGE ACROSS THE WORLD
SELECT SUM(new_cases) as total_cases, SUM(cast(total_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE Location = 'India'
--GROUP BY date 
ORDER BY 1,2 


SELECT *
FROM PortfolioProject.dbo.CovidVaccination

--LOOKING AT TOTAL POPULATION vs VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--we can use cte(common table expressions) or temp table also 
--A CTE (Common Table Expression) is a temporary result set( for example here it is RollingPeopleVaccinated) 
--that you can reference within another SELECT, INSERT, UPDATE, or DELETE statement.
--They were introduced in SQL Server version 2005. They are SQL-compliant and part of the ANSI SQL 99 specification. 
--A CTE always returns a result set.
--Difference between cte and temp:
--temp Tables are physically created in the tempdb database. These tables act as the normal table and also can have constraints,
--an index like normal tables. CTE is a named temporary result set which is used to manipulate the complex sub-queries data. ...
--This is created in memory rather than the Tempdb database.
WITH PopvsVac (Continent, location, date, Population, new_vaccination, RollingPeopleVaccinated)
as
(
SELECT  dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as
SELECT  dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated



