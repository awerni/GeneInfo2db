getTissueProcessedRNASeqProjects <- function() {
  human_projects <- recount3::available_projects()
  human_projects %>% dplyr::filter(file_source %in% c("gtex", "tcga"))
}

getTissueRNAseqGroup <- function() {
  RNAseqGroup <- data.frame(
    rnaseqgroupid = 1:2,
    rnaseqname = c("TCGA", "GTEX"),
    rdatafilepath = NA,
    processingpipeline = "recount3"
  ) 
  
  list(
    tissue.RNAseqGroup = RNAseqGroup
  )
}

getTissueProcessedRNASeq <- function(projects) {
  
  stopifnot(NROW(projects) > 0)
  
  result <- lapply(
      1:nrow(projects),
      processProcessedRNASeqExperiment,
      human_projects = projects
    )
  
  result <- list(
    tissue.patient = result %>% lapply("[[", "tissue.patient") %>% bind_rows() %>% distinct(),
    tissue.tissue = result %>% lapply("[[", "tissue.tissue") %>% bind_rows() %>% distinct(),
    tissue.rnaseqrun = result %>% lapply("[[", "tissue.rnaseqrun") %>% bind_rows(),
    tissue.processedrnaseq = result %>% lapply("[[", "tissue.processedrnaseq") %>% bind_rows()
  )
  
  if(NROW(result$tissue.tissue) == 0) {
    result$tissue.tissue <- NULL
    result$tissue.patient <- NULL
  }
  
  result
}


processProcessedRNASeqExperiment <- function(id, human_projects) {
  
  proj <- human_projects[id,]
  
  if(proj$file_source == "tcga") {
    
    id_column = "tcga.tcga_barcode"
    get_tissue_id <- function(x) substr(x, 1, 15)
    get_tissue_run <- function(x) substr(x[,id_column], 16, 16)
    get_rnaset_run <- function(x) x
    filter_bad_qc <- function(x) x
    
  } else if(proj$file_source == "gtex") {
    
    id_column = "gtex.sampid"
    get_tissue_id <- function(x) substr(x, 1, nchar(x) - 9)
    get_tissue_run <- function(x) as.numeric(gsub(rownames(x), pattern = ".*\\.", replacement = ""))
    get_rnaset_run <- function(x) gsub("\\.[0-9]$", "", gsub(".*-", "", x))
    filter_bad_qc <- function(x) x %>% dplyr::filter(gtex.smafrze != "EXCLUDE")
    
  } else {
    stop("other file source is not supported")
  }
  
  message("Processing: ", id, " ", proj$project, " ", proj$file_source)
  
  withr::with_package("S4Vectors", {
    rse_gene <- recount3::create_rse(proj)  
  })
  
  # Remove bad GTEX samples
  
  col_data <- SummarizedExperiment::colData(rse_gene) %>%
    as.data.frame() %>%
    filter_bad_qc()
  
  #col_data <- SummarizedExperiment::colData(rse_gene)
  col_ids <- col_data[[id_column]]
  
  run_id <- get_tissue_run(col_data)
  
  unique_ids <- tibble(col_id = col_ids) %>%
    dplyr::mutate(
      id = row_number(),
      sample = run_id,
      clean_id = get_tissue_id(col_id)
    ) %>%
    group_by(clean_id) %>%
    dplyr::filter(max(sample) == sample) %>%
    dplyr::pull(id)
  
  rse_gene <- rse_gene[, unique_ids]
  rse_gene@colData@rownames <- get_rnaset_run(rse_gene@colData@rownames)
  rse_gene@colData@listData$external_id <- get_rnaset_run(rse_gene@colData@listData$external_id)
  
  # Calculate counts
  #raw_count <- SummarizedExperiment::assay(rse_gene, "raw_counts")
  ensg <- substr(SummarizedExperiment::rowData(rse_gene)[,"gene_id"], 1, 15)
  dupl_ensg <- ensg[duplicated(ensg)]
  
  # rse_gene_clean <- rse_gene[!duplicated(ensg),] <------------ WRONG !!
  # 
  # duplicated_counts <- raw_count[duplicated(ensg),, drop = FALSE]
  # duplicated_ensg <- ensg[duplicated(ensg)]
  # duplicated_counts <- rowsum(duplicated_counts, duplicated_ensg)
  # 
  # clean_ensg <- substr(rownames(SummarizedExperiment::assay(rse_gene_clean, "raw_counts")), 1, 15)
  # idxes <- sapply(rownames(duplicated_counts), function(x) which(x == clean_ensg))
  # SummarizedExperiment::assay(rse_gene_clean, "raw_counts")[idxes,] <- SummarizedExperiment::assay(rse_gene_clean, "raw_counts")[idxes,] + duplicated_counts
   
  to_data_frame <- function(dt, name = "counts") {
    as.data.frame.table(dt, responseName = name) %>%
      dplyr::rename(ensg = Var1, rnaseqrunid = Var2) %>%
      dplyr::mutate(ensg =  substr(ensg, 1, 15))
  }
  
  counts <- to_data_frame(SummarizedExperiment::assay(rse_gene, "raw_counts"))
  
  SummarizedExperiment::assay(rse_gene, "counts") <- recount3::transform_counts(rse_gene)
  log2tpm <- to_data_frame(recount::getTPM(rse_gene), name = "tpm") %>%
    dplyr::mutate(log2tpm = log2(tpm + 1)) %>% select(-tpm)
  
  col_data <- SummarizedExperiment::colData(rse_gene) %>%
    as.data.frame() %>%
    filter_bad_qc()

  processedRNASeq <- counts %>% 
    dplyr::mutate(log2tpm = log2tpm$log2tpm, rnaseqrunid = as.character(rnaseqrunid)) %>%
    dplyr::filter(rnaseqrunid %in% rownames(col_data))
  
  processedRNASeq_clean <- processedRNASeq %>%
    dplyr::filter(!ensg %in% dupl_ensg)
  
  processedRNASeq_dupl <- processedRNASeq %>%
    dplyr::filter(ensg %in% dupl_ensg) %>%
    group_by(ensg, rnaseqrunid) %>%
    summarise(log2tpm = sum(log2tpm), counts = sum(counts), .groups = "drop")
  
  processedRNASeq <- processedRNASeq_clean %>%
    bind_rows(processedRNASeq_dupl)
  
  RNAseqGroupID <- case_when(
    proj$file_source == "tcga" ~ 1,
    proj$file_source == "gtex" ~ 2 
  )
  
  RNAseqRun <- data.frame(
    rnaseqrunid = rownames(col_data),
    tissuename = get_tissue_id(col_data[, id_column]),
    laboratory = "recount3",
    rnaseqgroupid = RNAseqGroupID,
    cellbatchid = NA,
    directory = "",
    isxenograft = FALSE,
    publish = TRUE,
    comment = "",
    canonical = TRUE,
    sourceid = col_data[, id_column]
  )
  
  result <- list(
    tissue.rnaseqrun = RNAseqRun,
    tissue.processedrnaseq = processedRNASeq
  )
  
  if (proj$file_source == "gtex") {
    anno <- getTissueGTEXAnno(rse_gene)
    result2 <- list(
      tissue.patient = anno$tissue.patient,
      tissue.tissue = anno$tissue.tissue
    )
    result <- c(result2, result)
  }
  
  result
  
}

getTissueGTEXAnno <- function(rse_gene) {
  anno <- SummarizedExperiment::colData(rse_gene)
  
  anno <- anno[, grep(colnames(anno), value = TRUE, pattern = "^gtex")] %>%
    as.data.frame()
  
  autolysis_score <-
    tibble(
      gtex.smatsscr = 0:3,
      autolysis_score = c("None", "Mild", "Moderate", "Severe")
    )
  
  hardy_scale <- tibble(
    gtex.dthhrdy = 0:4,
    death_classification = c(
      "Ventilator Case",
      "Violent and fast death",
      "Fast death of natural causes",
      "Intermediate death",
      "Slow death"
    )
  )
  
  # GTEX codes:
  # https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/GetListOfAllObjects.cgi?study_id=phs000424.v8.p2&object_type=variable
  anno_all <- anno %>%
    dplyr::left_join(autolysis_score, by = "gtex.smatsscr") %>%
    dplyr::left_join(hardy_scale, by = "gtex.dthhrdy") %>%
    dplyr::mutate(
      gender = ifelse(gtex.sex == 1, "male", "female"),
      days_to_birth = stringr::str_split(gtex.age, "-") %>% purrr::map(function(x)
        - round(mean(as.numeric(
          x
        )) * 365.25)) %>% unlist(),
      tissuename = substr(gtex.sampid, 1, nchar(gtex.sampid) - 9)
    ) %>% 
    filter(gtex.smafrze != "EXCLUDE") %>%
    dplyr::select(
      tissuename,
      organ = gtex.smts,
      tissue_subtype = gtex.smtsd,
      RNA_integrity_number = gtex.smrin,
      minutes_ischemia = gtex.smtsisch,
      patientname = gtex.subjid,
      comment = gtex.smpthnts,
      autolysis_score,
      gender,
      days_to_birth,
      death_classification
    ) 
  
  tissue_anno <- with(anno_all, tibble(
    tissuename           = tissuename,
    vendorname           = "GTEX",
    species              = "human",
    organ                = organ,
    tumortype            = "normal",
    patientname          = patientname,
    tumortype_adjacent   = NA,
    tissue_subtype       = tissue_subtype,
    metastatic_site      = NA,
    histology_type       = NA,
    histology_subtype    = NA,
    age_at_surgery       = NA,
    stage                = NA,
    grade                = NA,
    sample_description   = NA,
    comment              = comment,
    dnasequenced         = NA,
    tumorpurity          = NA,
    microsatellite_stability_score = NA,
    microsatellite_stability_class = NA,
    immune_environment   = NA,
    gi_mol_subgroup      = NA,
    icluster             = NA,
    til_pattern          = NA,
    number_of_clones     = NA,
    clone_tree_score     = NA,
    rna_integrity_number = RNA_integrity_number,
    minutes_ischemia     = minutes_ischemia,
    autolysis_score      = autolysis_score,
    consmolsubtype       = NA,
    lossofy              = NA
  ))
  
  patient_anno <- with(anno_all, tibble(
    patientname              = patientname,
    vital_status             = FALSE,
    days_to_birth            = days_to_birth,
    gender                   = gender,
    height                   = NA,
    weight                   = NA,
    race                     = NA,
    ethnicity                = NA,
    days_to_last_followup    = NA,
    days_to_last_known_alive = NA,
    days_to_death            = NA,
    person_neoplasm_cancer_status = NA,
    death_classification     = death_classification,
    treatment                = NA,
  )) %>% distinct()
  
  stopifnot("found duplicated patient name" =
              (anyDuplicated(patient_anno$patientname) == 0))
  
  list(
    tissue.tissue = as.data.frame(tissue_anno),
    tissue.patient = as.data.frame(patient_anno)
  )
  
}