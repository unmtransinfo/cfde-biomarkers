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

message(sprintf("Columns: %s", paste(names(hf_pt), collapse=", ")))
message(sprintf("Encounters: %s", hf_pt[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures: %s", hf_pt[, uniqueN(lab_procedure_id)]))

hf_pt[, admitted_year := year(admitted_dt_tm)]
table(hf_pt[, admitted_year])

y <- 2016
message(sprintf("Sample one year for computability: %d", y))

hf_pt <- hf_pt[admitted_year == y]


table(hf_pt[, gender])

table(hf_pt[, patient_type_desc])

hf_pt_counts <- hf_pt[, .(n_encounter = .N), by="lab_procedure_id"]

hf2loinc <- read_delim("cerner_hf_data/hf2loinc.tsv", delim = "\t")

hf_pt_counts <- merge(hf_pt_counts, hf2loinc, by="lab_procedure_id", how="left")
hf_pt_counts <- hf_pt_counts[order(-n_encounter)]
head(hf_pt_counts, 100)

# plot_ly(x = hf_pt[, age_in_years], type = "histogram")
