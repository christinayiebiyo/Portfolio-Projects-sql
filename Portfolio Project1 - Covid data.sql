--Select Location, date, total_cases, new_cases, total_deaths, population 
--From PortfolioProject..['covid-deaths']
--Order by 1,2

-- Total cases Vs. Total deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..['covid-deaths']
Where continent is not null
Order by 1,2


-- Total cases vs. Population 
Select Location, date, population, total_cases, (total_cases/population) * 100 as CasesPerPopulation
From PortfolioProject..['covid-deaths']
Where location like '%Canada%'
Order by 1,2


-- Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths']
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths']
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global numbers 
Select date, SUM(new_cases) as TotalCases, SUM(cast (total_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths']
Where continent is not null
Group by date
Order by 1,2


-- Total population vs vaccination --Using CTE: 

with PopVsVacc (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations,
SUM(Cast(vaccination.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingVaccinationCount
From PortfolioProject..['covid-deaths'] death
join PortfolioProject..['covid-vaccination'] vaccination
	on death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null 

)

Select * , (RollingVaccinationCount/population)*100
From PopVsVacc

