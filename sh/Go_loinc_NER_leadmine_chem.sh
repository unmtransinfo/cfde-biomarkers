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
#DICTDIR="${NM_ROOT}/dictionaries-20250331/Dictionaries"
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
# Chemical dictionaries and config files.
#
PREFIX="NM"
#
###
# CONFIG: Create LeadMine config file:
###
#
CFGFILE="$CFGDIR/chem.cfg"
#
(cat <<__EOF__
[resolver]
  location ${DICTDIR}/Resolvers/trivial.dict
  caseSensitive  false
  entityType  Mol
  entityType  RegNum
  entityType  CASNum
  entityType  DictMol
  outputType  SMILES

[resolver]
  location ${DICTDIR}/Resolvers/chembl.dict
  caseSensitive  false
  entityType  Mol
  entityType  RegNum
  entityType  CASNum
  entityType  DictMol
  outputType  SMILES

[resolver]
  location  ${DICTDIR}/Resolvers/pubchem_names.dict
  caseSensitive  false
  mmap  true
  validate false
  entityType  Mol
  entityType  DictMol
  entityType  DictMolPubChem
  outputType  SMILES

#A noise word, predominately a false positive e.g. lead
[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictChemicalNoise.cfx
  entityType  N
  htmlColor  #ff4500
  caseSensitive  false
  useSpellingCorrection  false
  excludeFromOutput  true

#An element of the periodic table e.g. sodium
[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictElement.cfx
  entityType  E
  htmlColor  violet
  caseSensitive  false
  allowSpellingCorrectionEvenAfterExactMatch  true
  useSpellingCorrection  false

[dictionary]
  location ${DICTDIR}/Dictionaries/CFDictTrivial.cfx
  entityType  DictMol
  htmlColor  #9090ff
  caseSensitive  false
  useSpellingCorrection  true
  maxCorrectionDistance  0
  minimumCorrectedEntityLength  8

[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictChembl.cfx
  entityType  DictMol
  htmlColor  #9090ff
  caseSensitive  false
  useSpellingCorrection  true
  maxCorrectionDistance  0
  minimumCorrectedEntityLength  8

[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictPubChem.cfx
  entityType  DictMol
  htmlColor  #9090ff
  caseSensitive  false
  allowSpellingCorrectionEvenAfterExactMatch  true
  useSpellingCorrection  true
  maxCorrectionDistance  0
  minimumCorrectedEntityLength  8

#A chemical prefix that describes at most a single heavy atom e.g. methyl
[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictAtomic.cfx
  entityType  A
  htmlColor  lime
  caseSensitive  false
  allowSpellingCorrectionEvenAfterExactMatch  true
  useSpellingCorrection  false

#A name indicating a class of compound/substituent e.g. isoflavonoid, heteroaryl
[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictGeneric.cfx
  entityType  G
  htmlColor  orange
  caseSensitive  false
  allowSpellingCorrectionEvenAfterExactMatch  true
  useSpellingCorrection  false

__EOF__
) \
	>"$CFGFILE"
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
if [ ! -e "${DATADIR}/loinc_chem_names.tsv" ]; then
	printf "ERROR: File not found: \"${DATADIR}/loinc_chem_names.tsv\". First run Go_loinc_GetData.sh.\n"
	exit
fi
#
echo "Chemical NER (ANALYTE_TEXTs)..."
#
dictname=$(basename $CFGFILE |perl -pe 's/^(.*)\.cfg$/$1/')
#
idcol="1"
#
col="2"
colname="component"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/loinc_chem_names.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
	-v
#
col="6"
colname="shortname"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/loinc_chem_names.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
	-v
#
col="4"
colname="definitiondescription"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/loinc_chem_names.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
	-v
#
col="7"
colname="long_common_name"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/loinc_chem_names.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
	-v
#
col="10"
colname="relatedname"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/loinc_chem_names.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/loinc_chem_names_${colname}_${dictname}_leadmine.tsv \
	-v
#
