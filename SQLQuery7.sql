SELECT *
FROM [portfolio Project ]..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM [portfolio Project ]..CovidVaccinations$
-- WHERE continent is not Null
--ORDER BY 3,4

SELECT location,date,total_deaths,new_cases total_cases, population
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
ORDER BY 3,4

SELECT location,date,total_deaths,total_cases,(total_deaths/total_cases)*100 as DeathsPrecentage
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
--WHERE location like '%states%'
ORDER BY 1,2


SELECT location,date,population,total_cases,(total_cases/population)*100 as PrecentOfPopulationInfected
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
--WHERE location like '%states%'
ORDER BY 1,2


SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PrecentOfPopulationInfected
FROM [portfolio Project ]..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PrecentOfPopulationInfected desc

SELECT location, MAX(total_deaths) as TotalDeathsCount
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathsCount desc

SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathsCount
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathsCount desc

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathsCount
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
--WHERE location like '%states%'
GROUP BY continent
ORDER BY TotalDeathsCount desc

SELECT SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)
* 100 DeathsPercentage
FROM [portfolio Project ]..CovidDeaths$
WHERE continent is not Null
--WHERE location like '%states%'
--GROUP BY date
ORDER BY 1,2 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)* 100
FROM [portfolio Project ]..CovidDeaths$ dea
JOIN [portfolio Project ]..CovidVacinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3



With PopvsVac (Continent, Location, Date, Population,New_vacinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM [portfolio Project ]..CovidDeaths$ dea
JOIN [portfolio Project ]..CovidVacinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/population)* 100
FROM  PopvsVac


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vacinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM [portfolio Project ]..CovidDeaths$ dea
JOIN [portfolio Project ]..CovidVacinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
----WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/population)* 100
FROM  #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM [portfolio Project ]..CovidDeaths$ dea
JOIN [portfolio Project ]..CovidVacinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated 