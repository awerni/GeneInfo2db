getTissueMutation <- function() {
  
  con <- getPostgresqlConnection()
  
  transcript <- dplyr::tbl(con, dbplyr::in_schema("public", "transcript"))  %>%
    select(enst, ensg) %>%
    dplyr::filter(grepl("ENST", enst)) %>%
    dplyr::collect()
  
  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  %>%
    select(tissuename) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # ---------------
  
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
        tissuename = substr(Tumor_Sample_Barcode, 1, 15),
        dnazygosity = t_alt_count / t_depth,
        aammutation = ifelse(Variant_Classification == "Silent", "wt", HGVSp_Short)
      ) %>%
      filter(!grepl(pattern = "(Flank)|(UTR)", Variant_Classification)) %>%
      dplyr::select(
        tissuename,
        enst = Transcript_ID,
        dnamutation = HGVSc,
        aammutation,
        dnazygosity
      )
    res %>% group_by(tissuename, enst) %>% summarise(
      dnamutation = paste(dnamutation, collapse = ";"),
      aamutation = paste(aammutation, collapse = ";"),
      dnazygosity = max(dnazygosity),
      .groups = "drop"
    ) %>%
    as.data.frame()
  }
  
  mut <- lapply(project, getData) %>%
    dplyr::bind_rows() %>%
    filter(enst %in% transcript$enst) %>%
    filter(tissuename %in% tissue$tissuename)
  
  list(
    tissue.processedsequence = mut
  )
}