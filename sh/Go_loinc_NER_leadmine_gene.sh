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
NM_ROOT="$(cd $HOME/../app/nextmove; pwd)"
#DICTDIR="${NM_ROOT}/dictionaries-20231222"
#DICTDIR="${NM_ROOT}/dictionaries-20250331"
DICTDIR="${NM_ROOT}/dictionaries-20260610"
#
LIBDIR="$(cd $HOME/../app/lib; pwd)"
#BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.3-SNAPSHOT-jar-with-dependencies.jar"
#BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.4-SNAPSHOT-jar-with-dependencies.jar"
BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.5-SNAPSHOT-jar-with-dependencies.jar"
#
CFGDIR="${DATADIR}/config"
if [ ! -e ${CFGDIR} ]; then
	mkdir ${CFGDIR}
fi
#
#############################################################################
# GeneAndProtein dictionaries and config files.
#
###
# CONFIG: Create LeadMine config file:
###
dict="${DICTDIR}/Dictionaries/CFDictGeneAndProtein.cfx"
#
printf "CFG: %s\n" $(basename $dict)
DICTNAME="$(basename $dict|sed -e 's/\.cfx$//')"
#
caseSens="false"
minEntLen="5"
#spelCor="false"
spelCor="true"
maxCorDist="1"
minCorEntLen="5"
#
#
(cat <<__EOF__
[dictionary]
  location ${dict}
  entityType  GeneOrProtein
  caseSensitive ${caseSens}
  minimumEntityLength ${minEntLen}
  useSpellingCorrection ${spelCor}
  maxCorrectionDistance  ${maxCorDist}
  minimumCorrectedEntityLength ${minCorEntLen}

[resolver]
  location ${DICTDIR}/Resolvers/hgnc.dict
  mmap  true
  validate false
  caseSensitive  false
  entityType  GeneOrProtein
  outputType  HGNC

[resolver]
  location ${DICTDIR}/Resolvers/uniprot.dict
  mmap  true
  validate false
  caseSensitive  false
  entityType  GeneOrProtein
  outputType  UniProt

[resolver]
  location ${DICTDIR}/Resolvers/entrez.dict
  mmap true
  validate false
  caseSensitive false
  entityType  GeneOrProtein
  outputType Entrez

__EOF__
) \
	>"$CFGDIR/${DICTNAME}.cfg"
#
###
#
nthreads="4"
#
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
#
###
# Input file for all NER:
IFILE="${DATADIR}/loinc_chem_names.tsv"
if [ ! -e "${IFILE}" ]; then
	printf "ERROR: File not found: \"${IFILE}\". First run Go_loinc_GetData.sh.\n"
	exit
fi
#
cfgfile="$CFGDIR/${DICTNAME}.cfg"
#
dictname=$(basename $cfgfile |perl -pe 's/^(.*)\.cfg$/$1/')
printf "Leadmine: $(basename $cfgfile) (${dictname})\n"
#
cols="2:component 4:definitiondescription 7:long_common_name 10:relatedname"
#
for col in $cols ; do
	colnum=$(echo $col |sed -e 's/:.*$//')
	colname=$(echo $col |sed -e 's/^.*://')
	printf "Gene+protein NER (${colnum}:${colname})...\n"
	java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
		-config $cfgfile \
		-i ${IFILE} \
		-textcol $colnum -unquote -idcol 1 \
		-o ${DATADIR}/loinc_${colname}_${dictname}_leadmine.tsv \
		-v
done
#
#
###
# Combine results into one file.
args=""
for col in $cols ; do
	colname=$(echo $col |sed -e 's/^.*://')
	args="${args} -i ${DATADIR}/loinc_${colname}_${dictname}_leadmine.tsv"
done
#
${cwd}/python/combine_leadmine_results.py ${args} \
	-o ${DATADIR}/loinc_${dictname}_leadmine_COMBINED.tsv
#
