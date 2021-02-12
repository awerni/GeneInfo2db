getMetabolomics <- function() {
  
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # ---------------
  
  CCLE.metabolomics <- getFileData("CCLE_metabolomics_20190502") %>%
    as.data.frame() %>%
    tibble::rownames_to_column("depmap") %>%
    tidyr::pivot_longer(!depmap, names_to = "metabolite", values_to = "score") %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::select(-depmap) %>%
    dplyr::distinct(celllinename, metabolite, .keep_all = TRUE)
  
  metabolites <- CCLE.metabolomics %>% select(metabolite) %>% unique()
  
  list(cellline.metabolite = metabolites,
       cellline.processedmetabolite = CCLE.metabolomics)
  
}