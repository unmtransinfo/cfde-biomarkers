SELECT
        main.loinc_num,
        main.shortname,
        r.relatedname
FROM
        main
        JOIN relatedname r ON r.loinc_num = main.loinc_num
WHERE main.shortname ILIKE '%gene%'
ORDER BY main.loinc_num
        ;