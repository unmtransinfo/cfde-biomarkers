-- For selected LOINC codes, analysis of empirical distributions.
-- TO DO: DEFINE EXCLUSION CRITERIA FOR Alkaline Phosphatase normals.
ALTER TABLE jjyang.hf_f_lab_alp_2018_patients
        ADD COLUMN IF NOT EXISTS exclusion_flag BOOLEAN DEFAULT FALSE ;
UPDATE jjyang.hf_f_lab_alp_2018_patients jp
        SET exclusion_flag = TRUE
        WHERE jp.patient_id IN (
               SELECT
                        jpd.patient_id
                FROM
                        jjyang.hf_f_lab_alp_2018_pt_dx jpd
                WHERE
                        jpd.diagnosis_description ILIKE '%diabetes%'
                        OR jpd.diagnosis_description ILIKE '%hyperglycemia%'
                        OR jpd.diagnosis_description ILIKE '%cancer%'
        )
        ;
SELECT
        COUNT(jp.patient_id),
        jp.exclusion_flag
FROM
        jjyang.hf_f_lab_alp_2018_patients jp
GROUP BY
        jp.exclusion_flag
        ;
