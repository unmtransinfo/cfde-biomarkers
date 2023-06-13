#!/bin/bash
###

T0=$(date +%s)

cwd=$(pwd)

LOINC_RELEASE="2.74"
DBNAME="loinc"
DBDIR=$(cd $HOME/../data/LOINC/v${LOINC_RELEASE}; pwd)
#
if [ ! -e "${DBDIR}" ]; then
	printf "ERROR: DBDIR not found: ${DBDIR}\n"
	exit 1
fi
#
csvfile="${DBDIR}/LoincTable/Loinc.csv"
#
psql -c "DROP DATABASE IF EXISTS $DBNAME"
psql -c "CREATE DATABASE $DBNAME"
#
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'LOINC: Logical Observation Identifiers, Names and Codes, from the Regenstrief Institute (v${LOINC_RELEASE}); see loinc.org'";
#
python3 -m BioClients.util.pandas.Csv2Sql create \
	--i $csvfile --tablename "main" --fixtags --nullify --maxchar 2000 \
	|sed 's/definitiondescription.*$/definitiondescription VARCHAR(5000),/' \
	|sed 's/exmpl_answers.*$/exmpl_answers VARCHAR(5000),/' \
	|sed 's/external_copyright_notice.*$/external_copyright_notice VARCHAR(5000),/' \
	|psql -d $DBNAME
python3 -m BioClients.util.pandas.Csv2Sql insert \
	--i $csvfile --tablename "main" --fixtags --nullify --maxchar 5000 \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE main IS 'Build from file LoincTable/Loinc.csv'";
psql -d $DBNAME -c "ALTER TABLE main DROP COLUMN RELATEDNAMES2";
psql -d $DBNAME -c "CREATE INDEX loinc_num_idx on main (loinc_num)";
#
###
tsvfile="/tmp/relatedname.tsv"
${cwd}/python/relatednames_table.py \
	-i /home/data/LOINC/v2.74/LoincTable/Loinc.csv \
	>$tsvfile
python3 -m BioClients.util.pandas.Csv2Sql create \
	--i $tsvfile --tsv --tablename "relatedname" --fixtags --nullify --maxchar 200 \
	|psql -d $DBNAME
python3 -m BioClients.util.pandas.Csv2Sql insert \
	--i $tsvfile --tsv --tablename "relatedname" --fixtags --nullify --maxchar 200 \
	|psql -q -d $DBNAME
psql -d $DBNAME -c "CREATE INDEX rname_loinc_num_idx on relatedname (loinc_num)"
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
