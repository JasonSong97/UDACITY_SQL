CREATE VIEW deforestation AS
SELECT 
     f.country_code,
     f.country_name,
     f.year,
     f.forest_area_sqkm,
     l.total_area_sq_mi * 2.59 as total_area_sq_km,
     r.region,
     r.income_group,
     100.0*(fa.forest_area_sqkm / (l.total_area_sq_mi * 2.59)) AS percentage
     FROM forest_area AS f, land_area AS l, regions AS r
     WHERE (
          f.country_code  = l.country_code AND 
          f.year = l.year AND 
          r.country_code = l.country_code
     );

-- Global Situation
-- 1)
SELECT 
     SUM(forest_area_sqkm) as total_forest_area
     FROM forest_area
     WHERE year = 1990 and country_name = 'World';

-- 2)
SELECT 
     SUM(forest_area_sqkm) as total_forest_area
     FROM forest_area
     WHERE year = 2016 AND country_name = 'World';

-- 3)
SELECT  
     fp.forest_area_sqkm - fc.forest_area_sqkm as difference
     FROM forest_area AS fc
     JOIN forest_area AS fp
          ON (fc.year = '2016' AND fp.year = '1990' AND fc.country_name = 'World' AND fp.country_name = 'World');

-- 4)
SELECT
     COALESCE(fc.forest_area_sqkm, 0) - COALESCE(fp.forest_area_sqkm, 0) as difference
     FROM forest_area AS fc
     JOIN forest_area AS fa_previous
          ON fc.year = '2016' AND fp.year = '1990' AND fc.country_name = 'World' AND fp.country_name = 'World';

-- 5)
SELECT  
     100 * (fp.forest_area_sqkm - fc.forest_area_sqkm)/fp.forest_area_sqkm  as difference
     FROM forest_area AS fc
     JOIN forest_area AS fp
          ON (fc.year = '2016' AND fp.year = '1990' AND fc.country_name = 'World' AND fp.country_name = 'World');

-- 6)
SELECT 
     year,
     country_name,
     total_area_sq_mi * 2.59 as total_area_sqkm
     FROM land_area
WHERE 
    year = 2016 AND total_area_sq_mi * 2.59 >= 1200000
ORDER BY 
    total_area_sqkm 


-- Regional Outlook
-- 1)
SELECT
    f.country_name,
    f.year,
    f.forest_area_sqkm,
    la.total_area_sq_mi * 2.59 as total_area_sq_km,
    ROUND(CAST(100 * f.forest_area_sqkm/(la.total_area_sq_mi * 2.59) AS NUMERIC),2) as percent_forest_entire_world
FROM
    forest_area f
JOIN land_area as la 
	ON 
    (la.year = 2016 AND f.year = 2016
    AND  f.country_name = 'World' AND la.country_name = 'World')

-- 1-2)

WITH table_1 AS(
SELECT 
    a.region,
    SUM(a.forest_area_sqkm) region_forest_2016,
    SUM(a.total_area_sq_km) region_area_2016
FROM  deforestation a, deforestation b
WHERE  
    a.year = '2016' AND a.country_code != 'World'
    AND a.region = b.region
GROUP  BY a.region)
SELECT 
    table_1.region,
    ROUND(CAST((region_forest_2016/ region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016
FROM table_1
ORDER BY forest_percent_2016 DESC


-- 1-3)

WITH table_1 AS(
SELECT 
    a.region,
    SUM(a.forest_area_sqkm) region_forest_2016,
    SUM(a.total_area_sq_km) region_area_2016
FROM  deforestation a, deforestation b
WHERE  
    a.year = '2016' AND a.country_code != 'World'
    AND a.region = b.region
GROUP  BY a.region)
SELECT 
    table_1.region,
    ROUND(CAST((region_forest_2016/ region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016
FROM table_1
ORDER BY forest_percent_2016

-- 2)
SELECT
    f.country_name,
    f.year,
    f.forest_area_sqkm,
    la.total_area_sq_mi * 2.59 as total_area_sq_km,
    ROUND(CAST(100 * f.forest_area_sqkm/(la.total_area_sq_mi * 2.59) AS NUMERIC),2) as percent_forest_entire_world
FROM
    forest_area f
JOIN land_area as la 
	ON 
    (la.year = 2016 AND f.year = 2016
    AND  f.country_name = 'World' AND la.country_name = 'World')


-- 2-1)

WITH table_1 AS(
SELECT 
    a.region,
    SUM(a.forest_area_sqkm) region_forest_1990,
    SUM(a.total_area_sq_km) region_area_1990
FROM  deforestation a, deforestation b
WHERE  
    a.year = '1990' AND a.country_code != 'World'
    AND a.region = b.region
GROUP  BY a.region)
SELECT 
    table_1.region,
    ROUND(CAST((region_forest_1990/ region_area_1990) * 100 AS NUMERIC), 2) AS forest_percent_1990
FROM table_1
ORDER BY forest_percent_1990 DESC



-- 3)

WITH table_1 AS(
SELECT 
    a.region,
    SUM(a.forest_area_sqkm) region_forest_1990,
    SUM(a.total_area_sq_km) region_area_1990,
    SUM(b.forest_area_sqkm) region_forest_2016,
    SUM(b.total_area_sq_km) region_area_2016
FROM  deforestation a, deforestation b
WHERE  
    a.year = '1990' AND a.country_code != 'World' AND
    b.year = '2016' AND b.country_code != 'World'
    AND a.region = b.region
GROUP  BY a.region)
SELECT 
    table_1.region,
    ROUND(CAST((region_forest_1990/ region_area_1990) * 100 AS NUMERIC), 2) AS forest_percent_1990,
    ROUND(CAST((region_forest_2016/ region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016,
    (region_forest_1990 / region_area_1990) * 100  - (region_forest_2016 / region_area_2016) * 100 AS decrease_1990_2016
FROM table_1
ORDER BY decrease_1990_2016 DESC


-- Country-Level Detail
-- 1)
SELECT
    fa_current.country_name,
    fa_current.forest_area_sqkm as forest_area_sqkm_2016,
    fa_previous.forest_area_sqkm as forest_area_sqkm_1990,
    fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm as difference
FROM 
    forest_area AS fa_current
JOIN 
    forest_area AS fa_previous
  ON 
    (fa_current.year = '2016' AND fa_previous.year = '1990'
    AND fa_current.country_name = fa_previous.country_name
    )
WHERE 
    fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm IS NOT NULL
 ORDER BY difference DESC
 LIMIT 5;

-- =2)

SELECT
    fa_current.country_name,
    fa_current.forest_area_sqkm as forest_area_sqkm_2016,
    fa_previous.forest_area_sqkm as forest_area_sqkm_1990,
    fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm as difference,
    ROUND(CAST(100 *  (fa_current.forest_area_sqkm/(fa_previous.forest_area_sqkm)) AS NUMERIC),2) as forest_area_fraction
FROM 
    forest_area AS fa_current
JOIN 
    forest_area AS fa_previous
  ON 
    (fa_current.year = '2016' AND fa_previous.year = '1990'
    AND fa_current.country_name = fa_previous.country_name
    )
WHERE 
    fa_current.forest_area_sqkm - fa_previous.forest_area_sqkm IS NOT NULL
 ORDER BY forest_area_fraction
 LIMIT 5;




-- 3)
WITH quartile_cte AS (
  SELECT
    country_name,
    CASE
      WHEN percentage <= 25 THEN '0-25%'
      WHEN percentage <= 50 THEN '25-50%'
      WHEN percentage <= 75 THEN '50-75%'
      ELSE '75-100%'
    END AS quartiles
  FROM
    deforestation
  WHERE
    percentage IS NOT NULL
    AND year = 2016
)

SELECT
  DISTINCT quartiles,
  COUNT(country_name) OVER (PARTITION BY quartiles) AS country_count
FROM
  quartile_cte;


-- 4)


WITH quartile_cte AS (
  SELECT
    country_name,
    CASE
      WHEN percentage <= 25 THEN '0-25%'
      WHEN percentage <= 50 THEN '25-50%'
      WHEN percentage <= 75 THEN '50-75%'
      ELSE '75-100%'
    END AS quartiles
  FROM
    deforestation
  WHERE
    percentage IS NOT NULL
    AND year = 2016
)
SELECT
    country_name
FROM
    quartile_cte
WHERE quartiles = '75-100%'



-- 5)
SELECT 
    COUNT(*) as count_bigger_USA 
    FROM deforestation
WHERE 
    deforestation.year = 2016 AND
    deforestation.percentage >(SELECT deforestation.percentage FROM deforestation WHERE country_name = 'United States'AND YEAR = 2016)


-- 6)
SELECT 
     country_name, 
     percentage
     FROM deforestation
     WHERE 
          percentage > 75 AND year = 2016;