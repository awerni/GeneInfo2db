DROP VIEW IF EXISTS tissue.processedcopynumberview;
CREATE VIEW tissue.processedcopynumberview AS
SELECT symbol, pcn.* FROM tissue.processedcopynumber pcn JOIN gene g ON (g.ensg = pcn.ensg);

DROP VIEW IF EXISTS tissue.processedsequenceview;
CREATE VIEW tissue.processedsequenceview AS
SELECT symbol, t.ensg, ps.* from tissue.processedsequence ps JOIN transcript t on (t.enst = ps.enst) join gene g on (g.ensg = t.ensg);

DROP VIEW IF EXISTS tissue.processedfusiongeneview;
CREATE VIEW tissue.processedfusiongeneview AS
SELECT pfg.processedfusion, pfg.tissuename, pfg.ensg1, pfg.ensg2, g1.symbol as symbol1, g2.symbol as symbol2, pfg.countsofcommonmappingreads,
       pfg.spanningpairs, pfg.spanninguniquereads, pfg.longestanchorfound, pfg.fusionfindingmethod, pfg.chrgene1, pfg.chrgene2,
       pfg.nuclgene1, pfg.nuclgene2, pfg.strandgene1, pfg.strandgene2, pfg.rnaseqrunid, pfg.predictedeffect FROM tissue.processedfusiongene pfg
       JOIN gene g1 on (pfg.ensg1 = g1.ensg)
       JOIN gene g2 on (pfg.ensg2 = g2.ensg);

DROP VIEW IF EXISTS tissue.processedrnaseqview CASCADE;
CREATE VIEW tissue.processedrnaseqview AS
SELECT prs.rnaseqrunid, tissuename, prs.ensg, prs.log2fpkm, prs.log2tpm, prs.log2cpm, prs.counts FROM tissue.processedrnaseq prs 
       JOIN tissue.rnaseqrun nr ON nr.rnaseqrunid = prs.rnaseqrunid WHERE nr.canonical AND nr.publish;

DROP VIEW IF EXISTS tissue.processedrnaseqtranscriptview CASCADE;
CREATE VIEW tissue.processedrnaseqtranscriptview AS
SELECT prs.rnaseqrunid, tissuename, prs.enst, prs.log2fpkm, prs.log2tpm, prs.counts FROM tissue.processedrnaseqtranscript 
       prs JOIN tissue.rnaseqrun nr ON nr.rnaseqrunid = prs.rnaseqrunid WHERE nr.canonical and nr.publish;

---- formerly used in the view tissue.processedsequenceExtended 
--DROP MATERIALIZED VIEW tissue.tcgaensg CASCADE;
--CREATE MATERIALIZED VIEW tissue.tcgaensg AS
--SELECT DISTINCT enst
--  FROM tissue.processedsequence WHERE processedsequence.tissuename IN 
--  (SELECT tissuename FROM tissue.tissueassignment WHERE tissuepanel = 'TCGA tumors');

----
DROP VIEW IF EXISTS tissue.TCGAenst CASCADE;
CREATE MATERIALIZED VIEW tissue.TCGAenst AS
WITH TCGAtissue AS (
  SELECT t.tissuename
    FROM tissue.tissueassignment ta JOIN tissue.tissue t ON t.tissuename = ta.tissuename
    WHERE tissuepanel = 'TCGA tumors' AND dnasequenced
  )
  SELECT distinct enst FROM tissue.processedsequence p JOIN TCGAtissue t ON p.tissuename = t.tissuename;
--

DROP VIEW IF EXISTS tissue.processedsequenceExtended CASCADE;
CREATE VIEW tissue.processedsequenceExtended AS
WITH TCGAtissue AS (
  SELECT t.tissuename
    FROM tissue.tissueassignment ta JOIN tissue.tissue t ON t.tissuename = ta.tissuename
    WHERE tissuepanel = 'TCGA tumors' AND dnasequenced
  ),
  otherTissue AS (
  SELECT tissuename
    FROM tissue.tissue WHERE tissuename NOT IN (SELECT tissuename FROM TCGAtissue)
  )
  SELECT * FROM (
  SELECT ensg, ps.enst, ps.tissuename, ps.dnamutation, ps.aamutation, ps.dnazygosity, ps.exonscomplete
    FROM tissue.processedsequence ps JOIN transcript tr ON (ps.enst = tr.enst AND tr.iscanonical) WHERE tissuename IN (SELECT tissuename FROM otherTissue)
  UNION
  SELECT ensg, e.enst, t.tissuename,
    coalesce(dnamutation, 'wt') AS dnamutation, coalesce(aamutation, 'wt') AS aamutation, dnazygosity, exonscomplete
    FROM (SELECT tissuename FROM TCGAtissue) AS t
    LEFT OUTER JOIN tissue.TCGAenst e ON (TRUE)
    LEFT OUTER JOIN transcript tr ON (e.enst = tr.enst AND tr.iscanonical)
    LEFT OUTER JOIN tissue.processedsequence ps ON (t.tissuename = ps.tissuename AND e.enst = ps.enst)) t;

-------------

--- alternative to the above one
--DROP VIEW IF EXISTS tissue.processedsequenceExtended CASCADE;
--CREATE VIEW tissue.processedsequenceExtended AS
--WITH TCGAtissue AS (
--  SELECT tissuename             
--    FROM tissue.tissueassignment WHERE tissuepanel = 'TCGA tumors'
--  ),
--  TCGAenst AS (
--  SELECT DISTINCT enst FROM tissue.processedsequence
--    WHERE tissuename IN (SELECT tissuename FROM TCGAtissue)
--  )
--  SELECT ps.* FROM tissue.processedsequence ps
--  UNION
--  SELECT tissuename, e.enst, 1 AS versionnumber, 'wt' AS dnamutation, 'wt' AS aamutation, NULL AS zygosity, NULL AS exonscomplete
--    FROM TCGAtissue t, TCGAenst e WHERE (t.tissuename, e.enst) NOT IN 
--     (SELECT ps.tissuename, ps.enst FROM tissue.processedsequence ps JOIN TCGAtissue t ON (ps.tissuename = t.tissuename)
--  ) AS;

-------------

DROP MATERIALIZED VIEW IF EXISTS tissue.mutationalburden CASCADE;
CREATE MATERIALIZED VIEW tissue.mutationalburden AS
SELECT pse.tissuename, species, tumortype, sum((aamutation <> 'wt')::INT4)/count(*)::REAL AS mutational_fraction
  FROM tissue.processedsequenceExtended pse JOIN tissue.tissue t ON t.tissuename = pse.tissuename JOIN transcript tr on tr.enst = pse.enst
  WHERE iscanonical 
  GROUP BY pse.tissuename, species, tumortype HAVING count(*) > 10000;

----------------------

CREATE OR REPLACE VIEW tissue.hla_a_type AS
SELECT t.tissuename, n.rnaseqrunid, allele1 AS HLA_A_allele1, allele2 AS HLA_A_allele2 FROM tissue.tissue t
JOIN tissue.rnaseqrun n ON (t.tissuename = n.tissuename AND canonical)
JOIN tissue.hlatype h ON (n.rnaseqrunid = h.rnaseqrunid AND hla_class = 'A');

----------------------

DROP MATERIALIZED VIEW IF EXISTS tissue.processedrnaseq_array;

DROP MATERIALIZED VIEW IF EXISTS tissue.expressed_ensg;

CREATE MATERIALIZED VIEW tissue.expressed_ensg AS
SELECT p.ensg, species
  FROM tissue.processedrnaseq p JOIN public.gene g ON (p.ensg = g.ensg)
  GROUP BY p.ensg, species
  HAVING max(counts) >= 20 ORDER BY species, p.ensg;

CREATE MATERIALIZED VIEW tissue.processedrnaseq_array AS
SELECT tissuename,
  array(SELECT log2tpm FROM tissue.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid AND ensg IN (SELECT ensg FROM tissue.expressed_ensg) ORDER BY ensg) AS log2tpm,
  array(SELECT counts FROM tissue.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid AND ensg IN (SELECT ensg FROM tissue.expressed_ensg) ORDER BY ensg) AS counts
  FROM tissue.rnaseqrun r WHERE canonical AND publish AND rnaseqrunid NOT LIKE '%mouse' 
  AND tissuename IN (SELECT tissuename FROM tissue.tissueassignment WHERE tissuepanel IN ('TCGA and GTEx', 'PDX Models'));

---

DROP MATERIALIZED VIEW IF EXISTS tissue.processedrnaseq_array_full;

DROP MATERIALIZED VIEW IF EXISTS tissue.expressed_ensg_full;

CREATE MATERIALIZED VIEW tissue.expressed_ensg_full AS
SELECT distinct p.ensg, species
  FROM tissue.processedrnaseq p JOIN public.gene g ON (p.ensg = g.ensg) 
  ORDER by species, p.ensg;

CREATE MATERIALIZED VIEW tissue.processedrnaseq_array_full AS
SELECT tissuename,
  array(SELECT log2tpm FROM tissue.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY ensg) AS log2tpm,
  array(SELECT counts FROM tissue.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY ensg) AS counts
  FROM  tissue.rnaseqrun r WHERE canonical AND publish AND rnaseqrunid NOT LIKE '%mouse' 
  AND tissuename IN (SELECT tissuename FROM tissue.tissueassignment WHERE tissuepanel IN ('TCGA and GTEx', 'PDX Models'));

----------------------

DROP MATERIALIZED VIEW IF EXISTS tissue.processedrnaseqtranscript_array;

DROP MATERIALIZED VIEW IF EXISTS tissue.expressed_enst;

CREATE MATERIALIZED VIEW tissue.expressed_enst AS
SELECT p.enst, species
  FROM tissue.processedrnaseqtranscript p
    JOIN public.transcript t ON (p.enst = t.enst)
    JOIN public.gene g ON (g.ensg = t.ensg)
  GROUP BY p.enst, species
  HAVING max(counts) >= 20 ORDER by species, p.enst;

CREATE MATERIALIZED VIEW tissue.processedrnaseqtranscript_array AS
SELECT tissuename,
  array(SELECT log2tpm FROM tissue.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid AND enst IN (SELECT enst from tissue.expressed_enst) ORDER BY enst) AS log2tpm,
  array(SELECT counts FROM tissue.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid AND enst IN (SELECT enst from tissue.expressed_enst) ORDER BY enst) AS counts
  FROM  tissue.rnaseqrun r WHERE canonical AND publish AND rnaseqrunid NOT LIKE '%mouse' 
  AND tissuename IN (SELECT tissuename FROM tissue.tissueassignment WHERE tissuepanel IN ('TCGA and GTEx', 'PDX Models'));

---

DROP MATERIALIZED VIEW IF EXISTS tissue.processedrnaseqtranscript_array_full;

DROP MATERIALIZED VIEW IF EXISTS tissue.expressed_enst_full;

CREATE MATERIALIZED VIEW tissue.expressed_enst_full AS
SELECT distinct p.enst, species
  FROM tissue.processedrnaseqtranscript p
    JOIN public.transcript t ON (p.enst = t.enst)
    JOIN public.gene g ON (g.ensg = t.ensg)
    ORDER by species, p.enst;

CREATE MATERIALIZED VIEW tissue.processedrnaseqtranscript_array_full AS
SELECT tissuename,
  array(SELECT log2tpm FROM tissue.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY enst) AS log2tpm,
  array(SELECT counts FROM tissue.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY enst) AS counts
  FROM  tissue.rnaseqrun r WHERE canonical AND publish AND rnaseqrunid NOT LIKE '%mouse' 
  AND tissuename IN (SELECT tissuename FROM tissue.tissueassignment WHERE tissuepanel IN ('TCGA and GTEx', 'PDX Models')); 

---
DROP MATERIALIZED VIEW IF EXISTS tissue.processedcopynumber_array;

DROP MATERIALIZED VIEW IF EXISTS tissue.cnaltered_ensg;

CREATE MATERIALIZED VIEW tissue.cnaltered_ensg AS
SELECT p.ensg, species
  FROM tissue.processedcopynumber p JOIN public.gene g ON (p.ensg = g.ensg)
  GROUP BY p.ensg, species
  HAVING min(log2relativecopynumber) < log(2, 0.75) OR max(log2relativecopynumber) > log(2, 1.5) ORDER BY species, p.ensg;

CREATE MATERIALIZED VIEW tissue.processedcopynumber_array AS
WITH cntissue AS (SELECT DISTINCT tissuename FROM tissue.processedcopynumber WHERE ensg IN (SELECT ensg FROM tissue.cnaltered_ensg LIMIT 20))
SELECT tissuename,
  array(SELECT log2relativecopynumber FROM tissue.cnaltered_ensg e LEFT JOIN tissue.processedcopynumber p ON (p.ensg = e.ensg AND p.tissuename = cnt.tissuename) ORDER BY e.ensg) AS log2relativecopynumber
  FROM cntissue cnt;

-------------
