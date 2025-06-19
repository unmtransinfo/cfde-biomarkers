-- For selected LOINC codes, and date range, retrieve patient metadata for stratification and precision analysis of empirical associations.
--
SELECT DISTINCT
	fe.encounter_id,
	fe.admitted_dt_tm,
	dlp.loinc_code,
	fe.patient_id,
	fe.patient_type_id,
	dpt.patient_type_desc,
	dp.gender,
	dp.race,
	dp.ethnicity,
	fe.age_in_years
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_f_encounter fe ON fe.encounter_id = flp.encounter_id
JOIN
	hf_d_patient dp ON dp.patient_id = fe.patient_id
JOIN
	hf_d_patient_type dpt ON fe.patient_type_id = dpt.patient_type_id
WHERE
	dlp.loinc_code IN ('2857-1','10886-0','12841-3') -- PSA
        OR dlp.loinc_code IN ('10839-9','6598-7','42757-5','16255-2','49563-0') -- Troponin
        OR dlp.loinc_code IN ('1742-6') -- ALT/SGPT (Alanine Aminotransferase / SGPT)
        OR dlp.loinc_code IN ('1798-8') -- amylase
        OR dlp.loinc_code IN ('30522-7', '1988-5') -- C-Reactive Protein (CRP)
        OR dlp.loinc_code IN ('5195-3') -- Hep B Surface AG (HBSAG)
	;
