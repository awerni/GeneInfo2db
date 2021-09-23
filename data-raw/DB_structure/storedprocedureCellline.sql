-------------------------------------------------------------------------------
-- Name:             storedprocedureCellline.sql
-- Last changed:     
-- Description:      stored procedures for schema cellline
-- Author:           Andreas Wernitznig
-------------------------------------------------------------------------------

--CREATE OR REPLACE LANGUAGE 'plperl';

-------------------------------------------------------------------------------
-- findMutationORsnp(text, text)
-- find a list of cell lines that have or have not a certain mutation of SNP 
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS cellline.findMutationORsnp(symbol TEXT, proteinmutation TEXT);
DROP TYPE IF EXISTS mutsummary;

CREATE TYPE mutsummary AS (
  celllinename TEXT,
  numBINGS INT2,
  numBICS INT2,
  numBIWXS INT2,
  numCCLEWXS INT2,
  zygosity REAL,
  found BOOL,
  notfound BOOL
);

---------------------------------------------------------------------
DROP FUNCTION IF EXISTS cellline.getCopyNumberCellline(TEXT);
DROP TYPE IF EXISTS copynumberresult;

CREATE TYPE copynumberresult AS (
  celllinename varchar(50),
  ensg varchar(20),
  log2copynumber real,
  weightedlog2copynumber real,
  copynumbergainintron  boolean,
  copynumberlossintron  boolean,
  copynumbergainexon    boolean,
  copynumberlossexon    boolean,
  gap                   boolean,
  jump                  boolean, 
  exonicchange          boolean, 
  intronicchange        boolean, 
  cosmicdeletion        TEXT,
  cosmiczygosity        real, 
  bicsdeletion          TEXT, 
  bicszygosity          real, 
  ngsdeletion           TEXT,
  ngszygosity           real,
  snpchipalteration     TEXT, 
  snpchipzygocity       real,
  numsources            smallint
);

----------------------------------------

CREATE OR REPLACE FUNCTION cellline_expression(rnaseqrun TEXT[], min_max INT4)
RETURNS TABLE (
    celllinename TEXT,
    ENSG TEXT,
    log2fpkm real,
    log2tpm real,
    log2cpm real, 
    counts INTEGER
  )
AS $$
BEGIN
  RETURN QUERY 
  WITH expr_data AS (
    SELECT r.celllinename, e.ensg, e.log2fpkm, e.log2tpm, e.log2cpm, e.counts FROM cellline.processedrnaseq e
    INNER JOIN cellline.rnaseqrun r ON r.rnaseqrunid = e.rnaseqrunid
    WHERE r.rnaseqrunid = ANY(rnaseqrun)
  ),
  ensg_expr AS (
    SELECT e.ensg from expr_data e GROUP BY e.ensg HAVING max(e.counts) >= min_max
  )
  SELECT n.celllinename, n.ensg, n.counts FROM expr_data n INNER JOIN ensg_expr e ON e.ensg = n.ensg;
END; $$ 
LANGUAGE 'plpgsql'; 
