#!/usr/bin/env Rscript
##
## Cerner HealthFacts: Laboratory molecular biomarker diagnoses associations


library(readr)
library(data.table)
#library(plotly)

hf_dx <- read_delim("cerner_hf_data/hf_labs-selected_dx_OUT.tsv", delim = "\t")
setDT(hf_dx)
head(hf_dx)

sprintf("Columns: %s", paste(names(hf_dx), collapse=", ")) 

sprintf("Encounters: %s", hf_dx[, uniqueN(encounter_id)])
sprintf("Lab_procedures: %s", hf_dx[, uniqueN(lab_procedure_id)])
sprintf("Diagnoses: %s", hf_dx[, uniqueN(diagnosis_id)])

table(hf_dx[, diagnosis_type])

hf_dx_counts <- hf_dx[, .(n_encounter = .N), by="diagnosis_id"]


dxs <- unique(hf_dx[, .(diagnosis_id, diagnosis_code, diagnosis_description)][order(diagnosis_code, diagnosis_id)])

hf_dx_counts <- merge(hf_dx_counts, dxs, by="diagnosis_id", how="left")
hf_dx_counts <- hf_dx_counts[, .(diagnosis_id, diagnosis_code, diagnosis_description, n_encounter)]
hf_dx_counts <- hf_dx_counts[order(-n_encounter)]
head(hf_dx_counts, 100)

