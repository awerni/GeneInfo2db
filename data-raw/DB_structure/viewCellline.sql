-------------------------------------------------
---- Views for celllineDB -----------------------
-------------------------------------------------

CREATE OR REPLACE VIEW cellline.combiDetails AS
SELECT doseresponsematrix, drugid, drugid2, (cellline.getcombiResults(drm.doseresponsematrix)).* FROM cellline.doseresponsematrix drm;

CREATE OR REPLACE VIEW cellline.hla_a_type AS
SELECT c.celllinename, n.rnaseqrunid, allele1 AS HLA_A_allele1, allele2 as HLA_A_allele2 FROM cellline.cellline c
JOIN cellline.rnaseqrun n ON (c.celllinename = n.celllinename AND canonical)
JOIN cellline.hlatype h ON (n.rnaseqrunid = h.rnaseqrunid AND hla_class = 'A');

-----------------------------------------------------

DROP VIEW IF EXISTS cellline.hybrid;
CREATE VIEW cellline.hybrid AS
SELECT hybridizationid, h.chipname, chiptype, h.celllinename, organ, tumortype, histology_type, histology_subtype, 
       morphology, growth_type, laboratory, hybridizationgroupname, cellbatchid, analysisdirectory as directory, isxenograft, compound, h.comment 
FROM cellline.hybridization h JOIN cellline.hybridizationgroup hg ON (hg.hybridizationgroupid = h.hybridizationgroupid) 
JOIN cellline.cellline c ON (h.celllinename = c.celllinename) JOIN chiptechnology ct ON (ct.chipname = h.chipname) WHERE publish = TRUE;

-------------------------------------------------

DROP VIEW IF EXISTS cellline.availabledata;
CREATE VIEW cellline.availabledata AS 
SELECT celllinename,
  exists (SELECT enst FROM cellline.processedsequence WHERE celllinename = cl.celllinename) as dnaseqexists,
  exists (SELECT ensg FROM cellline.processedcopynumber WHERE celllinename = cl.celllinename) as copynumberexists, 
  exists (SELECT rnaseqrunid FROM cellline.rnaseqrun WHERE celllinename = cl.celllinename AND canonical) as rnaseqexists,
  exists (SELECT ensg1 FROM cellline.processedfusiongene WHERE celllinename = cl.celllinename) as fusiongeneexists,       
  exists (SELECT rnaseqrunid FROM cellline.hla_a_type WHERE celllinename = cl.celllinename) as hlatypeexists,
  tumortype
FROM cellline.cellline cl;

DROP VIEW IF EXISTS cellline.other_celllinename;
CREATE VIEW  cellline.other_celllinename AS
SELECT celllinename, alternative_celllinename AS other_celllinename FROM cellline.alternative_celllinename
UNION
SELECT celllinename, ccle AS other_celllinename FROM cellline.cellline WHERE ccle IS NOT NULL
UNION
SELECT celllinename, depmap AS other_celllinename FROM cellline.cellline WHERE depmap IS NOT NULL
UNION
SELECT celllinename, cell_model_passport AS other_celllinename FROM cellline.cellline WHERE cell_model_passport IS NOT NULL
UNION
SELECT celllinename, cellosaurus AS other_celllinename FROM cellline.cellline WHERE cellosaurus IS NOT NULL;

-------------
DROP MATERIALIZED VIEW IF EXISTS cellline.processedrnaseq_array;

DROP MATERIALIZED VIEW IF EXISTS cellline.expressed_ensg;

CREATE MATERIALIZED VIEW cellline.expressed_ensg AS
SELECT p.ensg, species
  FROM cellline.processedrnaseq p JOIN public.gene g ON (p.ensg = g.ensg)
  GROUP BY p.ensg, species
  HAVING max(counts) >= 20 ORDER BY species, p.ensg;

CREATE MATERIALIZED VIEW cellline.processedrnaseq_array AS
SELECT celllinename,
  array(SELECT log2tpm FROM cellline.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid AND ensg IN (SELECT ensg from cellline.expressed_ensg) ORDER BY ensg) AS log2tpm,
  array(SELECT counts FROM cellline.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid AND ensg IN (SELECT ensg from cellline.expressed_ensg) ORDER BY ensg) AS counts
  FROM cellline.rnaseqrun r WHERE canonical AND publish AND rnaseqgroupid IN (select rnaseqgroupid from cellline.rnaseqgroup WHERE rnaseqname like 'untreated %cellline reference set%');

---

DROP MATERIALIZED VIEW IF EXISTS cellline.processedrnaseq_array_full;

DROP MATERIALIZED VIEW IF EXISTS cellline.expressed_ensg_full;

CREATE MATERIALIZED VIEW cellline.expressed_ensg_full AS
SELECT distinct p.ensg, species
  FROM cellline.processedrnaseq p JOIN public.gene g ON (p.ensg = g.ensg)
  ORDER by species, p.ensg;

CREATE MATERIALIZED VIEW cellline.processedrnaseq_array_full AS
SELECT celllinename,
  array(SELECT log2tpm FROM cellline.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY ensg) AS log2tpm,
  array(SELECT counts FROM cellline.processedrnaseq p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY ensg) AS counts
  FROM cellline.rnaseqrun r WHERE canonical AND publish AND rnaseqgroupid IN (select rnaseqgroupid from cellline.rnaseqgroup WHERE rnaseqname like 'untreated %cellline reference set%');


-----------
DROP MATERIALIZED VIEW IF EXISTS cellline.processedrnaseqtranscript_array;

DROP MATERIALIZED VIEW IF EXISTS cellline.expressed_enst;

CREATE MATERIALIZED VIEW cellline.expressed_enst AS
SELECT p.enst, species
  FROM cellline.processedrnaseqtranscript p 
    JOIN public.transcript t ON (p.enst = t.enst)
    JOIN public.gene g ON (g.ensg = t.ensg)
  GROUP BY p.enst, species
  HAVING max(counts) >= 20 ORDER by species, p.enst;

CREATE MATERIALIZED VIEW cellline.processedrnaseqtranscript_array AS
SELECT celllinename,
  array(SELECT log2tpm FROM cellline.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid AND enst IN (SELECT enst from cellline.expressed_enst) ORDER BY enst) AS log2tpm,
  array(SELECT counts FROM cellline.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid AND enst IN (SELECT enst from cellline.expressed_enst) ORDER BY enst) AS counts
  FROM cellline.rnaseqrun r WHERE canonical AND publish AND rnaseqgroupid IN (select rnaseqgroupid from cellline.rnaseqgroup WHERE rnaseqname like 'untreated %cellline reference set%');

---

DROP MATERIALIZED VIEW IF EXISTS cellline.processedrnaseqtranscript_array_full;

DROP MATERIALIZED VIEW IF EXISTS cellline.expressed_enst_full;

CREATE MATERIALIZED VIEW cellline.expressed_enst_full AS
SELECT distinct p.enst, species
  FROM cellline.processedrnaseqtranscript p
    JOIN public.transcript t ON (p.enst = t.enst)
    JOIN public.gene g ON (g.ensg = t.ensg)
    ORDER by species, p.enst;

CREATE MATERIALIZED VIEW cellline.processedrnaseqtranscript_array_full AS
SELECT celllinename,
  array(SELECT log2tpm FROM cellline.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY enst) AS log2tpm,
  array(SELECT counts FROM cellline.processedrnaseqtranscript p WHERE p.rnaseqrunid = r.rnaseqrunid ORDER BY enst) AS counts
  FROM cellline.rnaseqrun r WHERE canonical AND publish AND rnaseqgroupid IN (select rnaseqgroupid from cellline.rnaseqgroup WHERE rnaseqname like 'untreated %cellline reference set%');

---

DROP MATERIALIZED VIEW IF EXISTS cellline.processedcopynumber_array;

DROP MATERIALIZED VIEW IF EXISTS cellline.cnaltered_ensg;

CREATE MATERIALIZED VIEW cellline.cnaltered_ensg AS
SELECT p.ensg, species
  FROM cellline.processedcopynumber p JOIN public.gene g ON (p.ensg = g.ensg)
  GROUP BY p.ensg, species
  HAVING min(log2relativecopynumber) < log(2, 0.75) OR max(log2relativecopynumber) > log(2, 1.5) ORDER BY species, p.ensg;

CREATE MATERIALIZED VIEW cellline.processedcopynumber_array AS
WITH cncellline AS (SELECT DISTINCT celllinename FROM cellline.processedcopynumber)
SELECT celllinename,
  array(SELECT log2relativecopynumber FROM cellline.processedcopynumber p WHERE p.celllinename = cnc.celllinename AND ensg IN (SELECT ensg FROM cellline.cnaltered_ensg) ORDER BY ensg) AS log2relativecopynumber
  FROM cncellline cnc;

---

DROP MATERIALIZED VIEW IF EXISTS cellline.hallmarkscore;

CREATE MATERIALIZED VIEW cellline.hallmarkscore AS
WITH hallmark AS (SELECT gene_set, species, unnest(ensg_array) AS ensg FROM msigdb WHERE gene_set LIKE 'HALLMARK%'),
     expr AS (SELECT celllinename, ensg, log2tpm FROM cellline.processedrnaseqview WHERE ensg IN (SELECT distinct ensg FROM hallmark)),
     stats AS (SELECT ensg, avg(log2tpm) AS log2tpm_mean, stddev(log2tpm) AS log2tpm_stddev FROM expr GROUP BY ensg HAVING stddev(log2tpm) > 0)
SELECT gene_set, celllinename, sum(log2tpm) AS log2tpm_sum, sum((log2tpm - log2tpm_mean)/log2tpm_stddev) AS z_score_sum
  FROM expr e INNER JOIN hallmark h ON e.ensg = h.ensg INNER JOIN stats s ON e.ensg = s.ensg GROUP BY gene_set, celllinename;

---

DROP MATERIALIZED VIEW IF EXISTS cellline.mostvaryinggeneexpr;

CREATE MATERIALIZED VIEW cellline.mostvaryinggeneexpr AS
WITH rsspecies AS (SELECT DISTINCT species FROM cellline.rnaseqrun rsr JOIN cellline.cellline cl ON rsr.celllinename = cl.celllinename WHERE publish),
     varying_ensg AS (SELECT ensg, species, variance, rank_number FROM rsspecies rss 
                        JOIN LATERAL (SELECT ensg, variance(log2tpm) AS variance, rank() over(ORDER BY variance(log2tpm) DESC) rank_number FROM cellline.processedrnaseq prs JOIN cellline.rnaseqrun rsr ON prs.rnaseqrunid = rsr.rnaseqrunid 
                                      JOIN cellline.cellline cl ON cl.celllinename = rsr.celllinename 
                                      WHERE cl.species = rss.species AND publish GROUP BY ensg ORDER BY variance(log2tpm) DESC LIMIT 1000) AS t ON TRUE)
SELECT pr.rnaseqrunid, pr.ensg, log2tpm, species, variance, rank_number FROM cellline.processedrnaseq pr JOIN cellline.rnaseqrun rr ON rr.rnaseqrunid = pr.rnaseqrunid JOIN varying_ensg ve ON (pr.ensg = ve.ensg) WHERE rr.publish;

-------------------------------------------------
---- Views for sequenceDB -----------------------
-------------------------------------------------

DROP VIEW IF EXISTS cellline.microsatelliteinstabilityview;
CREATE VIEW cellline.microsatelliteinstabilityview AS
SELECT dnaseqrunid, microsatellite_stability_score, microsatellite_stability_class, celllinename FROM 
(
  SELECT ms.dnaseqrunid, microsatellite_stability_score, microsatellite_stability_class, celllinename, ROW_NUMBER() OVER (PARTITION BY celllinename ORDER BY total_number_of_sites DESC) AS row_id 
  FROM cellline.microsatelliteinstability ms JOIN cellline.dnaseqrun r ON r.dnaseqrunid = ms.dnaseqrunid WHERE publish
) AS a WHERE Row_ID = 1;

-------------------------------------------------

DROP VIEW IF EXISTS cellline.sequencingResults ;
DROP VIEW IF EXISTS cellline.sequencingResultsSNP ;
DROP VIEW IF EXISTS cellline.canonicalMutation;
DROP VIEW IF EXISTS cellline.analysis;

-------------------------------------------------

CREATE VIEW cellline.analysis AS
SELECT DISTINCT ensg, dnaseqrunid FROM cellline.analyzedexon ae INNER JOIN gene2transcript2exon g2t2e ON g2t2e.ense = ae.ense;

-------------------------------------------------

CREATE VIEW cellline.canonicalMutation AS
SELECT m.*, t.ENSG, t.transcriptname FROM cellline.mutation m, transcript t WHERE t.enst = m.enst AND t.iscanonical;

-------------------------------------------------
CREATE VIEW cellline.sequencingResults AS
SELECT ar.celllinename, ar.cellbatchid, c.cosmicid, ar.analysissource, g.symbol, g.name, ar.dnaseqrunid, 
cm.chromosome, cm.startpos, cm.enst,
cm.mutationeffect, cm.assembly, cm.genomicregion, cm.exon,
cm.dnacoverage, rnacoverage, gnomAD_allelicFreq, oneKG_allelicFreq, 
cm.cdnamutation, cm.proteinmutation, cm.snp, cm.snpsource, cm.dbsnpid,
cm.dnazygosity, cm.qualityscore,
cm.siftscore, g.ensg, g.biotype
FROM cellline.dnaseqrun ar
JOIN cellline.analysis a ON ar.dnaseqrunid = a.dnaseqrunid
JOIN gene g ON (a.ENSG = g.ENSG)
JOIN cellline.cellline c ON (c.celllinename = ar.celllinename)
LEFT OUTER JOIN cellline.canonicalMutation cm ON (cm.dnaseqrunid = a.dnaseqrunid AND cm.ensg = a.ensg AND NOT snp)
WHERE publish;

---------------------------------------------------

CREATE VIEW cellline.sequencingResultsSNP AS
SELECT ar.celllinename, ar.cellbatchid, c.cosmicid, ar.analysissource, g.symbol, g.name, ar.dnaseqrunid,
cm.chromosome, cm.startpos, cm.enst,
cm.mutationeffect, cm.assembly, cm.genomicregion, cm.exon,
cm.dnacoverage, rnacoverage, gnomAD_allelicFreq, oneKG_allelicFreq,
cm.cdnamutation, cm.proteinmutation, cm.snp, cm.snpsource, cm.dbsnpid,
cm.dnazygosity, cm.qualityscore,
cm.siftscore, g.ensg, g.biotype
FROM cellline.dnaseqrun ar
JOIN cellline.analysis a ON ar.dnaseqrunid = a.dnaseqrunid
JOIN gene g ON (a.ENSG = g.ENSG)
JOIN cellline.cellline c ON (c.celllinename = ar.celllinename)
LEFT OUTER JOIN cellline.canonicalMutation cm ON (cm.dnaseqrunid = a.dnaseqrunid AND cm.ensg = a.ensg)
WHERE publish;

---------------------------------------------------

DROP VIEW IF EXISTS cellline.sequencingResultsAllTranscripts;
DROP VIEW IF EXISTS cellline.allTranscriptMutation;

---------------------------------------------------

CREATE VIEW cellline.allTranscriptMutation AS
SELECT m.*, t.ENSG, t.transcriptname FROM cellline.mutation m, transcript t WHERE t.enst = m.enst;

---------------------------------------------------

--CREATE VIEW cellline.sequencingResultsAllTranscripts AS
--SELECT ar.celllinename, ar.cellbatchid, c.cosmicid, ar.analysissource, g.symbol, g.name, a.analysisid, a.dnaseqrunid,
--atm.chromosome, atm.startpos, atm.enst,
--atm.mutationtype, atm.mutationeffect, atm.assembly, atm.genomicregion, atm.exon,
--atm.cdnamutation, atm.proteinmutation, atm.snp, atm.snpsource, atm.dbsnpid,
--atm.numreads, atm.nummutantreads, atm.numreferencereads, atm.dnazygosity, atm.qualityscore,
--atm.siftscore, g.ensg, g.biotype
--FROM cellline.dnaseqrun ar
--JOIN transcript t on (t.enst = ar.enst)
--JOIN gene g ON (a.ENSG = g.ENSG)
--JOIN cellline.cellline c ON (c.celllinename = ar.celllinename)
--LEFT OUTER JOIN cellline.allTranscriptMutation atm ON (atm.dnaseqrunid = a.dnaseqrunid)
--WHERE publish;

----------------------------------------------------
DROP VIEW IF EXISTS cellline.celllineMutCN;
DROP VIEW IF EXISTS cellline.processedsequenceview;

CREATE VIEW cellline.processedsequenceview AS 
SELECT symbol, t.ensg, ps.* from cellline.processedsequence ps JOIN transcript t on (t.enst = ps.enst AND iscanonical) join gene g on (g.ensg = t.ensg);

DROP VIEW IF EXISTS cellline.processedcopynumberview;
CREATE VIEW cellline.processedcopynumberview AS
SELECT symbol, pcn.* FROM cellline.processedcopynumber pcn JOIN gene g ON (g.ensg = pcn.ensg);

----------------------------------------------------
CREATE VIEW cellline.celllineMutCN AS
SELECT gcl.ensg, gcl.symbol, gcl.celllinename, psv.enst, psv.dnamutation, psv.aamutation, psv.dnazygosity, psv.exonscomplete, psv.confirmeddetail, psv.numsources as processedsequencenumsources,
       pcn.log2relativecopynumber, pcn.log2relativeCopyNumberDev, pcn.copynumbergainintron, pcn.copynumberlossintron, pcn.copynumbergainexon, pcn.copynumberlossexon,
       pcn.gap, pcn.jump, pcn.exonicchange, pcn.intronicchange, pcn.numsources as processedcopynumbernumsources,
       pcn.totalAbsCopyNumber, pcn.totalAbsCopyNumberDev, pcn.minorAbsCopyNumber, pcn.minorAbsCopyNumberDev, pcn.lossofheterozygosity 
       FROM (SELECT ensg, symbol, celllinename FROM gene g, cellline.cellline cl) gcl 
       LEFT JOIN cellline.processedsequenceview psv on (gcl.ensg = psv.ensg AND gcl.celllinename = psv.celllinename) 
       LEFT JOIN cellline.processedcopynumber pcn on (gcl.ensg = pcn.ensg AND gcl.celllinename = pcn.celllinename);

DROP VIEW IF EXISTS cellline.processedfusiongeneview;
CREATE VIEW cellline.processedfusiongeneview AS
SELECT pfg.processedfusion, pfg.celllinename, pfg.ensg1, pfg.ensg2, g1.symbol as symbol1, g2.symbol as symbol2, pfg.countsofcommonmappingreads, 
       pfg.spanningpairs, pfg.spanninguniquereads, pfg.longestanchorfound, pfg.fusionfindingmethod, pfg.chrgene1, pfg.chrgene2, 
       pfg.nuclgene1, pfg.nuclgene2, pfg.strandgene1, pfg.strandgene2, pfg.rnaseqrunid, pfg.predictedeffect FROM cellline.processedfusiongene pfg
       JOIN gene g1 on (pfg.ensg1 = g1.ensg)
       JOIN gene g2 on (pfg.ensg2 = g2.ensg);

DROP VIEW IF EXISTS cellline.processedrnaseqview CASCADE;
CREATE VIEW cellline.processedrnaseqview AS
SELECT prs.rnaseqrunid, celllinename, prs.ensg, prs.log2fpkm, prs.log2tpm, prs.log2cpm, prs.counts FROM cellline.processedrnaseq prs 
  JOIN cellline.rnaseqrun nr ON nr.rnaseqrunid = prs.rnaseqrunid 
  JOIN cellline.rnaseqgroup ng ON nr.rnaseqgroupid = ng.rnaseqgroupid 
  WHERE nr.canonical AND (rnaseqname like 'untreated %cellline reference set%' AND processingpipeline LIKE 'RNA-seq%');

--DROP VIEW IF EXISTS cellline.processedrnaseqview2 CASCADE;
--CREATE VIEW cellline.processedrnaseqview2 AS
--WITH rnaseqrun2 AS (
--  SELECT  nr.rnaseqrunid, nr.celllinename 
--  FROM cellline.rnaseqrun nr
--  JOIN cellline.rnaseqgroup ng ON nr.rnaseqgroupid = ng.rnaseqgroupid
--  WHERE nr.canonical AND (rnaseqname like 'untreated %cellline reference set%' AND processingpipeline LIKE 'RNA-seq%')
--)
--SELECT prs.rnaseqrunid, celllinename, prs.ensg, prs.log2fpkm, prs.log2tpm, prs.log2cpm, prs.counts FROM cellline.processedrnaseq prs
--  INNER JOIN rnaseqrun2 nr ON prs.rnaseqrunid = nr.rnaseqrunid;

DROP VIEW IF EXISTS cellline.processedrnaseqtranscriptview CASCADE;
CREATE VIEW cellline.processedrnaseqtranscriptview AS
SELECT prs.rnaseqrunid, celllinename, prs.enst, prs.log2fpkm, prs.log2tpm, prs.counts FROM cellline.processedrnaseqtranscript prs 
  JOIN cellline.rnaseqrun nr ON nr.rnaseqrunid = prs.rnaseqrunid    
  JOIN cellline.rnaseqgroup ng ON nr.rnaseqgroupid = ng.rnaseqgroupid 
  WHERE nr.canonical AND (rnaseqname like 'untreated %cellline reference set%' AND processingpipeline LIKE 'RNA-seq%');

--CREATE VIEW cellline.processedrnaseqview AS
--SELECT prs.rnaseqrunid, celllinename, prs.ensg, prs.log2fpkm, prs.log2tpm, prs.counts FROM cellline.rnaseqrun nr JOIN cellline.processedrnaseq prs ON (nr.rnaseqrunid = prs.rnaseqrunid) WHERE nr.canonical;

DROP VIEW IF EXISTS cellline.processeddepletionscoreview CASCADE;
CREATE VIEW cellline.processeddepletionscoreview AS
SELECT d.ensg, symbol, celllinename, depletionscreen, rsa, ataris, ceres, escore FROM cellline.processeddepletionscore d
JOIN gene g ON (d.ENSG = g.ENSG);

DROP MATERIALIZED VIEW IF EXISTS cellline.mutationalburden CASCADE;
CREATE MATERIALIZED VIEW cellline.mutationalburden AS
SELECT psv.celllinename, species, tumortype, sum((aamutation <> 'wt')::INT4)/count(*)::REAL AS mutational_fraction 
  FROM cellline.processedsequenceview psv JOIN cellline.cellline cl ON cl.celllinename = psv.celllinename 
  GROUP BY psv.celllinename, species, tumortype having count(*) > 10000;

-------------------------------------------------
---- Views for prolifDB -----------------------
-------------------------------------------------

DROP VIEW IF EXISTS cellline.results;

CREATE VIEW cellline.results AS 
SELECT doseresponsecurve, ec50, ec50calc, ec50operator, top, bottom, slope,
gi50, gi50calc, gi50operator, ic50, ic50calc, ic50operator, tgi, tgicalc, tgioperator, 
tzero, tzerosd, negControlSD, amax, actarea, drc.classification, round, deviation, 
drc.celllinename, cl.organ, cl.tissue_subtype, cl.tumortype, cl.metastatic_site, cl.histology_type, 
cl.histology_subtype, cl.morphology, cl.growth_type, cl.gender, drc.cellsperwell, timepoint, drc.drugid, d.target, sampleid, 
pretreatment, laboratory, proliferationtest, campaign, imagepath,
calcimpossible, biphasiccurve, flatcurve, wrongconcrange, inactive, drc.valid, recalculate, locked, fixedtop, fixedbottom, fixedslope, fixedec50
FROM cellline.doseresponsecurve drc
JOIN cellline.cellline cl ON cl.celllinename = drc.celllinename
JOIN drug d ON d.drugid = drc.drugid;

-------------------------------------------------------
--DROP VIEW IF EXISTS cellline.results2;

--CREATE VIEW cellline.results2 AS
--SELECT distinct drc.doseresponsecurve, ec50, ec50calc, ec50operator, top, bottom, slope,
--gi50, ic50, tgi, tzero, tzerosd, negControlSD, drc.classification, p.round, deviation, datafile,
--m.celllinename, organ, drc.cellsperwell, p.timepoint, m.drugid, d.target, m.sampleid, m.pretreatment, p.laboratory, p.proliferationtest, p.campaign, imagepath,
--calcimpossible, drc.valid, recalculate, locked, fixedtop, fixedbottom, fixedslope, fixedec50
--FROM cellline.doseresponsecurve drc
--JOIN cellline.curveanalysis c ON c.doseresponsecurve = drc.doseresponsecurve
--JOIN cellline.measuredvalue m ON (m.plateid = c.plateid AND m.well = c.well)
--JOIN cellline.plate p ON p.plateid = m.plateid
--JOIN cellline.cellline cl ON cl.celllinename = m.celllinename
--JOIN drug d ON d.drugid = m.drugid
--WHERE category = 'test';

-------------------------------------------------------

--DROP VIEW IF EXISTS cellline.resultsCombi;

--CREATE VIEW cellline.resultsCombi AS
--SELECT distinct drm.doseresponsematrix, maxcgiblissexcess, mincgiblissexcess, maxpocblissexcess, minpocblissexcess, 
--mincgihsaexcess, maxcgihsaexcess, minpochsaexcess, maxpochsaexcess, tzero, tzerosd, negControlSD, p.round, 
--m.celllinename, organ, cl.tissue_subtype, cl.tumortype, cl.metastatic_site, cl.histology_type, 
--cl.histology_subtype, cl.morphology, cl.growth_type, cl.gender, m.cellsperwell, p.timepoint, 
--m.drugid, d1.target, m.sampleid, drm.treatmenttime, 
--m.drugid2, d2.target as target2, m.sampleid2, drm.treatmenttime2, 
--drm.pretreatment, p.laboratory, p.proliferationtest, p.campaign, imagepath,
--drm.valid, recalculate, locked
--FROM cellline.doseresponsematrix drm
--JOIN cellline.matrixanalysis ma ON ma.doseresponsematrix = drm.doseresponsematrix
--JOIN cellline.measuredvalue m ON (m.plateid = ma.plateid AND m.well = ma.well AND (m.drugid <> 'DMSO' AND m.drugid2 <> 'DMSO'))
--JOIN cellline.plate p ON p.plateid = m.plateid
--JOIN cellline.cellline cl ON cl.celllinename = m.celllinename
--JOIN drug d1 ON d1.drugid = m.drugid
--JOIN drug d2 ON d2.drugid = m.drugid2
--WHERE category = 'test';

DROP VIEW IF EXISTS cellline.resultsCombi;

CREATE VIEW cellline.resultsCombi AS
SELECT distinct drm.doseresponsematrix, maxcgiblissexcess, mincgiblissexcess, maxpocblissexcess, minpocblissexcess,
mincgihsaexcess, maxcgihsaexcess, minpochsaexcess, maxpochsaexcess, min3cgiblissexcess + max3cgiblissexcess as combo6, tzero, tzerosd, negControlSD, round,
cl.celllinename, organ, cl.tissue_subtype, cl.tumortype, cl.metastatic_site, cl.histology_type,
cl.histology_subtype, cl.morphology, cl.growth_type, cl.gender, cellsperwell, timepoint,
drm.drugid, d1.target, sampleid, drm.treatmenttime,
drm.drugid2, d2.target as target2, sampleid2, drm.treatmenttime2,
drm.pretreatment, laboratory, proliferationtest, campaign, imagepath,
drm.valid, recalculate, locked
FROM cellline.doseresponsematrix drm
JOIN cellline.cellline cl ON cl.celllinename = drm.celllinename
JOIN drug d1 ON d1.drugid = drm.drugid
JOIN drug d2 ON d2.drugid = drm.drugid2;