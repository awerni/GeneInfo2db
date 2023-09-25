### CAUTION !
### This scirpt is not run during the building process.
library(dplyr)

# ---  Ensembl Gene File ---
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

FIGSHARE_ID <- 22765112 # 22Q4 = 21637199; 22Q2 = 19700056; 22Q1 = 19139906; 21Q4 = 16924132; 21Q3 = 15160110
DEPMAP_VERSION  <- "23q2"
depmap_info <- jsonlite::fromJSON(sprintf("https://api.figshare.com/v2/articles/%s/files", FIGSHARE_ID)) %>%
  mutate(data_name = "depmap", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(
    data_file %in% c(
      "Model",
      "OmicsExpressionProteinCodingGenesTPMLogp1",
      "OmicsExpressionTranscriptsExpectedCountProfile",
      "OmicsExpressionGenesExpectedCountProfile",
      "CRISPRGeneDependency",
      "CRISPRGeneEffect",
      "AchillesCommonEssentialControls",
      "AchillesNonessentialControls",
      "OmicsCNGene",
      "OmicsFusionFiltered",
      "OmicsSomaticMutations",
      "OmicsDefaultModelConditionProfiles",
      "ModelCondition",
      "OmicsProfiles"
    )
  )

FIGSHARE_ID_OLD <- 19700056 #
DEPMAP_VERSION_OLD  <- "22q2"
depmap_info_old <- jsonlite::fromJSON(sprintf("https://api.figshare.com/v2/articles/%s/files", FIGSHARE_ID_OLD)) %>%
  mutate(data_name = "depmap", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(
    data_file %in% c(
      "CCLE_expression_full",
      "CCLE_RNAseq_reads",
      "CCLE_RNAseq_transcripts",
      "CCLE_gene_cn",
      "CCLE_mutations"
    )
  )

drive_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/6025238/files") %>%
  mutate(data_name = "demeter2-drive", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(grepl("(D2_DRIVE_gene_dep_scores)", data_file)) %>%
  mutate(data_file = "gene_effect")

prism_info <- jsonlite::fromJSON("https://api.figshare.com/v2/articles/20564034/files") %>%
  mutate(data_name = "prism", data_file = gsub("\\.csv$", "", name)) %>%
  select(data_name,  url = download_url, data_file) %>%
  filter(data_file %in% c("prism-repurposing-20q2-secondary-screen-dose-response-curve-parameters"))

sanger_info_chronos <-  jsonlite::fromJSON("https://api.figshare.com/v2/articles/9116732/files") %>%
  mutate(data_name = "sanger-crispr-project-score", data_file = gsub("(\\.csv$|\\.tsv$|\\.txt$)", "", name)) %>%
  select(data_name,  url = download_url, data_file)

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
  "msi", "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-019-1102-x/MediaObjects/41586_2019_1102_MOESM1_ESM.xlsx", "msi",
  "TCSA", "http://fcgportal.org/TCSA/Download/Table%20S2.xlsx", "TCSA_ensg.xlsx",
  "TF", "https://cdn.netbiol.org/tflink/download_files/TFLink_Homo_sapiens_interactions_All_simpleFormat_v1.0.tsv.gz", "TFLink_Homo_sapiens.tsv.gz",  
  "mTF", "https://www.science.org/doi/suppl/10.1126/sciadv.abf6123/suppl_file/sciadv.abf6123_tables_s1_to_s14.zip", "Reddy_al_master_TF.zip"
)

drugcomb_info <- tibble::tribble(
  ~data_name, ~url, ~data_file,
  "drugcomb", " ", "summary_v_1_5_update_with_drugIDs.csv"
)

download_file_info <- depmap_info %>%
  bind_rows(depmap_info_old) %>%
  bind_rows(drive_info) %>%
  bind_rows(sanger_info) %>%
  bind_rows(prism_info) %>%
  bind_rows(other_info) %>%
  bind_rows(drugcomb_info)

file_version <- tibble::tribble(
  ~description, ~information,
  "Depmap Version", paste("public", DEPMAP_VERSION),
  "Depmap Version DNAseq", paste("public", DEPMAP_VERSION),
  "CCLE Version Omics", paste("public", DEPMAP_VERSION_OLD),
  "metabolomics", "CCLE_metabolomics_20190502",
  "Proteomics", "CCLE_RPPA_20181003"
)

additional_TCGA_antibodies <- tibble::tribble(
  ~antibody, ~validation_status, ~vendor, ~catalog_number, ~antibody_coarse,
  "AMPKa", "Caution", "CST", "2532", "AMPKALPHAPT172",
  "A-Raf", "Valid", "CST", "4432", "ARAF",
  "ARID1A", "Caution", "Sigma-Aldrich", "HPA005456", "ARID1A",
  "Axl", "Valid", "CST", "8661", "AXL",
  "Bcl2A1", "Valid", "Abnova", "PAB8528", "BCL2A1",
  "Bim (C34C5)", "Valid", "CST", "2933", "BIM",
  "BRD4", "Valid", "CST", "13440", "BRD4",
  "CA9 (CAIX)", "Caution", "CST", "5649", "CA9",
  "c-Abl", "Valid", "CST", "2862", "CABL",
  "Caspase 3 (cleaved asp175)", "Caution", "CST", "9661", "CASPASE3",
  "CD26", "Valid", "Abcam", "ab28340", "CD26",
  "Cdc2 (phospho Y15)", "Caution", "CST", "4539", "CDK1PY15",
  "CDKN2A/p16INK4a", "Caution", "CST", "92803", "P16INK4A",
  "Chk1 (phospho S296)", "Valid", "Abcam", "ab79758", "CHK1PS296",
  "COG3", "Valid", "ProteinTech", "11130-1-AP", "COG3",
  "C-Raf", "Caution", "Millipore", "04-739", "CRAF",
  "DUSP4/MKP2", "Valid", "CST", "5149", "DUSP4",
  "E2F1", "Valid", "CST", "3742", "E2F1",
  "ENY2", "Caution", "GeneTex", "GTX629542", "ENY2",
  "GATA6", "Valid", "CST", "5851", "GATA6",
  "GCN5L2", "Valid", "CST", "3305", "GCN5L2",
  "Glycogen Synthase", "Valid", "CST", "3886", "GYS",
  "Glycogen Synthase (phospho S641)", "Valid", "CST", "3891", "GYSPS641",
  "Hif-1-alpha", "Caution", "CST", "36169", "HIF1ALPHA",
  "IGF1R (phospho Y1135/Y1136)", "Valid", "CST", "3024", "IGF1RPY1135Y1136",
  "IRF-1", "Valid", "CST", "8478", "IRF1",
  "JAB1", "Caution", "Santa Cruz", "sc-13157", "JAB1",
  "KEAP1", "Valid", "CST", "8047", "KEAP1",
  "LDHA", "Caution", "CST", "3582", "LDHA",
  "MACC1", "Valid", "CST", "86290", "MACC1",
  "Myosin IIa", "Caution", "CST", "3403", "MYOSINIIA",
  "NAPSIN-A", "Caution", "Epitomics/Abcam", "5795-1/ab129189", "NAPSINA",
  "NRF2", "Caution", "CST", "12721", "NRF2",
  "p70/S6K1", "Valid", "Epitomics/Abcam", "1494-1/ab32529", "P70S6K1",
  "PARP", "Valid", "CST", "9532", "PARP1",
  "PD-1", "Valid", "GeneTex", "GTX128436", "PDCD1",
  "PD-L1", "Caution", "CST", "13684", "PDL1",
  "PKM2", "Caution", "CST", "4053", "PKM2",
  "PYGB", "Valid", "Sigma-Aldrich", "SAB2900066", "PYGB",
  "PYGM", "Caution", "Novus", "H00005837-M10", "PYGM",
  "Rab11", "Caution", "CST", "3539", "RAB11",
  "S6 Ribosomal Protein", "Valid", "CST", "2317", "S6",
  "SLC1A5", "Caution", "Sigma-Aldrich", "HPA035240", "SLC1A5",
  "Synaptophysin", "Caution", "CST", "36406", "SYNAPTOPHYSIN",
  "VHL-EPPK1", "Caution", "BD Biosciences", "556347", "EPPK1",
  "XPG", "Caution", "Proteintech Group", "11331-1-AP", "ERCC5"
)


# -------------MSigDB --------------------

gmt.files <- tibble::tribble(
  ~file, ~collection, ~collection_name, ~gene_set_group,
  "c1.all.$.entrez.gmt", "c1", "positional", "positional",
  "c2.cgp.$.entrez.gmt", "c2", "curated", "chemical and genetic perturbations",
  "c2.cp.biocarta.$.entrez.gmt", "c2", "curated", "biocarta",
  "c2.cp.kegg.$.entrez.gmt", "c2", "curated", "KEGG",
  "c2.cp.pid.$.entrez.gmt", "c2", "curated", "PID",
  "c2.cp.reactome.$.entrez.gmt", "c2", "curated", "Reactome",
  "c2.cp.wikipathways.$.entrez.gmt", "c2", "curated", "wiki pathways",
  "c2.cp.$.entrez.gmt", "c2", "curated", "canonical pathways",
  "c3.mir.mirdb.$.entrez.gmt", "c3", "regulatory target", "MIRDB targets",
  #"c3.mir.mir_legacy.$.entrez.gmt", "c3", "regulatory target", "Legacy microRNA targets",
  #"c3.mir.$.entrez.gmt", "c3", "regulatory target", "all microRNA targets",
  "c3.tft.gtrd.$.entrez.gmt", "c3", "regulatory target", "GTRD targets",
  "c3.tft.tft_legacy.$.entrez.gmt", "c3", "regulatory target", "Legacy transcription factor targets",
  #"c3.tft.$.entrez.gmt", "c3", "regulatory target", "all transcription factor targets",
  "c4.cgn.$.entrez.gmt", "c4", "computational", "cancer gene neighborhoods",
  "c4.cm.$.entrez.gmt", "c4", "computational", "cancer modules",
  "c5.go.bp.$.entrez.gmt", "c5", "gene ontology", "biological processes",
  "c5.go.cc.$.entrez.gmt", "c5", "gene ontology", "cellular components",
  "c5.go.mf.$.entrez.gmt", "c5", "gene ontology", "molecular functions",
  "c6.all.$.entrez.gmt", "c6", "oncogenic signatures", "all oncogenic signatures",
  "c7.all.$.entrez.gmt", "c7", "immunologic signatures", "all immunologic signatures ",
  "c8.all.$.entrez.gmt", "c8", "cell type signatures", "all cell type signatures",
  "h.all.$.entrez.gmt", "h", "hallmark", "hallmark"
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

usethis::use_data(db_info, overwrite = TRUE)
usethis::use_data(gene_info, overwrite = TRUE)
usethis::use_data(refseq_info, overwrite = TRUE)
usethis::use_data(db_compara, overwrite = TRUE)
usethis::use_data(download_file_info, overwrite = TRUE)
usethis::use_data(gmt.files,  overwrite = TRUE)
usethis::use_data(TCGA_study, overwrite = TRUE)
usethis::use_data(TCGA_sample_type, overwrite = TRUE)
usethis::use_data(file_version, overwrite = TRUE)
