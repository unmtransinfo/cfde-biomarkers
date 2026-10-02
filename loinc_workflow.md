# LOINC Workflow

__CFDE BiomarkerKB Project__

_LOINC is the international standard for identifying health observations, measurements, and documents._ As such, this project employs LOINC codes as a key identifier for integration of datasets, including genomic, proteomic, chemical, biological, medical, and regulatory.

## LOINC Database

The following are fields with names or descriptions suitable for named entity recognition.

| Field | Description |
|---:|:---|
| component              | First major axis-component or analyte |
| definitiondescription  | Narrative text that describes the LOINC term taken as a whole (i.e., taking all of the parts of the term together) or relays information specific to the term, such as the context in which the term was requested or its clinical utility. |
| consumer\_name         | An experimental (beta) consumer friendly name for this item. The intent is to provide a test name that health care consumers will recognize. |
| shortname              | Introduced in version 2.07, this field contains the short form of the LOINC name and is created via a table-driven algorithmic process. The short name often includes abbreviations and acronyms. |
| long\_common\_name     | This field contains the LOINC name in a more readable format than the fully specified name. The long common names have been created via a tabledriven algorithmic process. Most abbreviations and acronyms that are used in the LOINC database have been fully spelled out in English. |
| displayname | This field contains the LOINC name in a more readable format than the fully specified name. The long common names have been created via a tabledriven algorithmic process. Most abbreviations and acronyms that are used in the LOINC database have been fully spelled out in English. |
| relatedname            | From RELATEDNAMES2 field in Loinc.csv. |


## Workflow

 * Download LOINC db from [loinc.org](https://loinc.org)
 * [relatednames\_table.py](python/relatednames_table.py) - Split Loinc.csv relatenames2 column to create separate table.
 * [Go\_loinc\_DbCreate.sh](sh/Go_loinc_DbCreate.sh) - Build PgSql db from Loinc.csv and relatename.tsv.
 * [Go\_loinc\_GetData.sh](sh/Go_loinc_GetData.sh) - Query db for chemicals with names, relatednames.
 * [Go\_loinc\_NER\_leadmine\_gene.sh](sh/Go_loinc_NER_leadmine_gene.sh) - NER for genes using [NextMove Leadmine](https://nextmovesoftware.com/).
 * [Go\_loinc\_NER\_leadmine\_chem.sh](sh/Go_loinc_NER_leadmine_chem.sh) - NER for chemicals using [NextMove Leadmine](https://nextmovesoftware.com/).

## Named-Entity Recognition (NER)

NER is a form of text-mining, here implemented using [NextMove Software](https://www.nextmovesoftware.com/) [Leadmine](https://www.nextmovesoftware.com/leadmine.htmlz), a leading, advanced, high-performance, open-source, supported, commercial system build with extensive, maintained dictionaries of terms.

## References

 * [CFDE BiomarkerKB Project](https://github.com/biomarker-ontology/biomarker-partnership)
 * [LOINC](https://loinc.org/) | [KB](https://loinc.org/kb/) | [Learn](https://loinc.org/learn/) | [Downloads](https://loinc.org/downloads/)
 * [LOINC Table Structure](https://loinc.org/kb/users-guide/loinc-database-structure/loinc-table-structure) (includes field descriptions)
 * [NextMove Software](https://www.nextmovesoftware.com/) | [Leadmine](https://www.nextmovesoftware.com/leadmine.html)
