getTissueProcessedRNASeqProjects <- function() {
  human_projects <- recount3::available_projects()
  human_projects %>% filter(file_source %in% c("gtex", "tcga"))
}

getTissueRNAseqGroup <- function() {
  RNAseqGroup <- data.frame(
    RNAseqGroupID = 1:2,
    RNAseqName = c("TCGA", "GTEX"),
    RdataFilePath = NA,
    processingPipeline = ""
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
      human_projects = human_projects
    )
  
  result <- list(
    tissue.processedRNASeq = result %>% lapply("[[", "tissue.processedRNASeq") %>% bind_rows(),
    tissue.RNAseqRun = result %>% lapply("[[", "tissue.RNAseqRun") %>% bind_rows(),
    tissue.tissue = result %>% lapply("[[", "tissue.tissue") %>% bind_rows(),
    tissue.patient = result %>% lapply("[[", "tissue.patient") %>% bind_rows(),
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
    
  } else if(proj$file_source == "gtex") {
    
    id_column = "gtex.sampid"
    get_tissue_id <- function(x) x
    get_tissue_run <- function(x) as.numeric(gsub(rownames(x), pattern = ".*\\.", replacement = ""))
    
  } else {
    stop("Other file source is not supported")
  }
  
  
  
  message("Processing: ", id, " ", proj$project, " ", proj$file_source)
  
  withr::with_package("S4Vectors", {
    rse_gene <- recount3::create_rse(proj)  
  })
  
  # Remove duplicated tissuenames
  col_data <- SummarizedExperiment::colData(rse_gene)
  col_ids <- col_data[[id_column]]
  
  run_id <- get_tissue_run(col_data)
  
  unique_ids <- tibble(col_id = col_ids) %>%
    mutate(
      id = row_number(),
      sample = run_id,
      clean_id = get_tissue_id(col_id)
    ) %>%
    group_by(clean_id) %>%
    filter(max(sample) == sample) %>%
    dplyr::pull(id)
  
  rse_gene <- rse_gene[,unique_ids]
  
  # Calculate counts
  SummarizedExperiment::assay(rse_gene, "counts") <- recount3::transform_counts(rse_gene)
  
  # TODO: sum duplicates after extracting 15 digits of ensg 
  ensg <- substr(SummarizedExperiment::rowData(rse_gene)[,"gene_id"], 1, 15)
  rse_gene <- rse_gene[!(duplicated(ensg) | duplicated(ensg, fromLast = TRUE)), ]
  
  to_data_frame <- function(dt, name = "counts") {
    as.data.frame.table(dt, responseName = name) %>%
      dplyr::rename(ENSG = Var1, RNAseqRunID = Var2) %>%
      mutate(ENSG =  substr(ENSG, 1, 15))
  }
  
  counts <- to_data_frame(SummarizedExperiment::assay(rse_gene, "counts"))
  log2tpm <- to_data_frame(recount::getTPM(rse_gene), name = "tpm") %>%
    mutate(log2tpm = log2(tpm)) %>% select(-tpm)
  
  processedRNASeq <- counts %>% mutate(log2tpm = log2tpm$log2tpm)
  
  col_data <- SummarizedExperiment::colData(rse_gene)
  
  
  RNAseqGroupID <- case_when(
    proj$file_source == "tcga" ~ 1,
    proj$file_source == "gtex" ~ 2 
  )
  
  RNAseqRun <- data.frame(
    RNAseqRunID = rownames(col_data),
    tissuename = get_tissue_id(col_data[, id_column]),
    laboratory = "recount3",
    RNAseqGroupID = RNAseqGroupID,
    cellbatchID = NA,
    directory = "",
    isXenograft = FALSE,
    publish = TRUE,
    comment = "",
    canonical = TRUE,
    sourceID = col_data[, id_column]
  )
  
  result <- list(
    tissue.processedRNASeq = processedRNASeq,
    tissue.RNAseqRun = RNAseqRun
  )
  
  if(proj$file_source == "gtex") {
    anno <- getTissueGTEXAnno(rse_gene)
    result$tissue.tissue <- anno$tissue.tissue
    result$tissue.patient <- anno$tissue.patient
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
    left_join(autolysis_score, by = "gtex.smatsscr") %>%
    left_join(hardy_scale, by = "gtex.dthhrdy") %>%
    mutate(
      gender = ifelse(gtex.sex == 1, "male", "female"),
      days_to_birth = stringr::str_split(gtex.age, "-") %>% purrr::map(function(x)
        - round(mean(as.numeric(
          x
        )) * 365.25)) %>% unlist()
    ) %>%
    select(
      tissuename = gtex.sampid,
      organ = gtex.smts,
      tissue_subtype = gtex.smtsd,
      RNA_integrity_number = gtex.smrin,
      minutes_ischemia = gtex.smtsisch,
      patientname = gtex.subjid,
      autolysis_score,
      gender,
      days_to_birth,
      death_classification
    )
  
  tissue_anno <- with(anno_all, tibble(
    TISSUENAME           = anno_all$tissuename,
    VENDORNAME           = "GTEX",
    SPECIES              = "human",
    ORGAN                = anno_all$organ,
    TUMORTYPE            = "normal",
    PATIENTNAME          = anno_all$patientname,
    TUMORTYPE_ADJACENT   = NA,
    TISSUE_SUBTYPE       = tissue_subtype,
    METASTATIC_SITE      = NA,
    HISTOLOGY_TYPE       = NA,
    HISTOLOGY_SUBTYPE    = NA,
    AGE_AT_SURGERY       = NA,
    STAGE                = NA,
    GRADE                = NA,
    SAMPLE_DESCRIPTION   = NA,
    COMMENT              = NA,
    DNASEQUENCED         = NA,
    TUMORPURITY          = NA,
    TDPID                = NA,
    MICROSATELLITE_STABILITY_SCORE = NA,
    MICROSATELLITE_STABILITY_CLASS = NA,
    IMMUNE_ENVIRONMENT   = NA,
    GI_MOL_SUBGROUP      = NA,
    ICLUSTER             = NA,
    TIL_PATTERN          = NA,
    NUMBER_OF_CLONES     = NA,
    CLONE_TREE_SCORE     = NA,
    RNA_INTEGRITY_NUMBER = RNA_integrity_number,
    MINUTES_ISCHEMIA     = minutes_ischemia,
    AUTOLYSIS_SCORE      = autolysis_score,
    CONSMOLSUBTYPE       = NA,
    LOSSOFY              = NA
  ))
  
  patient_anno <- with(anno_all, tibble(
    PATIENTNAME              = patientname,
    VITAL_STATUS             = FALSE,
    DAYS_TO_BIRTH            = days_to_birth,
    GENDER                   = gender,
    HEIGHT                   = NA,
    WEIGHT                   = NA,
    RACE                     = NA,
    ETHNICITY                = NA,
    DAYS_TO_LAST_FOLLOWUP    = NA,
    DAYS_TO_LAST_KNOWN_ALIVE = NA,
    DAYS_TO_DEATH            = NA,
    PERSON_NEOPLASM_CANCER_STATUS = NA,
    DEATH_CLASSIFICATION     = death_classification,
    TREATMENT                = NA,
  )) %>% distinct()
  
  stopifnot("Found duplicated patient name" =
              !isTRUE(anyDuplicated(patient_anno$PATIENTNAME)))
  
  list(
    tissue.tissue = as.data.frame(tissue_anno),
    tissue.patient = as.data.frame(patient_anno)
  )
  
}
