SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4


SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Dying % if infected with covid in India
SELECT Location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2


-- % of polulation had covid

SELECT Location, date, population,  total_cases, (CONVERT(float, total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2


--Countries with highest infection rate compared to polulation
SELECT Location, population,  MAX(total_cases) as HighestInfection, MAX(( total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Countries with the highest death count per population
SELECT Location,  MAX(cast(total_deaths as int)) as Totaldeathcount
FROM CovidDeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Totaldeathcount desc


-- by location
SELECT location,  MAX(cast(total_deaths as int)) as Totaldeathcount
FROM CovidDeaths
--WHERE location like '%india%'
WHERE continent is NULL
GROUP BY location
ORDER BY Totaldeathcount desc

--Continents with highest death per population
SELECT continent ,  MAX(cast(total_deaths as int)) as Totaldeathcount
FROM CovidDeaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Totaldeathcount desc

-- Global
SELECT date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS int)) as total_deaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100
  END AS GlobalDeathPercentage
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS int)) as total_deaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100
  END AS GlobalDeathPercentage
FROM CovidDeaths
WHERE continent IS not NULL
--GROUP BY date
ORDER BY 1,2

--Vaccination table joned with death table

SELECT *
FROM CovidDeaths d
JOIN CovidVaccinations v
 ON d.location = v.location
 AND d.date = v.date

 -- vaccinated population

 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM CovidDeaths d
JOIN CovidVaccinations v
 ON d.location = v.location
 AND d.date = v.date
 WHERE d.continent IS NOT NULL
 ORDER BY 1,2,3

 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
 ON d.location = v.location
 AND d.date = v.date
 WHERE d.continent IS NOT NULL
 ORDER BY 2,3

 --CTE with Population vs Vaccinated

WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
    SELECT
        d.continent,
        d.location,
        CONVERT(datetime, d.date) as date, -- Specify the data type here
        d.population,
        v.new_vaccinations,
        SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
    FROM
        CovidDeaths d
    JOIN
        CovidVaccinations v ON d.location = v.location AND d.date = v.date
    WHERE
        d.continent IS NOT NULL
)
SELECT
    *,
    (RollingPeopleVaccinated / population) * 100 
FROM
    PopvsVac;


 
 
 --TEMP table
 DROP TABLE IF exists #PERCENTPEOPLEVACCINATED

 CREATE TABLE #PERCENTPEOPLEVACCINATED
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PERCENTPEOPLEVACCINATED
SELECT
    d.continent,
    d.location,
    CONVERT(datetime, d.date) as date,
    d.population,
    v.new_vaccinations,
    SUM(CONVERT(NUMERIC, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM
    CovidDeaths d
JOIN
    CovidVaccinations v ON d.location = v.location AND d.date = v.date;
	 --WHERE d.continent IS NOT NULL
	  -- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated /Population) * 100 
FROM #PERCENTPEOPLEVACCINATED



--Creating view to store data for visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT
    d.continent,
    d.location,
    CONVERT(datetime, d.date) as date,
    d.population,
    v.new_vaccinations,
    SUM(CONVERT(NUMERIC, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v 
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated

