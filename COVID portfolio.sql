--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccines
--ORDER BY 3,4

-- Select data we are going to be using

SELECT
continent,
date,
total_cases,
new_cases,
total_deaths,
population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract COVID

SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases) * 100 as death_rate
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- looking at total cases vs population
-- shows percent of people infected

SELECT
continent,
date,
total_cases,
population,
(total_cases/population) * 100 as infection_rate
FROM PortfolioProject..CovidDeaths

ORDER BY 1,2

-- looking at countries with highest infection rate compared to population

SELECT
continent,
MAX(total_cases) as highest_infection_count,
population,
MAX((total_cases/population)) * 100 as percent_of_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY
continent,
population
ORDER BY percent_of_population_infected DESC

-- showing countries with highest death count per population


SELECT
location,
MAX (cast (total_deaths as bigint)) as Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY
Location,
Population
ORDER BY Total_death_count desc

-- selecting by continent vs location
-- showing the continents with the highest death count

SELECT
continent,
MAX (cast (total_deaths as bigint)) as Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY
continent
ORDER BY Total_death_count desc




-- global COVID deaths by date

SELECT
date,
SUM(new_cases) AS total_cases,
SUM(cast(new_deaths as bigint)) AS total_deaths,
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccinations

SELECT 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS rolling_people_vaccinated,
--	(rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is NOT NULL
ORDER BY 
2,3


-- using CTE

WITH population_vs_vaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(SELECT 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM population_vs_vaccination

-- Temp table

DROP table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
rolling_people_vaccinated numeric)

INSERT INTO #percentpopulationvaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is NOT NULL
SELECT *, (rolling_people_vaccinated/population)*100
FROM #percentpopulationvaccinated



-- creating view to store data for later visualization

CREATE view percentpopulationvaccinated as
SELECT 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
dea.continent is NOT NULL


CREATE view Highestdeathcountbycontinent AS
SELECT
continent,
MAX (cast (total_deaths as bigint)) as Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY
continent

