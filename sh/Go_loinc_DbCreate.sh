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
#
DATADIR="${cwd}/loinc_data/v${LOINC_RELEASE}"
#
printf "${LOINC_RELEASE}\n" >${DATADIR}/loinc_release.txt
#
DBNAME="loinc"
DBDIR=$(cd $HOME/../data/LOINC/v${LOINC_RELEASE}; pwd)
#
if [ ! -e "${DBDIR}" ]; then
	printf "ERROR: DBDIR not found: ${DBDIR}\n"
	exit 1
fi
#
loinc_csvfile="${DBDIR}/LoincTable/Loinc.csv"
#
relatednames_tsvfile="/tmp/relatedname.tsv"
${cwd}/python/relatednames_table.py \
	-i /home/data/LOINC/v${LOINC_RELEASE}/LoincTable/Loinc.csv \
	>$relatednames_tsvfile
#
psql -c "DROP DATABASE IF EXISTS $DBNAME"
psql -c "CREATE DATABASE $DBNAME"
#
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'LOINC: Logical Observation Identifiers, Names and Codes, from the Regenstrief Institute (v${LOINC_RELEASE}); see loinc.org'";
#
###
if [ ! "$CONDA_EXE" ]; then
	CONDA_EXE=$(which conda)
fi
if [ ! "$CONDA_EXE" -o ! -e "$CONDA_EXE" ]; then
	echo "ERROR: conda not found."
	exit
fi
#
# For bioclients conda config, see https://github.com/jeremyjyang/BioClients
source $(dirname $CONDA_EXE)/../bin/activate bioclients
#
python3 -m BioClients.util.pandas.Csv2Sql create \
	--i $loinc_csvfile --tablename "main" --fixtags --nullify --maxchar 2000 \
	|sed 's/definitiondescription.*$/definitiondescription VARCHAR(5000),/' \
	|sed 's/exmpl_answers.*$/exmpl_answers VARCHAR(5000),/' \
	|sed 's/external_copyright_notice.*$/external_copyright_notice VARCHAR(5000),/' \
	|psql -d $DBNAME
python3 -m BioClients.util.pandas.Csv2Sql insert \
	--i $loinc_csvfile --tablename "main" --fixtags --nullify --maxchar 5000 \
	|psql -q -d $DBNAME
#
###
python3 -m BioClients.util.pandas.Csv2Sql create \
	--i $relatednames_tsvfile --tsv --tablename "relatedname" --fixtags --nullify --maxchar 200 \
	|psql -d $DBNAME
python3 -m BioClients.util.pandas.Csv2Sql insert \
	--i $relatednames_tsvfile --tsv --tablename "relatedname" --fixtags --nullify --maxchar 200 \
	|psql -q -d $DBNAME
#
conda deactivate
#
psql -d $DBNAME -c "COMMENT ON TABLE main IS 'Built from file Loinc.csv'";
psql -d $DBNAME -c "ALTER TABLE main DROP COLUMN RELATEDNAMES2";
psql -d $DBNAME -c "CREATE INDEX loinc_num_idx on main (loinc_num)";
psql -d $DBNAME -c "CREATE INDEX rname_loinc_num_idx on relatedname (loinc_num)"
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
