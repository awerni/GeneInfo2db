### CAUTION !
### This scirpt is not run during the building process.
library(dplyr)

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
# complete file https://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz
gene_info <- tibble::tribble(
  ~species, ~taxid, ~file,
  "human",  9606, "https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/Homo_sapiens.gene_info.gz",
  "mouse", 10090, "https://ftp.ncbi.nlm.nih.gov/refseq/M_musculus/Mus_musculus.gene_info.gz",
  "rat",   10116, "https://ftp.ncbi.nlm.nih.gov/refseq/R_norvegicus/Rattus_norvegicus.gene_info.gz",
)

# --- Refseq File ---
refseq_info <- tibble::tribble(
  ~species, ~taxid, ~file,
  "human",  9606, "https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/mRNA_Prot/human.files.installed",
  "mouse", 10090, "https://ftp.ncbi.nlm.nih.gov/refseq/M_musculus/mRNA_Prot/mouse.files.installed",
  "rat",   10116, "https://ftp.ncbi.nlm.nih.gov/refseq/R_norvegicus/mRNA_Prot/rat.files.installed",
)

# ------figshare (depmap) and direct links -----------

DEPMAP_API_PATH <- 19700056 # 22Q1 = 19139906 # 21Q4 = 16924132 # 21Q3 = 15160110
DEPMAP_VERSION  <- "22q2"
depmap_info <- jsonlite::fromJSON(sprintf("https://api.figshare.com/v2/articles/%s/files", DEPMAP_API_PATH)) %>%
  mutate(data_name = "depmap", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(
    data_file %in% c(
      "sample_info",
      "CCLE_expression_full",
      "CCLE_RNAseq_reads",
      "CCLE_RNAseq_transcripts",
      "CCLE_gene_cn",
      "CCLE_mutations",
      "Achilles_gene_dependency",
      "Achilles_gene_effect",
      "Achilles_gene_effect_unscaled",
      "Achilles_gene_dependency_CERES",
      "Achilles_gene_effect_CERES",
      "Achilles_gene_effect_unscaled_CERES",
      "Achilles_common_essentials_CERES", # to decide if needed, there's
      # no nonessentials like this above
      "nonessentials",
      "common_essentials"
    )
  )

drive_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/6025238/files") %>%
  mutate(data_name = "demeter2-drive", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(grepl("(D2_DRIVE_gene_dep_scores)", data_file)) %>%
  mutate(data_file = "gene_effect")

prism_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/9393293/files") %>%
  mutate(data_name = "prism", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(data_file %in% c("secondary-screen-dose-response-curve-parameters"))

sanger_info_chronos <-  jsonlite::fromJSON("https://api.figshare.com/v2/articles/9116732/files") %>%
  mutate(data_name = "sanger-crispr-project-score", data_file = gsub("(\\.csv$|\\.tsv$|\\.txt$)", "", name)) %>%
  select(data_name,  url = download_url, data_file)

# sanger_info_ceres <- tibble::tribble(
#   ~"data_name", ~"url", ~"data_file",
#   "sanger-ceres", "https://ndownloader.figshare.com/files/16623887", "essential_genes",
#   "sanger-ceres", "https://ndownloader.figshare.com/files/16623890", "nonessential_genes",
#   "sanger-ceres", "https://ndownloader.figshare.com/files/16623881", "gene_effect",
#   "sanger-ceres", "https://ndownloader.figshare.com/files/16623851", "gene_effect_unscaled",
#   "sanger-ceres", "https://ndownloader.figshare.com/files/16623884", "gene_dependency"
# )

#sanger_info <- bind_rows(sanger_info_chronos, sanger_info_ceres)
sanger_info <- sanger_info_chronos

other_info <- tibble::tribble(
  ~data_name, ~url, ~data_file,
  "ccle", "https://data.broadinstitute.org/ccle/Cell_lines_annotations_20181226.txt", "Cell_lines_annotations_20181226",
  "ccle", "https://data.broadinstitute.org/ccle/CCLE_metabolomics_20190502.csv", "CCLE_metabolomics_20190502",
  #"ccle", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", 'msi',
  "ccle", "https://data.broadinstitute.org/ccle/CCLE_RPPA_20181003.csv", "CCLE_RPPA_20181003",
  "ccle", "https://data.broadinstitute.org/ccle/CCLE_RPPA_Ab_info_20181226.csv", "CCLE_RPPA_Ab_info_20181226",
  "total-proteome", "https://gygi.hms.harvard.edu/data/ccle/protein_quant_current_normalized.csv.gz", "protein_quant_current_normalized.csv.gz",
  "uniprot", "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping_selected.tab.gz", "HUMAN_9606_idmapping_selected.tab.gz",
  "metmap", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-020-2969-2/MediaObjects/41586_2020_2969_MOESM7_ESM.xlsx", 'metmap.xlsx',
  "msi", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", "msi"
)

drugcomb_info <- tibble::tribble(
  ~data_name, ~url, ~data_file,
  "drugcomb", "https://drugcomb.fimm.fi/jing/summary_v_1_5_update_with_drugIDs.csv", "summary_v_1_5_update_with_drugIDs.csv"
)

download_file_info <- depmap_info %>%
  bind_rows(drive_info) %>%
  bind_rows(sanger_info) %>%
  bind_rows(prism_info) %>%
  bind_rows(other_info) %>%
  bind_rows(drugcomb_info)

file_version <- tibble::tribble(
  ~description, ~information,
  "Depmap Version", paste("public", DEPMAP_VERSION),
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

TCGA_study <- tibble::tribble(
  ~project, ~tumortype,
  "LAML", "acute myeloid leukemia",
  "ACC",  "adrenocortical carcinoma",
  "BLCA", "bladder urothelial carcinoma",
  "LGG",  "brain lower grade glioma",
  "BRCA", "breast invasive carcinoma",
  "CESC", "cervical squamous cell carcinoma and endocervical adenocarcinoma",
  "CHOL", "cholangiocarcinoma",
  "LCML", "chronic myelogenous leukemia",
  "COAD", "colon adenocarcinoma",
  "CNTL", "controls",
  "ESCA", "esophageal carcinoma",
  "FPPP", "ffpe pilot phase II",
  "GBM",  "glioblastoma multiforme",
  "HNSC", "head and neck squamous cell carcinoma",
  "KICH", "kidney chromophobe",
  "KIRC", "kidney renal clear cell carcinoma",
  "KIRP", "kidney renal papillary cell carcinoma",
  "LIHC", "liver hepatocellular carcinoma",
  "LUAD", "lung adenocarcinoma",
  "LUSC", "lung squamous cell carcinoma",
  "DLBC", "lymphoid neoplasm diffuse large b-cell lymphoma",
  "MESO", "mesothelioma",
  "MISC", "miscellaneous",
  "OV",   "ovarian serous cystadenocarcinoma",
  "PAAD", "pancreatic adenocarcinoma",
  "PCPG", "pheochromocytoma and paraganglioma",
  "PRAD", "prostate adenocarcinoma",
  "READ", "rectum adenocarcinoma",
  "SARC", "sarcoma",
  "SKCM", "skin cutaneous melanoma",
  "STAD", "stomach adenocarcinoma",
  "TGCT", "testicular germ cell tumors",
  "THYM", "thymoma",
  "THCA", "thyroid carcinoma",
  "UCS",  "uterine carcinosarcoma",
  "UCEC", "uterine corpus endometrial carcinoma",
  "UVM",  "uveal melanoma"
)

TCGA_sample_type <- tibble::tribble(
  ~code, ~tissue_definition,
  "01", "Primary Solid Tumor",
  "02", "Recurrent Solid Tumor",
  "03", "Primary Blood Derived Cancer - Peripheral Blood",
  "04", "Recurrent Blood Derived Cancer - Bone Marrow",
  "05", "Additional - New Primary",
  "06", "Metastatic",
  "07", "Additional Metastatic",
  "08", "Human Tumor Original Cells",
  "09", "Primary Blood Derived Cancer - Bone Marrow",
  "10", "Blood Derived Normal",
  "11", "Solid Tissue Normal",
  "12", "Buccal Cell Normal",
  "13", "EBV Immortalized Normal",
  "14", "Bone Marrow Normal",
  "15", "sample type 15",
  "16", "sample type 16",
  "20", "Control Analyte",
  "40", "Recurrent Blood Derived Cancer - Peripheral Blood",
  "50", "Cell Lines",
  "60", "Primary Xenograft Tissue",
  "61", "Cell Line Derived Xenograft Tissue",
  "99", "sample type 99"
)

# -----------------
save(db_info, gene_info, refseq_info, db_compara, download_file_info,
     gmt.files, TCGA_study, TCGA_sample_type, file_version, file = "data/source_info.rdata")
