-- ============================================
-- 02_import_data.sql
-- Loads data from the /data CSV files. Run this SECOND.
--
-- NOTE: LOAD DATA LOCAL INFILE requires local_infile to be enabled.
-- If this fails, use MySQL Workbench's built-in GUI tool instead:
--   Right-click "wage_index_quarterly" table in the schema panel
--   -> Table Data Import Wizard -> select data/wage_price_index.csv
--   Repeat for cpi_quarterly with data/cpi_quarterly.csv
-- Both approaches load the exact same data - use whichever works
-- on your machine.
-- ============================================

USE WagesCPI_Australia;

-- Update the file path below to match where you cloned this repo
LOAD DATA LOCAL INFILE 'data/wage_price_index.csv'
INTO TABLE wage_index_quarterly
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(date, year, quarter, wage_index);

LOAD DATA LOCAL INFILE 'data/cpi_quarterly.csv'
INTO TABLE cpi_quarterly
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(year, quarter, cpi_index);

-- Sanity check
SELECT COUNT(*) AS wage_rows FROM wage_index_quarterly;
SELECT COUNT(*) AS cpi_rows FROM cpi_quarterly;
