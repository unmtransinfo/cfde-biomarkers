#!/bin/bash
###
# https://loinc.org/
# https://loinc.org/downloads/
###

T0=$(date +%s)

cwd=$(pwd)

# LOINC release:
if [ -f "${cwd}/LATEST_RELEASE_LOINC.txt" ]; then
	LOINC_RELEASE=$(cat ${cwd}/LATEST_RELEASE_LOINC.txt)
else
	printf "ERROR: not found: ${cwd}/LATEST_RELEASE_LOINC.txt\n"
	exit
fi
printf "LOINC release: ${LOINC_RELEASE}\n"
LOINC_VER=$(echo $LOINC_RELEASE |sed 's/\.//g')
#
DATADIR="${cwd}/loinc_data/v${LOINC_RELEASE}"
#
if [ ! -e "${DATADIR}" ]; then
	mkdir -p $DATADIR
	printf "NOTE: DATADIR created: ${DATADIR}\n"
fi
#
printf "${LOINC_RELEASE}\n" >${DATADIR}/loinc_release.txt
#
DBNAME="loinc_${LOINC_VER}"
DBDIR="$HOME/data/LOINC/v${LOINC_RELEASE}"
#
if [ ! -e "${DBDIR}" ]; then
	printf "ERROR: DBDIR not found: ${DBDIR}\n"
	printf "ERROR: LOINC ${LOINC_RELEASE} should be downloaded and unzipped into this directory.\n"
	exit 1
fi
#
loinc_csvfile="${DBDIR}/LoincTable/Loinc.csv"
#
relatednames_tsvfile="$DATADIR/relatednames.tsv"
${cwd}/python/relatednames_table.py \
	-i $HOME/data/LOINC/v${LOINC_RELEASE}/LoincTable/Loinc.csv \
	>$relatednames_tsvfile
#
psql -c "DROP DATABASE IF EXISTS $DBNAME"
psql -c "CREATE DATABASE $DBNAME"
#
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'LOINC: Logical Observation Identifiers, Names and Codes, from the Regenstrief Institute (v${LOINC_RELEASE}); see loinc.org'";
#
###
#
# For bioclients venv config, see https://github.com/jeremyjyang/bioclients
source $HOME/venv/bioclients/bin/activate
#
python3 -m bioclients.util.pandas.Csv2Sql create \
	--i $loinc_csvfile --tablename "main" --fixtags --nullify --maxchar 2000 \
	|sed 's/definitiondescription.*$/definitiondescription VARCHAR(5000),/' \
	|sed 's/exmpl_answers.*$/exmpl_answers VARCHAR(5000),/' \
	|sed 's/external_copyright_notice.*$/external_copyright_notice VARCHAR(5000),/' \
	|psql -d $DBNAME
python3 -m bioclients.util.pandas.Csv2Sql insert \
	--i $loinc_csvfile --tablename "main" --fixtags --nullify --maxchar 5000 \
	|psql -q -d $DBNAME
#
###
python3 -m bioclients.util.pandas.Csv2Sql create \
	--i $relatednames_tsvfile --tsv --tablename "relatedname" --fixtags --nullify --maxchar 200 \
	|psql -d $DBNAME
python3 -m bioclients.util.pandas.Csv2Sql insert \
	--i $relatednames_tsvfile --tsv --tablename "relatedname" --fixtags --nullify --maxchar 200 \
	|psql -q -d $DBNAME
#
deactivate
#
psql -d $DBNAME -c "COMMENT ON TABLE main IS 'Built from file Loinc.csv'";
psql -d $DBNAME -c "ALTER TABLE main DROP COLUMN RELATEDNAMES2";
psql -d $DBNAME -c "CREATE INDEX loinc_num_idx on main (loinc_num)";
psql -d $DBNAME -c "CREATE INDEX rname_loinc_num_idx on relatedname (loinc_num)"
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
