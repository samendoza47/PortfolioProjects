

SELECT * FROM CovidDeaths cd WHERE cd.continent IS NOT NULL


SELECT cd.location, cd.date, cd.total_cases, cd.new_cases, cd.total_deaths, cd.population
FROM CovidDeaths cd
ORDER BY 1,2

-- Looking at total cases vs total deaths
SELECT cd.location, cd.date, cd.total_cases,  cd.total_deaths, (cd.total_deaths / cd.total_cases)* 100 AS DeathPercentage
FROM CovidDeaths cd
WHERE cd.location LIKE '%states%'
AND cd.continent IS NOT NULL
ORDER BY 1,2


-- looking at total cases vs population
-- Show what percentage of population got Covid
SELECT cd.location, cd.date, cd.population, cd.total_cases, (cd.total_cases / cd.population)* 100 AS PercentageOfPopulationInfected
FROM CovidDeaths cd
WHERE cd.location LIKE '%states%'
AND cd.continent IS NOT NULL
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population

SELECT cd.location, cd.population, MAX(cd.total_cases) AS HighestInfectionCount, MAX(cd.total_cases / cd.population)* 100 AS PopulationPercentage
FROM CovidDeaths cd
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY PopulationPercentage DESC


-- Showing Countries with highest Death Count per population

SELECT cd.location, MAX(CAST(cd.total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths cd
WHERE cd.continent IS NOT NULL
GROUP BY cd.location
ORDER BY TotalDeathCount DESC



-- Let's break things down by continent
-- Showing continents with the highest death count per population

SELECT cd.continent, MAX(CAST(cd.total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths cd
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent
ORDER BY TotalDeathCount DESC



-- GLobal Numbers
SELECT SUM(cd.new_cases) AS total_cases, SUM(CAST(cd.new_deaths AS INT)) AS total_deaths,
		SUM(CAST(cd.new_deaths AS INT)) / SUM(cd.new_cases) * 100 AS DeathPercentage
FROM CovidDeaths cd
WHERE cd.continent IS NOT NULL
ORDER BY 1,2



-- Looking at total population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
		SUM(CONVERT (FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS  RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd. date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
		SUM(CONVERT (FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS  RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd. date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population) *100 
FROM PopvsVac


-- Temp table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
	Continent VARCHAR(100),
	Location VARCHAR(100),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentagePopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
		SUM(CONVERT (FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS  RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd. date = cv.date
--WHERE cd.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/population) *100 
FROM #PercentagePopulationVaccinated ppv



-- Create view to store data for later visualizations

--CREATE VIEW PercentagePopulationVaccinated AS 
--SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
--		SUM(CONVERT (FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS  RollingPeopleVaccinated
--FROM CovidDeaths cd
--JOIN CovidVaccinations cv
--	ON cd.location = cv.location
--	AND cd. date = cv.date
--WHERE cd.continent IS NOT NULL
----ORDER BY 2,3


SELECT * FROM [dbo].[PercentagePopulationVaccinated]

