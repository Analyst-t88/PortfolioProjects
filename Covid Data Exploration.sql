/*
Covid-19 Data Exploration

Skills used: JOINS, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4



--Select Data that we are going to be starting with

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE Location like '%states%'
and continent is not null
ORDER BY 1,2



-- Total Cases vs. Population
-- Shows what percentage of population infected with covid

SELECT Location, Date, Population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc




-- BREAKING THINGS DOWN BY CONTINENT


-- Showing continents with highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY Date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.Date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated
