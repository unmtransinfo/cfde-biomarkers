#!/usr/bin/env python3
###
import sys,os,io,csv,click,logging
import pandas as pd

#logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.INFO))
logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG))

@click.command()
@click.option("-i", "--input_file", required=True,
type=click.Path(file_okay=True, dir_okay=False, exists=True), help="Input CSV|TSV file.")
@click.option("--tsv", default=False, help="Input TSV flag (default is CSV)")

def main(input_file, tsv):
  """Split Loinc.csv relatednames2 column and create new table."""
  if not input_file:
    click.echo("ERROR: no input_file.")

  df_in = pd.read_csv(input_file, sep=("\t" if tsv else ","), low_memory=False)
  buff  = io.StringIO()
  #df_in.info(buff)
  #logging.info(buff.getvalue())

  df_out = df_in.loc[:, ["LOINC_NUM", "RELATEDNAMES2"]]
  #df_out.info(buff)
  #logging.info(buff.getvalue())
  df_out.set_index("LOINC_NUM", drop=True, inplace=True)
  #df_out.info(buff)
  #logging.info(buff.getvalue())

  # Split field on semicolons into separate rows indexed by LOINC_NUM.
  s = df_out['RELATEDNAMES2'].str.split(f"\s*;\s*").apply(pd.Series, 1).stack()
  s.index = s.index.droplevel(-1) # to line up with df's index
  s.name = 'RELATEDNAME' # needs a name to join
  del df_out['RELATEDNAMES2']
  df_out = df_out.join(s)
  df_out.drop_duplicates(inplace=True)
  #df_out.info(buff)
  #logging.info(buff.getvalue())
  logging.debug(df_out.head())

  df_out.to_csv(sys.stdout, sep="\t", index=True)
  logging.info(f"Output rows: {df_out.shape[0]}")

  buff.close()

if __name__ == '__main__':
  main()
