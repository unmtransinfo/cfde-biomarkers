#!/bin/bash
###
# https://loinc.org/downloads/
# LOINC 2.74 released 2023-02-22
# LOINC 2.76 released 2023-09-18
# LOINC 2.80 released 2025-02-26
###
DBNAME="loinc"
DBHOST="localhost"

cwd="$(pwd)"

DATADIR="${cwd}/loinc_data"

sql="\
SELECT
	m.loinc_num,
	m.component,
	m.class,
	m.definitiondescription,
	m.status,
	m.shortname,
	m.long_common_name,
	m.displayname,
	m.consumer_name,
	r.relatedname
FROM
	main m
JOIN	relatedname r ON r.loinc_num = m.loinc_num
WHERE
	class = 'CHEM'
ORDER BY component, loinc_num
"
#
psql -P pager=off -qAF $'\t' -h $DBHOST -d $DBNAME -c "${sql}" |sed '$d' \
	>$DATADIR/loinc_chem_names.tsv
#
# Split relatednames2 into separate rows.
