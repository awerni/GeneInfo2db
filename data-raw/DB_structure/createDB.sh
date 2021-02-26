#!/bin/sh

cd /data/bioinf/wernitznig/bioinfoDB/Database
DB="psql ordino_new.hg38"

echo "drop schema cellline cascade;" | $DB

cat recreatePublic.sql | $DB

echo "CREATE schema cellline;" | $DB

cat geneAnnotation.sql | $DB 
echo "set search_path = cellline,public;" | cat - celllineDB.sql | $DB

cat storedprocedure.sql view.sql trigger.sql | $DB

cat storedprocedureCellline.sql viewCellline.sql triggerCellline.sql | $DB 

cat sequenceCellline.sql | $DB

cat indexCellline.sql index.sql | $DB 

cat permission.sql | $DB
