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
      vital_status = na_if(vital_status, "Not Reported"),
      vital_status = ifelse(vital_status == "Alive", TRUE, FALSE),
      person_neoplasm_cancer_status = NA,
      death_classification = NA,
      treatment = NA,
      height = NA,
      weight = NA
    )
  
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
      tissue_subtype    = NA,
      metastatic_site   = NA,
      histology_type    = NA,
      histology_subtype = NA,
      age_at_surgery    = NA,
      sample_description = NA,
      comment            = NA,
      dnasequenced       = NA,
      tumorpurity        = NA,
      microsatellite_stability_score  = NA,
      microsatellite_stability_class  = NA,
      immune_environment = NA,
      gi_mol_subgroup    = NA,
      icluster           = NA,
      til_pattern        = NA,
      number_of_clones      = NA,
      clone_tree_score      = NA,
      rna_integrity_number  = NA,
      minutes_ischemia      = NA,
      autolysis_score       = NA,
      consmolsubtype        = NA,
      lossofy               = NA
    )

  tumortype <- data.frame(
    tumortype = unique(x$tissue.tissue$tumortype),
    tumortypedesc = NA
  )

  res <- list(
    tissue.tumortype = tumortype,
    tissue.patient = patient, 
    tissue.tissue = tissue
  )
}
