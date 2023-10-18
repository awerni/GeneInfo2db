#' @export
getCelllineMetabolomics <- function() {

  con <- getPostgresqlConnection()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ---------------

  CCLE.metabolomics <- getFileData("CCLE_metabolomics_20190502")

  if ("matrix" %in% class(CCLE.metabolomics)) {
    CCLE.metabolomics <- CCLE.metabolomics %>%
      as.data.frame() %>%
      tibble::rownames_to_column("depmap")
  } else {
    CCLE.metabolomics <- CCLE.metabolomics %>%
      dplyr::rename(depmap = DepMap_ID) %>%
      dplyr::select(-CCLE_ID)
  }

  CCLE.metabolomics <- CCLE.metabolomics %>%
    tidyr::pivot_longer(!depmap, names_to = "metabolite", values_to = "score") %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::select(-depmap) %>%
    dplyr::distinct(celllinename, metabolite, .keep_all = TRUE)

  metabolites <- CCLE.metabolomics %>% select(metabolite) %>% unique()

  list(cellline.metabolite = metabolites,
       cellline.processedmetabolite = CCLE.metabolomics)

}
