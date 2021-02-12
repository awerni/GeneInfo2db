getMicrosatelliteStability <- function() {
  
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  #------------------------------
  
  msi_mapping <- data.frame(CCLE_NGS = 0:2, status = c(NA, "MSS", "MSI"), stringsAsFactors = FALSE)
  
  msi <- getTaiga('msi') %>%
    as.data.frame() %>%
    tibble::rownames_to_column("depmap") %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::rename(CCLE_NGS = `CCLE (NGS)`, GDSC_PCR = `GDSC (PCR)`) %>%
    dplyr::left_join(msi_mapping, by = "CCLE_NGS") %>%
    dplyr::mutate(dnaseqrunid = as.numeric(gsub("ACH-", "", depmap)))
  
  dnaseqrun <- msi %>%
    dplyr::select(dnaseqrunid, celllinename) %>%
    dplyr::mutate(publish = TRUE)
  
  microsatelliteinstability <- msi %>%
    dplyr::filter(!is.na(status)) %>%
    dplyr::select(dnaseqrunid, microsatellite_stability_class = status)
  
  list(cellline.dnaseqrun = dnaseqrun,
       cellline.microsatelliteinstability = microsatelliteinstability)
}