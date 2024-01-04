-- originally from base celllineDB

--CREATE INDEX snpannotation_id on cellline.snpannotation(dbsnpid);
--CREATE INDEX idx_copynumberregion ON cellline.copynumberregion(start, stop, chromosome, algorithm);
--CREATE INDEX idx_processedcopynumber ON cellline.processedcopynumber(log2copynumber);
CREATE INDEX idx_processedcopynumberensg ON cellline.processedcopynumber(ensg);
--CREATE INDEX idx_processedcopynumbercell ON cellline.processedcopynumber(celllinename);

CREATE INDEX idx_processedsequenceenst ON cellline.processedsequence(enst);
CREATE INDEX idx_processedrnaseq ON cellline.processedrnaseq using hash (ensg);
CREATE INDEX idx_processedrnaseqtrans ON cellline.processedrnaseqtranscript(enst, rnaseqrunid);
CREATE INDEX idx_processedfusiongene1 ON cellline.processedfusiongene(ensg1, celllinename);  
CREATE INDEX idx_processedfusiongene2 ON cellline.processedfusiongene(ensg2, celllinename);  
CREATE INDEX idx_processedfusioncl ON cellline.processedfusiongene(celllinename);
CREATE INDEX idx_processeddepletionscore ON cellline.processeddepletionscore(ensg, depletionscreen);
CREATE INDEX idx_processeddepletionscore2 ON cellline.processeddepletionscore(depletionscreen, celllinename);
CREATE INDEX idx_rnaseqruncelllinename ON cellline.rnaseqrun(celllinename, canonical);

CREATE INDEX idx_log2relativecopynumber on cellline.processedcopynumber (log2relativecopynumber);
CREATE INDEX idx_cellline_tdpid on cellline.cellline(tdpid, species, tumortype);

-- originally from sequenceDB

--CREATE INDEX idx_analysis on cellline.analysis(ensg);
--CREATE INDEX idx_analysisrun on cellline.analysisrun(analysissource);
--CREATE INDEX idx_analysisruncl on cellline.analysisrun(celllinename);

-- originally from prolifDB

--CREATE INDEX campaign_plate_index on cellline.plate (campaign);
--CREATE INDEX conc_measuredvalue_index on cellline.measuredvalue(isPositive(concentration));
--CREATE INDEX drugcat_measuredvalue_index on cellline.measuredvalue(drugid, category);
--CREATE INDEX plateid_plate_index on cellline.plate(plateid);
