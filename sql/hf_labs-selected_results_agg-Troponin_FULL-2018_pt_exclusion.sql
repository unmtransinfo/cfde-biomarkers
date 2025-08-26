-- For selected LOINC codes, analysis of empirical distributions.
SELECT DISTINCT
	jpd.patient_id
FROM
	jjyang.hf_f_lab_troponin_2018_pt_dx jpd
WHERE
	jpd.patient_id NOT IN (
		SELECT
			jpd.patient_id
		FROM
			jjyang.hf_f_lab_troponin_2018_pt_dx jpd
		WHERE
			jpd.diagnosis_description ILIKE '%heart%'
			OR jpd.diagnosis_description ILIKE '%cardiac%'
	)
	;
