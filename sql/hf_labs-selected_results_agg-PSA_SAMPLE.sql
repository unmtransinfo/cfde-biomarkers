-- For selected LOINC codes, analysis of empirical distributions.
-- PSA codes: '2857-1','10886-0','12841-3',
SELECT
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,        
	du.unit_display,
	ROUND(AVG(flp.numeric_result)::NUMERIC, 2) psa_mean,
	ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) psa_stddev,
        COUNT(flp.numeric_result) N
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_d_unit du ON du.unit_id = flp.result_units_id
WHERE
	dlp.loinc_code IN ('2857-1','10886-0','12841-3')
        AND du.unit_display IS NOT NULL
        AND du.unit_display != 'NULL'
        AND du.unit_display IN ('ng/dL', 'ng/mL', '%')
GROUP BY
	dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,       
	du.unit_display
	;
