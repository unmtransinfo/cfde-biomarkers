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
# Merge PubChem files via SMILES to add CIDs.
for f in $(ls $DATADIR/loinc_chem_names_*_${dictname}_leadmine.tsv) ; do
	printf "NOTE: LeadMine chemical NER file: ${f}\n"
	pubchem_file=$(echo $f |sed 's/.tsv$/_pubchem.tsv/')
	ofile=$(echo $pubchem_file |sed 's/.tsv$/_merged.tsv/')
	if [ ! -e "${pubchem_file}" ]; then
		printf "ERROR: PubChem file missing: ${pubchem_file}; skipping.\n"
		continue
	fi
	printf "NOTE: PubChem SMI2CID file: ${pubchem_file}\n"
	${cwd}/python/merge_leadmine_pubchem.py \
		--ifile_a ${f} \
		--ifile_b ${pubchem_file} \
		-o $ofile
	printf "NOTE: Merged output file: ${ofile}\n"
done
#
#
