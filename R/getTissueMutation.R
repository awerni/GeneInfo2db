getTissueMutation <- function(nCores = parallel::detectCores() / 2) {
  
  project <- TCGAbiolinks::getGDCprojects()$project_id
  project <- grep("TCGA", project, value = TRUE)
  
  getData <- function(p) {
    library(dplyr)
    query <- TCGAbiolinks::GDCquery(
      project = p, 
      data.category = "Simple Nucleotide Variation", 
      access = "open", 
      legacy = FALSE, 
      data.type = "Masked Somatic Mutation", 
      workflow.type = "Aliquot Ensemble Somatic Variant Merging and Masking"
    )
    
    TCGAbiolinks::GDCdownload(query)
    maf <- TCGAbiolinks::GDCprepare(query)
    maf %>%
      dplyr::mutate(
        TISSUENAME = substr(Tumor_Sample_Barcode, 1, 15),
        DNAzygosity = t_alt_count / t_depth
      ) %>%
      dplyr::select(
        TISSUENAME,
        ENST = Transcript_ID,
        DNAmutation = HGVSc,
        AAMmutation = HGVSp_Short,
        DNAzygosity
      )
  }
  
  if(nCores > 1) {
    cl <- parallel::makeCluster(nCores)
    res <- parallel::parLapply(cl, project, getData)
    parallel::stopCluster(cl)    
  } else {
    res <- lapply(project, getData)
  }
  
  list(
    tiff.processedSequence = dplyr::bind_rows(res)
  )
  
}