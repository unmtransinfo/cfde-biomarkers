-- Lab tests for Hemoglobin A1C (Glycosylated Hemoglobin)
-- 
SELECT *
FROM hf_d_lab_procedure
WHERE
        lab_procedure_name ILIKE 'Hemoglobin%A1C%'
        ;