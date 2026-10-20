#!/usr/bin/env python3
"""
Combine LeadMine NER results files, one document-entity pair per line.
Concatenate and remove duplicate rows.

Delete fields:
    SectionType,
    OriginalText,
    EntityText,
    PossiblyCorrectedText,
    BegIndex,
    CorrectionDistance,
Keep fields:
    DocName,
    EntityType,
    ResolvedForm,

"""
###
import sys,os,io,csv,click,logging
import pandas as pd

@click.command()
@click.option("-i", "--input_file", "ifiles", required=True, multiple=True, help="Input CSV|TSV files (multiple values allowed).")
@click.option("-o", "--output_file", "ofile", required=False, type=click.Path(file_okay=True, dir_okay=False), help="Output TSV file.")
@click.option("--csv", is_flag=True, help="Input CSV flag (default is TSV)")
@click.option("--debug", is_flag=True)

def main(ifiles, ofile, csv, debug):
  """Combine LeadMine NER results into one file.
"""
  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if debug else logging.INFO))
  df_out = None; i_file=0; n_err=0;
  for ifile in ifiles:
    i_file += 1
    df_in_this = pd.read_csv(ifile, sep=("," if csv else "\t"), dtype=str)
    logging.info(f"Input {i_file}. {ifile}: {df_in_this.shape[0]} x {df_in_this.shape[1]}")
    logging.debug(f"Input {i_file}. {ifile}: columns: {df_in_this.columns}")

    keep_cols = ['DocName', 'EntityType', 'ResolvedForm']
    for col in keep_cols:
      if col not in df_in_this:
        logging.error(f"Required column '{col}' not in file {ifile}")
        n_err+=1
    df_in_this = df_in_this[keep_cols]
    df_in_this.rename(columns={'DocName':'LOINC_code'}, inplace=True)
    df_out = pd.concat([df_out, df_in_this], axis=0, ignore_index=True)
    df_out.drop_duplicates(inplace=True, ignore_index=True)
    df_out.dropna(inplace=True, ignore_index=True)
    df_out.sort_values(by=['LOINC_code', 'EntityType', 'ResolvedForm'], inplace=True, ignore_index=True)

  fout = open(ofile, "w") if ofile else sys.stdout
  df_out.to_csv(fout, sep=("," if csv else "\t"), index=False)
  logging.info(f"Output {ofile}: {df_out.shape[0]} x {df_out.shape[1]}")
  logging.debug(f"Output {ofile}: columns: {df_out.columns}")

if __name__ == '__main__':
    main()
