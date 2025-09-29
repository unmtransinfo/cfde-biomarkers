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
'10480-2',
'14130-9',
'16112-5',
'40556-3',
'85337-4',
'85310-1',
'16113-3',
'10861-3',
'31207-4',
'40557-1',
'14228-1',
'85329-1',
'85339-0',
'85331-7',
'14230-7',
'85325-9',
'109336-8',
'48676-1',
'32996-1',
'72382-5',
'48675-3',
'42914-2',
'51981-9',
'72383-3',
'74885-5',
'18474-7',
'85319-2',
'85328-3',
'74860-8',
'49683-6',
'96893-3',
'31150-6',
'85318-4',
'104279-5',
'42783-1'
        )
        ;