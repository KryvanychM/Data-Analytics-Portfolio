--select * from CovidDeaths$
--select * from CovidVaccinations$

--Select Data I'm going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where Location like '%states' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentent of population contracted COVID
select Location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
where Location like '%states' 
order by 1,2

-- Looking at countries with Highest Infection rate compared to Population
select Location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths$
group by Location, Population
order by PercentPopulationInfected desc


--Looking at countries with the highest death count 
select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by Location
order by TotalDeathCount desc


-- Showing the continents with the highset death count per population
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Global tota cases, total deaths, and death percentages per total cases for each day
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccination
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ DEA
join CovidVaccinations$ VAC
	on DEA.location=VAC.location
	and DEA.date=VAC.date
where DEA.continent is not null
order by 2,3


--Using CTE for (RollingPeopleVaccinated/population)*100
With PopVsVac (Continet, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ DEA
join CovidVaccinations$ VAC
	on DEA.location=VAC.location
	and DEA.date=VAC.date
where DEA.continent is not null) 
select *, (RollingPeopleVaccinated/Population)*100 from PopVsVac

-- Using Temp Table
drop table if exists #PercentPopulationVaccineted
Create Table #PercentPopulationVaccineted 
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccineted 
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ DEA
join CovidVaccinations$ VAC
	on DEA.location=VAC.location
	and DEA.date=VAC.date
--where DEA.continent is not null 

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccineted


-- Creating view to store data for later visualizations
create view PercentPopulationVaccineted as
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ DEA
join CovidVaccinations$ VAC
	on DEA.location=VAC.location
	and DEA.date=VAC.date
where DEA.continent is not null 
