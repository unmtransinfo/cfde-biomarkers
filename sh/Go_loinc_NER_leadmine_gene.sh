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
#DICTDIR="${NM_ROOT}/dictionaries-20231222/Dictionaries"
DICTDIR="${NM_ROOT}/dictionaries-20250331/Dictionaries"
#
LIBDIR="$(cd $HOME/../app/lib; pwd)"
#BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.3-SNAPSHOT-jar-with-dependencies.jar"
BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.4-SNAPSHOT-jar-with-dependencies.jar"
#
CFGDIR="${DATADIR}/config"
if [ ! -e ${CFGDIR} ]; then
	mkdir ${CFGDIR}
fi
#
#############################################################################
# GeneAndProtein dictionaries and config files.
#
PREFIX="NM"
#
###
# CONFIG: Create LeadMine config file:
###
dict="${DICTDIR}/CFDictGeneAndProtein.cfx"
#
printf "CFG: %s\n" $(basename $dict)
DICTNAME="${PREFIX}_$(basename $dict|sed -e 's/\.cfx$//')"
#
caseSens="false"
minEntLen="5"
#spelCor="false"
spelCor="true"
maxCorDist="1"
minCorEntLen="5"
#
#  location  loinc_data/Resolvers/entrez.dict
# location /home/app/nextmove/dictionaries-20231222/Resolvers/entrez.dict
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
  location /home/app/nextmove/dictionaries-20231222/Resolvers/hgnc.dict
  mmap  true
  validate false
  caseSensitive  false
  entityType  GeneOrProtein
  outputType  HGNC

[resolver]
  location /home/app/nextmove/dictionaries-20231222/Resolvers/uniprot.dict
  mmap  true
  validate false
  caseSensitive  false
  entityType  GeneOrProtein
  outputType  UniProt

[resolver]
  location /home/app/nextmove/dictionaries-20231222/Resolvers/entrez.dict
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
#
for cfgfile in $(ls $CFGDIR/${PREFIX}_*.cfg) ; do
	#
	dictname=$(basename $cfgfile |perl -pe 's/^(.*)\.cfg$/$1/')
	printf "Leadmine: $(basename $cfgfile) (${dictname})\n"
	#
	col="2"
	colname="component"
	echo "Gene+protein NER (${colname})..."
	java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
		-config $cfgfile \
		-i ${DATADIR}/loinc_chem_names.tsv \
		-textcol $col -unquote -idcol 1 \
		-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
		-v
	#
	col="4"
	colname="definitiondescription"
	echo "Gene+protein NER (${colname})..."
	java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
		-config $cfgfile \
		-i ${DATADIR}/loinc_chem_names.tsv \
		-textcol $col -unquote -idcol 1 \
		-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
		-v
	#
	col="7"
	colname="long_common_name"
	echo "Gene+protein NER (${colname})..."
	java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
		-config $cfgfile \
		-i ${DATADIR}/loinc_chem_names.tsv \
		-textcol $col -unquote -idcol 1 \
		-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
		-v
	#
	#
	col="10"
	colname="relatedname"
	echo "Gene+protein NER (${colname})..."
	java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
		-config $cfgfile \
		-i ${DATADIR}/loinc_chem_names.tsv \
		-textcol $col -unquote -idcol 1 \
		-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
		-v
	#
done
#
