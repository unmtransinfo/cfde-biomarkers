#!/usr/bin/env python3
###
import sys,os,io,csv,click,logging
import pandas as pd

logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG))

@click.command()
@click.option("--input_file", "ifile", required=True, type=click.Path(file_okay=True, dir_okay=False, exists=True), help="Input CSV|TSV file.")
@click.option("--csv", default=False, help="Input CSV flag (default is TSV)")
@click.option("--lab_procedure_group", "lpg", required=False, default=None, help="lab_procedure_group")

def main(ifile, lpg, csv):
  df_in = pd.read_csv(ifile, sep=("," if csv else "\t"), dtype=str)
  logging.info(f"Input rows: {df_in.shape[0]}")
  logging.info(f"Input columns: {df_in.columns}")
  #df_in.to_csv(sys.stderr, index=False)

  lpgs = df_in['lab_procedure_group'].unique()
  lpgs = pd.Series(lpgs).to_list()
  logging.info(f"lab_procedure_group values: {lpgs}")

  if not lpg:
      click.echo("ERROR: required: lab_procedure_group")

  df_lpg = df_in[df_in["lab_procedure_group"] == lpg]
  loinc_codes = df_lpg["loinc_code"].to_list()
  loinc_codes_sql = "'"+("','".join(loinc_codes))+"'"
  logging.info(f"For lab_procedure_group \"{lpg}\", loinc_code values: {loinc_codes}")

  sql = f"""\
-- For selected LOINC codes, analysis of empirical distributions.
-- LOINC codes for lab_procedure_group: {lpg}
SELECT
    dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,        
    du.unit_display,
    ROUND(AVG(flp.numeric_result)::NUMERIC, 2) psa_mean,
    ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) psa_stddev,
    COUNT(flp.numeric_result) N
FROM
	jjyang.hf_f_lab_2015_sample flp
JOIN
	public.hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
JOIN
	hf_d_unit du ON du.unit_id = flp.result_units_id
WHERE
	dlp.loinc_code IN ({loinc_codes_sql})
    AND du.unit_display IS NOT NULL
    AND du.unit_display != 'NULL'
    AND du.unit_display IN ('ng/dL', 'ng/mL', '%')
GROUP BY
	dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,       
	du.unit_display
	;
"""

  logging.debug(sql)

if __name__ == '__main__':
    main()
