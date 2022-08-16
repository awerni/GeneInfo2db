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
      mutate(vendorname = "TCGA", species = "human")
    
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
      vital_status = na_if(vital_status, "Not Reported"),
      vital_status = ifelse(vital_status == "Alive", TRUE, FALSE),
      person_neoplasm_cancer_status = NA,
      death_classification = NA,
      treatment = NA,
      height = NA,
      weight = NA
    )
  
  pancancer_data <- getTCGApancancerData(tissuesample$tissuename)
  
  tissue <- tissuesample %>%
    rename(stage = ajcc_pathologic_stage) %>%
    filter(tissue_definition != "Blood Derived Normal") %>% 
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
      tissue_subtype       = as.character(NA),
      metastatic_site      = as.character(NA),
      histology_type       = as.character(NA),
      histology_subtype    = as.character(NA),
      age_at_surgery       = as.character(NA),
      sample_description   = as.character(NA),
      comment              = as.character(NA),
      dnasequenced         = NA,
      rna_integrity_number = as.numeric(NA),
      minutes_ischemia     = as.integer(NA),
      autolysis_score      = as.character(NA),
      consmolsubtype       = as.character(NA),
      lossofy              = NA
    ) %>%
    left_join(pancancer_data, by = c("tissuename", "patientname"))

  tumortype <- data.frame(
    tumortype = unique(tissue$tumortype),
    tumortypedesc = NA
  )

  res <- list(
    tissue.tumortype = tumortype,
    tissue.patient = patient, 
    tissue.tissue = tissue
  )
}
