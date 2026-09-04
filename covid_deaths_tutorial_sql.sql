DROP TABLE IF EXISTS covid_deaths;
CREATE TABLE covid_deaths (
	iso_code VARCHAR(20),
    continent VARCHAR(100),
    loaction VARCHAR(255),
    date DATE,
    total_cases INT,
    new_cases INT,
    total_deaths INT,
    new_deaths INT,
    new_deaths_smoothed FLOAT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients INT,
    icu_patients_per_million FLOAT,
    hosp_patients INT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions INT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions FLOAT,
    weekly_hosp_admissions_per_million FLOAT,
    total_tests FLOAT
);

ALTER TABLE covid_deaths
RENAME COLUMN loaction to location;

ALTER TABLE covid_deaths
ADD COLUMN new_cases_smoothed FLOAT;

ALTER TABLE covid_deaths
ADD COLUMN population INT;

ALTER TABLE covid_deaths 
MODIFY COLUMN new_cases_smoothed FLOAT AFTER new_cases;

ALTER TABLE covid_deaths
MODIFY COLUMN population INT AFTER date;

SELECT * FROM portfolioproject.covid_deaths;

SELECT COUNT(*) FROM covid_deaths;

SELECT *
FROM covid_deaths
ORDER BY 3;

-- converting empty spaces ' ' to NULL
UPDATE covid_deaths 
SET continent = NULL 
WHERE continent = '';

SELECT date, new_cases, new_cases_smoothed 
FROM covid_deaths LIMIT 10;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in a country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location = 'Asia';

-- looking at total cases vs population
-- shows percentage of the population that contracted covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS pop_infected_percentage
FROM covid_deaths
WHERE location LIKE '%states%'
 -- AND continent is NOT NULL
ORDER BY 1, 2;

-- looking at countries with the max infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)) * 100 AS pop_infected_percentage
FROM covid_deaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY pop_infected_percentage DESC;

-- showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC
LIMIT 10;

SELECT location, MAX(population) AS highest_pop
FROM covid_deaths
GROUP BY location
ORDER BY highest_pop DESC
LIMIT 1;

SELECT 
    location AS country, 
    MAX(population) AS highest_population
FROM 
    covid_deaths
WHERE 
    continent IS NOT NULL 
GROUP BY 
    location
ORDER BY 
    highest_population DESC
LIMIT 10;

-- breaking things down by continent


-- showing the continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent is NOT NULL
ORDER BY 1, 2;

CREATE TABLE covid_vaccinations (
	iso_code VARCHAR(20),
    continent VARCHAR(100),
    location VARCHAR(255),
    date DATE,
    new_tests FLOAT,
    total_tests FLOAT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed FLOAT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR(100),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    stringency_index FLOAT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_death_rate FLOAT,
    femaile_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT
);

SET GLOBAL local_infile = 1;

ALTER TABLE covid_vaccinations 
MODIFY COLUMN new_vaccinations INT;


UPDATE covid_vaccinations 
SET continent = NULL 
WHERE continent = '';



SELECT 	continent, location, date, new_vaccinations
FROM covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 2, 3;


SELECT * FROM covid_vaccinations;

TRUNCATE TABLE covid_vaccinations;

SELECT COUNT(*) 
FROM information_schema.columns 
WHERE table_name = 'covid_vaccinations' AND table_schema = 'portfolioproject';

SELECT location, date, stringency_index, population_density 
FROM covid_vaccinations 
WHERE location = 'Afghanistan' AND stringency_index > 0 
LIMIT 10;


ALTER TABLE covid_vaccinations
RENAME COLUMN femaile_smokers to female_smokers,
RENAME COLUMN diabetes_death_rate to diabetes_prevalance,
RENAME COLUMN humand_development_index to human_development_index;


-- looking at total population vs vaccinations

SELECT 	cd.continent,
		cd.location,
		cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinated_count
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- USE CTE
WITH PopvsVac ( continent, location, date, population, new_vaccinations, rolling_vaccinated_count)
AS (
SELECT 	cd.continent,
		cd.location,
		cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinated_count
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_vaccinated_count/population) * 100 AS percent_rolling_vacc_count
FROM PopvsVac;

-- Using Temp Table
DROP TABLE if exists percent_pop_vacc;
CREATE TABLE percent_pop_vacc 
	(continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_vaccinated_count NUMERIC
);

INSERT INTO percent_pop_vacc
SELECT 	cd.continent,
		cd.location,
		cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinated_count
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT *, (rolling_vaccinated_count/population) * 100 AS percent_rolling_vacc_count
FROM percent_pop_vacc;

-- creating view to store data for future visualizations
CREATE VIEW population_vacc_percent AS
SELECT 	cd.continent,
		cd.location,
		cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinated_count
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT * FROM population_vacc_percent;
