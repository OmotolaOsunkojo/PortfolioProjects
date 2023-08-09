----SELECT * 
----FROM CovidPortfolioProject.DBO.CovidDeaths$
----ORDER BY 3, 4

----SELECT *
----FROM CovidPortfolioProject. .CovidVaccinations$
----ORDER BY 3,4

----SELECT location, date, total_cases, new_cases, total_deaths, population 
----FROM CovidPortfolioProject.DBO.CovidDeaths$
----order by location, date

--- LOOKING AT DEATH RATE; TOTAL DEATHS/TOTAL CASES * 100 
----This shows the percentage of Covid cases that will lead to death in Nigeria

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'DeathRate'
--FROM CovidPortfolioProject. .CovidDeaths$
--where location = 'nigeria'
--ORDER BY location, date

----LOOKING AT INFECTION RATE; TOTAL CASES/POPULATION * 100
----This shows the percentage of infected individuals in the population

--SELECT location, date, total_cases, population, (total_cases/population)*100 AS 'InfectionRate'
--FROM CovidPortfolioProject. .CovidDeaths$
--where location = 'nigeria'
--ORDER BY location, date

----LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO THE POPULATION SIZE

--SELECT location, MAX (total_cases) AS'HighestInfectionCount', population, MAX((total_cases/population))*100  AS 'InfectionRate'
--FROM CovidPortfolioProject. .CovidDeaths$
--group by population, location
--order by InfectionRate desc

----SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

----SELECT location, population, MAX (CAST (total_deaths AS int)) AS 'HighestDeathCount', MAX((total_deaths/population))*100 AS 'DeathRatePerPoplulation'
----from CovidPortfolioProject. .CovidDeaths$
----WHERE continent IS NOT NULL 
----GROUP BY location, population
----ORDER BY 3 DESC

----SHOWING GLOBAL NUMBERS

--SELECT date, SUM (CAST(new_cases AS int)) AS 'TotalCases', SUM(CAST(new_deaths AS int)) AS 'TotalDeaths',
--SUM(CAST(new_deaths AS int)) / SUM(new_cases)* 100 AS 'DeathPercentage'
--FROM CovidPortfolioProject. .CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date, TotalCases


----SHOWING GLOBAL REPORT 

--SELECT SUM (CAST(new_cases AS int)) AS 'TotalCases', SUM(CAST(new_deaths AS int)) AS 'TotalDeaths',
--SUM(CAST(new_deaths AS int)) / SUM(new_cases)* 100 AS 'DeathPercentage'
--FROM CovidPortfolioProject. .CovidDeaths$
--WHERE continent IS NOT NULL
--ORDER BY TotalCases


--LOOKING AT TOTAL POPULATIONS VS VACCINATIONS

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date)
AS 'RollingPeopleVaccinated'
FROM CovidPortfolioProject..CovidDeaths$ CD
INNER JOIN CovidPortfolioProject..CovidVaccinations$ CV
ON CD.location= CV.location
AND CD.date= CV.date
WHERE CD.continent IS NOT NULL
ORDER BY location, date

--USE CTE

WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date)
AS 'RollingPeopleVaccinated'
FROM CovidPortfolioProject..CovidDeaths$ CD
INNER JOIN CovidPortfolioProject..CovidVaccinations$ CV
ON CD.location= CV.location
AND CD.date= CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY location, date)
)
SELECT *, RollingPeopleVaccinated/population*100
FROM POPvsVAC


--TEMP TABLE

CREATE TABLE #PercentVaccinatedPopulation
( continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentVaccinatedPopulation
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date)
AS 'RollingPeopleVaccinated'
FROM CovidPortfolioProject..CovidDeaths$ CD
INNER JOIN CovidPortfolioProject..CovidVaccinations$ CV
ON CD.location= CV.location
AND CD.date= CV.date
WHERE CD.continent IS NOT NULL
ORDER BY location, date

SELECT *,  RollingPeopleVaccinated/population*100
FROM #PercentVaccinatedPopulation


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentVaccinatedPopulation AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date)
AS 'RollingPeopleVaccinated'
FROM CovidPortfolioProject..CovidDeaths$ CD
INNER JOIN CovidPortfolioProject..CovidVaccinations$ CV
ON CD.location= CV.location
AND CD.date= CV.date
WHERE CD.continent IS NOT NULL

CREATE VIEW DeathRate2 AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'DeathRate'
FROM CovidPortfolioProject. .CovidDeaths$
where location = 'nigeria'


