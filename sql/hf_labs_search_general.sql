SELECT *
FROM hf_d_lab_procedure
WHERE
        (lab_procedure_name ILIKE '%Tryptophan%'
        OR lab_procedure_name ILIKE '%Phosphatase%'
        OR lab_procedure_name ILIKE '%Serum or Plasma%'
        OR lab_procedure_name ILIKE '%Blood%'
        OR lab_procedure_name ILIKE '%Urine%'
        )
        AND lab_procedure_group = 'General Test'
        AND lab_super_group = 'General Test'
        ;