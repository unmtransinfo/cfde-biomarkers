-- For selected LOINC codes, and date range, retrieve results for analysis of empirical distributions.
-- PSA codes: '2857-1','10886-0','12841-3',
-- Troponin codes: '10839-9','6598-7','42757-5','16255-2','49563-0'
SELECT DISTINCT
        dlp.loinc_code,
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,        
	flp.numeric_result,
	du.unit_display,
	dr.result_indicator_desc
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	public.hf_f_encounter fe ON fe.encounter_id = flp.encounter_id
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_d_unit du ON du.unit_id = flp.result_units_id
JOIN
        hf_d_result_indicator dr ON dr.result_indicator_id = flp.result_indicator_id
WHERE
	dlp.loinc_code IN ('2857-1','10886-0','12841-3') 
        OR dlp.loinc_code IN ('10839-9','6598-7','42757-5','16255-2','49563-0')
	;
