#!/bin/bash
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
cwd=$(pwd)
DATADIR="$cwd/loinc_data"
#
# LOINC release:
if [ -f "${DATADIR}/loinc_release.txt" ]; then
	LOINC_RELEASE=$(cat ${DATADIR}/loinc_release.txt)
else
	printf "ERROR: not found: ${DATADIR}/loinc_release.txt\n"
	exit
fi
printf "LOINC release: ${LOINC_RELEASE}\n"
#
NM_ROOT="$(cd $HOME/../app/nextmove; pwd)"
DICTDIR="${NM_ROOT}/dictionaries-20231222/Dictionaries"
#
LIBDIR="$(cd $HOME/../app/lib; pwd)"
BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.3-SNAPSHOT-jar-with-dependencies.jar"
#
CFGDIR="${DATADIR}/config"
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
echo "Gene+protein NER (descriptions)..."
#
for f in $(ls $CFGDIR/${PREFIX}_*.cfg) ; do
	#
	dictname=$(basename $f |perl -pe 's/^(.*)\.cfg$/$1/')
	printf "Leadmine: $(basename $f) (${dictname})\n"
	#
	for col in "2" "10" ; do
		java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
			-config $f \
			-i ${DATADIR}/loinc_chem_names.tsv \
			-textcol $col -unquote -idcol 1 \
			-o ${DATADIR}/loinc_chem_names_${col}_${dictname}_leadmine.tsv \
			-v
	done
	#
done
#
