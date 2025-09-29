#!/bin/bash
###
# https://loinc.org/downloads/
# LOINC 2.74 released 2023-02-22
# LOINC 2.76 released 2023-09-18
# LOINC 2.80 released 2025-02-26
# LOINC 2.81 released 2025-08-12
###
DBHOST="localhost"

cwd="$(pwd)"

# LOINC release:
if [ -f "${cwd}/LATEST_RELEASE_LOINC.txt" ]; then
	LOINC_RELEASE=$(cat ${cwd}/LATEST_RELEASE_LOINC.txt)
else
	printf "ERROR: not found: ${cwd}/LATEST_RELEASE_LOINC.txt\n"
	exit
fi
printf "LOINC release: ${LOINC_RELEASE}\n"
LOINC_VER=$(echo $LOINC_RELEASE |sed 's/\.//g')

DBNAME="loinc_${LOINC_VER}"
printf "DBNAME: ${DBNAME}\n"

DATADIR="${cwd}/loinc_data/v${LOINC_RELEASE}"

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
psql -e -P pager=off -qAF $'\t' -h $DBHOST -d $DBNAME -c "${sql}" \
	-o $DATADIR/loinc_chem_names.tsv
#
perl -ne 'print if eof' $DATADIR/loinc_chem_names.tsv
# Remove last line with rowcount.
perl -i -ne 'print unless eof' $DATADIR/loinc_chem_names.tsv
#
printf "Rows: %d\n" $[$(cat $DATADIR/loinc_chem_names.tsv |wc -l) - 1]
#
