Select * from COVID_19..['Covid 19 deaths$']
where continent is null
order by 3,4

Select * from COVID_19..Vaccinations$
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from COVID_19..['Covid 19 deaths$']


---Shows likelihood of dying if you contract covid in this country
Select location, date, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from COVID_19..['Covid 19 deaths$']
where location like '%ind%'
order by 1,2

--- Looking at Total cases vs Population
--- Shows what percentage of population got covid
Select location, date, total_deaths, (total_cases/population)*100 as infection_rate
from COVID_19..['Covid 19 deaths$']
---where location like '%indi%'
order by 1,2

--- Looking at countries with highest infection rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population)*100) as Percent_pop_inf
from COVID_19..['Covid 19 deaths$']
---where location like '%indi%'
Group by location, population
order by Percent_pop_inf desc

--- Showing countries with the highest death count per population
--- Let's breakdown by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from COVID_19..['Covid 19 deaths$']
---where location like '%indi%'
where continent is not null
Group by continent
order by TotalDeathCount desc;


--- Showing the continent with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from COVID_19..['Covid 19 deaths$']
---where location like '%indi%'
where continent is not null
Group by continent
order by TotalDeathCount desc;
 
--- Global numbers
 Select Location, date, total_cases, total_deaths, 
 (total_deaths/total_cases)*100 as deathPerc 
 From COVID_19..['Covid 19 deaths$']
 Where ---location like '%states%' 
 continent is not null
 order by 1,2

 Select sum(new_cases) as total_cases,
 sum(cast(new_deaths as int)) as total_deaths, 
 sum(cast(new_deaths as int))/sum(New_cases)*100 as deathPerc
 from COVID_19..['Covid 19 deaths$']
 where continent is not null
 order by 1,2;

 select * from COVID_19..Vaccinations$
 order by 1

 --- Joining tables
 --- Looking at total population vs vaccinations

 Select  dea.continent, dea.location, dea.date,
 dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) 
 over (Partition by dea.location
 order by dea.location, dea.date) as rolling_mean_vac
 from COVID_19..['Covid 19 deaths$']  dea
 join COVID_19..Vaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
and dea.location like '%alba%'
order by 2,3


--- Sum of new vaccinations by country
Select dea.location, sum(cast(vac.new_vaccinations as bigint)) as total_vac
from COVID_19..['Covid 19 deaths$'] dea
join COVID_19..Vaccinations$ vac
on dea.location = vac.location
where dea.continent is not null
group by dea.location
order by 1

--- Use CTE

With PopvsVac (continent,  Location, Date, population, New_vaccinations, rolling_mean_vac)
as 
(
Select  dea.continent, dea.location, dea.date,
 dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) 
 over (Partition by dea.location
 order by dea.location, dea.date) as rolling_mean_vac
 from COVID_19..['Covid 19 deaths$']  dea
 join COVID_19..Vaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
and dea.location like '%alba%'
-- order by 2,3
)
select *, (rolling_mean_vac/population)*100 From PopvsVac



--- Temp Tables
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
rolling_mean_vac numeric
)


Insert into #PercentPopulationVaccinated
Select  dea.continent, dea.location, dea.date,
 dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) 
 over (Partition by dea.location
 order by dea.location, dea.date) as rolling_mean_vac
 from COVID_19..['Covid 19 deaths$']  dea
 join COVID_19..Vaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
-- and dea.location like '%alba%'

Select *, (Rolling_mean_vac/population)*100
From #PercentPopulationVaccinated


---- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select  dea.continent, dea.location, dea.date,
 dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) 
 over (Partition by dea.location
 order by dea.location, dea.date) as rolling_mean_vac
 from COVID_19..['Covid 19 deaths$']  dea
 join COVID_19..Vaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated