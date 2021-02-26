CREATE INDEX idx_altentrezgenesymbol ON altentrezgenesymbol (symbol);
CREATE INDEX idx_entrezgenesymbol ON entrezgene (symbol);
CREATE INDEX idx_genesymbol ON gene (symbol);
CREATE INDEX idx_cosmicGene on gene(cosmic_id_gene);

CREATE INDEX idx_genetdpid ON gene(tdpid);

CREATE INDEX idx_transcript_location on transcript(chromosome, seqstart, seqend);
CREATE INDEX idx_transcript_ensg on transcript(ensg);
CREATE INDEX idx_transcript_canon on transcript(iscanonical);

CREATE INDEX idx_exon on exon(chromosome, seqstart, seqend);
