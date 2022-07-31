
--Covid-19 DATA Exploration




select *
from PortfolioProject .. CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject .. CovidVaccinations
--order by 3,4



select location, date, Total_Cases, new_cases, total_deaths, population
from PortfolioProject .. CovidDeaths
where continent is not null
order by 1,2


--Total Cases vs Toatal Deaths
--Illustrates Likelihood of diying if you contract covid in your country

select location, date, Total_Cases, total_deaths,(total_deaths/Total_Cases)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths
where location like '%united kingdom%'
where continent is not null
order by 1,2



--Total Cases vs Population
--Illustrates what percentage of population got covid

select location, date, population, Total_Cases, (Total_Cases/population)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths
where location like '%united kingdom%'
where continent is not null
order by 1,2



--Looking at countries with highest infection rates

select location, population, Max(Total_Cases) as HighestInfectionCount, Max((Total_Cases/population))*100 as PercentPopulationInfected
from PortfolioProject .. CovidDeaths
--where location like '%united kingdom%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc



--Countries With Highest Death per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject .. CovidDeaths
--where location like '%united kingdom%'
where continent is not null
Group by location
order by TotalDeathCount desc



--BREAKING THINGS DOWN BY CONTINENT

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject .. CovidDeaths
--where location like '%united kingdom%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Continents With Highest Death Count per Population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject .. CovidDeaths
--where location like '%united kingdom%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers

select date, SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths
--where location like '%united kingdom%'
where continent is not null
Group By date
order by 1,2


--Over All (across the World)
select SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths
--where location like '%united kingdom%'
where continent is not null
--Group By date
order by 1,2



--Total Population vs Total Vaccination

select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPepoleVaccitated
--, (RollingPepoleVaccitated/population)*100
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPepoleVaccitated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPepoleVaccitated
--, (RollingPepoleVaccitated/population)*100
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPepoleVaccitated/population)*100
From PopvsVac






--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population Numeric,
new_vaccination Numeric,
RollingPepoleVaccitated Numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPepoleVaccitated
--, (RollingPepoleVaccitated/population)*100
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPepoleVaccitated/population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later visualisations


CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPepoleVaccitated
--, (RollingPepoleVaccitated/population)*100
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated