#!/bin/bash

# change filepath to database path
DATABASE_PATH="/home/nreboul/.dbvis/DEMO/sakila-dbvis;AUTO_SERVER=TRUE"

NER_SHELL_PATH="/home/nreboul/Documents/FDA_CLIA/CLIA_NER"

# change to SQL script path
SQL_SCRIPT1="/home/nreboul/.dbvis/Bookmarks/FDA_CLIA/CLIA_tables.sql"

SQL_SCRIPT2="/home/nreboul/.dbvis/Bookmarks/FDA_CLIA/CLIA_NER.sql"

# change to database jar file
H2_JAR="/home/nreboul/.dbvis/drivers/local/h2-2.1.214.jar"

# URL to FDA CLIA zip file
CLIA_URL="https://www.accessdata.fda.gov/premarket/ftparea/clia_detail.zip"
CLIA_CDC_URL="https://www.accessdata.fda.gov/premarket/ftparea/clia_cdc.zip"

# destination path
DEST_PATH="/home/nreboul/Documents/FDA_CLIA"

#Leadmine path
LEADMINE_PATH="/home/nreboul/LeadMine/v4.0.2"

# database username
USERNAME=""

# database name
DB_NAME=""

# download CDC CLIA data if not already downloaded
#curl -L -o clia_cdc.zip "$CLIA_CDC_URL" && unzip clia_cdc.zip -d $DEST_PATH && rm clia_cdc.zip

# download CLIA file, unzip
rm $DEST_PATH/clia_detail.txt && curl -L -o clia_detail.zip "$CLIA_URL" && unzip clia_detail.zip -d $DEST_PATH && rm clia_detail.zip

# Run CLIA_tables.sql file to extract data from txt file into tables, and to create table for analytes for NER
# remove old NER CLIA files if already exist
# run NER on analyte table using Leadmine, then run CLIA_NER.sql script to create tables to query
# uncomment for corresponding database type

# postgresql
#psql -U $USERNAME -d $DB_NAME -f $SQL_SCRIPT && rm $NER_SHELL_PATH/clia_detail_chem_leadmine.tsv && rm $NER_SHELL_PATH/clia_detail_gene_or_protein_leadmine.tsv

# H2 
java -cp $H2_JAR org.h2.tools.RunScript -url "jdbc:h2:$DATABASE_PATH" -script $SQL_SCRIPT1 && rm $NER_SHELL_PATH/clia_detail_chem_leadmine.tsv && rm $NER_SHELL_PATH/clia_detail_gene_or_protein_leadmine.tsv

if [ ! -f "$NER_SHELL_PATH/clia_detail_gene_or_protein_leadmine.tsv" ]; then
	$NER_SHELL_PATH/Go_fda_NER_leadmine_chem.sh # use custom config or leadmine config
	#$NER_SHELL_PATH/Go_fda_NER_leadmine_gene.sh
	java -jar $LEADMINE_PATH/leadmine-4.0.2/bin/leadmine.jar -c $LEADMINE_PATH/dictionaries-20250331/gpro.cfg $DEST_PATH/clia_analytes.tsv > $DEST_PATH/gp_analytes.tsv 2> $DEST_PATH/ner_error.log
fi
if [ -f "$NER_SHELL_PATH/clia_detail_gene_or_protein_leadmine.tsv" ]; then	
	java -cp $H2_JAR org.h2.tools.RunScript -url "jdbc:h2:$DATABASE_PATH" -script $SQL_SCRIPT2
	#postgresql
	#psql -U $USERNAME -D $DB_NAME -F $SQL_SCRIPT
fi
