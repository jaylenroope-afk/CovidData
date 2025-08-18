--What percent of the population is vaccinated and percent infected? (this query will be used to analyze the effectiveness of vaccines)
--My goal here is to find the percent of the population infected after vaccinations were introduced to each country while keeping into consideration of vaccination rate. A scatterplot will be formed either in Excel or Tableau to see if there is a correlation. 
--First, I need to find the first date where the vaccine was introduced to each country. I can accomplish this by simply using the WHERE function and setting total_vaccinations > 0. I will utilize new_cases and new_vaccinations columns so I can find the percent infected and vaccinated after the date vaccines were introduced. I need to use PARTITION function so that I can add the rolling number of people. 
SELECT d.location, d.date, d.population, v.total_vaccinations, ROUND((v.total_vaccinations/d.population),2) AS percent_vaccinated, ROUND((d.total_cases))
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date

--Using CTE because I am creating two variables to add a rolling count of people infected and vaccinated.
WITH InfvsVac
AS 
(
SELECT 
  d.continent,
  d.location, 
  d.date, 
  d.population, 
  d.new_cases,
  v.new_vaccinations, 
  v.total_vaccinations,
  SUM(d.new_cases) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleInfected,
  SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated --To add the total vaccinations over time for each country
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
)

SELECT *, 
  ROUND((RollingPeopleInfected/population)*100,2) AS percent_infected, 
  ROUND((RollingPeopleVaccinated/population)*100,2) AS percent_vaccinated
FROM InfvsVac
WHERE total_vaccinations > 0 AND continent is not null

--For scatterplot purposes, this will be the query that will be used for the correlation. I will pull data based on the last day data was collected which is 04-30-2021. Correlation will be used with two variables percent_infected and percent_vaccinated out of the population for all the countries. 

--Start with CTE
WITH InfvsVac
AS 
(
SELECT 
  d.continent,
  d.location, 
  d.date, 
  d.population, 
  d.new_cases,
  v.new_vaccinations, 
  v.total_vaccinations,
  SUM(d.new_cases) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleInfected,
  SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated, --To add the total vaccinations over time for each country
  ROW_NUMBER() OVER (PARTITION BY d.location ORDER BY d.location, d.date DESC) AS row_number
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
)
--This query allows me to see what percent of the population is infected and vaccinated after the COVID vaccine was introduced to each country
SELECT 
  location, 
  date,   
  ROUND((RollingPeopleInfected/population)*100,2) AS percent_infected, 
  ROUND((RollingPeopleVaccinated/population)*100,2) AS percent_vaccinated,
FROM InfvsVac
WHERE total_vaccinations > 0 AND continent is not null AND row_number = 1

WITH InfvsVac AS (
  SELECT 
    d.continent,
    d.location, 
    d.date, 
    d.population, 
    d.new_cases,
    v.new_vaccinations, 
    v.total_vaccinations,
    SUM(d.new_cases) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingPeopleInfected, --Adding the total number of cases after vaccines introduced
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingPeopleVaccinated, --Adding the total number of vaccinations using new_vaccinations column 
    ROW_NUMBER() OVER (PARTITION BY d.location ORDER BY d.date DESC) AS row_number --Need to find the last date where data was reported. Countries in the dataset reported their numbers at different dates so we must use this partition. 
  FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
  JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
    ON d.location = v.location
    AND d.date = v.date
)
--This query allows me to see what percent of the population is infected and vaccinated after the COVID vaccine was introduced to each country
SELECT 
  location, 
  date,   
  ROUND((RollingPeopleInfected / population) * 100, 2) AS percent_infected, 
  ROUND((RollingPeopleVaccinated / population) * 100, 2) AS percent_vaccinated
FROM InfvsVac
WHERE continent IS NOT NULL
  AND row_number = 1 --Takes the latest date where data was reported for each country
  AND population > 0
ORDER BY location;


--Creating View to store data for later visualizations using VIEW function
CREATE VIEW `coviddata-468920.CovidDeaths_Vaccinations.InfectedvsVaccinated` AS
WITH InfvsVac AS (
  SELECT 
    d.continent,
    d.location, 
    d.date, 
    d.population, 
    d.new_cases,
    v.new_vaccinations, 
    v.total_vaccinations,
    SUM(d.new_cases) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingPeopleInfected, --Adding the total number of cases after vaccines introduced
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingPeopleVaccinated, --Adding the total number of vaccinations using new_vaccinations column 
    ROW_NUMBER() OVER (PARTITION BY d.location ORDER BY d.date DESC) AS row_number --Need to find the last date where data was reported. Countries in the dataset reported their numbers at different dates so we must use this partition. 
  FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
  JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
    ON d.location = v.location
    AND d.date = v.date
)
--This query allows me to see what percent of the population is infected and vaccinated after the COVID vaccine was introduced to each country
SELECT 
  location, 
  date,   
  ROUND((RollingPeopleInfected / population) * 100, 2) AS percent_infected, 
  ROUND((RollingPeopleVaccinated / population) * 100, 2) AS percent_vaccinated
FROM InfvsVac
WHERE continent IS NOT NULL
  AND row_number = 1 --Takes the latest date where data was reported for each country
  AND population > 0
ORDER BY location;