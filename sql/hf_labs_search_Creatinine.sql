SELECT *
FROM hf_d_lab_procedure
WHERE
        lab_procedure_group = 'Creatinine Test, Urine'
        OR lab_procedure_name ILIKE '%creatinine%urine%'
        ;