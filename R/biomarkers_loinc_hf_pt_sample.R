#!/usr/bin/env Rscript
###
### title: Cerner HealthFacts: Laboratory molecular biomarker patient metadata
### Sample large input file for analysis by separate R notebook.
###

library(readr)
library(stringr)
library(data.table)

fpath_in <- "cerner_hf_data/hf_labs-selected_pt_OUT.tsv.gz"
message(sprintf("Input: %s", fpath_in))

hf_pt <- read_delim(fpath_in, delim = "\t", col_types = cols(.default = col_character(), admitted_dt_tm = col_datetime(), age_in_years = col_integer()))
setDT(hf_pt)
head(hf_pt)
message(sprintf("Columns: %s", paste(names(hf_pt), collapse=", ")))

hf_pt[, admitted_year := year(admitted_dt_tm)]
hf_pt <- hf_pt[admitted_year > 1999] #Earlier probably spurious.
yr_min <- hf_pt[, min(admitted_year)]
yr_max <- hf_pt[, max(admitted_year)]
hf_pt <- hf_pt[age_in_years > 0 & age_in_years < 90] #Extremes probably spurious.

nrow_all <- nrow(hf_pt)
size_all <- object.size(hf_pt)

message(sprintf("Encounters(%d-%d): %s", yr_min, yr_max, hf_pt[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures(%d-%d): %s", yr_min, yr_max, hf_pt[, uniqueN(lab_procedure_id)]))

tbl <- table(hf_pt[, admitted_year])
message(sprintf("===\nEncounters by year:"))
writeLines(sprintf("%4s: %8d", names(tbl), tbl))

y <- 2016
message(sprintf("Sample one year for computability: %d", y))
hf_pt <- hf_pt[admitted_year == y]
message(sprintf("Sampled rows: %d / %d (%.1f%%)", nrow(hf_pt), nrow_all, 100 * nrow(hf_pt) / nrow_all))
message(sprintf("Size all: %s; sample: %s (%.1f%%)", format(size_all, units="auto"), format(object.size(hf_pt), units="auto"), 100 * object.size(hf_pt) / size_all))
message(sprintf("Encounters (%d): %s", y, hf_pt[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures (%d): %s", y, hf_pt[, uniqueN(lab_procedure_id)]))
#
fpath_out <- str_replace(fpath_in, "\\.tsv", sprintf("_%d.tsv", y))
message(sprintf("Output: %s", fpath_out))
write_delim(hf_pt, fpath_out, "\t")
#
fpath_eid2pid_out <- str_replace(fpath_in, "\\.tsv",  sprintf("_eid2pid_%d.tsv", y))
message(sprintf("Output: %s", fpath_eid2pid_out))
hf_eid2pid <- unique(hf_pt[, .(encounter_id, patient_id)])
write_delim(hf_eid2pid, fpath_eid2pid_out, "\t")
#
fpath_ptdata_out <- str_replace(fpath_in, "\\.tsv",  sprintf("_ptdata_%d.tsv", y))
message(sprintf("Output: %s", fpath_ptdata_out))
hf_ptdata <- unique(hf_ptdata[, .(patient_id, patient_type_id, patient_type_desc, gender, race, ethnicity, admitted_year, age_in_years)])
hf_ptdata[, yob := admitted_year - age_in_years]
hf_ptdata[, c("admitted_year", "age_in_years") := NULL]
write_delim(hf_ptdata, fpath_ptdata_out, "\t")

