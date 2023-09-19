#!/bin/bash
###
# This query has taken ~10hrs.
###

cwd=$(pwd)

# Define db credentials, ssh tunnel config.
. ${HOME}/.healthfactsrc

#
${cwd}/sh/runsql_pg_hf.sh -t -v \
	-h $DBHOST -z $DBPORT -n $DBNAME \
	-y localhost -x $TUNNELPORT \
	-f ${cwd}/sql/hf_lab_loinc_counts.sql \
	>${cwd}/data/hf_lab_loinc_counts_OUT.tsv
#
###
# Alternate method, directly via psql on db server:
# psql -d $DBNAME -p $DBPORT -c "COPY ($(cat hf_lab_loinc_counts.sql |sed 's/;//')) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" >hf_lab_loinc_counts_OUT.tsv
###
