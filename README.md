# Real Wage Growth in Australia: Are Wages Keeping Up With Inflation? (2024–2026)

**Author:** Nikhil Chhetri
**Data sources:** Australian Bureau of Statistics — Wage Price Index (Table 1, quarterly, 1997–2026) and Consumer Price Index (Table 3, monthly, 2024–2026)
**Tools:** SQL (SQLite) — multi-table JOIN, CTEs, window functions (LAG)

## The business question
Nominal wages in Australia have been rising every quarter. But rising wages don't mean people are better off — if prices rise faster than pay, real purchasing power falls. This project answers: **has real wage growth in Australia been positive or negative since early 2024?**

## Data engineering
Two independent ABS datasets, different native frequencies:
- Wage Price Index — quarterly, back to 1997
- CPI — monthly, back to April 2024 (the ABS only began full monthly CPI reporting in 2025)

CPI was aggregated to quarterly averages to align with the wage series, then joined on `(year, quarter)`.

## Key query — JOIN + CTE + window function
```sql
WITH joined AS (
  SELECT w.year, w.quarter, w.wage_index, c.cpi_index
  FROM wage_index_quarterly w
  JOIN cpi_quarterly c ON w.year = c.year AND w.quarter = c.quarter
),
with_yoy AS (
  SELECT year, quarter, wage_index, cpi_index,
         ROUND(100.0*(wage_index - LAG(wage_index,4) OVER (ORDER BY year,quarter))
               / LAG(wage_index,4) OVER (ORDER BY year,quarter), 2) AS wage_yoy_pct,
         ROUND(100.0*(cpi_index - LAG(cpi_index,4) OVER (ORDER BY year,quarter))
               / LAG(cpi_index,4) OVER (ORDER BY year,quarter), 2) AS cpi_yoy_pct
  FROM joined
)
SELECT year, quarter, wage_index, cpi_index, wage_yoy_pct, cpi_yoy_pct,
       ROUND(wage_yoy_pct - cpi_yoy_pct, 2) AS real_wage_growth_pct
FROM with_yoy
ORDER BY year, quarter;
```

## Results

| Year | Qtr | Wage YoY % | CPI YoY % | Real wage growth % |
|------|-----|-----------|-----------|---------------------|
| 2025 | Q2  | 3.38      | 2.13      | **+1.25** |
| 2025 | Q3  | 3.40      | 3.24      | **+0.16** |
| 2025 | Q4  | 3.44      | 3.67      | **-0.23** |
| 2026 | Q1  | 3.22      | 4.04      | **-0.82** |

## The finding
Nominal wages grew every quarter — but **real wage growth flipped negative in late 2025 and kept worsening into early 2026**, as inflation accelerated faster than pay. By Q1 2026, workers were effectively 0.82% worse off year-on-year in real terms, despite headline wage growth of 3.22%. This is the gap between the headline "wages are rising" narrative and what people actually feel in their pocket.

## Why this matters
This mirrors the analytical instinct behind my procurement work at Naval Dockyard Mumbai — comparing supplier quotes against market benchmarks rather than trusting a single number in isolation. Here, wages alone looked fine; only joining against inflation revealed the real trend.
