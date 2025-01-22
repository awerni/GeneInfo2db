ALTER TABLE tissue.processedrnaseq ADD CONSTRAINT PK_PROCESSEDRNASEQ PRIMARY KEY (ENSG, RNASEQRUNID);
--CREATE INDEX idx_processedrnaseq ON tissue.processedrnaseq USING HASH (rnaseqrunid);
CREATE INDEX idx_processedrnaseq2 ON tissue.processedrnaseq USING HASH (ensg);
