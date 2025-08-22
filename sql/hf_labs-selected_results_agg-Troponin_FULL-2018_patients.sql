-- For selected LOINC codes, analysis of empirical distributions.
-- Troponin codes: '10839-9','6598-7','42757-5','16255-2','49563-0'
CREATE TABLE jjyang.hf_f_lab_troponin_2018_patients
AS
SELECT DISTINCT
	jjl.patient_id,
        jjl.patient_type_id,
        dpt.patient_type_desc,
        dp.gender,
        dp.race,
        dp.ethnicity
FROM
	jjyang.hf_f_lab_troponin_2018 jjl
JOIN
	public.hf_d_patient dp ON dp.patient_id = jjl.patient_id
JOIN
        public.hf_d_patient_type dpt ON jjl.patient_type_id = dpt.patient_type_id
WHERE
	dp.gender IS NOT NULL
	AND dpt.patient_type_desc IS NOT NULL
ORDER BY
	jjl.patient_id
	;
