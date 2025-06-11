-- For selected LOINC codes, analysis of empirical distributions.
-- Troponin codes: '10839-9','6598-7','42757-5','16255-2','49563-0'
SELECT
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,        
	du.unit_display,
	ROUND(AVG(flp.numeric_result)::NUMERIC, 2) psa_mean,
	ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) psa_stddev,
        COUNT(flp.numeric_result) n
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_d_unit du ON du.unit_id = flp.result_units_id
WHERE
	dlp.loinc_code IN ('10839-9','6598-7','42757-5','16255-2','49563-0')
        AND du.unit_display IS NOT NULL
        AND du.unit_display != 'NULL'
        AND du.unit_display IN ('ng/dL', 'ng/mL', 'ug/mL', '%')
GROUP BY
	dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,       
	du.unit_display
	;
