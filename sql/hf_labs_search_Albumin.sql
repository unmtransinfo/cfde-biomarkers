-- Exclude urine tests, Prealbumin.
SELECT *
FROM hf_d_lab_procedure
WHERE
        lab_procedure_group = 'Albumin Test'
        AND lab_procedure_name ILIKE 'Albumin%serum%'
        ;
