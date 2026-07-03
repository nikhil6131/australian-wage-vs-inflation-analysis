-- ============================================
-- Real Wage Growth Analysis (MySQL 8+)
-- Run this AFTER setup_wages_cpi_mysql.sql
-- ============================================
USE WagesCPI_Australia;

WITH joined AS (
  SELECT w.year, w.quarter, w.wage_index, c.cpi_index
  FROM wage_index_quarterly w
  JOIN cpi_quarterly c ON w.year = c.year AND w.quarter = c.quarter
),
with_yoy AS (
  SELECT year, quarter, wage_index, cpi_index,
         ROUND(100.0 * (wage_index - LAG(wage_index, 4) OVER (ORDER BY year, quarter))
               / LAG(wage_index, 4) OVER (ORDER BY year, quarter), 2) AS wage_yoy_pct,
         ROUND(100.0 * (cpi_index - LAG(cpi_index, 4) OVER (ORDER BY year, quarter))
               / LAG(cpi_index, 4) OVER (ORDER BY year, quarter), 2) AS cpi_yoy_pct
  FROM joined
)
SELECT year, quarter, wage_index, cpi_index, wage_yoy_pct, cpi_yoy_pct,
       ROUND(wage_yoy_pct - cpi_yoy_pct, 2) AS real_wage_growth_pct
FROM with_yoy
WHERE wage_yoy_pct IS NOT NULL
ORDER BY year, quarter;
