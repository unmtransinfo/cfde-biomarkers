#!/usr/bin/env python3
###
import sys,os,io,csv,click,logging
import pandas as pd

@click.command()
@click.option("--input_file", "ifiles", required=True, multiple=True, help="Input CSV|TSV files (multiple values allowed).")
@click.option("--output_file", "ofile", required=False, type=click.Path(file_okay=True, dir_okay=False), help="Output TSV file.")
@click.option("--csv", is_flag=True, help="Input CSV flag (default is TSV)")
@click.option("--debug", is_flag=True)

def main(ifiles, ofile, csv, debug):
  """Concatenate stratified stats reports into one file.
"""
  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if debug else logging.INFO))
  df_out = None; i_file=0;
  for ifile in ifiles:
    i_file += 1
    df_in_this = pd.read_csv(ifile, sep=("," if csv else "\t"),
                             dtype=str)
    logging.info(f"Input {i_file}. {ifile}: {df_in_this.shape[0]} x {df_in_this.shape[1]}")
    logging.debug(f"Input {i_file}. {ifile}: columns: {df_in_this.columns}")
    df_out = pd.concat([df_out, df_in_this], axis=0)

  fout = open(ofile, "w") if ofile else sys.stdout
  df_out.to_csv(fout, sep=("," if csv else "\t"), index=False)
  logging.info(f"Output {ofile}: {df_out.shape[0]} x {df_out.shape[1]}")
  logging.debug(f"Output {ofile}: columns: {df_out.columns}")

if __name__ == '__main__':
    main()
