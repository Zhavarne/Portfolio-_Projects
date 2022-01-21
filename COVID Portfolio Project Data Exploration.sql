select *
FROM PortfolioProject..CovidDeaths
where continent is null 
Order by 3, 4


--Select * 
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1, 2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, convert(float,total_cases) as total_cases , convert(float,total_deaths)as total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Order by 1, 2

--This changes the data type so we dont get an error
--ALTER TABLE CovidDeaths
--ALTER COLUMN total_case TYPE Float;
--ALTER COLUMN total_deaths TYPE float;

--Looking at Total Cases vs Population
--sows what percentage of population got covid
Select Location, date, convert(float, total_cases) as total_cases , Population , (convert(float,total_cases)/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Order by 1, 2

--looking at countries with highest infection rate compare to populations
Select Location, Population, MAX(convert(float, total_cases)) as HighestInfectionCount  , MAX((convert(float,total_cases)/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc


--MAX(cast(total_deaths as int))...this is a way to also fix the problem of NULL's not being an integer/float
--showing the countries with the highest death_count per population
Select Location, MAX(convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
Order by TotalDeathCount desc

--Group TotalDeathCount by continents
Select continent, MAX(convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL numbers per date
Select date, sum(convert(float,new_cases)) as Total_Cases , sum(convert(float,new_deaths))as Total_Deaths, (sum(convert(float,new_deaths))/sum(convert(float,new_cases)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
Order by 1, 2

--GLOBAL NUMBERS
Select sum(convert(float,new_cases)) as Total_Cases , sum(convert(float,new_deaths))as Total_Deaths, (sum(convert(float,new_deaths))/sum(convert(float,new_cases)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
Order by 1, 2

--Looking at Total Population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Total_Vaccinated 
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location, date, population, New_vaccinations, Total_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as Total_Vaccinated 
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (Total_Vaccinated/Population)*100 as Percentage_Vaccinated
From PopvsVac



--TEMP TABLE(this one is faulty)
DROP Table if exists #Percentage_Vaccinated
Create Table #Percentage_Vaccinated
(
continent nvarchar(255),
location nvarchar(255), 
Date datetime,
population numeric,
New_vaccinations numeric,
Total_Vaccinated numeric
) 

Insert into #Percentage_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as Total_Vaccinated 
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (Total_Vaccinated/Population)*100
From #Percentage_Vaccinated


--Creating view to store data for later vizualizations
Create View DeathPercentage as  
Select date, sum(convert(float,new_cases)) as Total_Cases , sum(convert(float,new_deaths))as Total_Deaths, (sum(convert(float,new_deaths))/sum(convert(float,new_cases)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
--Order by 1, 2

Select *
From DeathPercentage