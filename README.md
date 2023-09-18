# `CFDE-Biomarkers`

CFDE Biomarkers partnership project, UNM and IDG contributions

## Workflow

 * Download LOINC db from [loinc.org](https://loinc.org)
 * [relatednames\_table.py](python/relatednames_table.py) - Split Loinc.csv relatenames2 column to create separate table.
 * [Go\_loinc\_DbCreate.sh](sh/Go_loinc_DbCreate.sh) - Build PgSql db from Loinc.csv and relatename.tsv.
 * [Go\_loinc\_GetData.sh](sh/Go_loinc_GetData.sh) - Query db for chemicals with names, relatednames.
 * [Go\_loinc\_NER\_tagger\_gene.sh](sh/Go_loinc_NER_tagger_gene.sh) - NER for genes using JensenLab Tagger.
 * [Go\_loinc\_NER\_leadmine\_gene.sh](sh/Go_loinc_NER_leadmine_gene.sh) - NER for genes using NextMove Leadmine.
 * [Go\_hf\_labs.sh](sh/Go_hf_labs.sh) - Query Cerner HealthFacts for labs.
 * [biomarkers\_loinc\_hf.Rmd](R/biomarkers_loinc_hf.Rmd) - Analysis featuring molecular biomarkers ranked by weight of clinical evidence.


## Output

 * [biomarkers\_loinc\_hf\_out.tsv](output/biomarkers_loinc_hf_out.tsv)
 * [biomarkers\_loinc\_hf.html](R/biomarkers_loinc_hf.html)

## References

 * <https://loinc.org/>
 * <https://loinc.org/learn/>
 * <https://loinc.org/downloads/>
 * <https://www.cerner.com/ap/en/solutions/data-research>

