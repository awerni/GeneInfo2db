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
        select(patientname = submitter_id, 
              vital_status, 
              days_to_birth, 
              days_to_death,
              days_to_last_followup = days_to_last_follow_up,
              gender, 
              race, 
              ethnicity, 
              tissue_or_organ_of_origin,
              prior_treatment,
              disease,
              primary_diagnosis,
              contains("weight"),
              contains("height"),
              starts_with("ajcc_pathologic")) %>%
        mutate(project = p)
             
      query <- TCGAbiolinks::GDCquery(
        project = p,
        data.category = "Transcriptome Profiling",
        data.type = "miRNA Expression Quantification",
        legacy = FALSE
      )
      
      tissue <- data.frame(
        tissuename = substr(query$results[[1]]$sample.submitter_id, 1, 15) %>% unique(),
        project = p
      ) %>%
        mutate(patientname = substr(tissuename, 1, 12))
      
      list(
        clin = clin,
        tissue = tissue
      )
    }
  )
  
  res <- list(
    tissue.patient = lapply(data, '[[', 1) %>% bind_rows(), 
    tissue.tissue = lapply(data, '[[', 2) %>% bind_rows()
  )
}




