CREATE VIEW deforestation AS
SELECT 
     fa.country_code,
     fa.country_name,
     fa.year,
     fa.forest_area_sqkm,
     la.total_area_sq_mi * 2.59 as total_area_sq_km,
     r.region,
     r.income_group,
     100.0*(fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)) AS percentage
     FROM forest_area AS fa, land_area AS la, regions AS r
     WHERE (
          fa.country_code  = la.country_code AND fa.year = la.year AND r.country_code = la.country_code);

-- Global Situation
-- 1. What was the total forest area (in sq km) of the world in 1990? 
     -- Please keep in mind that you can use the country record denoted as “World" in the region table.
     -- 41282694.9
SELECT 
     SUM(forest_area_sqkm) as total_forest_area
     FROM forest_area
     WHERE year = 1990 and country_name = 'World';
-- 2. What was the total forest area (in sq km) of the world in 2016? 
     -- Please keep in mind that you can use the country record in the table is denoted as “World.
     -- 39958245.9
SELECT 
     SUM(forest_area_sqkm) as total_forest_area
     FROM forest_area
     WHERE year = 2016 AND country_name = 'World';
-- 3. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
     -- 1324449
SELECT  
     fa_previous.forest_area_sqkm - fa_current.forest_area_sqkm as difference
     FROM rest_area AS fa_current
     JOIN forest_area AS fa_previous
          ON (fa_current.year = '2016' AND fa_previous.year = '1990' AND fa_current.country_name = 'World' AND fa_previous.country_name = 'World');

SELECT
     COALESCE(fa_current.forest_area_sqkm, 0) - COALESCE(fa_previous.forest_area_sqkm, 0) as difference
     FROM forest_area AS fa_current
     JOIN forest_area AS fa_previous
          ON fa_current.year = '2016' AND fa_previous.year = '1990' AND fa_current.country_name = 'World' AND fa_previous.country_name = 'World';
-- 4. What was the percent change in forest area of the world between 1990 and 2016?
     -- 3.208
SELECT  
     100 * (fa_previous.forest_area_sqkm - fa_current.forest_area_sqkm)/fa_previous.forest_area_sqkm  as difference
     FROM forest_area AS fa_current
     JOIN forest_area AS fa_previous
          ON (fa_current.year = '2016' AND fa_previous.year = '1990' AND fa_current.country_name = 'World' AND fa_previous.country_name = 'World');
-- 5. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?
     -- Peru 1279999.9891
SELECT 
     year,
     country_name,
     total_area_sq_mi * 2.59 as total_area_sqkm
     FROM land_area
     WHERE year = 2016 AND total_area_sq_mi * 2.59 >= 1200000
     ORDER BY total_area_sqkm; 


-- Regional Outlook
-- 1.1 What was the percent forest of the entire world in 2016? 
     -- 31.38%
SELECT
     f.country_name,
     f.year,
     f.forest_area_sqkm,
     la.total_area_sq_mi * 2.59 as total_area_sq_km,
     ROUND(CAST(100 * f.forest_area_sqkm/(la.total_area_sq_mi * 2.59) AS NUMERIC),2) as percent_forest_entire_world
     FROM forest_area f
     JOIN land_area as la 
	     ON (la.year = 2016 AND f.year = 2016 AND f.country_name = 'World' AND la.country_name = 'World');

-- 1.2 Which region had the HIGHEST percent forest in 2016?
     -- Latin America & Caribbean: 46.16%
WITH table_1 AS(
     SELECT 
          a.region,
          SUM(a.forest_area_sqkm) region_forest_2016,
          SUM(a.total_area_sq_km) region_area_2016
     FROM deforestation a, deforestation b
     WHERE a.year = '2016' AND a.country_code != 'World' AND a.region = b.region
     GROUP  BY a.region)
SELECT 
     table_1.region,
     ROUND(CAST((region_forest_2016/ region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016
     FROM table_1
     ORDER BY forest_percent_2016 DESC;


-- 1.3 ... and which had the LOWEST, to 2 decimal places?
     -- Middle East & North Africa: 2.07%
WITH table_1 AS(
     SELECT 
          a.region,
          SUM(a.forest_area_sqkm) region_forest_2016,
          SUM(a.total_area_sq_km) region_area_2016
     FROM  deforestation a, deforestation b
     WHERE  a.year = '2016' AND a.country_code != 'World' AND a.region = b.region
     GROUP  BY a.region)
SELECT 
     table_1.region,
     ROUND(CAST((region_forest_2016/ region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016
     FROM table_1
     ORDER BY forest_percent_2016;
-- 2. What was the percent forest of the entire world in 1990? 
-- 32.42%
SELECT
     f.country_name,
     f.year,
     f.forest_area_sqkm,
     la.total_area_sq_mi * 2.59 as total_area_sq_km,
     ROUND(CAST(100 * f.forest_area_sqkm/(la.total_area_sq_mi * 2.59) AS NUMERIC),2) as percent_forest_entire_world
     FROM forest_area f
     JOIN land_area as la 
          ON (la.year = 2016 AND f.year = 2016 AND f.country_name = 'World' AND la.country_name = 'World');


-- 2.1
--Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
     -- Latin America 51.03%
     --Middle East & North Africa 1.78%
WITH table_1 AS(
     SELECT 
          a.region,
          SUM(a.forest_area_sqkm) region_forest_1990,
          SUM(a.total_area_sq_km) region_area_1990
     FROM deforestation a, deforestation b
     WHERE a.year = '1990' AND a.country_code != 'World' AND a.region = b.region
     GROUP  BY a.region)
SELECT 
     table_1.region,
     ROUND(CAST((region_forest_1990/ region_area_1990) * 100 AS NUMERIC), 2) AS forest_percent_1990
     FROM table_1
     ORDER BY forest_percent_1990 DESC;
-- 3. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
-- Latin America & Caribbean: 4.87%.
WITH table_1 AS(
     SELECT 
          a.region,
          SUM(a.forest_area_sqkm) region_forest_1990,
          SUM(a.total_area_sq_km) region_area_1990,
          SUM(b.forest_area_sqkm) region_forest_2016,
          SUM(b.total_area_sq_km) region_area_2016
     FROM  deforestation a, deforestation b
     WHERE a.year = '1990' AND a.country_code != 'World' AND b.year = '2016' AND b.country_code != 'World' AND a.region = b.region
     GROUP  BY a.region)
SELECT 
     table_1.region,
     ROUND(CAST((region_forest_1990/ region_area_1990) * 100 AS NUMERIC), 2) AS forest_percent_1990,
     ROUND(CAST((region_forest_2016/ region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016,
     (region_forest_1990 / region_area_1990) * 100  - (region_forest_2016 / region_area_2016) * 100 AS decrease_1990_2016
     FROM table_1
     ORDER BY decrease_1990_2016 DESC;

-- Country-Level Detail
-- 1. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
     -- China 527229.062
     -- United States 79200
     -- India 69213.9844
     -- Russian Federation 59395
     -- Vietnam 55390
SELECT
     fa_current.country_name,
     fa_current.forest_area_sqkm as forest_area_sqkm_2016,
     fa_previous.forest_area_sqkm as forest_area_sqkm_1990,
     fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm as difference
     FROM forest_area AS fa_current
     JOIN forest_area AS fa_previous
          ON (fa_current.year = '2016' AND fa_previous.year = '1990' AND fa_current.country_name = fa_previous.country_name)
     WHERE fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm IS NOT NULL
     ORDER BY difference DESC
     LIMIT 5;
-- 2. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
     -- Togo 1-0.2455
     -- Nigeria 1-0.3820
     -- Uganda 1-0.4087
     -- Mauritania 1-0.5325
     -- Honduras 1-0.5497
SELECT
     fa_current.country_name,
     fa_current.forest_area_sqkm as forest_area_sqkm_2016,
     fa_previous.forest_area_sqkm as forest_area_sqkm_1990,
     fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm as difference,
     ROUND(CAST(100 *  (fa_current.forest_area_sqkm/(fa_previous.forest_area_sqkm)) AS NUMERIC),2) as forest_area_fraction
     FROM forest_area AS fa_current
     JOIN forest_area AS fa_previous
          ON (fa_current.year = '2016' AND fa_previous.year = '1990' AND fa_current.country_name = fa_previous.country_name)
     WHERE fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm IS NOT NULL
     ORDER BY forest_area_fraction
     LIMIT 5;
-- 3. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
     -- 9 countries in the first quantile
WITH quartile_cte AS (
     SELECT
          country_name,
          CASE
               WHEN percentage <= 25 THEN '0-25%'
               WHEN percentage <= 50 THEN '25-50%'
               WHEN percentage <= 75 THEN '50-75%'
               ELSE '75-100%'
          END AS quartiles
     FROM deforestation
     WHERE percentage IS NOT NULL AND year = 2016)
SELECT
     DISTINCT quartiles,
     COUNT(country_name) OVER (PARTITION BY quartiles) AS country_count
FROM quartile_cte;
-- 4. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
     --American Samoa
     --Micronesia, Fed. Sts.
     --Gabon
     --Guyana
     --Lao PDR
     --Palau
     --Solomon Islands
     --Suriname
     --Seychelles
WITH quartile_cte AS (
     SELECT
          country_name,
          CASE
               WHEN percentage <= 25 THEN '0-25%'
               WHEN percentage <= 50 THEN '25-50%'
               WHEN percentage <= 75 THEN '50-75%'
               ELSE '75-100%'
          END AS quartiles
     FROM deforestation
     WHERE percentage IS NOT NULL AND year = 2016)
SELECT
     country_name
     FROM quartile_cte
     WHERE quartiles = '75-100%';
-- 5. How many countries had a percent forestation higher than the United States in 2016?
     -- 94 countries
SELECT 
     COUNT(*) as count_bigger_USA 
     FROM deforestation
     WHERE deforestation.year = 2016 AND deforestation.percentage > (
          SELECT deforestation.percentage 
               FROM deforestation 
               WHERE country_name = 'United States' AND YEAR = 2016)

-- Top Quartile Countries, 2016:
SELECT 
     country_name, 
     percentage
     FROM deforestation
     WHERE percentage > 75 AND year = 2016;