-- For selected LOINC codes, analysis of empirical distributions.
DROP TABLE IF EXISTS jjyang.hf_f_lab_psa_2018_pt_dx ;
CREATE TABLE jjyang.hf_f_lab_psa_2018_pt_dx
AS
SELECT DISTINCT
	jjp.patient_id,
	jjl.encounter_id,
	jjl.admitted_dt_tm,
	dd.diagnosis_id,
	dd.diagnosis_code,
	dd.diagnosis_type,
	dd.diagnosis_description
FROM
	jjyang.hf_f_lab_psa_2018_patients jjp
JOIN
	jjyang.hf_f_lab_psa_2018 jjl ON jjp.patient_id = jjl.patient_id
JOIN
	public.hf_f_diagnosis fd ON fd.encounter_id = jjl.encounter_id
JOIN
	public.hf_d_diagnosis dd ON dd.diagnosis_id = fd.diagnosis_id
JOIN
	public.hf_d_diagnosis_type ddt ON fd.diagnosis_type_id = ddt.diagnosis_type_id
WHERE
	ddt.diagnosis_type_display = 'Final'
	;
