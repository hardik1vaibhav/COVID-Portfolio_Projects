SELECT * FROM  Portfolio_Project..CovidDeaths
WHERE continent is not null 
order by 3,4


--SELECT * FROM Portfolio_Project..CovidVaccinations order by 3,4

SELECT Location,date,total_cases,new_cases,total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1,2; --Order by Based off Location & Date


--Looking at the total cases V/s Total Deaths
--Shows likelihood of dying if you contract covid in United states
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE location LIKE'%states%'
order by 1,2;


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 19
SELECT Location,date,total_cases,population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE location LIKE'%states%'
order by 1,2;

-- Looking at countries with Highest Infection rate compared to Population

SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM Portfolio_Project..CovidDeaths
GROUP BY location,population
order by PercentagePopulationInfected DESC


-- Showing Countries with Highest Death Count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC

--Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers grouped by Dates

SELECT date,SUM(new_cases) AS Total_Cases,SUM(cast(new_deaths as int)) AS Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS
DeathPercentage
FROM Portfolio_Project..CovidDeaths
--WHERE location LIKE'%states%'
WHERE continent IS NOT NULL
GROUP BY date 
order by 1,2

-- Global numbers

SELECT SUM(new_cases) AS Total_Cases,SUM(cast(new_deaths as int)) AS Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS
DeathPercentage
FROM Portfolio_Project..CovidDeaths
--WHERE location LIKE'%states%'
WHERE continent IS NOT NULL 
order by 1,2

--Looking Population V/s Vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac ON
 dea.location = vac.location
 and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


--USE CTE

WITH PopVsVac (Continent,Location,Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac ON
 dea.location = vac.location
 and dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
 Continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac ON
 dea.location = vac.location
 and dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View Percent_Population_Vaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
     ON dea.location=vac.date
WHERE dea.cardiovasc_death_rate IS NOT NULL
--ORDER BY 2,3


SELECT * FROM Percent_Population_Vaccinated