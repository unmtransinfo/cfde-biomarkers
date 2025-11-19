-- For selected LOINC codes, analysis of empirical distributions.
-- Breast cancer (BC) sub-type biomarkers ERs, PRs, HER2.
-- LOINC codes from hf_labs_search_BCTYPE.sql and LOINC.org search. 
DROP TABLE IF EXISTS jjyang.hf_f_lab_psa_2018 ;
CREATE TABLE jjyang.hf_f_lab_psa_2018
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
	AND dlp.loinc_code IN (
		'104279-5',
'10480-2',
'14228-1',
'14230-7',
'18474-7',
'31150-6',
'40556-3',
'40557-1',
'42783-1',
'42914-2',
'48675-3',
'49683-6',
'51981-9',
'72382-5',
'72383-3',
'74860-8',
'74885-5',
'85310-1',
'85318-4',
'85319-2',
'85325-9',
'85328-3',
'85329-1',
'85331-7',
'85337-4',
'85339-0',
'96893-3',
'LP217197-5',
'LP31671-8',
'LP31675-9',
'LP31899-5',
'LP432811-0',
'LP62864-1',
'LP6333-1',
'LP6393-5',
'LP6404-0'
	)
--        AND flp.numeric_result IS NOT NULL
--        AND du.unit_display IS NOT NULL
--        AND du.unit_display != 'NULL'
--        AND du.unit_display IN ('ng/dL', 'ng/mL', 'ug/mL')
	;
