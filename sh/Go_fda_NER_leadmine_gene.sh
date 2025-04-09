#!/bin/bash
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
cwd=$(pwd)
#
NM_ROOT="$(cd $HOME/../app/nextmove; pwd)"
#DICTDIR="${NM_ROOT}/dictionaries-20231222/Dictionaries"
DICTDIR="${NM_ROOT}/dictionaries-20250331/Dictionaries"
#
LIBDIR="$(cd $HOME/../app/lib; pwd)"
#BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.3-SNAPSHOT-jar-with-dependencies.jar"
BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.4-SNAPSHOT-jar-with-dependencies.jar"
#
DATADIR="$cwd/fda_clia_data"
CFGDIR="${DATADIR}/config"
CFGFILE="${CFGDIR}/gene_or_protein.cfg"
#
#############################################################################
# GeneAndProtein dictionaries and config files.
#
###
# CONFIG: Create LeadMine config file:
###
dict="${DICTDIR}/CFDictGeneAndProtein.cfx"
#
printf "Dictionary: %s\n" $(basename $dict)
#
caseSens="false"
minEntLen="5"
spelCor="false"
#spelCor="true"
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
	>"$CFGFILE"
#
###
#
nthreads="4"
###
# clia_detail.tsv cols:
# 1. "DOCUMENT_NUMBER"
# 2. "TEST_SYSTEM_ID"
# 3. "TEST_SYSTEM_NAME"
# 4. "QUALIFIER1"
# 5. "QUALIFIER2"
# 6. "ANALYTE_ID"
# 7. "ANALYTE_NAME"
# 8. "SPECIALTY_ID"
# 9. "COMPLEXITY"
# 10. "DATE_EFFECTIVE"
#
echo "Gene+protein NER (ANALYTE_TEXTs)..."
#
dictname=$(basename $CFGFILE |perl -pe 's/^(.*)\.cfg$/$1/')
#
col="7"
idcol="6"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config $CFGFILE \
	-i ${DATADIR}/clia_detail.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/clia_detail_${dictname}_leadmine.tsv \
	-v
#
#
###
# clia_cdc.tsv cols:
# 1. "ID"
# 2. "Document_Number"
# 3. "Test_System_ID"
# 4. "Test_System_Name"
# 5. "Qualifier1"
# 6. "Qualifier2"
# 7. "Analyte_ID"
# 8. "Analyte_Name"
# 9. "Specialty_ID"
# 10. "Complexity"
# 11. "Date_Effective"
#
#
col="8"
idcol="7"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config $CFGFILE \
	-i ${DATADIR}/clia_cdc.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/clia_cdc_${dictname}_leadmine.tsv \
	-v
#
#
