insert into tissue.vendor VALUES ('TCGA', 'https://www.cancer.gov/about-nci/organization/ccg/research/structural-genomics/tcga');
insert into tissue.vendor VALUES ('GTEX', 'https://www.genome.gov/Funded-Programs-Projects/Genotype-Tissue-Expression-Project');

insert into laboratory values ('recount3');
insert into laboratory values ('Broad Institute');

insert into tissue.rnaseqgroup (rnaseqgroupid, rnaseqname, processingpipeline) VALUES (1, 'TCGA', 'recount3');
insert into tissue.rnaseqgroup (rnaseqgroupid, rnaseqname, processingpipeline) VALUES (2, 'GTEX', 'recount3');