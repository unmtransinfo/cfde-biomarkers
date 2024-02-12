#!/usr/bin/env Rscript
##
## Cerner HealthFacts: Laboratory molecular biomarker patient metadata
##

library(readr)
library(data.table)
library(plotly)

hf_pt <- read_delim("cerner_hf_data/hf_labs-selected_pt_OUT.tsv", delim = "\t")
setDT(hf_pt)
head(hf_pt)

sprintf("Columns: %s", paste(names(hf_pt), collapse=", "))

sprintf("Encounters: %s", hf_pt[, uniqueN(encounter_id)])
sprintf("Lab_procedures: %s", hf_pt[, uniqueN(lab_procedure_id)])

table(hf_pt[, gender])

table(hf_pt[, patient_type_desc])

hf_pt_counts <- hf_pt[, .(n_encounter = .N), by="lab_procedure_id"]

hf2loinc <- read_delim("cerner_hf_data/hf2loinc.tsv", delim = "\t")

hf_pt_counts <- merge(hf_pt_counts, hf2loinc, by="lab_procedure_id", how="left")
hf_pt_counts <- hf_pt_counts[order(-n_encounter)]
head(hf_pt_counts, 100)

# plot_ly(x = hf_pt[, age_in_years], type = "histogram")
