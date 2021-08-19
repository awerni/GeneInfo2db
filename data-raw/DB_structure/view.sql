CREATE OR REPLACE VIEW gene2transcript2exon AS
  SELECT g.*, t.enst, t.transcriptname, t.seqstart as transcript_seqstart, t.seqend as transcript_seqend, t.iscanonical, t.cosmic_id_transcript, 
  e.ense, t2e.exon, e.seqstart as exon_seqstart, e.seqend as exon_seqend FROM 
  gene g INNER JOIN transcript t on t.ensg = g.ensg
  JOIN transcript2exon t2e ON t2e.enst =  t.enst
  JOIN exon e ON e.ense = t2e.ense;

-------------------------------------------------------
--CREATE OR REPLACE VIEW normchromentrezgene2ensemblgene AS
--SELECT e2e.* FROM entrezgene2ensemblgene e2e JOIN gene g on g.ensg = e2e.ensg WHERE length(chromosome) <= 2;

DROP VIEW IF EXISTS distinctentrezgene2ensemblgene;
CREATE OR REPLACE VIEW normchromentrezgene2ensemblgene AS
SELECT e2e.* FROM entrezgene2ensemblgene e2e 
  JOIN gene g ON g.ensg = e2e.ensg 
  JOIN entrezgene eg ON eg.geneid = e2e.geneid
  WHERE length(g.chromosome) <= 2 AND localisation <> '-';

CREATE OR REPLACE VIEW distinctentrezgene2ensemblgene AS
SELECT g.ensg, e.geneid FROM
       (SELECT ensg, geneid FROM normchromentrezgene2ensemblgene
       WHERE ensg IN (SELECT ensg FROM normchromentrezgene2ensemblgene GROUP BY ensg HAVING count(*) = 1)
       AND geneid IN (SELECT geneid FROM normchromentrezgene2ensemblgene GROUP BY geneid HAVING count(*) = 1)) e2e
       JOIN gene g ON g.ensg = e2e.ensg JOIN entrezgene e ON e.geneid = e2e.geneid
       WHERE e.chromosome = g.chromosome 
UNION 
SELECT g.ensg, e.geneid FROM
       (SELECT ensg, geneid FROM normchromentrezgene2ensemblgene
       WHERE ensg IN (SELECT ensg FROM normchromentrezgene2ensemblgene GROUP BY ensg HAVING count(*) > 1)
       OR geneid IN (SELECT geneid FROM normchromentrezgene2ensemblgene GROUP BY geneid HAVING count(*) > 1)) e2e
       JOIN gene g ON g.ensg = e2e.ensg JOIN entrezgene e ON e.geneid = e2e.geneid
       WHERE e.chromosome = g.chromosome AND g.symbol = e.symbol AND e.nuclstart IS NOT NULL AND e.nuclend IS NOT NULL;


--CREATE OR REPLACE VIEW distinctentrezgene2ensemblgene AS
--SELECT g.ensg, e.geneid FROM
--       (SELECT ensg, geneid FROM normchromentrezgene2ensemblgene
--       WHERE ensg IN (SELECT ensg FROM normchromentrezgene2ensemblgene GROUP BY ensg HAVING count(*) = 1)
--       AND geneid IN (SELECT geneid FROM normchromentrezgene2ensemblgene GROUP BY geneid HAVING count(*) = 1)) e2e
--       JOIN gene g ON g.ensg = e2e.ensg JOIN entrezgene e ON e.geneid = e2e.geneid
--       WHERE e.chromosome = g.chromosome;


CREATE OR REPLACE VIEW humanmouseorthologs AS
SELECT eh.ensg as humanensg, eh.geneid as humangeneid, eh.symbol as humansymbol, em.ensg as mouseensg, em.geneid as mousegeneid, em.symbol as mousesymbol
  from (SELECT e.ensg, g.symbol, h.* from normchromentrezgene2ensemblgene e JOIN homologene h on h.geneid = e.geneid and getspecies(ensg) = 'human' JOIN gene g on g.ensg = e.ensg) eh
  JOIN (SELECT e.ensg, g.symbol, h.* from normchromentrezgene2ensemblgene e JOIN homologene h on h.geneid = e.geneid and getspecies(ensg) = 'mouse' JOIN gene g on g.ensg = e.ensg) em
    ON eh.homologenecluster = em.homologenecluster;

CREATE OR REPLACE VIEW codingExons AS
SELECT *, getCodingLength(exon, transstart, transend, seqstart, seqend, strand, startexon, endexon) as codinglength 
FROM (SELECT t2e.ense, t2e.enst, t2e.exon, t2e.transstart, t2e.transend, e.chromosome, e.seqstart, e.seqend, t.strand, 
  (SELECT exon FROM transcript2exon WHERE transstart IS NOT NULL AND enst = t.enst) AS startexon, 
  (SELECT exon FROM transcript2exon WHERE transend IS NOT NULL AND enst = t.enst) AS endexon 
  FROM transcript2exon t2e natural join exon e join transcript t ON t.enst = t2e.enst) AS x;

CREATE OR REPLACE VIEW datastackstat AS
SELECT datastackid, key, created, count(*) AS rows
  FROM (SELECT datastackid, created, jsonb_object_keys(jsonb_array_elements(playload)) AS key FROM datastack ) AS t
  WHERE key IN ('celllinename', 'tissuename') GROUP BY datastackid, key, created ORDER BY created;

--WITH celllinetpm AS (
--      SELECT prv.celllinename, ensg, log2tpm FROM cellline.processedrnaseqview prv join cellline.cellline c ON c.celllinename = prv.celllinename
--      WHERE tumortype = 'melanoma' AND
--      ensg in (SELECT ensg FROM gene WHERE biotype = 'protein_coding' AND species = 'human') 
--    ), 
--    percentile AS (
--      SELECT ensg, percentile_cont(array[0.25, 0.5, 0.75]) within GROUP (ORDER BY log2tpm) AS percentile 
--      FROM celllinetpm GROUP by ensg
--    ),
--    boxlimit AS (
--      SELECT ensg, 2.5 * percentile[1] - 1.5 * percentile[3] AS minWhisker, 2.5 * percentile[3] - 1.5 * percentile[1] AS maxWhisker, percentile FROM percentile
--    )
--    SELECT ensg, minWhisker, maxWhisker, percentile[1] AS p25, percentile[2] AS p50, percentile[3] AS p75, 
--      (SELECT max(log2tpm) FROM celllinetpm WHERE ensg = bl.ensg AND log2tpm > percentile[3] AND log2tpm <= maxWhisker) AS endwhisker FROM boxlimit bl;
--
--explain analyze select ensg, percentile_cont(array[0.25, 0.5, 0.75]) within group (order by log2tpm) as percentile, percentile  from cellline.processedrnaseqview prv join cellline.cellline c on c.celllinename = prv.celllinename WHERE tumortype = 'melanoma' and ensg in (select ensg from gene where biotype = 'protein_coding' and species = 'human') GROUP by ensg;
