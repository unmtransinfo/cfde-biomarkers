-- Use CLIA_ANALYTES for Leadmine NER -> Create GENE_PROTEIN_ANALYTES table and CHEMICAL_ANALYTES table from results -> Create new analytes tables for Gene and Protein NER counts, and for chemical NER counts


--Import gene or protein analytes from Leadmine NER output
DROP TABLE IF EXISTS GP_NEW;
CREATE TABLE GP_NEW (
                        FILE_NAME        CHARACTER VARYING(300), 
                        LOCATION         CHARACTER VARYING(15), 
                        TYPE             CHARACTER VARYING(30), 
                        AMOUNT           INT, 
                        CORRECTED        INT, 
                        IDENTIFIER           CHARACTER VARYING(10), 
                        ANALYTE_NAME     CHARACTER VARYING(100),
                        UNCORRECTED_NAME CHARACTER VARYING(100)
);
-- COPY GENE_PROTEIN_ANALYTES FROM '/home/nreboul/Documents/FDA_CLIA/CLIA_NER/clia_detail_gene_or_protein_leadmine.csv' WITH CSV HEADER; --postgreSQL
-- FOR H2 DB
INSERT INTO GP_NEW (
                        FILE_NAME, 
                        LOCATION, 
                        TYPE, 
                        AMOUNT,
                        CORRECTED, 
                        IDENTIFIER, 
                        ANALYTE_NAME,
                        UNCORRECTED_NAME
                        )
SELECT * FROM CSVREAD('/home/nreboul/Documents/FDA_CLIA/gp_analytes.tsv', 'FILE_NAME, LOCATION, TYPE, AMOUNT, CORRECTED, IDENTIFIER, ANALYTE_NAME, UNCORRECTED_NAME','UTF8');
ALTER TABLE GP_NEW DROP COLUMN FILE_NAME;
-- FOR H2 DB

--Import chemical analytes from Leadmine NER output, chemical analytes are given SMILES code, gene_or_protein are not
DROP TABLE IF EXISTS CHEMICAL_ANALYTES;
CREATE TABLE CHEMICAL_ANALYTES (
                        FILE_NAME        CHARACTER VARYING(15) NOT NULL, 
                        LOCATION         CHARACTER VARYING(15) NOT NULL, 
                        TYPE             CHARACTER VARYING(15) NOT NULL, 
                        AMOUNT           INT NOT NULL, 
                        CORRECTED        INT NOT NULL, 
                        SMILES           CHARACTER VARYING(700), 
                        ANALYTE_NAME     CHARACTER VARYING(100) NOT NULL,
                        UNCORRECTED_NAME CHARACTER VARYING(100)
);
-- COPY CHEMICAL_ANALYTES FROM '/home/nreboul/Documents/FDA_CLIA/CLIA_NER/clia_detail_chem_leadmine.csv' WITH CSV HEADER; --postgreSQL
-- FOR H2                        
INSERT INTO CHEMICAL_ANALYTES (
                        FILE_NAME, 
                        LOCATION, 
                        TYPE, 
                        AMOUNT,
                        CORRECTED, 
                        SMILES, 
                        ANALYTE_NAME,
                        UNCORRECTED_NAME
                        )
SELECT * FROM CSVREAD('/home/nreboul/Documents/FDA_CLIA/CLIA_NER/clia_detail_chem_leadmine.tsv', 'FILE_NAME, LOCATION, TYPE, AMOUNT, CORRECTED, SMILES, ANALYTE_NAME, UNCORRECTED_NAME','UTF8');
-- FOR H2


-- find analytes recognized as both chemicals and gene or proteins
SELECT ANALYTE_NAME FROM GENE_PROTEIN_ANALYTES
WHERE ANALYTE_NAME IN (SELECT ANALYTE_NAME FROM CHEMICAL_ANALYTES);
              

-- all gene_or_protein with analyte_name changed by Leadmine NER
SELECT ANALYTE_NAME FROM GENE_PROTEIN_ANALYTES
WHERE ANALYTE_NAME NOT IN (SELECT ANALYTE_NAME FROM CLIA_ANALYTES);

-- Table for NER genes and proteins that were resolved
DROP TABLE IF EXISTS GP_IDENTIFY;
CREATE TABLE GP_IDENTIFY(
                          ANALYTE_NAME CHARACTER VARYING(400) NOT NULL,
                          IDENTIFIER CHARACTER VARYING(100)
                          );
INSERT INTO GP_IDENTIFY(ANALYTE_NAME, IDENTIFIER)
SELECT DISTINCT ANALYTE_NAME, IDENTIFIER FROM GP_NEW WHERE ANALYTE_NAME IS NOT NULL;

-- create table of all gene or protein analytes that have a name matched in CLIA records
DROP TABLE IF EXISTS GP_RECORDS;
CREATE TABLE GP_RECORDS(
                           ANALYTE_NAME CHARACTER VARYING(400) NOT NULL
                          );
INSERT INTO GP_RECORDS (ANALYTE_NAME)
SELECT DISTINCT CLIA.ANALYTE_NAME FROM CLIA_ANALYTES CLIA
INNER JOIN GP_NEW GP ON CLIA.ANALYTE_NAME LIKE '%' || GP.ANALYTE_NAME || '%'; -- uses wildcard to see if the clia analytes include the identified gene or protein anywhere within the analyte name

-- create table of all chemical analytes that have a name matched in CLIA records
DROP TABLE IF EXISTS CHEMICALS_FROM_RECORDS;
CREATE TABLE CHEMICALS_FROM_RECORDS(
                           ANALYTE_NAME CHARACTER VARYING(400) NOT NULL
                          );
INSERT INTO CHEMICALS_FROM_RECORDS (ANALYTE_NAME)
SELECT DISTINCT CLIA.ANALYTE_NAME FROM CLIA_ANALYTES CLIA
INNER JOIN CHEMICAL_ANALYTES CH ON CLIA.ANALYTE_NAME LIKE '%' || CH.ANALYTE_NAME || '%';

-- select all analytes from CLIA records that were both identified as including a gene or protein and considered chemical
SELECT * FROM GENE_OR_PROTEIN_FROM_RECORDS AS GP
WHERE GP.ANALYTE_NAME IN (SELECT CH.ANALYTE_NAME FROM CHEMICALS_FROM_RECORDS AS CH);

-- NER gene or protein analyte names most present in CLIA records
SELECT GP.ANALYTE_NAME, COUNT(LOWER(CLIA.ANALYTE_NAME)) AS OCCURRENCE FROM GP_IDENTIFY GP
LEFT JOIN CLIA_TABLE CLIA ON LOWER(CLIA.ANALYTE_NAME) LIKE '%' || GP.ANALYTE_NAME || '%'
GROUP BY GP.ANALYTE_NAME ORDER BY OCCURRENCE DESC;

SELECT ANALYTE_NAME, IDENTIFIER, COUNT(IDENTIFIER) FROM GP_IDENTIFY
GROUP BY ANALYTE_NAME HAVING COUNT(IDENTIFIER) = 1;
SELECT DISTINCT IDENTIFIER, DISTINCT ANALYTE_NAME FROM GP_IDENTIFY WHERE IDENTIFIER IS NOT NULL;
