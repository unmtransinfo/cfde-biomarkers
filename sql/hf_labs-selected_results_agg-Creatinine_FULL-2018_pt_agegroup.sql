-- For selected LOINC codes, analysis of empirical distributions.
ALTER TABLE jjyang.hf_f_lab_creatinine_2018_patients
        DROP COLUMN IF EXISTS agegroup ;
ALTER TABLE jjyang.hf_f_lab_creatinine_2018_patients
        ADD COLUMN agegroup VARCHAR(12) DEFAULT NULL ;
UPDATE jjyang.hf_f_lab_creatinine_2018_patients jp
        SET agegroup = 
                CASE WHEN jp.age_mid_year < 10.0 THEN '00-09'
                    WHEN jp.age_mid_year >= 10.0 AND jp.age_mid_year < 20.0 THEN '10-19'
                    WHEN jp.age_mid_year >= 20.0 AND jp.age_mid_year < 30.0 THEN '20-29'
                    WHEN jp.age_mid_year >= 30.0 AND jp.age_mid_year < 40.0 THEN '30-39'
                    WHEN jp.age_mid_year >= 40.0 AND jp.age_mid_year < 50.0 THEN '40-49'
                    WHEN jp.age_mid_year >= 50.0 AND jp.age_mid_year < 60.0 THEN '50-59'
                    WHEN jp.age_mid_year >= 60.0 AND jp.age_mid_year < 70.0 THEN '60-69'
                    WHEN jp.age_mid_year >= 70.0 AND jp.age_mid_year < 80.0 THEN '70-79'
                    WHEN jp.age_mid_year >= 80.0 AND jp.age_mid_year < 90.0 THEN '80-89'
                    WHEN jp.age_mid_year >= 90.0 THEN '90+'
                    ELSE 'Unknown'
               END  
        ;
SELECT
        COUNT(jp.patient_id),
        jp.agegroup
FROM
        jjyang.hf_f_lab_creatinine_2018_patients jp
GROUP BY
        jp.agegroup
ORDER BY
        jp.agegroup
        ;
