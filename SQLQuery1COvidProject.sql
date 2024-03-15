Select*
From [Portfolio Project]..CovidDeaths
Where continent is not Null
Order by 3,4

--Select*
--From [Portfolio Project]..CovidVaccinations
--Order by 3,4

-- Select Data that We are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not Null
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not Null
Order by 1,2

--Looking at Total Cases vs Total Deaths selecting location
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not Null
and location like '%states%'
Order by 1,2

--Shows the likelihood of dyeing if you contract covid in your country

-- Looking at the total cases vs Population
--Shows What Percent of Population got covid

Select location, date, total_cases, population, (total_cases/Population)*100 as InfactedPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not Null
and location like '%states%'
Order by 1,2


--Looking at Countries with highest infection rate compared to population

Select location, population, MAX( total_cases) as HighestInfactionCountry, Max((total_cases/Population))*100 as InfactedPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not Null
Group By location, population
Order by 4 desc

--Showing countries with Highest Death Count according Population

Select location, MAX( cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not Null
Group By location, population
Order by TotalDeathCount desc


--Lets Break things down by continent


Select continent, MAX( cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not Null
Group By continent
Order by TotalDeathCount desc


-- Global Number
Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100
as death_Percentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not Null
Order By 1,2



-- Looking total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM( Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project].. CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null
	order by 2,3



	--Use CTE

	With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
	as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM( Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project].. CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null
	--order by 2,3
	)

	Select*, (RollingPeopleVaccinated/ population)*100
	From PopvsVac

--Temp Table


Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM( Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project].. CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null
	order by 2,3

	Select*, (RollingPeopleVaccinated/ population)*100
	From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentilePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM( Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project].. CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null
	--order by 2,3

	Select*
	From PercentilePopulationVaccinated