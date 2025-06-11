SELECT
        dlp.loinc_code,
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,
        dlp.lab_procedure_name,        
        dlp.lab_procedure_group,
        dlp.lab_super_group
FROM
        public.hf_d_lab_procedure dlp
WHERE
        dlp.loinc_code IN ('2857-1','10886-0','12841-3') 
        OR dlp.loinc_code IN ('10839-9','6598-7','10839-9','42757-5','16255-2','49563-0')
ORDER BY
        dlp.lab_procedure_mnemonic
        ;
 