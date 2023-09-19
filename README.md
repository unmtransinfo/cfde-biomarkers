# `CFDE-Biomarkers`

__CFDE Biomarkers partnership project__

For the Biomarkers project, the UNM-IDG Team is developing a dataset of clinically
relevant molecular biomarkers, using the Cerner HealthFacts 2019 database,
containing deidentified EHR data, including LOINC codes for laboratory tests.
Named entity recognition (NER) associates LOINC terms with biomolecules and
particularly genes and proteins, an initial focus of this study.

## Workflow

 * Download LOINC db from [loinc.org](https://loinc.org)
 * [relatednames\_table.py](python/relatednames_table.py) - Split Loinc.csv relatenames2 column to create separate table.
 * [Go\_loinc\_DbCreate.sh](sh/Go_loinc_DbCreate.sh) - Build PgSql db from Loinc.csv and relatename.tsv.
 * [Go\_loinc\_GetData.sh](sh/Go_loinc_GetData.sh) - Query db for chemicals with names, relatednames.
 * [Go\_loinc\_NER\_tagger\_gene.sh](sh/Go_loinc_NER_tagger_gene.sh) - NER for genes using [JensenLab Tagger](https://github.com/larsjuhljensen/tagger).
 * [Go\_loinc\_NER\_leadmine\_gene.sh](sh/Go_loinc_NER_leadmine_gene.sh) - NER for genes using [NextMove Leadmine](https://nextmovesoftware.com/).
 * [Go\_hf\_labs.sh](sh/Go_hf_labs.sh), [hf\_lab\_loinc\_counts.sql](sql/hf_lab_loinc_counts.sql) - Query Cerner HealthFacts 2019 for labs.
 * [biomarkers\_loinc\_hf.Rmd](R/biomarkers_loinc_hf.Rmd)
   * Generate list of clinically relevant molecular biomarker candidates.
   * Count encounters and patients for all LOINC codes (chemical).
   * Group lab procedures into list; aggregate on LOINC codes.
   * Group protein synonyms; aggregate on LOINC codes.
   * Sort LOINC codes by occurence, as a proxy for clinical relevance.


## Output

 * [biomarkers\_loinc\_hf.html](R/biomarkers_loinc_hf.html)
 * [biomarkers\_loinc\_hf\_out.tsv](output/biomarkers_loinc_hf_out.tsv)

## References

 * [LOINC](https://loinc.org/) | [Learn](https://loinc.org/learn/) | [Downloads](https://loinc.org/downloads/)
 * [Cerner Research Data](https://www.cerner.com/ap/en/solutions/data-research)
 * [BEST (Biomarkers, EndpointS, and other Tools) Resource](https://www.ncbi.nlm.nih.gov/books/NBK326791/)
