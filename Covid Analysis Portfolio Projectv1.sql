 SELECT *    
 FROM [ProjectPortfolio].[dbo].[CovidDeaths]
 ORDER BY 3,4

  SELECT *
  FROM [ProjectPortfolio].[dbo].[CovidVaccinations]
  ORDER BY 3,4

  SELECT location,date,total_cases,new_cases,total_deaths,population   
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  ORDER BY 1,2

  -- Total Cases Versus Total Deaths
  --Shows Chances of dying in each Country by Percentage 

  SELECT location,date,total_cases,total_deaths,convert(float,total_deaths)/NULLIF(convert(float,total_cases),0)*100 AS DeathPercentage
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE location like '%states%'
  ORDER BY 1,2

  --Total Cases Versus Population
  --Shows rate of infection by population

  SELECT location,date,population,total_cases,convert(float,total_cases)/convert(float,population)*100 AS InfectionPercentage
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE location like '%states%'
  ORDER BY 1,2

  --Highest number of infection Versus Population
  --Shows highest Covid cases by country

  SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX(convert(float,total_cases)/convert(float,population)*100) AS InfectionPercentage
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  --WHERE location like '%states%'
  GROUP BY location,population
  ORDER BY InfectionPercentage desc

  -- Total number of Death count by Country
  --Shows Number of deaths in each country

  SELECT location,population,MAX(cast(total_deaths as int)) AS TotalDeathCount
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE continent IS NOT NULL
  GROUP BY location,population
  ORDER BY TotalDeathCount desc


  --Total number of Death Count by Continent

  SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY TotalDeathCount desc

  -- Global Values
  -- Total number of cases and deaths worldwide by date

  SELECT date,SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(NULLIF(convert(int,new_deaths),0))/SUM(NULLIF(new_cases,0))*100 AS WorldDeathPercentage
  FROM ProjectPortfolio..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY date
  ORDER BY 1,2

  -- Total number of cases and deaths worldwide

  SELECT SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(NULLIF(cast(new_deaths as int),0))/SUM(NULLIF(new_cases,0))*100 AS WorldDeathPercentage
  FROM ProjectPortfolio..CovidDeaths
  WHERE continent IS NOT NULL
  ORDER BY 1,2

  --- Looking at Total Population versus Total Vaccination

  SELECT dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
  SUM(NULLIF(convert(float,vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingSumPeopleVaccinated
  FROM ProjectPortfolio..CovidDeaths AS dea
  JOIN ProjectPortfolio..CovidVaccinations AS vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2,4


  -- Showing People Vaccinated Versus the Population
  --using CTE

  WITH PopvsVac(continent,location,population,date,new_vaccinations,RollingSumPeopleVaccinated)
  AS
  (
  SELECT dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
  SUM(NULLIF(convert(float,vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingSumPeopleVaccinated
  FROM ProjectPortfolio..CovidDeaths AS dea
  JOIN ProjectPortfolio..CovidVaccinations AS vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent IS NOT NULL)
  SELECT *,(RollingSumPeopleVaccinated/population)*100 AS VaccinatedPercentage
  FROM PopvsVac

  ---Using Temp table

  DROP TABLE IF EXISTS #PeopleVaccinatedPercentage
  CREATE TABLE #PeopleVaccinatedPercentage
  (Continent nvarchar(255),
  Location nvarchar(255),
  Population float,
  Date datetime,
  New_vaccinations numeric,
  RollingSumPeopleVaccinated float
  )
  INSERT INTO #PeopleVaccinatedPercentage
  SELECT dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
  SUM(NULLIF(convert(float,vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingSumPeopleVaccinated
  FROM ProjectPortfolio..CovidDeaths AS dea
  JOIN ProjectPortfolio..CovidVaccinations AS vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent IS NOT NULL

  SELECT *,(RollingSumPeopleVaccinated/Population) *100 as VaccinatedPercentage
  FROM #PeopleVaccinatedPercentage

  --- CREATING VIEWS FOR VISUALIZATION
  -- Percentage number of people Vaccinated

  CREATE VIEW PeopleVaccinatedPercentage AS
  SELECT dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
  SUM(NULLIF(convert(float,vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingSumPeopleVaccinated
  FROM ProjectPortfolio..CovidDeaths AS dea
  JOIN ProjectPortfolio..CovidVaccinations AS vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent IS NOT NULL

  ---Total number of Cases and Death worldwide by Date

  Create View WorldCasesbyDate as
  SELECT date,SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(NULLIF(convert(int,new_deaths),0))/SUM(NULLIF(new_cases,0))*100 AS WorldDeathPercentage
  FROM ProjectPortfolio..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY date
  --ORDER BY 1,2

  --Total Death by Continent

  Create View DeathByContinent as
  SELECT date,SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(NULLIF(convert(int,new_deaths),0))/SUM(NULLIF(new_cases,0))*100 AS WorldDeathPercentage
  FROM ProjectPortfolio..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY date
  --ORDER BY 1,2

  --Total Death by Country

  CREATE VIEW DeathByCountry as
  SELECT location,population,MAX(cast(total_deaths as int)) AS TotalDeathCount
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE continent IS NOT NULL
  GROUP BY location,population
  --ORDER BY TotalDeathCount desc

  -- Total Deaths and Total Cases in the United States

  CREATE VIEW DeathVsCases_UnitedStates AS
  SELECT location,date,total_cases,total_deaths,convert(float,total_deaths)/NULLIF(convert(float,total_cases),0)*100 AS DeathPercentage
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE location = 'United States'
  

  --Total Cases in the United States

  CREATE VIEW TotalCases_UnitedStates AS
  SELECT location,date,population,total_cases,convert(float,total_cases)/convert(float,population)*100 AS InfectionPercentage
  FROM [ProjectPortfolio].[dbo].[CovidDeaths]
  WHERE location = 'United States'
  