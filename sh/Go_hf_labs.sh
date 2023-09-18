#!/bin/bash
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
