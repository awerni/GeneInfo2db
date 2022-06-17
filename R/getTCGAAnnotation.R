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
  #project <- project[1:5]

  subtypes <- TCGAbiolinks::PanCancerAtlas_subtypes()

  data <- lapply(project, function(p) {
      print(paste("processing", p))
      clin <- TCGAbiolinks::GDCquery_clinic(p, "Clinical") %>%
        select(patientname = submitter_id, 
              vital_status, 
              days_to_birth, 
              days_to_death,
              days_to_last_followup = days_to_last_follow_up,
              days_to_last_known_alive = days_to_last_known_disease_status,
              gender, 
              race, 
              ethnicity, 
              organ = tissue_or_organ_of_origin,
              site_of_resection_or_biopsy,
              prior_treatment,
              disease,
              primary_diagnosis,
              contains("weight"),
              contains("height"),
              starts_with("ajcc_pathologic")) %>%
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

      getTissuename <- function(q) substr(q$results[[1]]$cases, 1, 15) %>% unique()

      t1 <- getTissuename(query1)
      t2 <- getTissuename(query2)
      t3 <- getTissuename(query3)
      t4 <- getTissuename(query4)

      tissuesample <- data.frame(
        tissuename = unique(c(t1, t2, t3, t4))
      ) %>%
        mutate(patientname = substr(tissuename, 1, 12),
               Code = substr(tissuename, 14, 15)) %>%
        left_join(clin, by = "patientname") %>%
        left_join(TCGA_study, by = "project") %>%
        left_join(TCGA_sample_type, by = "Code") %>%
        left_join(subtypes, by = c("patientname" = "pan.samplesID")) %>%
        mutate(vendorname = "TCGA", 
               species = "human")

      patient <- clin %>%
        select(patientname, vital_status, days_to_birth, gender, race, ethnicity, 
               days_to_last_followup, days_to_last_known_alive, days_to_death)

      tissue <- tissuesample %>%
        filter(Short_Letter_Code != "NB") %>%
        rename(stage = ajcc_pathologic_stage) %>%
        mutate(tumortype_adjacent = ifelse(grepl("Normal", Definition), tumortype, NA), 
               tumortype = ifelse(grepl("Normal", Definition), "normal", tumortype),
               grade = paste(ajcc_pathologic_t, ajcc_pathologic_n, ajcc_pathologic_m),
               stage = gsub("Stage ", "", stage)) %>%
        select(tissuename,
               vendorname,
               species,
               organ,
               tumortype,
               patientname,
               tumortype_adjacent,
               stage,
               grade
        )

      list(
        patient = patient,
        tissue = tissue
      )
    }
  )
  
  res <- list(
    tissue.patient = lapply(data, '[[', 1) %>% bind_rows(), 
    tissue.tissue = lapply(data, '[[', 2) %>% bind_rows()
  )
}




