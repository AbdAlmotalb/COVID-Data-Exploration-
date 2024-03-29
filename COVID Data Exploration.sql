
select *
from CovidDeaths

-- Select Data that we are going to be starting with

select location,date,total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2 ASC

-- Total Cases vs Total Deaths

select location,date,total_cases, total_deaths, (total_deaths/total_cases*100) Death_Percntage
from CovidDeaths
Where location like 'eg%'
order by 1,2 ASC

-- Total Cases vs Population

select location,date,total_cases, population, (total_cases/population*100) infection_Percentage
from CovidDeaths
Where location like 'eg%'
order by 1,2 ASC

-- Countries with Highest Infection Rate compared to Population

select location, MAX(cast(total_cases AS int)) MAX_Cases, population, 
				MAX(cast(total_cases as float)/ cast(population as float)*100) MAX_infection_Percentage
from CovidDeaths
Where continent is not null 
GROUP BY location, population
order by 4 DESC

-- Countries with Highest Death Count

select location, MAX(cast(total_deaths AS int)) MAX_deaths
from CovidDeaths
Where continent is not null 
GROUP BY location
order by MAX_deaths DESC


-- Countries with Highest Death Rate compared Population

select location, MAX(cast(total_deaths AS int)) MAX_deaths, population, 
				MAX(cast(total_deaths as float)/ cast(population as float)*100) MAX_Deaths_Percentage
from CovidDeaths
Where continent is not null 
GROUP BY location, population
order by MAX_Deaths_Percentage DESC

-- continent with Highest Death Count

select location, MAX(cast(total_deaths AS int)) MAX_deaths
from CovidDeaths
Where continent is null 
GROUP BY location
order by MAX_deaths DESC

-- global Cases vs Total Deaths

select date,SUM(cast (total_cases as int)) cases, SUM(Cast (total_deaths as int)) deaths, 
			SUM(cast(total_deaths as float))/SUM(cast(total_cases as float)*100) Death_Percntage
from CovidDeaths
Where continent is not null
Group By Date
order by date ASC

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, vaccin.total_vaccinations,
		sum(cast (vaccin.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) summation,
		CAST(vaccin.total_vaccinations as float)/ CAST(death.population as float)*100 Vaccination_Percentage
from CovidDeaths death
JOIN CovidVaccinations vaccin
ON death.date = vaccin.date and
	death.location=vaccin.location
Where death.location like 'alb%'
AND death.continent is not null
order by death.location, death.date asc
;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using CTE

with Vaccination_call as
(
select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, vaccin.total_vaccinations,
		sum(cast (vaccin.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) summation,
		CAST(vaccin.total_vaccinations as float)/ CAST(death.population as float)*100 Vaccination_Percentage
from CovidDeaths death
JOIN CovidVaccinations vaccin
ON death.date = vaccin.date and
	death.location=vaccin.location
)
SELECT *, summation/ CAST(population as float)*100 Vaccination_Percentage2
FROM Vaccination_call
Where location like 'alb%'
AND continent is not null
order by location, date asc

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Temp Table
--DROP TABLE IF EXISTS #Vaccination_Death  
--CREATE TABLE #Vaccination_Death 
--(
--continent varchar(100),
--location varchar(100),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--total_vaccinations numeric,
--summation numeric,
--Vaccination_Percentage numeric
--)

--INSERT INTO #Vaccination_Death
--select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, vaccin.total_vaccinations,
--		sum(cast (vaccin.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) summation,
--		CAST(vaccin.total_vaccinations as float)/ CAST(death.population as float)*100 Vaccination_Percentage
--from CovidDeaths death
--JOIN CovidVaccinations vaccin
--ON death.date = vaccin.date and
--	death.location=vaccin.location
--Where death.continent is not null
--order by death.location, death.date asc

SELECT *, summation/ CAST(population as float)*100 Vaccination_Percentage2
FROM #Vaccination_Death
Where location like 'alb%'

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
