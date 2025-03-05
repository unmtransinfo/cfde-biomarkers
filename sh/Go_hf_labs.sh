#!/bin/bash
###
# This query has taken ~10hrs.
###

cwd=$(pwd)

DATADIR="${cwd}/oracle_hf_data"

# Define db credentials, ssh tunnel config.
# DBHOST,DBPORT,DBNAME,TUNNELPORT
. ${HOME}/.healthfactsrc

#
${cwd}/sh/runsql_pg_hf.sh -t -v \
	-h $DBHOST -z $DBPORT -n $DBNAME \
	-y localhost -x $TUNNELPORT \
	-f ${cwd}/sql/hf_lab_loinc_counts.sql \
	>${DATADIR}/hf_lab_loinc_counts_OUT.tsv
#
###
# Alternate method, directly via psql on db server:
# psql -d $DBNAME -p $DBPORT -c "COPY ($(cat hf_lab_loinc_counts.sql |sed 's/;//')) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" >hf_lab_loinc_counts_OUT.tsv
###
