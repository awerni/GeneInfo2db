getMicrosatelliteStability <- function() {

  con <- getPostgresqlConnection()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()

  # alternative_celllinename <- dplyr::tbl(con, dbplyr::in_schema("cellline", "alternative_celllinename"))  %>%
  #   dplyr::select(celllinename, alternative_celllinename) %>%
  #   dplyr::collect() %>%
  #   unique()

  RPostgres::dbDisconnect(con)

  #------------------------------
  msi_data <- getFileData('msi')

  if (length(intersect(colnames(msi_data), c("CCLE (NGS)", "GDSC (PCR)"))) == 2) {
    msi_mapping <- data.frame(CCLE_NGS = 0:2, status = c(NA, "MSS", "MSI"), stringsAsFactors = FALSE)

    msi <- msi_data %>%
      as.data.frame() %>%
      tibble::rownames_to_column("depmap") %>%
      dplyr::inner_join(cellline, by = "depmap") %>%
      dplyr::rename(CCLE_NGS = `CCLE (NGS)`, GDSC_PCR = `GDSC (PCR)`) %>%
      dplyr::left_join(msi_mapping, by = "CCLE_NGS") %>%
      dplyr::mutate(dnaseqrunid = as.numeric(gsub("ACH-", "", depmap)))
  } else {

    msi <- msi_data %>%
      #left_join(alternative_celllinename, by = c("CCLE_ID" = "alternative_celllinename"))
      dplyr::select(celllinename = CCLE_ID, status = CCLE_MSI, GDSC_PCR = GDSC_MSI) %>%
      dplyr::inner_join(cellline, by = "celllinename") %>%
      dplyr::mutate(dnaseqrunid = as.numeric(gsub("ACH-", "", depmap))) %>%
      dplyr::mutate(status = ifelse(status %in% c("NA", "indeterminate"), NA, status))
  }

  dnaseqrun <- msi %>%
    dplyr::select(dnaseqrunid, celllinename) %>%
    dplyr::mutate(publish = TRUE)

  microsatelliteinstability <- msi %>%
    dplyr::filter(!is.na(status)) %>%
    dplyr::select(dnaseqrunid, microsatellite_stability_class = status)

  list(cellline.dnaseqrun = dnaseqrun,
       cellline.microsatelliteinstability = microsatelliteinstability)
}
