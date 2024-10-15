select *
from covid..CovidDeaths
where continent is not null
order by 3,4

--select *
--from covid..CovidVaccination
-- where continent is not null
--order by 3,4

/* Select data that we are going to be using
*/


Select location, date, total_cases, new_cases,total_deaths, population
From covid..CovidDeaths
where continent is not null
order by 1,2

-- lets look at total cases vs total death
--show the likelihood of dying in your country
Select location, date, total_cases,total_deaths, (cast(total_deaths as int)/total_cases)*100 as Death_Percentage
from covid..CovidDeaths
where continent is not null
order by 1,2

-- lets look at total cases vs the population
-- show percentage of the population are infected by covid
Select location, date,population, total_cases, (total_cases/population)*100 as Pecentage_of_Population_infected
from covid..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to population

Select location, population, max(total_cases) as HighestInfectioncount, (Max(total_cases)/Population)* 100 as InfectionPercentage
from covid..CovidDeaths
---where location = 'Nigeria'
where continent is not null
group by location,population
order by infectionPercentage desc


-- Show the country witht he highest death count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths
--where location  Not In ('World','North America','European Union','South America','Europe','Asia','Africa')
where continent is not null
group by location
Order by TotalDeathCount desc

-- Let break it down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths
--where location  Not In ('World','North America','European Union','South America','Europe','Asia','Africa')
where continent is not null
group by continent
Order by TotalDeathCount desc


Select Continent, sum(new_cases) as total_Case,sum(cast(new_deaths as int)) as total_death, 
	sum(cast(new_deaths as int))/(sum(new_cases))*100 as  Death_Percentage
from covid..CovidDeaths
where continent is not null
group by continent

-- Global Numbers
Select date, sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,
	sum(cast(new_deaths as int))/(sum(new_cases))*100 as  Death_Percentage
from covid..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Global Numbers summation
Select  sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,
	sum(cast(new_deaths as int))/(sum(new_cases))*100 as  Death_Percentage
from covid..CovidDeaths 
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vacination using Partition window

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
From covid..CovidDeaths dea
join
	covid..CovidVaccination vac
on dea.location = vac.location
and
	dea.date = vac.date
where dea.continent is not null --and dea.location = 'Canada'
order by 2,3

-- Use CTE (with population vs Vaccination)

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
 as
 (
	Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
	From covid..CovidDeaths dea
	join
		covid..CovidVaccination vac
	on dea.location = vac.location
	and
		dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--order by 2,3
	)
Select *,(RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac


--- using Temp table to resolve the above issue
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
	From covid..CovidDeaths dea
	join
		covid..CovidVaccination vac
	on dea.location = vac.location
	and
		dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100 as PercentageVaccinated
from #PercentPopulationVaccinated

-- Create view for Later vizualization

create view PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
	From covid..CovidDeaths dea
	join
		covid..CovidVaccination vac
	on dea.location = vac.location
	and
		dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--order by 2,3