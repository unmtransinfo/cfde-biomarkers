#!/usr/bin/env python3
###
import sys,os,io,csv,click,logging
import pandas as pd

logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG))

@click.command()
@click.option("--input_file", "ifile", required=True, type=click.Path(file_okay=True, dir_okay=False, exists=True), help="Input CSV|TSV file.")
@click.option("--output_file", "ofile", required=False, type=click.Path(file_okay=True, dir_okay=False), help="Output SQL file.")
@click.option("--csv", is_flag=True, help="Input CSV flag (default is TSV)")
@click.option("--lab_procedure_group", "lpg", required=False, default=None, help="lab_procedure_group")
@click.option("--raw", is_flag=True, help="No aggregate functions, just raw lab results.")
@click.option("--lpg_all", is_flag=True, help="Include all codes from input file.")

def main(ifile, ofile, lpg, csv, raw, lpg_all):
  """This program generates SQL for HF lab results, for LOINC codes specified via input lookup table formated thus:

loinc_code,lab_procedure_mnemonic,lab_procedure_name,lab_procedure_group
"""
  df_in = pd.read_csv(ifile, sep=("," if csv else "\t"), dtype=str)
  logging.info(f"Input rows: {df_in.shape[0]}")
  logging.info(f"Input columns: {df_in.columns}")
  #df_in.to_csv(sys.stderr, index=False)

  lpgs = df_in['lab_procedure_group'].unique()
  lpgs = pd.Series(lpgs).to_list()
  logging.info(f"lab_procedure_group values: {lpgs}")

  if lpg:
    df_lpg = df_in[df_in["lab_procedure_group"] == lpg]
    loinc_codes = df_lpg["loinc_code"].to_list()
  elif lpg_all:
    loinc_codes = df_in["loinc_code"].to_list()
    lpg = ",".join(lpgs)
  else:
    logging.error("required: --lab_procedure_group or --lpg_all")
    sys.exit()

  loinc_codes_sql = "'"+("','".join(loinc_codes))+"'"
  logging.info(f"For lab_procedure_group \"{lpg}\", loinc_code values: {loinc_codes}")

  if raw:
    sql = f"""\
-- For selected LOINC codes, analysis of empirical distributions.
-- LOINC codes for lab_procedure_group[s]: {lpg}
SELECT
	dlp.loinc_code,
    dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,        
    dlp.lab_procedure_name,        
    dlp.lab_procedure_group,        
    flp.numeric_result,
    du.unit_display,
    du.unit_desc
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
ORDER BY
	dlp.loinc_code,
    dlp.lab_procedure_id
	;
"""
  else:
    sql = f"""\
-- For selected LOINC codes, analysis of empirical distributions.
-- LOINC codes for lab_procedure_group[s]: {lpg}
SELECT
    dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,        
    dlp.lab_procedure_name,        
    dlp.lab_procedure_group,        
    du.unit_display,
    du.unit_desc,
    ROUND(AVG(flp.numeric_result)::NUMERIC, 2) result_mean,
    ROUND(STDDEV(flp.numeric_result)::NUMERIC, 2) result_stddev,
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
GROUP BY
	dlp.lab_procedure_id,
    dlp.lab_procedure_mnemonic,       
    dlp.lab_procedure_name,        
    dlp.lab_procedure_group,        
	du.unit_display,
    du.unit_desc
	;
"""

  #logging.debug(sql)
  fout = open(ofile, "w") if ofile else sys.stdout
  fout.write(sql)

if __name__ == '__main__':
    main()
