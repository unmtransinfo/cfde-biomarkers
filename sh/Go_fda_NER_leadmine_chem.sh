#!/bin/bash
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
cwd=$(pwd)
#
NM_ROOT="$(cd $HOME/../app/nextmove; pwd)"
DICTDIR="${NM_ROOT}/dictionaries-20231222"
#
LIBDIR="$(cd $HOME/../app/lib; pwd)"
BIOCOMP_NEXTMOVE_JARFILE="${LIBDIR}/unm_biocomp_nextmove-0.0.3-SNAPSHOT-jar-with-dependencies.jar"
#
DATADIR="$cwd/fda_clia_data"
CFGDIR="${DATADIR}/config"
CFGFILE="$CFGDIR/chem.cfg"
#
#############################################################################
# Chemical dictionaries and config files.
#
###
# CONFIG: Create LeadMine config file:
###
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

#A noise word, that is one that should not be recognised due to being predominately a false positive e.g. lead
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

#[dictionary]
#  location  ${DICTDIR}/Dictionaries/chemicalmolecule.cfx2
#  entityType  M
#  htmlColor  violet
#  enforceBracketing  true
#  caseSensitive  false
#  allowSpellingCorrectionEvenAfterExactMatch  true
#  useSpellingCorrection  true
#  minimumCorrectedEntityLength  9
#  maxCorrectionDistance  0

#A chemical prefix that describes at most a single heavy atom e.g. methyl
[dictionary]
  location  ${DICTDIR}/Dictionaries/CFDictAtomic.cfx
  entityType  A
  htmlColor  lime
  caseSensitive  false
  allowSpellingCorrectionEvenAfterExactMatch  true
  useSpellingCorrection  false

#A chemical prefix/fragment e.g. 2-chlorobutyl
#[dictionary]
#  location  ${DICTDIR}/Dictionaries/chemicalprefix.cfx2
#  entityType  P
#  htmlColor  lime
#  enforceBracketing  true
#  caseSensitive  false
#  allowSpellingCorrectionEvenAfterExactMatch  true
#  useSpellingCorrection  true
#  minimumCorrectedEntityLength  9
#  maxCorrectionDistance  0

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
echo "Chemical NER (ANALYTE_TEXTs)..."
#
dictname=$(basename $CFGFILE |perl -pe 's/^(.*)\.cfg$/$1/')
#
col="7"
idcol="6"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/clia_detail.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/clia_detail_${dictname}_leadmine.tsv \
	-v
#
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
col="8"
idcol="7"
java -jar ${BIOCOMP_NEXTMOVE_JARFILE} \
	-config ${CFGFILE} \
	-i ${DATADIR}/clia_cdc.tsv \
	-textcol $col -unquote -idcol $idcol \
	-o ${DATADIR}/clia_cdc_${dictname}_leadmine.tsv \
	-v
#
#
