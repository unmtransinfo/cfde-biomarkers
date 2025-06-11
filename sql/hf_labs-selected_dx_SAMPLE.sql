-- For selected LOINC codes, and date range, retrieve diagnoses for analysis of empirical associations.
-- Only 'Final' diagnoses.
--
SELECT DISTINCT
	fe.encounter_id,
	fe.admitted_dt_tm,
	dlp.loinc_code,
	dlp.lab_procedure_mnemonic,
	dd.diagnosis_id,
	dd.diagnosis_code,
	dd.diagnosis_type,
	dd.diagnosis_description
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_f_encounter fe ON fe.encounter_id = flp.encounter_id
JOIN
	hf_f_diagnosis fd ON fd.encounter_id = fe.encounter_id
JOIN
	hf_d_diagnosis dd ON dd.diagnosis_id = fd.diagnosis_id
JOIN
	hf_d_diagnosis_type ddt ON fd.diagnosis_type_id = ddt.diagnosis_type_id
WHERE
	ddt.diagnosis_type_display = 'Final'
	AND dlp.loinc_code IN ('2857-1','10886-0','12841-3')
        OR dlp.loinc_code IN ('10839-9','6598-7','42757-5','16255-2','49563-0')
	;
