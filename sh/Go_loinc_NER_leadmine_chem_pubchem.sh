#!/bin/bash
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
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
DATADIR="$cwd/loinc_data/v${LOINC_RELEASE}"
#
###
#
dictname="chem"
#
# Filter lines missing SMILES.
for f in $(ls $DATADIR/loinc_chem_names_*_${dictname}_leadmine.tsv) ; do
	smifile=$(echo $f |sed 's/.tsv$/.smiles/')
	cat $f |awk -F '\t' '{print $5 "\t" $1}' |sed '1d' \
	|grep '^[A-Za-z]' \
	|sort -u >$smifile
	printf "$smifile (%s lines)\n" "$(cat $smifile |wc -l)"
	sleep 1
done
#
source $HOME/venv/bioclients/bin/activate
#
for f in $(ls $DATADIR/loinc_chem_names_*_${dictname}_leadmine.smiles) ; do
	printf "Input file: ${f}; bioclients.pubchem get_smi2cid...\n"
	ofile=$(echo $f |sed 's/.smiles$/_pubchem.tsv/')
	python -m bioclients.pubchem.Client get_smi2cid --i $f --o $ofile
done
#
