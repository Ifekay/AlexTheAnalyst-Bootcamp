
	--									 Covid 19 Data Exploration 
  
  --Checking all columns in the datasets
  
  SELECT *
  FROM PortfolioProject..CovidDeaths
  ORDER BY 3,4

    SELECT *
  FROM PortfolioProject..CovidVaccinations
  ORDER BY 3,4

  --Select needed columns from dataset
  
   SELECT location, date, total_cases, new_cases,total_deaths,population
  FROM PortfolioProject..CovidDeaths
  ORDER BY 1,2
 

--Checking for Total cases vs Total Deaths
--Get death probability of death from Covid in a country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%' AND continent IS NOT NULL
ORDER BY 1, 2

--Checking for Total cases vs Population
--Get PERCENTAGE of population who contacted Covid in a country


Select location, date, population, total_cases, (total_cases/population)*100 AS covidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%' AND continent IS NOT NULL
ORDER BY 5 desc



--Checking for Total cases vs Population
--Get Highest percentage of population who contacted Covid in a country

Select location, date, population, total_cases, (total_cases/population)*100 AS covidPercentage
FROM PortfolioProject..CovidDeaths
WHERE date = (select max(date) from  PortfolioProject..CovidDeaths) AND continent IS NOT NULL
ORDER BY 5 DESC

--Countries with highest infection rate compared to population

Select location,  population, MAX(total_cases) AS  highestInfectionCount, (MAX(total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,  population
ORDER BY 4 DESC


--Countries with highest death rate by population


SELECT location, population, MAX( CAST( total_deaths AS INT)) totalDeath, MAX((total_deaths/population)*100) AS highestDeathPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC



--BY continent
--Get Continents with higHest death count per population

SELECT continent, MAX( CAST( total_deaths AS INT)) totalDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeath DESC



--Global Numbers
--To get the Global death percentage

SELECT SUM(new_cases) totalCases, SUM(CAST ( new_deaths AS INT)) AS totalDeaths, (SUM(CAST (new_deaths AS INT))/SUM(new_cases) )*100 deathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL



-- Total Population vs Vaccinations
--Looking at Total Population vs people who are Vaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS v
JOIN PortfolioProject..CovidDeaths AS d
ON v.date = d.date AND v.location = d.location 
WHERE d.continent IS NOT NULL
ORDER BY 2,3




-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population,new_vaccinations, total_vaccinations, rollingPeopleVaccinated)
AS

(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, v.total_vaccinations, 
SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS v
JOIN PortfolioProject..CovidDeaths AS d
ON v.date = d.date AND v.location = d.location 
WHERE d.continent IS NOT NULL
)
SELECT *,  (rollingPeopleVaccinated/population) * 100 AS	rollingPercentagePeopleVaccinated
FROM PopvsVac
where location = 'Andorra'




-- Using Temp Table to perform Calculation on Partition By in the previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated