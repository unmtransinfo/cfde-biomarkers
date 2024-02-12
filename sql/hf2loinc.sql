--
SELECT DISTINCT
	dlp.lab_procedure_id,
        dlp.lab_procedure_name,
        dlp.lab_procedure_mnemonic,
        dlp.lab_procedure_group,
        dlp.lab_super_group,
	dlp.loinc_code
FROM
	hf_d_lab_procedure dlp
ORDER BY
        dlp.loinc_code,
	dlp.lab_procedure_id
	;
