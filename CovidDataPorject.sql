select *
from CovidDeaths$
Where continent is not null
order by 3,4


--select *
--from CovidVaccinations$
--order by 3,4
--commenting data

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--Looking at the Total Cases vs Total Deaths
--Show the likelihood of dying if you contract Covid in a chosen country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
 and continent is not null
order by 1,2

--Looking at Death Percentage in Vietnam
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from CovidDeaths$
--where location like '%Viet%'
--order by 1,2

--Looking at the Total Cases vs Population
--Show percentage of population got Covid

select location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
 and continent is not null
order by 1,2

--Looking at the percentage of population got Covid in Vietnam
--select location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
--from CovidDeaths$
--where location like '%Viet%'
--order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

select Location, max(total_cases) as HighestInfectionCount, Population, max((total_cases/Population))*100 as PercentagePopulationInfected
from CovidDeaths$
Group by Location, Population
order by PercentagePopulationInfected desc

--Showing the countries with the highest death count per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

--this query resulted in correct number of total death in North America continent
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
Where continent is null
 and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'International')
Group by Location
order by TotalDeathCount desc

--Break down by Continent
--Showing the continent with the highest death count per population

--select continent, max(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeaths$
--Where continent is not null
--Group by continent
--order by TotalDeathCount desc
--this query resulted in incorrect total deaths in North America continent



--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

select *
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--numeric instead of int since there is an error: Arithmetic overflow error converting expression to data type int.
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--numeric instead of int since there is an error: Arithmetic overflow error converting expression to data type int.
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--numeric instead of int since there is an error: Arithmetic overflow error converting expression to data type int.
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac


--temp table

Drop table if exists #PercentPopulationvaccinated
Create table #PercentPopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccination numeric,
 RollingPeopleVaccinated numeric
 )
insert into #PercentPopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--numeric instead of int since there is an error: Arithmetic overflow error converting expression to data type int.
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationvaccinated


--Create view to store data for later visualization

Create view PercentPopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--numeric instead of int since there is an error: Arithmetic overflow error converting expression to data type int.
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationvaccinated