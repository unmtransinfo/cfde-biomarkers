-- LOINC.org codes from query: "((estrogen OR progesterone) AND receptor) OR HER2" 
-- https://loinc.org/search/?t=1&s=%28%28estrogen+OR+progesterone%29+AND+receptor%29+OR+HER2--
SELECT *
FROM hf_d_lab_procedure
WHERE
        lab_procedure_mnemonic ILIKE '%HER2%'
        OR lab_procedure_name ILIKE '%estrogen%receptor%'
        OR lab_procedure_name ILIKE '%progesterone%receptor%'
        OR lab_procedure_name ILIKE '%breast%cancer%'
        OR loinc_code IN (
'LP432811-0',
'LP31675-9',
'LP6404-0',
'LP62864-1',
'49683-6',
'74860-8',
'85318-4',
'31150-6',
'96893-3',
'74885-5',
'48675-3',
'104279-5',
'42783-1',
'LP31899-5',
'LP217197-5',
'42914-2',
'51981-9',
'72382-5',
'72383-3',
'LP6393-5',
'LP31671-8',
'LP6333-1',
'85329-1',
'14228-1',
'85328-3',
'85325-9',
'14230-7',
'85337-4',
'40556-3',
'85310-1',
'10480-2',
'85319-2',
'18474-7',
'85339-0',
'40557-1',
'85331-7'
        )
        ;