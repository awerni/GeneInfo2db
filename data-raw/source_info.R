# ---  Ensembl Gene File ---
# db_info <- tibble::tribble(
#   ~species, ~database, ~symbol_source, ~transcriptname_source,
#   "human", "homo_sapiens_core_86_38", c("HGNC"), "HGNC_trans_name",
#   "mouse", "mus_musculus_core_86_38", c("MGI", "EntrezGene"), "MGI_trans_name",
#   "rat",   "rattus_norvegicus_core_86_6", c("RGD", "MGI", "EntrezGene"), "RFAM_trans_name",
# )

db_info <- tibble::tribble(
  ~species, ~database, ~symbol_source, ~transcriptname_source,
  "human", "homo_sapiens_core_95_38", c("HGNC"), "HGNC_trans_name",
  "mouse", "mus_musculus_core_95_38", c("MGI", "EntrezGene"), "MGI_trans_name",
  "rat",   "rattus_norvegicus_core_95_6", c("RGD", "MGI", "EntrezGene"), "RFAM_trans_name",
)

db_compara <- "ensembl_compara_101"

# --- Entrez Gene File
# complete file ftp://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz
gene_info <- tibble::tribble(
  ~species, ~taxid, ~file,
  "human",  9606, "ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/Homo_sapiens.gene_info.gz",
  "mouse", 10090, "ftp://ftp.ncbi.nlm.nih.gov/refseq/M_musculus/Mus_musculus.gene_info.gz",
  "rat",   10116, "ftp://ftp.ncbi.nlm.nih.gov/refseq/R_norvegicus/Rattus_norvegicus.gene_info.gz",
)

# --- Refseq File ---
refseq_info <- tibble::tribble(
  ~species, ~taxid, ~file,
  "human",  9606, "ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/mRNA_Prot/human.files.installed",
  "mouse", 10090, "ftp://ftp.ncbi.nlm.nih.gov/refseq/M_musculus/mRNA_Prot/mouse.files.installed",
  "rat",   10116, "ftp://ftp.ncbi.nlm.nih.gov/refseq/R_norvegicus/mRNA_Prot/rat.files.installed",
)

# ---- taiga links ----
taiga_info <- tibble::tribble(
  ~data_name, ~data_version, ~data_file,

  'internal-21q2-9d16', 17, 'sample_info', # ok
  'other-ccle2-c93e', 2, 'Cell_lines_annotations_20181226',

  'internal-21q2-9d16', 17, 'CCLE_expression_full',
  'internal-21q2-9d16', 17, 'CCLE_RNAseq_reads',
  'internal-21q2-9d16', 17, 'CCLE_RNAseq_transcripts',
  'internal-21q2-9d16', 17, 'CCLE_expression_transcripts_expected_count',

  # --------- this is an exact duplication of the expression data above -----------
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_genes_expected_count',
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_genes_tpm',
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_transcripts_expected_count',
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_transcripts_tpm',

  'internal-21q2-9d16', 17, 'CCLE_gene_cn',
  'internal-21q2-9d16', 17, 'CCLE_mutations',

  'internal-21q2-9d16', 17, 'Achilles_gene_dependency',
  'internal-21q2-9d16', 17, 'Achilles_gene_effect',
  'internal-21q2-9d16', 17, 'Achilles_gene_effect_unscaled',
  'internal-21q2-9d16', 17, 'nonessentials',
  'internal-21q2-9d16', 17, 'common_essentials',

  'internal-21q2-9d16', 17, 'Achilles_cell_line_efficacy',
  'internal-21q2-9d16', 17, 'Achilles_cell_line_growth_rate',
  'internal-21q2-9d16', 17, 'Achilles_common_essentials',
  'internal-21q2-9d16', 17, 'Achilles_common_essentials_Chronos',
  'internal-21q2-9d16', 17, 'Achilles_dropped_guides',

  'internal-21q2-9d16', 17, 'Achilles_gene_dependency_Chronos',
  'internal-21q2-9d16', 17, 'Achilles_gene_effect_Chronos',

  'internal-21q2-9d16', 17, 'CCLE_fusions',
  'internal-21q2-9d16', 17, 'CCLE_fusions_unfiltered',

  'internal-21q2-9d16', 17, 'CRISPR_common_essentials',
  'internal-21q2-9d16', 17, 'CRISPR_common_essentials_Chronos',
  'internal-21q2-9d16', 17, 'CRISPR_gene_dependency',
  'internal-21q2-9d16', 17, 'CRISPR_gene_dependency_Chronos',
  'internal-21q2-9d16', 17, 'CRISPR_gene_effect',
  'internal-21q2-9d16', 17, 'CRISPR_gene_effect_Chronos',

  'sanger-crispr-project-score--e20b', 4, 'essential_genes',
  'sanger-crispr-project-score--e20b', 4, 'nonessential_genes',
  'sanger-crispr-project-score--e20b', 4, 'gene_dependency',
  'sanger-crispr-project-score--e20b', 4, 'gene_effect',
  'sanger-crispr-project-score--e20b', 4, 'gene_effect_unscaled',

  'demeter2-drive-0591', 12, 'gene_effect',
  'demeter2-drive-0591', 12, 'gene_dependency',

  'metabolomics-cd0c', 4, 'CCLE_metabolomics_20190502',
  'secondary-screen-0854', 18, 'secondary-dose-response-curve-parameters',
  'msi-0584', 6, 'msi',
  'total-proteome--5c50', 2, 'normalized_protein_abundance',
  'total-proteome--5c50', 1, 'protein_quant_current_normalized',
  'depmap-rppa-1b43', 3, 'CCLE_RPPA_20181003',
  'depmap-rppa-1b43', 3, 'CCLE_RPPA_Ab_info_20181226',

  'metmap-data-f459', 3, 'metmap500_metastatic_potential',
  'metmap-data-f459', 3, 'metmap500_penetrance'
)

taiga_version <- tibble::tribble(
  ~description, ~information,
  "Depmap Version", "internal 21q2",
  "metabolomics", "CCLE_metabolomics_20190502",
  "Proteomics", "CCLE_RPPA_20181003"
)

# ------figshare (depmap) and direct links -----------
depmap_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/14541774/files") %>%
  mutate(data_name = "depmap", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(data_file %in% c("sample_info", "CCLE_expression_full", "CCLE_RNAseq_reads", "CCLE_RNAseq_transcripts", "CCLE_gene_cn", "CCLE_mutations",
           "Achilles_gene_dependency", "Achilles_gene_effect", "Achilles_gene_effect_unscaled", "nonessentials", "common_essentials"))

drive_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/6025238/files") %>%
  mutate(data_name = "demeter2-drive", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(grepl("(D2_DRIVE_gene_dep_scores|D2_DRIVE_seed_dep_scores)", data_file)) %>%
  mutate(data_file = gsub("^D2_DRIVE_", "", data_file))

prism_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/9393293/files") %>%
  mutate(data_name = "prism", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(data_file %in% c("secondary-screen-dose-response-curve-parameters"))

sanger_info <-  jsonlite::fromJSON("https://api.figshare.com/v2/articles/9116732/files") %>%
  mutate(data_name = "sanger", data_file = gsub("(\\.csv$|\\.tsv$|\\.txt$)", "", name)) %>%
  select(data_name,  url = download_url, data_file)

other_info <- tibble::tribble(
  ~data_name, ~url, ~data_file,
  "ccle", "https://data.broadinstitute.org/ccle/Cell_lines_annotations_20181226.txt", "Cell_lines_annotations_20181226",
  "ccle", "https://data.broadinstitute.org/ccle/CCLE_metabolomics_20190502.csv", "CCLE_metabolomics_20190502",
  #"ccle", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", 'msi',
  "ccle", "https://data.broadinstitute.org/ccle/CCLE_RPPA_20181003.csv", "CCLE_RPPA_20181003",
  "ccle", "https://data.broadinstitute.org/ccle/CCLE_RPPA_Ab_info_20181226.csv", "CCLE_RPPA_Ab_info_20181226",
  "total-proteome", "https://gygi.hms.harvard.edu/data/ccle/protein_quant_current_normalized.csv.gz", "protein_quant_current_normalized.csv.gz",
  "uniprot", "ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping_selected.tab.gz", "HUMAN_9606_idmapping_selected.tab.gz",
  "metmap", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-020-2969-2/MediaObjects/41586_2020_2969_MOESM7_ESM.xlsx", 'metmap.xlsx',
  "msi", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", "msi"
)

download_file_info <- depmap_info %>%
  bind_rows(drive_info) %>%
  bind_rows(sanger_info) %>%
  bind_rows(prism_info) %>%
  bind_rows(other_info)

file_version <- tibble::tribble(
  ~description, ~information,
  "Depmap Version", "public 21q1",
  "metabolomics", "CCLE_metabolomics_20190502",
  "Proteomics", "CCLE_RPPA_20181003"
)

# -------------MSigDB --------------------

gmt.files <- tibble::tribble(
  ~file, ~collection, ~collection_name, ~gene_set_group,
  "c1.all.v7.4.entrez.gmt", "c1", "positional", "positional",
  "c2.cgp.v7.4.entrez.gmt", "c2", "curated", "chemical and genetic perturbations",
  "c2.cp.biocarta.v7.4.entrez.gmt", "c2", "curated", "biocarta",
  "c2.cp.kegg.v7.4.entrez.gmt", "c2", "curated", "KEGG",
  "c2.cp.pid.v7.4.entrez.gmt", "c2", "curated", "PID",
  "c2.cp.reactome.v7.4.entrez.gmt", "c2", "curated", "Reactome",
  "c2.cp.wikipathways.v7.4.entrez.gmt", "c2", "curated", "wiki pathways",
  "c2.cp.v7.4.entrez.gmt", "c2", "curated", "canonical pathways",
  "c3.mir.mirdb.v7.4.entrez.gmt", "c3", "regulatory target", "MIRDB targets",
  "c3.mir.mir_legacy.v7.4.entrez.gmt", "c3", "regulatory target", "Legacy microRNA targets",
  #"c3.mir.v7.4.entrez.gmt", "c3", "regulatory target", "all microRNA targets",
  "c3.tft.gtrd.v7.4.entrez.gmt", "c3", "regulatory target", "GTRD targets",
  "c3.tft.tft_legacy.v7.4.entrez.gmt", "c3", "regulatory target", "Legacy transcription factor targets",
  #"c3.tft.v7.4.entrez.gmt", "c3", "regulatory target", "all transcription factor targets",
  "c4.cgn.v7.4.entrez.gmt", "c4", "computational", "cancer gene neighborhoods",
  "c4.cm.v7.4.entrez.gmt", "c4", "computational", "cancer modules",
  "c5.go.bp.v7.4.entrez.gmt", "c5", "gene ontology", "biological processes",
  "c5.go.cc.v7.4.entrez.gmt", "c5", "gene ontology", "cellular components",
  "c5.go.mf.v7.4.entrez.gmt", "c5", "gene ontology", "molecular functions",
  "c6.all.v7.4.entrez.gmt", "c6", "oncogenic signatures", "all oncogenic signatures",
  "c7.all.v7.4.entrez.gmt", "c7", "immunologic signatures", "all immunologic signatures ",
  "c8.all.v7.4.entrez.gmt", "c8", "cell type signatures", "all cell type signatures",
  "h.all.v7.4.entrez.gmt", "h", "hallmark", "hallmark"
)

# -----------------
save(db_info, gene_info, refseq_info, db_compara, taiga_info, download_file_info,
     gmt.files, taiga_version, file_version, file = "data/source_info.rdata")
