#!/bin/bash
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
### https://bitbucket.org/larsjuhljensen/tagger
### See http://download.jensenlab.org/ for dictionaries, e.g.
### http://download.jensenlab.org/human_dictionary.tar.gz

T0=$(date +%s)

printf "Executing: %s\n" "$(basename $0)"

cwd=$(pwd)
#
# LOINC release:
if [ -f "${cwd}/LATEST_RELEASE_LOINC.txt" ]; then
	LOINC_RELEASE=$(cat ${cwd}/LATEST_RELEASE_LOINC.txt)
else
	printf "ERROR: not found: ${cwd}/LATEST_RELEASE_LOINC.txt\n"
	exit
fi
printf "LOINC release: ${LOINC_RELEASE}\n"
DATADIR="${cwd}/loinc_data/v${LOINC_RELEASE}"
#
TAGGER_DIR="$(cd $HOME/../app/tagger_precompiled; pwd)"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$TAGGER_DIR"
DICT_DIR="$(cd $HOME/../data/JensenLab/data; pwd)"

TAGGER_EXE="${TAGGER_DIR}/tagcorpus"

###
# "9606" is taxonomy human type.
echo "9606" >$DATADIR/human_types.tsv
#
###
# Tagger (document.h) document TSV format requirements.
# Documents one per line.
# First field example PMID:23909892|DOI:10.1021/pr400457u
# so the program parses out the PMID 23909892.
# We kludge by prefixing every line with ":". Then first field parsed as docid.
# Also 5th field is text (skip author, year, etc.), so another
# kludge to insert dummy fields.
###
# Output mentions to stdout or --out-matches.
# Fields: docid, paragraph, sentence, ch_first, ch_last, term, type, serialno.
# (serialno from the names file, which resolves synonyms.)
###
# Cols:
# 1.	loinc_num,
# 2.	component,
# 3.	class,
# 4.	definitiondescription,
# 5.	status,
# 6.	shortname,
# 7.	long_common_name,
# 8.	displayname,
# 9.	consumer_name,
# 10.	relatedname
#
# NER on columns 2 (component), 7 (long_common_name), and 10 (relatedname).
###
ifile="${DATADIR}/loinc_chem_names.tsv"
###
coltag="component"
ofile="$DATADIR/loinc_chem_names_${coltag}_tagger_target_matches.tsv"
cat ${ifile} \
	|sed -e 's/^/:/' \
	|awk -F '\t' '{print $1 "\t" $5 "\t\t\t" $2}' \
	| ${TAGGER_EXE} \
	--threads=16 \
	--entities=$DICT_DIR/human_entities.tsv \
	--names=$DICT_DIR/human_names.tsv \
	--types=$DATADIR/human_types.tsv \
	--stopwords=$DATADIR/tagger_global.tsv \
	--out-matches=$ofile
n_ent=$(cat $ofile |wc -l)
printf "Entities in field \"${coltag}\": ${n_ent}\n"
#
coltag="long_common_name"
ofile="$DATADIR/loinc_chem_names_${coltag}_tagger_target_matches.tsv"
cat ${ifile} \
	|sed -e 's/^/:/' \
	|awk -F '\t' '{print $1 "\t" $5 "\t\t\t" $7}' \
	| ${TAGGER_EXE} \
	--threads=16 \
	--entities=$DICT_DIR/human_entities.tsv \
	--names=$DICT_DIR/human_names.tsv \
	--types=$DATADIR/human_types.tsv \
	--stopwords=$DATADIR/tagger_global.tsv \
	--out-matches=$ofile
n_ent=$(cat $ofile |wc -l)
printf "Entities in field \"${coltag}\": ${n_ent}\n"
#
coltag="relatedname"
ofile="$DATADIR/loinc_chem_names_${coltag}_tagger_target_matches.tsv"
cat ${ifile} \
	|sed -e 's/^/:/' \
	|awk -F '\t' '{print $1 "\t" $5 "\t\t\t" $10}' \
	| ${TAGGER_EXE} \
	--threads=16 \
	--entities=$DICT_DIR/human_entities.tsv \
	--names=$DICT_DIR/human_names.tsv \
	--types=$DATADIR/human_types.tsv \
	--stopwords=$DATADIR/tagger_global.tsv \
	--out-matches=$ofile
n_ent=$(cat $ofile |wc -l)
printf "Entities in field \"${coltag}\": ${n_ent}\n"
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
