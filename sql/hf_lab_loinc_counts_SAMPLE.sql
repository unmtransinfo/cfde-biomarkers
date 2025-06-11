--
SELECT
        dlp.loinc_code,
	dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,
	dlp.lab_procedure_name,
	dlp.lab_procedure_group,
	count(DISTINCT flp.encounter_id) encounter_id_count,
	count(DISTINCT fe.patient_id) patient_id_count
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	public.hf_f_encounter fe ON flp.encounter_id = fe.encounter_id
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
GROUP BY
        dlp.loinc_code,
        dlp.lab_procedure_id,
        dlp.lab_procedure_mnemonic,
        dlp.lab_procedure_name,
        dlp.lab_procedure_group
ORDER BY
	encounter_id_count DESC,
	patient_id_count DESC
	;
