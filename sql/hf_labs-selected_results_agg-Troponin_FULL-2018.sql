-- For selected LOINC codes, analysis of empirical distributions.
-- Troponin codes: '10839-9','6598-7','42757-5','16255-2','49563-0'
CREATE TABLE jjyang.hf_f_lab_troponin_2018
AS
SELECT DISTINCT
	fe.patient_id,
	fe.encounter_id,
	fe.admitted_dt_tm,
	fe.age_in_years,
	fe.patient_type_id,
	dlp.loinc_code,
	flp.accession,
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,        
	du.unit_display,
	flp.numeric_result
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
	;
