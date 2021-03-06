-------------------------------------------------------------------------------
-- Name:             storedprocedureCellline.sql
-- Last changed:     
-- Description:      stored procedures for schema cellline
-- Author:           Andreas Wernitznig
-------------------------------------------------------------------------------

CREATE OR REPLACE LANGUAGE 'plperl';

CREATE OR REPLACE FUNCTION cellline.getCopyNumberRegion(hid TEXT, chrom INT2, nucstart INT4, nucstop INT4, alg TEXT) RETURNS REAL as $$
DECLARE
  ld_row record;
  nCounter INTEGER;
  mymean REAL;
  retval REAL;
BEGIN
    nCounter = 0;

    FOR ld_row IN SELECT log2relativecopynumber as m FROM cellline.copynumberregion WHERE algorithm = alg AND 
        hybridizationid = hid AND chromosome = chrom AND start <= nucstart AND stop >= nucstop 
    LOOP
      nCounter = nCounter + 1;
      mymean = ld_row.m;
    END LOOP;

    IF nCounter = 1 THEN
      RETURN 2 * 2 ^ mymean;
    ELSE
      SELECT INTO nCounter count(*) FROM cellline.copynumberregion WHERE algorithm = alg AND 
        hybridizationid = hid AND chromosome = chrom AND 
        ((start >= nucstart AND start <= nucstop) OR (stop >= nucstart AND stop <= nucstop));
      IF (nCounter <= 1) THEN retval := -1; END IF;
      IF (nCounter > 1) THEN retval := -2; END IF;
      RETURN retval;
    END IF;
END;
$$ language 'plpgsql';

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

CREATE FUNCTION cellline.findMutationORsnp(symbol TEXT, proteinmutation TEXT) RETURNS SETOF mutsummary AS $$
  my $symbol = shift;
  my $proteinmutation = shift;
  my $res = [];
  my @sources = ("BI-NGS", "BI-CS", "BI-WXS", "CCLE-WXS");

  my $sql = "SELECT distinct exon FROM cellline.sequencingresultssnp WHERE symbol = '$symbol' 
             AND proteinmutation = '$proteinmutation'";
  my $findExon = spi_exec_query($sql);
  my $numExon = $findExon->{processed}; 
  my $exon = $findExon->{rows}[0]->{exon};

  if ($numExon == 1) {
    $sql = "SELECT celllinename, analysissource FROM cellline.analysisrun ar JOIN cellline.analysis a ON (a.analysisrunid = ar.analysisrunid) 
            JOIN cellline.analyzedexon ae ON (a.analysisrunid = ae.analysisrunid and a.analysisid = ae.analysisid) 
            WHERE ensg IN (SELECT ensg FROM gene WHERE symbol = '$symbol') and exon = $exon";

    my %analyzed;
    my $analyzed = spi_exec_query($sql);
    my $nrows = $analyzed->{processed};
    foreach my $rn (0 .. $nrows - 1) {
      my $row = $analyzed->{rows}[$rn];
      my $celllinename = $row->{celllinename};
      $analyzed{$celllinename} = [0, 0, 0, 0] unless (exists $analyzed{$celllinename});
      foreach my $n (0..3) {
        @{$analyzed{$celllinename}}[$n]++ if ($row->{analysissource} eq $sources[$n]);
      }
    }

    $sql = "SELECT celllinename, zygosity, analysissource FROM cellline.sequencingresultssnp 
            WHERE symbol = '$symbol' AND proteinmutation = '$proteinmutation'";

    my %mutations;
    my $mutations = spi_exec_query($sql);
    $nrows = $mutations->{processed};
    foreach my $rn (0 .. $nrows - 1) {
      my $row = $mutations->{rows}[$rn];
      my $celllinename = $row->{celllinename};
      $mutations{$celllinename} = [-1, -1, -1, -1] unless (exists $mutations{$celllinename});
      my $mymut = $mutations{$celllinename};
      foreach my $n (0..3) {
        @{$mymut}[$n] = $row->{zygosity} if (($row->{analysissource} eq $sources[$n]) & @{$mymut}[$n] < $row->{zygosity});
      }
    } 

    for my $celllinename (keys %analyzed) {
      my $zygosity = 0;
      my $found = 0;
      my $notfound = 0;
      if (exists $mutations{$celllinename}) {
        my $mymut = $mutations{$celllinename};
        @zyglist = sort { $a <=> $b } @{$mymut};
        $zygosity = $zyglist[$#zyglist]; 
        $found = 1;
        foreach my $n (0..3) { 
          $notfound = 1 if ((@{$analyzed{$celllinename}}[$n] > 0) & (@{$mymut}[$n] == -1));
        }
      } else {
        $zygosity = undef;
        $notfound = 1;
      }
      $sum = 0;
      $sum += $_ for @{$analyzed{$celllinename}};
      
      push(@$res, {celllinename => $celllinename, numbings => @{$analyzed{$celllinename}}[0], numbics => @{$analyzed{$celllinename}}[1], 
                   numbiwxs => @{$analyzed{$celllinename}}[2], numcclewxs => @{$analyzed{$celllinename}}[3],
                   zygosity => $zygosity, found => $found, notfound => $notfound}) unless ($sum == 0);
    }
  } else {
    elog(WARNING, "can not find snp/mutation in database") unless ($exon);
    return;
  }
  return $res;
$$ LANGUAGE plperl;

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

--- getCopyNumber(chromosome, start, stop, cellline)

CREATE FUNCTION cellline.getCopyNumberCellline(TEXT) RETURNS SETOF copynumberresult AS $$
  my ($chromosome, $start, $stop, $celllinename) = @_;
  my $res = [];

  my $sql1 = "SELECT * FROM cellline.copynumberregion WHERE hybridizationid IN 
              (SELECT hybridizationid FROM cellline.hybridization WHERE celllinename = '$celllinename' 
               AND chipname = 'GenomeWideSNP_6.Full') AND algorithm = 'GLAD'";
  my $rv1 = spi_exec_query($sql1);
  my @cn;
  my $nrows1 = $rv1->{processed};

  foreach my $rn1 (0 .. $nrows1 - 1) {
    my $row = $rv->{rows}[$rn];
    push(@cn, $row->{mean}); 
  }

  my $sql = "SELECT ensg, chromosome, seqregionstart, seqregionend FROM gene";
  my $rv = spi_exec_query($sql);
  my $nrows = $rv->{processed};

  foreach my $rn (0 .. $nrows - 1) {
    my $row = $rv->{rows}[$rn];    
 
    push(@$res,  {celllinename => $celllinename,
               ensg => $row->{ensg},
               log2copynumber => 2,
               weightedlog2copynumber => 2.2, 
               copynumbergainintron => FALSE,
               copynumberlossintron => FALSE,
               copynumbergainexon => FALSE,
               copynumberlossexon => FALSE,
               gap => FALSE,
               jump => FALSE,
               exonicchange => FALSE,
               intronicchange => FALSE,
               cosmicdeletion => undef,
               cosmiczygosity => undef,  
               bicsdeletion => undef,
               bicszygosity => undef,
               ngsdeletion => undef,
               ngszygosity => undef,
               snpchipalteration => undef,
               snpchipzygocity => undef,
               numsources => 1
            });
  } 
  return $res;
$$ LANGUAGE plperl;

--EXPLAIN ANALYZE SELECT * from cellline.getCopyNumberCellline('PC-3') limit 10;

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
