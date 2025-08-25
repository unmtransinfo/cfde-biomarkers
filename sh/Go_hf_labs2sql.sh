#!/bin/bash
#
cwd=$(pwd)
#
${cwd}/python/hf_labs2sql.py \
	--input_file ${cwd}/sql/hf_labs-selected_loincs.tsv
#

