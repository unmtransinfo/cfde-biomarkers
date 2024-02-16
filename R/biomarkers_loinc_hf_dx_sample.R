#!/usr/bin/env Rscript
###
### title: Cerner HealthFacts: Laboratory molecular biomarker diagnoses metadata
### Sample large input file for analysis by separate R notebook.
###

library(readr)
library(stringr)
library(data.table)

fpath_in <- "cerner_hf_data/hf_labs-selected_dx_OUT.tsv"
message(sprintf("Input: %s", fpath_in))

hf_dx <- read_delim(fpath_in, delim = "\t", col_types = cols(.default = col_character(), admitted_dt_tm = col_datetime()))
setDT(hf_dx)
head(hf_dx)
message(sprintf("Columns: %s", paste(names(hf_dx), collapse=", ")))

hf_dx[, admitted_year := year(admitted_dt_tm)]
hf_dx <- hf_dx[admitted_year > 1999] #Earlier probably spurious.
yr_min <- hf_dx[, min(admitted_year)]
yr_max <- hf_dx[, max(admitted_year)]

nrow_all <- nrow(hf_dx)
size_all <- object.size(hf_dx)

message(sprintf("Encounters(%d-%d): %s", yr_min, yr_max, hf_dx[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures(%d-%d): %s", yr_min, yr_max, hf_dx[, uniqueN(lab_procedure_id)]))

tbl <- table(hf_dx[, admitted_year])
message(sprintf("===\nEncounters by year:"))
writeLines(sprintf("%4s: %8d", names(tbl), tbl))

y <- 2016
message(sprintf("Sample one year for computability: %d", y))
hf_dx <- hf_dx[admitted_year == y]
message(sprintf("Sampled rows: %d / %d (%.1f%%)", nrow(hf_dx), nrow_all, 100 * nrow(hf_dx) / nrow_all))
message(sprintf("Size all: %s; sample: %s (%.1f%%)", format(size_all, units="auto"), format(object.size(hf_dx), units="auto"), 100 * object.size(hf_dx) / size_all))
message(sprintf("Encounters (%d): %s", y, hf_dx[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures (%d): %s", y, hf_dx[, uniqueN(lab_procedure_id)]))

fpath_out <- str_replace(fpath_in, "\\.tsv",  sprintf("_%d.tsv", y))
message(sprintf("Output: %s", fpath_out))
write_delim(hf_dx, fpath_out, "\t")
