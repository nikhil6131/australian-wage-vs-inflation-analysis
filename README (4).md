# Australian Wage vs Inflation Analysis

Does wage growth in Australia actually keep up with inflation? I pulled two official datasets from the Australian Bureau of Statistics (ABS) and joined them in SQL to find out.

## The question
Nominal wages have risen every quarter since 2024. But rising wages don't mean people are better off — if prices rise faster than pay, real purchasing power falls. This project calculates **real wage growth** (wage growth minus inflation) to check.

## Data sources
- **Wage Price Index** — ABS, quarterly, 1997–2026 ([abs.gov.au](https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/wage-price-index-australia/latest-release))
- **Consumer Price Index (CPI)** — ABS, monthly, aggregated to quarterly, 2024–2026 ([abs.gov.au](https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/latest-release))

## Repo structure
```
├── data/
│   ├── wage_price_index.csv      # raw wage data, exported from ABS
│   └── cpi_quarterly.csv         # CPI aggregated to quarterly
├── sql/
│   ├── 01_create_tables.sql      # schema
│   ├── 02_import_data.sql        # loads the CSVs into MySQL
│   └── 03_analysis.sql           # the actual analysis: JOIN + CTE + window function
├── screenshots/
│   └── sql_query_and_results.png
└── README.md
```

## How to run it
1. Run `sql/01_create_tables.sql` to create the database and schema
2. Run `sql/02_import_data.sql` to load the CSVs (or use MySQL Workbench's Table Data Import Wizard if `LOAD DATA LOCAL INFILE` is disabled on your machine — instructions are in the file)
3. Run `sql/03_analysis.sql` to get the results

## The analysis
```sql
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
```

`LAG(wage_index, 4)` looks back 4 quarters (one year) to compute a proper year-on-year growth rate for both series. Real wage growth = wage YoY% − CPI YoY%.

## Results

| Year | Qtr | Wage YoY % | CPI YoY % | Real wage growth % |
|------|-----|-----------|-----------|---------------------|
| 2025 | Q2  | 3.38      | 2.13      | +1.25 |
| 2025 | Q3  | 3.40      | 3.24      | +0.16 |
| 2025 | Q4  | 3.44      | 3.67      | -0.23 |
| 2026 | Q1  | 3.22      | 4.04      | -0.82 |

**Note on the earliest quarter:** the analysis starts at Q2 2025 rather than Q1, because `LAG(wage_index, 4)` needs 4 prior quarters of CPI data to compute a valid year-on-year figure, and the CPI dataset only goes back to Q2 2024.

## The finding
Real wage growth weakened every quarter across this window and turned negative by Q1 2026 — nominal wages kept rising, but inflation rose faster, meaning Australians lost purchasing power year-on-year despite bigger paychecks.

## Tools
MySQL, SQL (CTEs, window functions, multi-table JOINs), data sourced and cleaned from ABS Excel exports.

## Author
Nikhil Chhetri — [LinkedIn](https://www.linkedin.com/in/nikhilchhetrianalytics) | [Portfolio](https://codebasics.io/portfolio/NikhilChhetri)
