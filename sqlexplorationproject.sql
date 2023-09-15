select *
from PortfolioProject..coviddeaths
order by 3,4


--select*
--from PortfolioProject..CovidVAccination
--order by 3,4

--select data that we are going to use





select location, date, total_cases,new_cases , total_deaths,population
from PortfolioProject..coviddeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in country india



select location, date, total_cases, total_deaths,
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as Deathpercentage
from PortfolioProject..coviddeaths
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid


select location, date, total_cases, population,(total_cases/population)*100 as covidpercentage
from PortfolioProject..coviddeaths
order by 1,2


--looking at the country's highest infection rate at which time

select location, date, population, new_cases , total_cases,MAX(new_cases) as HighestInfected
from PortfolioProject..coviddeaths
Group by  new_cases, date, location,population, total_cases
order by HighestInfected desc


--looking at the country highest death rate at which time it was high

select location, date, population, new_cases , total_cases,  new_deaths, MAX(new_deaths) as HighestDeaths
from PortfolioProject..coviddeaths
Group by  new_cases, date, location,population, total_cases,new_deaths
order by HighestDeaths desc

--finding total cases ,total deaths and death percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
order by 1,2


--how many people got vaccinated out of indian population
select dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..CovidVAccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
 order by 2

 --looking at population vs total vaccination 


 select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingpeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..CovidVAccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
 order by 2


 --use CTE

 with popVsVac(location, date, population, new_vaccinations, RollingpeopleVaccinated)
 as
 (
  select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingpeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..CovidVAccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
-- order by 2
)
select*, ( RollingpeopleVaccinated/population)*100
from popVsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
  create table #PercentPopulationVaccinated
  (
  location nvarchar(255),
  date datetime,
  new_vaccination numeric,
  RollingPeopleVaccinated numeric,
  )

  insert into 
 select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingpeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..CovidVAccination vac
 on dea.location=vac.location 
 and dea.date=vac.date

 select*, (RollingpeopleVaccinated/population)*100
 from #PercentPopulationVaccinated

 --creating view to store data for later visualizations
 create view PercentPopulationVaccinated as 
  select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as RollingpeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..CovidVAccination vac
 on dea.location=vac.location 
 and dea.date=vac.date


 select *
 from PercentPopulationVaccinated
  