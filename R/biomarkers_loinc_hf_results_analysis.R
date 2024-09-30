#!/usr/bin/env Rscript
#
# 'Cerner HealthFacts: Laboratory molecular biomarker results analysis'
###


library(readr)
library(data.table)
library(plotly)
library(htmlwidgets)

## Read data file for sample, representative year[s], due to size constraints.


ifile <- "cerner_hf_data/hf_labs-selected_results_sex-agerange_OUT.tsv.gz"
hf_results <- read_delim(ifile, "\t", escape_double=F)
setDT(hf_results)
message(sprintf("Columns: %s", paste(names(hf_results), collapse=", ")) )

## Remove rows missing essential values: gender, units

hf_results <- hf_results[!is.na(gender)]
hf_results <- hf_results[!is.na(unit_display)]
hf_results <- hf_results[!is.na(numeric_result)]
hf_results <- hf_results[unit_display != "Not Mapped"]
message(sprintf("COUNTS: rows (lab results): %d; LOINC_CODEs: %d; GENEORPROTEIN_IDs: %d", nrow(hf_results), hf_results[, uniqueN(loinc_code)], hf_results[, uniqueN(geneOrProteinId)]))
message(sprintf("ADMITTED_YEARs: %s; \nGENDERs: %s; \nAGERANGEs: %s; \nUNITs: %s", 
                paste(unique(hf_results[["admitted_year"]]), collapse=", "),
                paste(unique(hf_results[["gender"]]), collapse=", "),
                paste(sort(unique(hf_results[["agerange"]])), collapse=", "),
                paste(sort(unique(hf_results[["unit_display"]])), collapse=", ")
                ))

## For each GeneOrProtein ID, determine most common unit, generate summary statistics (mean, variance).

gpids <- sort(unique(hf_results[["geneOrProteinId"]]))
report_dt <- data.table(gpid = gpids, labs = "", valcount = NaN, units = "", pref_units = "", pref_units_valcount = NaN, mean = NaN, sd = NaN)
for (i in 1:length(gpids)) {
  gpid <- report_dt$gpid[i]
  hf_results_this <- hf_results[geneOrProteinId == gpid]
  report_dt$labs[i] <- paste(unique(hf_results_this[["lab_procedure_mnemonic"]]), collapse=", ")
  report_dt$valcount[i] <- hf_results_this[, .N]
  tbl <- data.table(table(hf_results_this[["unit_display"]]))[order(-N)]
  units_preferred <- tbl[["V1"]][1]
  report_dt$units[i] <- paste(unique(hf_results_this[["unit_display"]]), collapse=", ")
  report_dt$pref_units[i] <- units_preferred
  report_dt$pref_units_valcount[i] <- tbl[["N"]][1]
  hf_results_this <- hf_results_this[unit_display == units_preferred]
  report_dt$mean[i] <- mean(hf_results_this[["numeric_result"]], na.rm=T)
  report_dt$sd[i] <- sd(hf_results_this[["numeric_result"]], na.rm=T)
}
write_delim(report_dt, "cerner_hf_data/results_analysis_report.tsv", "\t")
report_dt <- report_dt[order(-pref_units_valcount)]
knitr::kable(report_dt)

## Plots

plots <- list()
i_plot <- 0
for (gpid in report_dt$gpid) {
  hf_results_this <- hf_results[geneOrProteinId == gpid]
  tbl <- data.table(table(hf_results_this[["unit_display"]]))[order(-N)]
  units_preferred <- tbl[["V1"]][1]
  hf_results_this <- hf_results_this[unit_display == units_preferred]
  values <- hf_results_this[["numeric_result"]]
  message(sprintf("%s; N = %d", gpid, length(values)))
  if (length(values)<1000) {
	message(sprintf("Skipping %s; N insufficient (%d < 1000)", gpid, length(values)))
	next;
  } 
  i_plot <- i_plot + 1
  tbl <- data.table(table(hf_results_this[["lab_procedure_mnemonic"]]))[order(-N)]
  lpmnemonic_preferred <- tbl[["V1"]][1]
  # Remove extreme and many likely spurious values.
  qtl <- quantile(values, probs = c(.05, .95))
  values <- hf_results_this[numeric_result>qtl[["5%"]] & numeric_result<qtl[["95%"]]][["numeric_result"]]
  plotname <- sprintf("%d. %s (%s)<br>%s<br>N = %d", i_plot, gpid, units_preferred, lpmnemonic_preferred, length(values))
  plots[[i_plot]] <- plot_ly(type="histogram", x = values, name=plotname) %>%
	  layout(title=list(text=plotname, y=0.6, x=0.5, xanchor="center", yanchor="top", font=list(family="Courier New", size=10, color="blue")),
	  	xaxis=list(range=list(qtl[["5%"]], qtl[["95%"]])),
		annotations=list(text = plotname, x=0.5, y=0.7, xref="paper", yref="paper",
		yanchor="bottom", xanchor="center", align="center",
		font=list(family="Courier New", size=12, color="#222222"), showarrow=F))
}
message(sprintf("Plot count: %d / %d (%d skipped)", i_plot, length(report_dt$gpid), length(report_dt$gpid)-i_plot))
fig <- subplot(plots, nrows=6) %>%
   layout(title="Molecular biomarker Cerner-EHR lab value histograms (5-95 %ile)", showlegend=F)

ofile_html <- "output/fig.html"
message(sprintf("Output HTML file: %s", ofile_html))
htmlwidgets::saveWidget(fig, ofile_html, selfcontained = F, libdir = "lib")

# Kaleido required
library(reticulate)
ofile_png <- "output/fig.png"
message(sprintf("Output PNG file: %s", ofile_png))
save_image(fig, ofile_png, format="png", scale=NULL, width=2800, height=1600)
