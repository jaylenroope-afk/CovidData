--Beginning of Query
--Viewing Covid Death table and ordering it by location and date
SELECT *
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
ORDER BY
  location,
  date

--Selecting data that will be used 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
ORDER BY
  location,
  date

--Looking at total cases vs total deaths and calculating the mortality rate
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS mortality_rate
--Using ROUND to calculate mortality rate and rounding two decimal places
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
ORDER BY
  location,
  date

--USA Data
--Looking at USA contraction rate and mortality rate
SELECT location, date, total_cases, total_deaths, ROUND((total_cases/population)*100,2) AS contraction_rate, ROUND((total_deaths/total_cases)*100,2) AS mortality_rate
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE location = "United States"

--What was the max contraction rate and mortality rate in the USA
SELECT location, date, total_cases, total_deaths, (ROUND((total_cases/population)*100,2)) AS contraction_rate
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE location = "United States"
ORDER BY
  contraction_rate DESC
LIMIT 1
--We find that the max contraction rate was 9.77% on 2021-04-30

--What was the max mortality rate in the USA
SELECT location, date, total_cases, total_deaths, (ROUND((total_deaths/total_cases)*100,2)) AS mortality_rate
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE location = "United States"
ORDER BY
  mortality_rate DESC
LIMIT 1
--The max mortality rate was 10.91% during the early stage of the spread on 2020-03-02



--Top 10 Countries with the highest mortality rate as of the latest date (2021-04-30)
SELECT location, date, population, total_cases, total_deaths, (ROUND((total_deaths/total_cases)*100,2)) AS mortality_rate
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE date = "2021-04-30" AND total_cases > 6000
--Vanuatu, a small island-chain country had a mortality rate of 25% on 2021-04-30 but only had 4 cases which is not enough compared to other countries in the top 10 list. Every other country in the top 10 had more than 6,000 cases.
ORDER BY
  mortality_rate DESC
LIMIT 10
--Yemen had the highest mortality_rate of COVID-19 which was 19.41%. 1226 people died out of 6317 who had contracted the virus.

--Countries with the highest overall death count
SELECT location, (MAX(CAST(total_deaths as int))) AS TotalDeathCount
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE continent is not null
--The line above gets rid of continents in the location column so that it only shows top countries
GROUP BY 
  location
ORDER BY
  TotalDeathCount DESC

--Continents with the highest overall death count
SELECT location, (MAX(CAST(total_deaths as int))) AS TotalDeathCount
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE continent is null
--The line above gets rid of continents in the location column so that it only shows top countries
GROUP BY 
  location
ORDER BY
  TotalDeathCount DESC

--Total cases and deaths in the world over time
SELECT date, SUM(new_cases) AS total_world_cases, SUM(new_deaths) AS total_world_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS death_percentage
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths
WHERE continent is not null
GROUP BY 
  date
ORDER BY 
  date

--Start using vaccination data and JOIN with COVID deaths table
SELECT *
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date

--What percent of the population is vaccinated
SELECT d.location, d.date, d.population, v.total_vaccinations, ROUND((v.total_vaccinations/d.population),2) AS percent_vaccinated
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date

--Using partition 
SELECT 
  d.location, 
  d.date, 
  d.population, 
  v.new_vaccinations, 
  SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated --To add the total vaccinations over time for each country
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date

--Using a CTE because I am trying to calculate the percent of the population that is vaccinated over time using the new variable RollingPeopleVaccinated 
WITH PopsvsVac 
AS 
(
SELECT 
  d.continent,
  d.location, 
  d.date, 
  d.population, 
  v.new_vaccinations, 
  SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated --To add the total vaccinations over time for each country
FROM coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths AS d
JOIN coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
)
SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2) AS percent_vaccinated_over_time
FROM PopsvsVac




--Creating View to store data for later visualizations using VIEW function
CREATE VIEW `coviddata-468920.CovidDeaths_Vaccinations.PercentVaccinatedOverTime` AS
WITH PopsvsVac AS (
  SELECT 
    d.continent,
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations, 
    SUM(v.new_vaccinations) OVER (
      PARTITION BY d.location 
      ORDER BY d.location, d.date
    ) AS RollingPeopleVaccinated
  FROM `coviddata-468920.CovidDeaths_Vaccinations.CovidDeaths` AS d
  JOIN `coviddata-468920.CovidDeaths_Vaccinations.CovidVaccinations` AS v
    ON d.location = v.location
    AND d.date = v.date
)
SELECT 
  *, 
  ROUND((RollingPeopleVaccinated / population) * 100, 2) AS percent_vaccinated_over_time
FROM PopsvsVac;
