-- ============================================
-- 01_create_tables.sql
-- Creates the schema. Run this FIRST.
-- ============================================

CREATE DATABASE IF NOT EXISTS WagesCPI_Australia;
USE WagesCPI_Australia;

DROP TABLE IF EXISTS wage_index_quarterly;
CREATE TABLE wage_index_quarterly (
    date DATE PRIMARY KEY,
    year INT,
    quarter INT,
    wage_index DECIMAL(6,2)
);

DROP TABLE IF EXISTS cpi_quarterly;
CREATE TABLE cpi_quarterly (
    year INT,
    quarter INT,
    cpi_index DECIMAL(6,2),
    PRIMARY KEY (year, quarter)
);
