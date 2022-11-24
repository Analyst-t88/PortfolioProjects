SELECT *
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
ORDER BY 3, 4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3, 4

--Select Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying due to Covid by Country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid

SELECT Location, Date, Population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

--SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
--FROM [Portfolio Project]..CovidDeaths
----Where location like '%states%'
--Where continent is null
--GROUP BY location
--ORDER BY TotalDeathCount desc



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
GROUP BY Date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
		dea.Date) AS RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
		dea.Date) AS RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
		dea.Date) AS RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.Date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
		dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3


Select *
From PercentPopulationVaccinated

