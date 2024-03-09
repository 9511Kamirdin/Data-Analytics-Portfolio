

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2



----Looking at Total Cases vs Total Deaths
----Shows likelihood of dying if you contract Covid in your country
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%France%'
And continent is not null
Order by 1,2


---Looking at Total Cases vs the Population
---Shows what percentage of population got Covid

Select location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Order by 1,2


---Looking at Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by location,population
Order by PercentagePopulationInfected desc


----Showing Countries with the highest death count per population

Select location,MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-----Let's break things down by continent





---Showing continents with the highest death count per population

Select continent,MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



---Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerentage
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
--Group by date
Order by 1,2



---Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollongPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--- USE CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations, RollongPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollongPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollongPeopleVaccinated/Population)*100
From PopvsVac



----TEMP TABLE
Drop Table IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



---Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated





