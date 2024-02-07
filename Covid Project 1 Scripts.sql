/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) *100  DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float)) *100  PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%' 
Where continent is not null
and total_cases is not null
Order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as Highestinfeccount, MAX((cast(total_cases as float)/population)) *100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

 Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
 From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
 and new_cases is not null
 --Group by date
 Order by 1,2


 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/Population)* 100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3



-- Continent Death Count

Create View TotalDeathCount as
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
--Where Continent is not null
group by Continent
--Order by TotalDeathCount desc


--Country Death Count

Create View CountriesDeathCount as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
group by location 
--Order by TotalDeathCount desc


--countries with Highest Infection Rate compared to Population

Create View HighestInfectionRateByPopulation as
Select location, population, MAX(total_cases) as Highestinfeccount, MAX((cast(total_cases as float)/population)) *100 as PercentpopInfected
from PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
group by location, population
--Order by PercentpopInfected desc


-- looking at Total Cases vs Population
-- shows what percent of population got covid

Create View PercentInfected as
Select location, date,population, total_cases, (cast(total_cases as float)/cast(population as float)) *100  PercentInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%' 
where continent is not null
and total_cases is not null
--Order by 1,2