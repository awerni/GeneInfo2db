getTissueMutation <- function() {
  
  project <- TCGAbiolinks::getGDCprojects()$project_id
  project <- grep("TCGA", project, value = TRUE)
  
  getData <- function(p) {
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
    res <- maf %>%
      dplyr::mutate(
        TISSUENAME = substr(Tumor_Sample_Barcode, 1, 15),
        DNAzygosity = t_alt_count / t_depth,
        AAMmutation = ifelse(Variant_Classification == "Silent", "wt", HGVSp_Short)
      ) %>%
      filter(!grepl(pattern = "(Flank)|(UTR)", Variant_Classification)) %>%
      dplyr::select(
        TISSUENAME,
        ENST = Transcript_ID,
        DNAmutation = HGVSc,
        AAMmutation,
        DNAzygosity
      )
    res %>% group_by(TISSUENAME, ENST) %>% summarise(
      DNAmutation = paste(DNAmutation, collapse = ";"),
      AAMmutation = paste(AAMmutation, collapse = ";"),
      DNAzygosity = max(DNAzygosity),
      .groups = "drop"
    ) %>% 
    as.data.frame()
  }
  
  res <- lapply(project, getData)
  
  list(
    tiff.processedSequence = dplyr::bind_rows(res)
  )
  
}