#' Title
#'
#' @return
#' @export
#'
#' @importFrom dplyr na_if
#' @importFrom logger log_trace
#' @importFrom magrittr `%>%`
#'
#' @examples
getTCGAAnnotation <- function() {

  project <- TCGAbiolinks::getGDCprojects()$project_id
  project <- grep("TCGA", project, value = TRUE)
  subtypes <- TCGAbiolinks::PanCancerAtlas_subtypes()

  data <- lapply(project, function(p) {
    print(paste("processing", p))
    clin <- TCGAbiolinks::GDCquery_clinic(p, "Clinical") %>%
      rename(
        patientname = submitter_id,
        days_to_last_followup = days_to_last_follow_up,
        days_to_last_known_alive = days_to_last_known_disease_status,
        organ = tissue_or_organ_of_origin,
      ) %>%
      mutate(project = gsub("^TCGA-", "", p))
    
    query1 <- TCGAbiolinks::GDCquery(
      project = p,
      data.category = "Transcriptome Profiling",
      data.type = "miRNA Expression Quantification",
      legacy = FALSE
    )
    
    query2 <- TCGAbiolinks::GDCquery(
      project = p,
      data.category = "Transcriptome Profiling",
      data.type = "Gene Expression Quantification",
      legacy = FALSE
    )
    
    query3 <- TCGAbiolinks::GDCquery(
      project = p,
      data.category = "Copy Number Variation",
      data.type = "Gene Level Copy Number",
      legacy = FALSE
    )
    
    query4 <- TCGAbiolinks::GDCquery(
      project = p,
      data.category = "Simple Nucleotide Variation",
      data.type = "Raw Simple Somatic Mutation",
      legacy = FALSE
    )
    
    getTissuename <-
      function(q)
        substr(q$results[[1]]$cases, 1, 15) %>% unique()
    
    t1 <- getTissuename(query1)
    t2 <- getTissuename(query2)
    t3 <- getTissuename(query3)
    t4 <- getTissuename(query4)
    
    tissuesample <- data.frame(tissuename = unique(c(t1, t2, t3, t4))) %>%
      mutate(patientname = substr(tissuename, 1, 12),
             code = substr(tissuename, 14, 15)) %>%
      left_join(clin, by = "patientname") %>%
      left_join(TCGA_study, by = "project") %>%
      left_join(TCGA_sample_type, by = "code") %>%
      left_join(subtypes, by = c("patientname" = "pan.samplesID")) %>%
      mutate(vendorname = "TCGA",
             species = "human")
    
    list(
      clin = clin,
      tissuesample = tissuesample
    )
  })
  
  clin <- lapply(data, "[[", "clin") %>% bind_rows()
  tissuesample <- lapply(data, "[[", "tissuesample") %>% bind_rows()
  
  patient <- clin %>%
    select(
      patientname,
      vital_status,
      days_to_birth,
      gender,
      race,
      ethnicity,
      days_to_last_followup,
      days_to_last_known_alive,
      days_to_death
    ) %>% mutate(
    PERSON_NEOPLASM_CANCER_STATUS = NA,
    DEATH_CLASSIFICATION = NA,
    TREATMENT = NA,
    HEIGHT = NA,
    WEIGHT = NA
  )
  
  tissue <- tissuesample %>%
    # filter(Short_Letter_Code != "NB") %>% ????????????
    rename(stage = ajcc_pathologic_stage) %>%
    mutate(
      tumortype_adjacent = ifelse(grepl("Normal", tissue_definition), tumortype, NA),
      tumortype = ifelse(grepl("Normal", tissue_definition), "normal", tumortype),
      grade = paste(ajcc_pathologic_t, ajcc_pathologic_n, ajcc_pathologic_m),
      stage = gsub("Stage ", "", stage)
    ) %>%
    select(
      tissuename,
      vendorname,
      species,
      organ,
      tumortype,
      patientname,
      tumortype_adjacent,
      stage,
      grade
    ) %>%
    mutate(
      TISSUE_SUBTYPE    = NA,
      METASTATIC_SITE   = NA,
      HISTOLOGY_TYPE    = NA,
      HISTOLOGY_SUBTYPE = NA,
      AGE_AT_SURGERY    = NA,
      SAMPLE_DESCRIPTION = NA,
      COMMENT            = NA,
      DNASEQUENCED       = NA,
      TUMORPURITY        = NA,
      TDPID              = NA,
      MICROSATELLITE_STABILITY_SCORE  = NA,
      MICROSATELLITE_STABILITY_CLASS  = NA,
      IMMUNE_ENVIRONMENT = NA,
      GI_MOL_SUBGROUP    = NA,
      ICLUSTER           = NA,
      TIL_PATTERN        = NA,
      NUMBER_OF_CLONES      = NA,
      CLONE_TREE_SCORE      = NA,
      RNA_INTEGRITY_NUMBER  = NA,
      MINUTES_ISCHEMIA      = NA,
      AUTOLYSIS_SCORE       = NA,
      CONSMOLSUBTYPE        = NA,
      LOSSOFY               = NA
    )

  res <- list(
    tissue.patient = patient, 
    tissue.tissue = tissue
  )
}




