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
dictname="Chemical"
#
# Merge PubChem files via SMILES to add CIDs.
for f in $(ls $DATADIR/loinc_*_${dictname}_leadmine.tsv) ; do
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
###
# Combine results into one file.
#
cols="2:component 4:definitiondescription 7:long_common_name 10:relatedname"
args=""
for col in $cols ; do
	colname=$(echo $col |sed -e 's/^.*://')
	args="${args} -i ${DATADIR}/loinc_${colname}_${dictname}_leadmine_pubchem_merged.tsv"
done
#
set -x
#
${cwd}/python/combine_leadmine_results.py ${args} \
	--docname_tag "LOINC_code" --resolvedform_tag "SMILES" \
	--include_tag "PubChem_CID" \
	-o ${DATADIR}/loinc_${dictname}_leadmine_COMBINED.tsv
#
