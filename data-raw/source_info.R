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
  
  'internal-21q1-4fc4', 30, 'sample_info',
  'other-ccle2-c93e', 1, 'Cell_lines_annotations_20181226',
  
  'internal-21q1-4fc4', 30,'CCLE_expression_full',
  'internal-21q1-4fc4', 30,'CCLE_RNAseq_reads',
  'internal-21q1-4fc4', 30,'CCLE_RNAseq_transcripts',
  'internal-21q1-4fc4', 30,'CCLE_expression_transcripts_expected_count',
  
  # --------- this is an exact duplication of the expression data above -----------
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_genes_expected_count',
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_genes_tpm',
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_transcripts_expected_count',
  #'depmap-rnaseq-expression-data-363a', 36, 'expression_transcripts_tpm',
  
  'internal-21q1-4fc4', 30,'CCLE_gene_cn',
  'internal-21q1-4fc4', 30,'CCLE_mutations',
  
  'internal-21q1-4fc4', 30,'Achilles_gene_dependency',
  'internal-21q1-4fc4', 30,'Achilles_gene_effect',
  'internal-21q1-4fc4', 30,'Achilles_gene_effect_unscaled',
  'internal-21q1-4fc4', 30,'nonessentials',
  'internal-21q1-4fc4', 30,'common_essentials',
  
  'internal-21q1-4fc4', 30,'Achilles_cell_line_efficacy',
  'internal-21q1-4fc4', 30,'Achilles_cell_line_growth_rate',
  'internal-21q1-4fc4', 30,'Achilles_common_essentials',
  'internal-21q1-4fc4', 30,'Achilles_common_essentials_Chronos',
  'internal-21q1-4fc4', 30,'Achilles_dropped_guides',
  
  'internal-21q1-4fc4', 30,'Achilles_gene_dependency_Chronos',
  'internal-21q1-4fc4', 30,'Achilles_gene_effect_Chronos',
  
  'internal-21q1-4fc4', 30,'CCLE_fusions',
  'internal-21q1-4fc4', 30,'CCLE_fusions_unfiltered',
  
  'internal-21q1-4fc4', 30,'CRISPR_common_essentials',
  'internal-21q1-4fc4', 30,'CRISPR_common_essentials_Chronos',
  'internal-21q1-4fc4', 30,'CRISPR_gene_dependency',
  'internal-21q1-4fc4', 30,'CRISPR_gene_dependency_Chronos',
  'internal-21q1-4fc4', 30,'CRISPR_gene_effect',
  'internal-21q1-4fc4', 30,'CRISPR_gene_effect_Chronos',
  
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
  'depmap-rppa-1b43', 3, 'CCLE_RPPA_20181003',
  'depmap-rppa-1b43', 3, 'CCLE_RPPA_Ab_info_20181226',

  'metmap-data-f459', 3, 'metmap500_metastatic_potential',
  'metmap-data-f459', 3, 'metmap500_penetrance'
)

# ------figshare (depmap) links -----------
# download_file_info <- tibble::tribble(
#   ~data_name, ~url, ~data_file,
#   "depmap", "https://ndownloader.figshare.com/files/25494443", 'sample_info',
#   "depmap", "https://depmap.org/portal/download/api/download?file_name=ccle%2Fccle_2019%2FCell_lines_annotations_20181226.txt&bucket=depmap-external-downloads", 'Cell_lines_annotations_20181226',
#   "depmap", "https://ndownloader.figshare.com/files/25797014", 'CCLE_expression_full',
#   "depmap", "https://ndownloader.figshare.com/files/25797008", 'CCLE_RNAseq_reads',
#   "depmap", "https://ndownloader.figshare.com/files/25797206", 'CCLE_RNAseq_transcripts',
#   "depmap", "https://ndownloader.figshare.com/files/25770017", 'CCLE_gene_cn',
#   "depmap", "https://ndownloader.figshare.com/files/25494419", 'CCLE_mutations',
#   
#   # ----- Avana -----
#   "depmap", "https://ndownloader.figshare.com/files/25770032", 'Achilles_gene_dependency',
#   "depmap", "https://ndownloader.figshare.com/files/25770029", 'Achilles_gene_effect',
#   "depmap", "https://ndownloader.figshare.com/files/25770041", 'Achilles_gene_effect_unscaled',
#   "depmap", "https://ndownloader.figshare.com/files/25494437", 'nonessentials',
#   "depmap", "https://ndownloader.figshare.com/files/25494434", 'common_essentials',
#   
#   # --- sanger ---
#   "sanger", "https://ndownloader.figshare.com/files/16623887", 'essential_genes',
#   "sanger", "https://ndownloader.figshare.com/files/16623890", 'nonessential_genes',
#   "sanger", "https://ndownloader.figshare.com/files/16623884", 'gene_dependency',
#   "sanger", "https://ndownloader.figshare.com/files/16623881", 'gene_effect',
#   "sanger", "https://ndownloader.figshare.com/files/16623851", 'gene_effect_unscaled',
#   
#   # ---- drive ----
#   "demeter2-drive", "", 'gene_effect',
#   "demeter2-drive", "https://ndownloader.figshare.com/files/11489693", 'gene_dependency',
#   
#   "ccle", "", 'CCLE_metabolomics_20190502',
#   "prism", "", 'secondary-dose-response-curve-parameters',
#   "ccle", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", 'msi',
#   "total-proteome", "", 'normalized_protein_abundance',
#   "ccle", "", 'CCLE_RPPA_20181003',
#   "ccle", "", 'CCLE_RPPA_Ab_info_20181226',
#   "metmap", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-020-2969-2/MediaObjects/41586_2020_2969_MOESM7_ESM.xlsx", '41586_2020_2969_MOESM7_ESM.xlsx'
# )

depmap_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/13681534/files") %>%
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

other_info <- tibble::tribble(
  ~data_name, ~url, ~data_file,
  "ccle", "https://depmap.org/portal/download/api/download?file_name=ccle%2Fccle_2019%2FCCLE_metabolomics_20190502.csv&bucket=depmap-external-downloads", "CCLE_metabolomics_20190502",
  "ccle", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", 'msi',
  "ccle", "https://depmap.org/portal/download/api/download?file_name=ccle%2Fccle_2019%2FCCLE_RPPA_20181003.csv&bucket=depmap-external-downloads", "CCLE_RPPA_20181003",
  "ccle", "https://depmap.org/portal/download/api/download?file_name=ccle%2Fccle_2019%2FCCLE_RPPA_Ab_info_20181226.csv&bucket=depmap-external-downloads", "CCLE_RPPA_Ab_info_20181226"
)
  
download_file_info <- depmap_info %>%
  bind_rows(drive_info) %>%
  bind_rows(prism_info) %>%
  bind_rows(other_info)

# -------------MSigDB --------------------

gmt.files <- tibble::tribble(
  ~file, ~collection, ~collection_name, ~gene_set_group,
  "c1.all.v7.2.entrez.gmt", "c1", "positional", "positional",
  "c2.cgp.v7.2.entrez.gmt", "c2", "curated", "chemical and genetic perturbations",
  "c2.cp.biocarta.v7.2.entrez.gmt", "c2", "curated", "biocarta",
  "c2.cp.kegg.v7.2.entrez.gmt", "c2", "curated", "KEGG",
  "c2.cp.pid.v7.2.entrez.gmt", "c2", "curated", "PID",
  "c2.cp.reactome.v7.2.entrez.gmt", "c2", "curated", "Reactome",
  "c2.cp.wikipathways.v7.2.entrez.gmt", "c2", "curated", "wiki pathways",
  "c2.cp.v7.2.entrez.gmt", "c2", "curated", "canonical pathways",
  "c3.mir.mirdb.v7.2.entrez.gmt", "c3", "regulatory target", "MIRDB targets",
  "c3.mir.mir_legacy.v7.2.entrez.gmt", "c3", "regulatory target", "Legacy microRNA targets",
  #"c3.mir.v7.2.entrez.gmt", "c3", "regulatory target", "all microRNA targets",
  "c3.tft.gtrd.v7.2.entrez.gmt", "c3", "regulatory target", "GTRD targets",
  "c3.tft.tft_legacy.v7.2.entrez.gmt", "c3", "regulatory target", "Legacy transcription factor targets",
  #"c3.tft.v7.2.entrez.gmt", "c3", "regulatory target", "all transcription factor targets",
  "c4.cgn.v7.2.entrez.gmt", "c4", "computational", "cancer gene neighborhoods",
  "c4.cm.v7.2.entrez.gmt", "c4", "computational", "cancer modules",
  "c5.go.bp.v7.2.entrez.gmt", "c5", "gene ontology", "biological processes",
  "c5.go.cc.v7.2.entrez.gmt", "c5", "gene ontology", "cellular components",
  "c5.go.mf.v7.2.entrez.gmt", "c5", "gene ontology", "molecular functions",
  "c6.all.v7.2.entrez.gmt", "c6", "oncogenic signatures", "all oncogenic signatures",
  "c7.all.v7.2.entrez.gmt", "c7", "immunologic signatures", "all immunologic signatures ",
  "c8.all.v7.2.entrez.gmt", "c8", "cell type signatures", "all cell type signatures",
  "h.all.v7.2.entrez.gmt", "h", "hallmark", "hallmark"
)


# -----------------
save(db_info, gene_info, refseq_info, db_compara, taiga_info, download_file_info, gmt.files, file = "data/source_info.rdata")
