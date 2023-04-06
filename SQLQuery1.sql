SELECT *
FROM SQLProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM SQLProject..CovidVaccinations$
ORDER BY 3,4

SELECT location,date,total_cases,new_cases, total_cases,total_deaths,population
FROM SQLProject..CovidDeaths$
order by 1,2


--looking at total cases vs death
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM SQLProject..CovidDeaths$
WHERE location LIKE '%nigeria%'
order by 1,2


--looking at total cases vs total population, shows percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as Deathpercentage
FROM SQLProject..CovidDeaths$
--WHERE location LIKE '%states%'
order by 1,2

--countries population rate
SELECT location,date,total_cases,population,(total_cases/population)*100 as infectedpopulationpercentage
FROM SQLProject..CovidDeaths$
--WHERE location LIKE '%states%'
order by 1,2



--countires with the highest infection rate

SELECT location,population,MAX(total_cases) AS Highestinfectioncount,(MAX(total_cases)/population)*100 as infectedpopulationpercentage
FROM SQLProject..CovidDeaths$
GROUP BY location,population
order by infectedpopulationpercentage desc

--countries with highest death count perpopulaton
SELECT location,MAX(CAST(total_deaths as INT)) AS Totaldeathcount
FROM SQLProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
order by Totaldeathcount desc

--By continent

SELECT continent,MAX(CAST(total_deaths as INT)) AS Totaldeathcount
FROM SQLProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by Totaldeathcount desc;



SELECT location,MAX(CAST(total_deaths as INT)) AS Totaldeathcount
FROM SQLProject..CovidDeaths$
WHERE continent is  null
GROUP BY location
order by Totaldeathcount desc


--Global numbers
SELECT SUM(new_cases)  as  total_cases,  SUM(CAST(new_deaths  as int))  as total_deaths,
SUM(CAST(new_deaths  as int))/SUM(new_cases)* 100 as deathpercentage
FROM SQLProject..CovidDeaths$
WHERE continent is not Null
--group by date
order by 1,2;


--covid_vaccine
select*
From SQLProject..CovidDeaths$ as dth
 JOIN SQLProject..CovidVaccinations$ as vacc
	 ON dth.location =vacc.location
	and dth.date = vacc.date
WHERE dth.continent is not null
order by 3,4




select dth.continent, dth.location, dth.date,dth.population, vacc.new_vaccinations
From SQLProject..CovidDeaths$ as dth
 JOIN SQLProject..CovidVaccinations$ as vacc
	ON dth.location =vacc.location
	and dth.date = vacc.date
WHERE dth.continent is not null
order by 2,3

--cte

with PopvsVac(continent, location, Date, Population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dth.continent, dth.location, dth.date,dth.population, vacc.new_vaccinations,
sum(CONVERT(int,vacc.new_vaccinations)) Over (partition by dth.location order by dth.date) as Rollingpeoplevaccinated
From SQLProject..CovidDeaths$ as dth
 JOIN SQLProject..CovidVaccinations$ as vacc
	ON dth.location =vacc.location
	and dth.date = vacc.date
WHERE dth.continent is not null
)
select *, (Rollingpeoplevaccinated/Population)* 100
FROM PopvsVac



--TEMP TABLE

create Table  #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO  #PercentPopulationVaccinated
SELECT dth.continent, dth.location, dth.date,dth.population, vacc.new_vaccinations,
sum(CONVERT(int,vacc.new_vaccinations)) Over (partition by dth.location order by dth.date) as Rollingpeoplevaccinated
From SQLProject..CovidDeaths$ as dth
 JOIN SQLProject..CovidVaccinations$ as vacc
	ON dth.location =vacc.location
	and dth.date = vacc.date
--WHERE dth.continent is not null

select *, (Rollingpeoplevaccinated/Population)* 100
FROM #PercentPopulationVaccinated