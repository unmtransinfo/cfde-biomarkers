-- For selected LOINC codes, analysis of empirical distributions.
-- EPOCH = number of seconds since 1970-01-01 00:00:00
CREATE TABLE jjyang.hf_f_lab_psa_2018_patients
AS
SELECT DISTINCT
	jjl.patient_id,
        jjl.patient_type_id,
        dpt.patient_type_desc,
        dp.gender,
        dp.race,
        dp.ethnicity,
	ROUND((
                (EXTRACT(EPOCH FROM (CAST(jjl.age_in_days AS TEXT)||' days')::INTERVAL) +
		EXTRACT(EPOCH FROM TIMESTAMP '2018-07-01 00:00:00.00')
		- EXTRACT(EPOCH FROM jjl.admitted_dt_tm)
		) / 60.0 / 60.0 / 24.0 / 365.0)::NUMERIC, 2) age_mid_year
FROM
	jjyang.hf_f_lab_psa_2018 jjl
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
