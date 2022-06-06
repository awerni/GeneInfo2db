--CREATE UNIQUE INDEX idx_processedrnaseq_ ON tissue.processedrnaseq(rnaseqrunid, ensg);
CREATE INDEX idx_processedrnaseq  ON tissue.processedrnaseq USING HASH (rnaseqrunid);
CREATE INDEX idx_processedrnaseq2  ON tissue.processedrnaseq USING HASH (ensg);

CREATE UNIQUE INDEX idx_processedcnensgtissue ON tissue.processedcopynumber(ensg, tissuename);
CREATE INDEX idx_processedsequence ON tissue.processedsequence(enst);

CREATE INDEX idx_tissue_tdpid ON tissue.tissue(tdpid, species, tumortype);

CREATE INDEX idx_tissue_tumortype ON tissue.tissue(tumortype);

CREATE INDEX idx_rnaseqrun_tissuename ON tissue.rnaseqrun(tissuename);
CREATE INDEX idx_rnaseqrun_canonical ON tissue.rnaseqrun(canonical);

CREATE INDEX idx_tissueassignment_tissuename ON  tissue.tissueassignment (tissuepanel);

CREATE INDEX idx_tissue_dnasequence ON tissue.tissue(dnasequenced);

--- indices on a materialized view tissue.processedsequenceExtended
--CREATE UNIQUE INDEX idx_processedsequenceEx1 ON tissue.processedsequenceExtended (tissuename, enst);
--CREATE INDEX idx_processedsequenceEx2 ON tissue.processedsequenceExtended (enst);
