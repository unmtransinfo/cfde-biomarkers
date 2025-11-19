-- LOINC.org codes from query: 
-- "estrogen receptor" OR "progesterone receptor" OR HER2
SELECT *
FROM hf_d_lab_procedure
WHERE
        lab_procedure_mnemonic ILIKE '%HER2%'
        OR lab_procedure_name ILIKE '%estrogen%receptor%'
        OR lab_procedure_name ILIKE '%progesterone%receptor%'
        OR lab_procedure_name ILIKE '%breast%cancer%'
        OR loinc_code IN (
		'104279-5',
'10480-2',
'14228-1',
'14230-7',
'18474-7',
'31150-6',
'40556-3',
'40557-1',
'42783-1',
'42914-2',
'48675-3',
'49683-6',
'51981-9',
'72382-5',
'72383-3',
'74860-8',
'74885-5',
'85310-1',
'85318-4',
'85319-2',
'85325-9',
'85328-3',
'85329-1',
'85331-7',
'85337-4',
'85339-0',
'96893-3',
'LP217197-5',
'LP31671-8',
'LP31675-9',
'LP31899-5',
'LP432811-0',
'LP62864-1',
'LP6333-1',
'LP6393-5',
'LP6404-0'
        )
        ;
