#!/usr/bin/env python3
"""
Merge (1) LeadMine chemical NER results file with (2) PubChem SMILES-to-CID file, from bioclients.pubchem.Client get_smi2cid, on the SMILES string.
Remove duplicate rows.

Delete fields:
    SectionType,
    OriginalText,
    EntityText,
    PossiblyCorrectedText,
    BegIndex,
    CorrectionDistance,
Keep fields:
    DocName --> LOINC_code
    EntityType,
    ResolvedForm --> SMILES

"""
###
import sys,os,io,csv,click,logging
import pandas as pd

@click.command()
@click.option("--ifile_a", required=True, help="Input Leadmine chemical results file (CSV|TSV).")
@click.option("--ifile_b", required=True, help="Input PubChem get_smi2cid results file (CSV|TSV).")
@click.option("-o", "--output_file", "ofile", required=False, type=click.Path(file_okay=True, dir_okay=False), help="Output TSV file.")
@click.option("--csv", is_flag=True, help="Input CSV flag (default is TSV)")
@click.option("--debug", is_flag=True)

def main(ifile_a, ifile_b, ofile, csv, debug):
  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if debug else logging.INFO))
  df_out = None; n_err=0;

  df_in_A = pd.read_csv(ifile_a, sep=("," if csv else "\t"), dtype=str)
  logging.info(f"Input {ifile_a}: {df_in_A.shape[0]} x {df_in_A.shape[1]}")
  logging.debug(f"Input {ifile_a}: columns: {df_in_A.columns}")
  df_in_B = pd.read_csv(ifile_b, sep=("," if csv else "\t"), dtype=str)
  logging.info(f"Input {ifile_b}: {df_in_B.shape[0]} x {df_in_B.shape[1]}")
  logging.debug(f"Input {ifile_b}: columns: {df_in_B.columns}")

  keep_colsA = ['DocName', 'EntityType', 'ResolvedForm']
  for col in keep_colsA:
    if col not in df_in_A.columns:
      logging.error(f"Required column '{col}' not in file {ifile_a}")
      n_err+=1
  df_in_A = df_in_A[keep_colsA]
  df_in_A.rename(columns={'DocName':'LOINC_code', 'ResolvedForm':'SMILES'}, inplace=True)

  keep_colsB = ['CID', 'SMILES']
  for col in keep_colsB:
    if col not in df_in_B.columns:
      logging.error(f"Required column '{col}' not in file {ifile_b}")
      n_err+=1
  df_in_B = df_in_B[keep_colsB]
  df_in_B.rename(columns={'CID':'PubChem_CID'}, inplace=True)

  df_out = pd.merge(df_in_A, df_in_B, how='inner', on='SMILES')
  
  df_out.drop_duplicates(inplace=True, ignore_index=True)
  df_out.dropna(inplace=True, ignore_index=True)
  df_out = df_out[['LOINC_code', 'EntityType', 'PubChem_CID', 'SMILES']]
  df_out.sort_values(by=['LOINC_code', 'EntityType', 'PubChem_CID'], inplace=True, ignore_index=True)

  fout = open(ofile, "w") if ofile else sys.stdout
  df_out.to_csv(fout, sep=("," if csv else "\t"), index=False)
  logging.info(f"Output {ofile}: {df_out.shape[0]} x {df_out.shape[1]}")
  logging.debug(f"Output {ofile}: columns: {df_out.columns}")

if __name__ == '__main__':
    main()
