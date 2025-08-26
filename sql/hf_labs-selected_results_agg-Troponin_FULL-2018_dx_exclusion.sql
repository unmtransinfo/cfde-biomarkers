-- For selected LOINC codes, analysis of empirical distributions.
SELECT DISTINCT
	jpd.diagnosis_type,
	jpd.diagnosis_code,
	jpd.diagnosis_description
FROM
	jjyang.hf_f_lab_troponin_2018_pt_dx jpd
WHERE
	jpd.diagnosis_description ILIKE '%heart%'
	OR jpd.diagnosis_description ILIKE '%cardiac%'
ORDER BY
	jpd.diagnosis_type,
	jpd.diagnosis_description
	;
