#!/bin/bash
###

T0=$(date +%s)

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
	|psql -d $DBNAME
#
python3 -m BioClients.util.pandas.Csv2Sql insert \
	--i $csvfile --tablename "main" --fixtags --nullify --maxchar 2000 \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE main IS 'Build from file LoincTable/Loinc.csv'";
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
