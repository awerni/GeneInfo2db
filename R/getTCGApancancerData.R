getTCGApancancerData <- function(tissuename) {
  
  tissuename_to_patientname <-
    data.frame(tissuename = tissuename) %>%
    mutate(patientname = substr(tissuename, 1, 12)) %>%
    tissuename_to_patientname %>% filter(!grepl("1.$", tissuename))
  
  # ------------------------------------------------------------------------------
  # immune environments
  # ------------------------------------------------------------------------------
  
  ### download
  url <- "https://ars.els-cdn.com/content/image/1-s2.0-S1074761318301213-mmc2.xlsx"
  file_thorsson2018 <- "thorsson2018_supplemental_table1.xlsx"
  if (!file.exists(file_thorsson2018)) {
    download.file(url, destfile = file_thorsson2018, method = "curl", quiet = TRUE)
  }
  
  ### mapping
  mapper <- tibble(`Immune Subtype` = paste0("C", 1:6), 
                   immune_environment = c("C1 wound healing", "C2 IFN-γ dominant", "C3 inflammatory", 
                                          "C4 lymphocyte depleted", "C5 immunologically quiet", "C6 TGF-β dominant"))
  
  ### process
  thorsson2018 <- readxl::read_excel(file_thorsson2018, na = "NA")
  
  immune_environment <- thorsson2018 %>% 
    left_join(mapper, by = "Immune Subtype") %>%
    select(patientname = `TCGA Participant Barcode`, immune_environment) %>%
    inner_join(tissuename_to_patientname, by = "patientname")
  
  # SANITY CHECK:
  # 292 patients have a 1-to-n mapping between patientname and tissuename
  immune_environment %>%
    count(patientname) %>%
    rename(mapping = n) %>%
    count(mapping)
  
  # ------------------------------------------------------------------------------
  # msisensor score and classification
  # ------------------------------------------------------------------------------
  ### download
  url <- "https://www.cell.com/cms/attachment/2119196599/2090459486/mmc5.xlsx"
  file_ding2018 <- "ding2018_supplemental_table5.xlsx"
  if (!file.exists(file_ding2018)) {
    download.file(url, destfile = file_ding2018, method = "curl", quiet = TRUE)
  }
  
  ### process
  ding2018 <- readxl::read_excel(file_ding2018, skip = 2, col_types = c("text", "numeric", "skip"))
  
  microsatellite_stability <- ding2018 %>%
    select(patientname = `Participant Barcode`, msisensor_score = `MSIsensor score`) %>%
    # classify into MSS and MSI based on Ding 2018
    mutate(microsatellite_stability = if_else(msisensor_score < 4, "MSS", "MSI")) %>%
    inner_join(tissuename_to_patientname, by = "patientname") %>%
    select(tissuename, patientname, microsatellite_stability, msisensor_score)
  
  # SANITY CHECK:
  # 286 patients have a 1-to-n mapping between patientname and tissuename
  microsatellite_stability %>%
    count(patientname) %>%
    rename(mapping = n) %>%
    count(mapping)
  
  # ------------------------------------------------------------------------------
  # GI molecular subtypes
  # ------------------------------------------------------------------------------
  
  ### download
  url <- "https://www.cell.com/cms/attachment/2119160047/2089960709/mmc2.xlsx"
  file_liu2018 <- "liu2018_supplemental_table1.xlsx"
  if (!file.exists(file_liu2018)) {
    download.file(url, destfile = file_liu2018, method = "curl", quiet = TRUE)
  }
  
  ### process
  liu2018 <- readxl::read_excel(file_liu2018, skip = 1)
  
  gi_mol_subtype <- liu2018 %>%
    select(patientname = `TCGA Participant Barcode`, gi_mol_subtype = Molecular_Subtype) %>%
    inner_join(tissuename_to_patientname, by = "patientname") %>%
    select(tissuename, patientname, gi_mol_subtype)
  
  # SANITY CHECK:
  # 3 patients have a 1-to-2 mapping between patientname and tissuename
  gi_mol_subtype %>%
    count(patientname) %>%
    rename(mapping = n) %>%
    count(mapping)
  
  # ------------------------------------------------------------------------------
  # iCluster
  # ------------------------------------------------------------------------------
  
  ### download 
  url <- "https://www.cell.com/cms/10.1016/j.cell.2018.03.022/attachment/a2f5572a-9732-4fd0-a72e-71c14de55169/mmc6.xls"
  file_hoadley2018 <- "hoadley_supplemental_table_s6.xls"
  if (!file.exists(file_hoadley2018)) {
    download.file(url, destfile = file_hoadley2018, method = "wget", quiet = TRUE)
  }
  
  iClusterNames <- tibble(`iCluster` = 1:28, 
                          iClusterName = c("C1: STAD (EBVCIMP)", "C2: BRCA (Her2 amp)", "C3: Mesenchymal (Immune)", "C4: Pan-GI (CRC)", "C5: CNS/Endocrine",
                                           "C6: OV", "C7: Mixed (Chr 9 del)", "C8: UCEC", "C9: ACC/KICH", "C10: Pan-SCC", "C11: LGG (IDH1 mut)", "C12: THCA",
                                           "C13: Mixed (Chr 8 del)", "C14: LUAD", "C15: SKCM/UVM", "C16: PRAD", "C17: BRCA (Chr 8q amp)", "C18: Pan-GI (MSI)",
                                           "C19: BRCA (Luminal)", "C20: Mixed (Stromal/Immune)", "C21: DLBC", "C22: TGCT", "C23: GBM/LGG (IDH1 wt)", 
                                           "C24: LAML", "C25: Pan-SCC (Chr 11 amp)", "C26: LIHC", "C27: Pan-SCC (HPV)", "C28: Pan-Kidney"))
  
  ### process
  hoadley2018 <- read_xlsx(file_hoadley2018, na = "NA", skip = 1)
  iCluster <- hoadley2018 %>%
    rename(patientname = `Sample ID`) %>%
    left_join(iClusterNames, by = "iCluster") %>%
    select(-iCluster) %>%
    rename(iCluster = iClusterName) %>%
    inner_join(tissuename_to_patientname, by = "patientname")
  
  # SANITY CHECK:
  # 275 patients have a 1-to-n mapping between patientname and tissuename
  iCluster %>%
    count(patientname) %>%
    rename(mapping = n) %>%
    count(mapping)
  
  # ------------------------------------------------------------------------------
  # xCell immune cell deconvolution
  # ------------------------------------------------------------------------------
  
  # -------> xCell was recalculated based on Aran's git repository: https://github.com/dviraran/xCell
  # ---- find the scripts in signature ------
  
  # ### download
  # url <- "https://static-content.springer.com/esm/art%3A10.1186%2Fs13059-017-1349-1/MediaObjects/13059_2017_1349_MOESM6_ESM.tsv"
  # file_xCell <-"xcell_TCGA.tsv"
  # if (!file.exists(file_xCell)) {
  #   download.file(url, destfile = file_xCell, method = "wget", quiet = TRUE)
  # }
  # 
  # url <- "https://static-content.springer.com/esm/art%3A10.1186%2Fs13059-017-1349-1/MediaObjects/13059_2017_1349_MOESM1_ESM.xlsx"
  # file_xCell2 <-"xcell_celltypes.xlsx"
  # if (!file.exists(file_xCell2)) {
  #   download.file(url, destfile = file_xCell2, method = "wget", quiet = TRUE)
  # }
  # 
  # ### process
  # # the downloaded file contains some typos, which are corrected below
  # xCellTypes <- read_excel(file_xCell2) %>%
  #   rename(celltype_short = `Cell types`, celltype = `Full name`) %>%
  #   mutate(celltype = gsub("Multipotent rogenitors", "Multipotent progenitors", celltype)) %>%
  #   mutate(celltype = gsub("Xonventional dendritic cells", "Conventional dendritic cells", celltype)) %>%
  #   mutate(celltype_short = gsub(" muscle cells", " muscle", celltype_short))
  # 
  # xCell <- read_tsv(file_xCell)
  # 
  # xCellData <- xCell %>%
  #   rename(celltype_short = X1) %>%
  #   gather(tissuename, score, -celltype_short) %>%
  #   mutate(tissuename = gsub("\\.", "-", tissuename)) %>%
  #   filter(grepl("TCGA", tissuename)) %>%
  #   inner_join(xCellTypes, by = "celltype_short") %>%
  #   select(tissuename, celltype, score)
  
  # ------------------------------------------------------------------------------
  # Digital Pathology
  # ------------------------------------------------------------------------------
  
  ### download
  url <- "https://www.cell.com/cms/10.1016/j.celrep.2018.03.086/attachment/17876b53-062e-48ee-b5ba-a0c0f2409098/mmc2.xlsx"
  file_saltz2018 <- "saltz2018_supplemental_table1.xlsx"
  if (!file.exists(file_saltz2018)) {
    download.file(url, destfile = file_saltz2018, method = "wget", quiet = TRUE)
  }
  
  ### process
  saltz2018 <- read_excel(file_saltz2018)
  
  digital_pathology <- saltz2018 %>%
    select(patientname = ParticipantBarcode, TIL_pattern = Global_Pattern) %>%
    inner_join(tissuename_to_patientname, by = "patientname") %>%
    select(tissuename, patientname, TIL_pattern)
  
  # SANITY CHECK:
  # 196 patients have a 1-to-n mapping between patientname and tissuename
  digital_pathology %>%
    count(patientname) %>%
    rename(mapping = n) %>%
    count(mapping)
  
  ## distribution of categories
  # digital_pathology %>%
  #   count(TIL_pattern)
  
  
  # ------------------------------------------------------------------------------
  # number of clones and pyhlogenetic tree
  # ------------------------------------------------------------------------------
  
  url <- "https://doi.org/10.1371/journal.pgen.1007669.s008"
  file_raynaud2018 <- "raynaud2018_supplemental_table1.xlsx"
  if (!file.exists(file_raynaud2018)) {
    download.file(url, destfile = file_raynaud2018, method = "wget", quiet = FALSE)
  }
  raynaud2018 <- read_xlsx(file_raynaud2018)
  
  clones_and_phylo_tree <- raynaud2018 %>%
    select(sample_name, `number of clones`, `Tree score`) %>%
    rename(tissuename = sample_name, number_of_clones = `number of clones`, clone_tree_score = `Tree score`) %>%
    mutate_if(is.numeric, function(x) round(x, 3)) %>%
    inner_join(tissuename_to_patientname, by = "tissuename")
  
  # ------------------------------------------------------------------------------
  # tumor purity
  # ------------------------------------------------------------------------------
  
  url <- "https://media.nature.com/original/nature-assets/ncomms/2015/151204/ncomms9971/extref/ncomms9971-s2.xlsx"
  file_aran2015 <- "aran2015_supplement_table2.xlsx" 
  if (!file.exists(file_aran2015)) {
    download.file(url, destfile = file_aran2015, method = "wget", quiet = FALSE)
  }
  aran2015 <- read_xlsx(file_aran2015, skip = 3, na = "NaN")
  
  tumor_purity <- aran2015 %>%
    mutate(tissuename = substring(`Sample ID`, 1, 15)) %>%
    filter(!is.na(CPE)) %>%
    select(tissuename, CPE)
  
  # ------------------------------------------------------------------------------
  # ------- read metabolics data ----------------
  # (taken from shiny app described in https://doi.org/10.1186/s12943-018-0895-9)
  # ------------------------------------------------------------------------------
  
  files <- dir(path = "Metabolics", pattern = "*_metabolicsignatures.csv")
  all_data <- NULL
  
  for (f in files) {
    a <- read_csv(paste0("Metabolics/", f)) %>%
      rename(patientname = X1)
    all_data <- bind_rows(all_data, a)
  }
  
  all_data_long <- all_data %>%
    gather(metabolic_pathway, score, -patientname) %>%
    mutate(metabolic_pathway = gsub("REACTOME_", "", metabolic_pathway)) %>%
    mutate(metabolic_pathway = gsub("_", " ", tolower(metabolic_pathway))) %>%
    mutate(metabolic_pathway = gsub("rna", "RNA", metabolic_pathway))
  
  metabolics_data <- all_data_long %>%
    select(patientname, metabolic_pathway, score) %>%
    inner_join(tissuename_to_patientname, by = "patientname")
  
  # SANITY CHECK:
  # 60 patients have a 1-to-n mapping between patientname and tissuename
  metabolics_data %>%
    count(patientname) %>%
    rename(mapping = n) %>%
    count(mapping)
  
  metabolics_data <- metabolics_data %>% select(tissuename, metabolic_pathway, score)
  
  # ------------------------------------------------------------------------------
  # signaling pathways
  # ------------------------------------------------------------------------------
  
  url <- "https://www.cell.com/cms/10.1016/j.cell.2018.03.035/attachment/df428b16-a198-4049-8962-04af160a059b/mmc4.xlsx"
  file_sanches_vega2018 <- "sanches_vega2018_supplemental_table4.xlsx"
  if (!file.exists(file_sanches_vega2018)) {
    download.file(url, destfile = file_sanches_vega2018, method = "wget", quiet = TRUE)
  }
  
  sanches_vega2018 <- read_xlsx(file_sanches_vega2018, sheet = 3, na = "NA") %>%
    rename(tissuename = SAMPLE_BARCODE) %>%
    rename(cell_cycle = `Cell Cycle`, rtk_ras = `RTK RAS`, tgf_beta = `TGF-Beta`) %>%
    rename_all(tolower) %>%
    mutate_if(is.numeric, as.logical)
  
  # ------------------------------------------------------------------------------
  # combine pan cancer data
  # ------------------------------------------------------------------------------
  
  valNum <- function(x) ifelse(is.na(x), "NULL", x)
  valStr <- function(x) ifelse(is.na(x), "NULL", paste0("'", x, "'"))
  
  pancancer <- list(gi_mol_subtype, microsatellite_stability, immune_environment, 
                    iCluster, digital_pathology, clones_and_phylo_tree, tumor_purity) %>%
    reduce(full_join) %>%
    mutate(sql = paste0("UPDATE tissue.tissue SET microsatellite_stability_score = ", valNum(msisensor_score), 
                        ", microsatellite_stability_class = ", valStr(microsatellite_stability),
                        ", immune_environment = ", valStr(immune_environment),
                        ", gi_mol_subgroup = ", valStr(gi_mol_subtype),
                        ", icluster = ", valStr(iCluster),
                        ", TIL_pattern = ", valStr(TIL_pattern),
                        ", tumorpurity = ", valNum(CPE),
                        ", number_of_clones = ", valNum(number_of_clones),
                        ", clone_tree_score = ", valNum(clone_tree_score),
                        " WHERE tissuename = '", tissuename, "'"))
  
}