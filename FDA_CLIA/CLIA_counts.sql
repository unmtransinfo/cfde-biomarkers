SELECT
        SUM(CASE WHEN COMPLEXITY = 'WAIVED' THEN 1 ELSE 0 END) "WAIVED COMPLEXITY #",
        SUM(CASE WHEN COMPLEXITY = 'MODERATE' THEN 1 ELSE 0 END) "MODERATE COMPLEXITY #",
        SUM(CASE WHEN COMPLEXITY = 'HIGH' THEN 1 ELSE 0 END) "HIGH COMPLEXITY #",
        SUM(CASE WHEN COMPLEXITY IN ('WAIVED', 'MODERATE', 'HIGH') THEN 1 ELSE 0 END) "TOTAL",
FROM CLIA_TABLE;

SELECT
        SUM(CASE WHEN SPECIALTY_ID = 1 THEN 1 ELSE 0 END) "URINALYSIS",
        SUM(CASE WHEN SPECIALTY_ID = 2 THEN 1 ELSE 0 END) "GENERAL CHEMISTRY",
        SUM(CASE WHEN SPECIALTY_ID = 3 THEN 1 ELSE 0 END) "GENERAL IMMUNOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 4 THEN 1 ELSE 0 END) "HEMOTOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 5 THEN 1 ELSE 0 END) "IMMUNOHEMATOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 6 THEN 1 ELSE 0 END) "ENDROCRINOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 7 THEN 1 ELSE 0 END) "TOXICOLOGY/TDM",
        SUM(CASE WHEN SPECIALTY_ID = 8 THEN 1 ELSE 0 END) "BACTERIOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 9 THEN 1 ELSE 0 END) "MYCOBACTERIOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 10 THEN 1 ELSE 0 END) "VIROLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 11 THEN 1 ELSE 0 END) "PARASITOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 12 THEN 1 ELSE 0 END) "MYCOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 13 THEN 1 ELSE 0 END) "CYTOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 14 THEN 1 ELSE 0 END) "CYTOGENETICS",
        SUM(CASE WHEN SPECIALTY_ID = 15 THEN 1 ELSE 0 END) "HISTOCOMPATIBILITY",
        SUM(CASE WHEN SPECIALTY_ID = 16 THEN 1 ELSE 0 END) "PATHOLOGY",
        SUM(CASE WHEN SPECIALTY_ID = 17 THEN 1 ELSE 0 END) "SYPHILIS SEROLOGY"
FROM FDA_CLIA_TABLE;

SELECT COUNT(DISTINCT TEST_SYSTEM_NAME) "DISTINCT TEST SYSTEMS #" FROM FDA_CLIA_DATA;
SELECT COUNT(DISTINCT TEST_SYSTEM_ID) "DISTINCT TEST SYSTEM ID #" FROM FDA_CLIA_DATA;
SELECT COUNT(DISTINCT ANALYTE_NAME) "DISTINCT ANALYTES #" FROM FDA_CLIA_DATA;

SELECT LOWER(ANALYTE_NAME), COUNT(LOWER(ANALYTE_NAME)) AS FREQUENCY
FROM (
      SELECT ANALYTE_NAME FROM FDA_CLIA_DATA_OLD
      UNION ALL
      SELECT ANALYTE_NAME FROM CDC_CLIA_DATA
) 
GROUP BY LOWER(ANALYTE_NAME);
        
        
SELECT SUM(FREQUENCY) FROM ANALYTES_FINAL_2;


SELECT ANALYTE_NAME, COUNT(*) FROM CLIA_ANALYTES
GROUP BY ANALYTE_NAME HAVING COUNT(*)>1;

SELECT ANALYTE_NAME FROM CLIA_ANALYTES
WHERE ANALYTE_NAME NOT IN (SELECT ANALYTE_NAME FROM CLIA_ANALYTES_OLD);

SELECT COUNT(DISTINCT TEST_SYSTEM_ID) FROM CLIA_TABLE;

-- Many repeated document numbers? check how many times repeated
SELECT COUNT(DISTINCT DOCUMENT_NUMBER) FROM CLIA_TABLE;
SELECT DOCUMENT_NUMBER, COUNT(DOCUMENT_NUMBER) FROM CLIA_TABLE
GROUP BY DOCUMENT_NUMBER
ORDER BY COUNT(DOCUMENT_NUMBER) DESC;
