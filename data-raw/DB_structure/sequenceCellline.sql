-- from sequenceDB
--CREATE SEQUENCE cellline.dnaseqRunSequence;
CREATE SEQUENCE cellline.processedFusionSequence;

-- from prolifDB 
--CREATE SEQUENCE cellline.plateIDSequence;
CREATE SEQUENCE cellline.processedproliftestSequence;
CREATE SEQUENCE cellline.processedcombiproliftestSequence;

ALTER TABLE cellline.processedproliftest
ALTER COLUMN proliftestid  SET DEFAULT nextval('cellline.processedproliftestSequence');

ALTER TABLE cellline.processedcombiproliftest
ALTER COLUMN combiproliftestid SET DEFAULT nextval('cellline.processedcombiproliftestSequence');
