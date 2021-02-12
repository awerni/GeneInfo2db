getProteomicsMassSpec <- function() {
  
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()
  
  uniprotaccession <- dplyr::tbl(con, "uniprotaccession") %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # -------------------------
  #protein.quant.current.normalized <-getFileData('protein_quant_current_normalized')
  normalized_protein_abundance <- getFileData("normalized_protein_abundance")
  #protein_IDs <- getFileData("protein_IDs")
  #sample_info <- getFileData("sample_info@proteome")
  
  protein_long <- normalized_protein_abundance %>%
    as.data.frame() %>%
    tibble::rownames_to_column("depmap") %>%
    tidyr::pivot_longer(!depmap, names_to = "uniprot", values_to = "score") %>%
    dplyr::filter(!is.na(score)) %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::select(-depmap) %>%
    dplyr::mutate(accession = gsub("(.*\\(|\\))", "", uniprot),
                  isoform = ifelse(grepl("-", accession), gsub(".*-", "", accession), "0")) %>%
    dplyr::mutate(isoform = as.numeric(isoform),
                  accession = gsub("-.*", "", accession)) %>%
    dplyr::inner_join(uniprotaccession, by = "accession") %>%
    dplyr::select(-uniprot)
 
  list(
    cellline.processedproteinmassspec = protein_long
  )
}