-- For selected LOINC codes, analysis of empirical distributions.
-- LOINC codes from hf_labs_search_HgbA1C.sql and LOINC.org search. 
DROP TABLE IF EXISTS jjyang.hf_f_lab_hgba1c_2018 ;
CREATE TABLE jjyang.hf_f_lab_hgba1c_2018
AS
SELECT DISTINCT
	fe.patient_id,
	fe.encounter_id,
	fe.admitted_dt_tm,
	fe.age_in_years,
	fe.age_in_days,
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
--	AND dlp.loinc_code IN ()
	AND dlp.lab_procedure_name ILIKE 'Hemoglobin%A1C%'
        AND flp.numeric_result IS NOT NULL
        AND du.unit_display IS NOT NULL
        AND du.unit_display != 'NULL'
--        AND du.unit_display IN ('ng/dL', 'ng/mL', 'ug/mL')
	;
