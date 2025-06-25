-- For selected LOINC codes, analysis of empirical distributions.
-- LOINC codes for lab_procedure_group[s]: PSA Test,Troponin Test,ALT Test,Amylase Test,CRP Test,CK Test,Lipase Test,GGT Test,Cancer Antigen Test,H pylori Test,Hepatitis B Test,Hepatitis C Test
SELECT
    dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,        
    dlp.lab_procedure_name,        
    dlp.lab_procedure_group,        
    du.unit_display,
    du.unit_desc,
    ROUND(AVG(flp.numeric_result)::NUMERIC, 2) result_mean,
    ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) result_stddev,
    COUNT(flp.numeric_result) N
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_d_unit du ON du.unit_id = flp.result_units_id
WHERE
	dlp.loinc_code IN ('2857-1','10886-0','12841-3','10839-9','6598-7','42757-5','1742-6','1743-4','1798-8','30522-7','7916-0','1988-5','2157-6','5912-1','20569-0','3040-3','2324-2','2039-6','2006-5','2012-3','2009-9','2007-3','10334-1','17842-6','5176-3','6420-4','7900-4','5195-3','58452-4','5193-8','22316-4','31204-1','32019-2','16935-9','5185-4','29615-2','49600-0','16935-9','11258-1','42595-9','48398-2','5198-7','48159-8','49376-7','49380-9','22327-1','38180-6','47252-2','11011-4','49372-6','49376-7','20416-4','5012-0','49380-9')
    AND du.unit_display IS NOT NULL
    AND du.unit_display != 'NULL'
GROUP BY
	dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,       
    dlp.lab_procedure_name,        
    dlp.lab_procedure_group,        
	du.unit_display,
    du.unit_desc
	;
