-- For selected LOINC codes, analysis of empirical distributions.
-- Troponin codes: '10839-9','6598-7','42757-5','16255-2','49563-0'
SELECT
	fe.encounter_id,
	fe.admitted_dt_tm,
	dlp.loinc_code,
	flp.accession,
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,        
	du.unit_display,
	flp.numeric_result
--	ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) psa_stddev,
--	ROUND(AVG(flp.numeric_result)::NUMERIC, 2) psa_mean,
--	ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) psa_stddev,
--        COUNT(flp.numeric_result) n
FROM
	public.hf_f_lab_procedure flp
JOIN
	public.hf_f_encounter fe ON fe.encounter_id = flp.encounter_id
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	public.hf_d_unit du ON du.unit_id = flp.result_units_id
WHERE
	DATE_PART('year',  fe.admitted_dt_tm) = 2018
	AND dlp.loinc_code IN ('10839-9','6598-7','42757-5','16255-2','49563-0')
        AND flp.numeric_result IS NOT NULL
        AND du.unit_display IS NOT NULL
        AND du.unit_display != 'NULL'
        AND du.unit_display IN ('ng/dL', 'ng/mL', 'ug/mL')
--        AND du.unit_display IN ('ng/dL', 'ng/mL', 'ug/mL', '%')
-- GROUP BY
--	dlp.lab_procedure_id,
--        dlp.lab_procedure_mnemonic,       
--	du.unit_display
	;
