#!/usr/bin/env Rscript
###
### title: Cerner HealthFacts: Laboratory molecular biomarker results
### Sample large input file for analysis by separate R notebook.
###

library(readr)
library(stringr)
library(data.table)

fpath_in <- "cerner_hf_data/hf_labs-selected_results_OUT.tsv.gz"
message(sprintf("Input: %s", fpath_in))

hf_results <- read_delim(fpath_in, delim = "\t", col_types = cols(.default = col_character(), admitted_dt_tm = col_datetime(), numeric_result = col_double(), normal_range_low = col_double(), normal_range_high = col_double()))
setDT(hf_results)
head(hf_results)
message(sprintf("Columns: %s", paste(names(hf_results), collapse=", ")))

hf_results[, admitted_year := year(admitted_dt_tm)]
hf_results <- hf_results[admitted_year > 1999] #Earlier probably spurious.
yr_min <- hf_results[, min(admitted_year)]
yr_max <- hf_results[, max(admitted_year)]

nrow_all <- nrow(hf_results)
size_all <- object.size(hf_results)

message(sprintf("Encounters(%d-%d): %s", yr_min, yr_max, hf_results[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures(%d-%d): %s", yr_min, yr_max, hf_results[, uniqueN(lab_procedure_id)]))

tbl <- table(hf_results[, admitted_year])
message(sprintf("===\nEncounters by year:"))
writeLines(sprintf("%4s: %8d", names(tbl), tbl))

y <- 2016
message(sprintf("Sample one year for computability: %d", y))
hf_results <- hf_results[admitted_year == y]
message(sprintf("Sampled rows: %d / %d (%.1f%%)", nrow(hf_results), nrow_all, 100 * nrow(hf_results) / nrow_all))
message(sprintf("Size all: %s; sample: %s (%.1f%%)", format(size_all, units="auto"), format(object.size(hf_results), units="auto"), 100 * object.size(hf_results) / size_all))
message(sprintf("Encounters (%d): %s", y, hf_results[, uniqueN(encounter_id)]))
message(sprintf("Lab_procedures (%d): %s", y, hf_results[, uniqueN(lab_procedure_id)]))

fpath_out <- str_replace(fpath_in, "\\.tsv",  sprintf("_%d.tsv", y))
message(sprintf("Output: %s", fpath_out))
write_delim(hf_results, fpath_out, "\t")
