

select location , date , total_cases , new_cases , total_deaths , population
from portfolio..CovidDeaths
order by 1 ,2 

--looking at total cas vs total deaths 


select location , date , total_cases  , total_deaths , (total_deaths/total_cases)*100 as DeathsPercentage  
from portfolio..CovidDeaths
order by 1 ,2 

--looking at total cases vs total deaths ( states )


select location , date , total_cases  , total_deaths , (total_deaths/total_cases)*100 as DeathsPercentage  
from portfolio..CovidDeaths
where location like '%states%'
order by 1 ,2 


--looking at total cases vs population 
---showing the percentage of population that got covid 

select location , date , total_cases  , population , (total_cases/population)*100 as PopulationPercentage  
from portfolio..CovidDeaths
where location like '%states%'
order by 1 ,2  



---Countries with highest rate infection compared to population

select location , population ,max(total_cases) as   highestInfection ,max (total_cases/population)*100 as PercentPopulationInfection  
from portfolio..CovidDeaths
--where location like '%states%'
group by  location , population 
order by PercentPopulationInfection

--showing countries with the highest death count per Population 

select location , population ,max(cast(total_deaths as int)) as   TotalDeath--max (total_deaths/population)*100 as DeathPercentage    
from portfolio..CovidDeaths
where continent is not null
group by  location  , population 
order by TotalDeath DESC

--Highest death Per Continent 

select continent  ,max(cast(total_deaths as int)) as   TotalDeath--max (total_deaths/population)*100 as DeathPercentage    
from portfolio..CovidDeaths
where continent is not null
group by  continent 
order by TotalDeath DESC

--Global Analysis

select sum(new_cases) as Total_Cases , sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int)) /sum(new_cases) *100 as percentageDeaths 
from portfolio..CovidDeaths
where continent is not null 


--Looking at total Population vs vaccination 

select Dea.continent,Dea.location , Dea.date ,Dea.population  , Vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by Dea.location )  as RollVacc
from portfolio..CovidDeaths Dea
join portfolio..CovidVaccinations Vacc
    on Dea.location = Vacc.location
    and Dea.date = Vacc.date 
where dea.continent is not null
order by 1,2,3


--CTE 

with Pop_Vacc ( continent ,location ,date , population ,new_vaccinations, RollVacc)  as
(
select Dea.continent,Dea.location , Dea.date ,Dea.population  , Vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by Dea.location ,dea.date )  as RollVacc
from portfolio..CovidDeaths Dea
join portfolio..CovidVaccinations Vacc
    on Dea.location = Vacc.location
    and Dea.date = Vacc.date 
where dea.continent is not null
--order by 1,2,3)
)
select * , (RollVacc/population)*100 as PercentageVaccPop
from Pop_Vacc



--Temp table 

DROP TABLE IF EXISTS #PercentPopVaccination
CREATE TABLE #PercentPopVaccination 
(
Continent nvarchar (255),
location nvarchar (255) , 
date datetime ,
population numeric,
new_vaccinations numeric ,
RollVacc numeric 
)

INSERT INTO #PercentPopVaccination 
select Dea.continent,Dea.location , Dea.date ,Dea.population  , Vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by Dea.location order by Dea.Date )  as RollVacc
from portfolio..CovidDeaths Dea
join portfolio..CovidVaccinations Vacc
    on Dea.location = Vacc.location
    and Dea.date = Vacc.date 
where dea.continent is not null
--order by 1,2,3)

SELECT *,(RollVacc/ population )*100 
from #PercentPopVaccination

---CREATE VIEW
 
CREATE VIEW PercentPopVaccination AS
select Dea.continent,Dea.location , Dea.date ,Dea.population  , Vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by Dea.location order by Dea.Date )  as RollVacc
from portfolio..CovidDeaths Dea
join portfolio..CovidVaccinations Vacc
    on Dea.location = Vacc.location
    and Dea.date = Vacc.date 
where dea.continent is not null
--order by 1,2,3)
