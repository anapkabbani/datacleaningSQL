SELECT *
FROM `covid-project-381820.covid_info.covid_vaccinations` 
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM `covid-project-381820.covid_info.covid_deaths` 
--ORDER BY 3,4

--Select Data that we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-project-381820.covid_info.covid_deaths` 
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Gives us the likehood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM `covid-project-381820.covid_info.covid_deaths` 
ORDER BY 1,2


-- Checking Total Cases vs Population
-- Shows what percentage of the population contracted Covid

SELECT location, date, total_cases, population,(total_cases/population)*100 as PopulationPercentage
FROM `covid-project-381820.covid_info.covid_deaths` 
WHERE location like 'Israel'
ORDER BY 1,2

--Focusing on Countries with Highest Infection Rate compared to Population

SELECT location, population,MAX(total_cases) as HighestInfectionRate, MAX(total_cases/population)*100 as PopulationPercentage
FROM `covid-project-381820.covid_info.covid_deaths`
GROUP BY location,population
ORDER BY PopulationPercentage DESC

--Showing Countries with Highest Death Count per Population

SELECT location,MAX(total_deaths) as TotalDeathCount
FROM `covid-project-381820.covid_info.covid_deaths`
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Continents with Highest Death Count per Population

SELECT continent,MAX(total_deaths) as TotalDeathCount
FROM `covid-project-381820.covid_info.covid_deaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the global numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as TotalDeathPercentage 
FROM `covid-project-381820.covid_info.covid_deaths` 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Checking Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `covid-project-381820.covid_info.covid_deaths` as dea
JOIN `covid-project-381820.covid_info.covid_vaccinations` as vac
  ON dea.location = vac.location
  AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

--CTE to Calculate RollingPercentage of people vaccinated

WITH PercentPopulationVaccinated AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `covid-project-381820.covid_info.covid_deaths` as dea
JOIN `covid-project-381820.covid_info.covid_vaccinations` as vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageRollingVaccination
From PercentPopulationVaccinated
 
--Creating View to store data for visualizations

CREATE VIEW covid_info.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `covid-project-381820.covid_info.covid_deaths` as dea
JOIN `covid-project-381820.covid_info.covid_vaccinations` as vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM `covid-project-381820.covid_info.PercentPopulationVaccinated` 