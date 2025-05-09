-- Create FDA_CLIA_TABLE using newest clia_detail.txt -> Create CDC_CLIA_TABLE from clia_cdc.txt -> Combine into one table, CLIA_TABLE -> Create table of all unique analytes from CLIA_TABLE -> Save csv file for NER

-- Create table for updated CLIA data
DROP TABLE IF EXISTS FDA_CLIA_TABLE;
CREATE TABLE FDA_CLIA_TABLE (
        DOCUMENT_NUMBER  CHARACTER VARYING(200) NOT NULL, 
        TEST_SYSTEM_ID   BIGINT, 
        TEST_SYSTEM_NAME CHARACTER VARYING(400) NOT NULL, 
        QUALIFIER1       CHARACTER VARYING(400), 
        QUALIFIER2       CHARACTER VARYING(600), 
        ANALYTE_ID       BIGINT NOT NULL, 
        ANALYTE_NAME     CHARACTER VARYING(400) NOT NULL, 
        SPECIALTY_ID     BIGINT NOT NULL, 
        COMPLEXITY       CHARACTER VARYING(20) NOT NULL, 
        DATE_EFFECTIVE   CHARACTER VARYING(30) NOT NULL 
);
-- COPY my_table FROM '/home/nreboul/Documents/FDA_CLIA/clia_detail.txt' WITH DELIMITER '|' CSV HEADER; -- Fill table for POSTGRESQL

-- # Fill table if using H2 DB (remove for postgreSQL) # -- 
INSERT INTO FDA_CLIA_TABLE (
                        DOCUMENT_NUMBER,
                        TEST_SYSTEM_ID,
                        TEST_SYSTEM_NAME,
                        QUALIFIER1,
                        QUALIFIER2,
                        ANALYTE_ID,
                        ANALYTE_NAME,
                        SPECIALTY_ID,
                        COMPLEXITY,
                        DATE_EFFECTIVE
                        )
SELECT * FROM CSVREAD('/home/nreboul/Documents/FDA_CLIA/clia_detail.txt', NULL, 'UTF-8', '|');
-- # Fill table if using H2 DB (remove for postgreSQL) # --


-- Create Table for CDC CLIA DATA Pre-Feb 2000
DROP TABLE IF EXISTS CDC_CLIA_DATA;
CREATE TABLE CDC_CLIA_DATA ( 
        ID               BIGINT NOT NULL, 
        DOCUMENT_NUMBER  CHARACTER VARYING(10), 
        TEST_SYSTEM_ID   BIGINT NOT NULL, 
        TEST_SYSTEM_NAME CHARACTER VARYING(100) NOT NULL, 
        QUALIFIER1       CHARACTER VARYING(100), 
        QUALIFIER2       CHARACTER VARYING(100), 
        ANALYTE_ID       BIGINT NOT NULL, 
        ANALYTE_NAME     CHARACTER VARYING(100) NOT NULL, 
        SPECIALTY_ID     BIGINT NOT NULL, 
        COMPLEXITY       CHARACTER VARYING(10) NOT NULL, 
        DATE_EFFECTIVE   CHARACTER VARYING(30) NOT NULL 
    );
-- COPY my_table FROM '/home/nreboul/Documents/FDA_CLIA/corr_CDC.txt' WITH DELIMITER '|' CSV HEADER; -- Fill table for POSTGRESQL
-- # Fill table if using H2 DB (remove for postgreSQL) # --
INSERT INTO CDC_CLIA_DATA (
                        ID,
                        DOCUMENT_NUMBER,
                        TEST_SYSTEM_ID,
                        TEST_SYSTEM_NAME,
                        QUALIFIER1,
                        QUALIFIER2,
                        ANALYTE_ID,
                        ANALYTE_NAME,
                        SPECIALTY_ID,
                        COMPLEXITY,
                        DATE_EFFECTIVE
                        )
SELECT * FROM CSVREAD('/home/nreboul/Documents/FDA_CLIA/corr_CDC.txt', NULL, 'UTF-8', '|');
-- # Fill table if using H2 DB (remove for postgreSQL) # --

-- Make combined CLIA table from FDA and CDC files
DROP TABLE IF EXISTS CLIA_TABLE;
CREATE TABLE CLIA_TABLE (
        DOCUMENT_NUMBER  CHARACTER VARYING(200), 
        TEST_SYSTEM_ID   BIGINT, 
        TEST_SYSTEM_NAME CHARACTER VARYING(400) NOT NULL, 
        QUALIFIER1       CHARACTER VARYING(400), 
        QUALIFIER2       CHARACTER VARYING(600), 
        ANALYTE_ID       BIGINT NOT NULL, 
        ANALYTE_NAME     CHARACTER VARYING(400) NOT NULL, 
        SPECIALTY_ID     BIGINT NOT NULL, 
        COMPLEXITY       CHARACTER VARYING(20) NOT NULL, 
        DATE_EFFECTIVE   CHARACTER VARYING(30) NOT NULL 
);
-- Importing data using CSVREAD function
INSERT INTO CLIA_TABLE (
                        DOCUMENT_NUMBER,
                        TEST_SYSTEM_ID,
                        TEST_SYSTEM_NAME,
                        QUALIFIER1,
                        QUALIFIER2,
                        ANALYTE_ID,
                        ANALYTE_NAME,
                        SPECIALTY_ID,
                        COMPLEXITY,
                        DATE_EFFECTIVE
                        )
SELECT DOCUMENT_NUMBER, TEST_SYSTEM_ID, TEST_SYSTEM_NAME, QUALIFIER1, QUALIFIER2, ANALYTE_ID, ANALYTE_NAME, SPECIALTY_ID, COMPLEXITY, DATE_EFFECTIVE FROM FDA_CLIA_TABLE
UNION
SELECT DOCUMENT_NUMBER, TEST_SYSTEM_ID, TEST_SYSTEM_NAME, QUALIFIER1, QUALIFIER2, ANALYTE_ID, ANALYTE_NAME, SPECIALTY_ID, COMPLEXITY, DATE_EFFECTIVE FROM CDC_CLIA_DATA;

-- Create table of analytes by their occurrence in CLIA files
DROP TABLE IF EXISTS CLIA_ANALYTES;
CREATE TABLE CLIA_ANALYTES(
                           ANALYTE_NAME CHARACTER VARYING(400) NOT NULL,
                           OCCURRENCE   BIGINT NOT NULL
                          );
-- Fill table with all analytes from FDA and CDC files and their occurrence with no overlap (LOWER)
INSERT INTO CLIA_ANALYTES (ANALYTE_NAME, OCCURRENCE)
-- Set to lowecase to avoid duplicates
SELECT LOWER(ANALYTE_NAME), COUNT(LOWER(ANALYTE_NAME)) AS OCCURRENCE
FROM (SELECT ANALYTE_NAME FROM CLIA_TABLE)
GROUP BY LOWER(ANALYTE_NAME)
ORDER BY OCCURRENCE DESC;

-- Sum of occurrences must match total entries in CLIA data, there should only be one value if accounts for all analytes in records
SELECT SUM(OCCURRENCE) as "TOTAL OCCURRENCES" FROM CLIA_ANALYTES
UNION
SELECT SELECT COUNT(*) FROM CLIA_TABLE AS "TOTAL CLIA RECORDS";

-- Save CLIA_ANALYTES as a .csv file to run Leadmine NER
--COPY CLIA_ANALYTES TO '/home/nreboul/Documents/FDA_CLIA/clia_analytes.csv' WITH CSV HEADER; -- POSTGRESQL
CALL CSVWRITE('/home/nreboul/Documents/FDA_CLIA/clia_analytes.csv', 'SELECT * FROM CLIA_ANALYTES'); -- H2

