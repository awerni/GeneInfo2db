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
  protein.quant.current.normalized <- getFileData('protein_quant_current_normalized')
  #normalized_protein_abundance <- getFileData("normalized_protein_abundance")
  #protein_IDs <- getFileData("protein_IDs")
  #sample_info <- getFileData("sample_info@proteome")
  
  # protein_long <- normalized_protein_abundance %>%
  #   as.data.frame() %>%
  #   tibble::rownames_to_column("depmap") %>%
  #   tidyr::pivot_longer(!depmap, names_to = "uniprot", values_to = "score") %>%
  #   dplyr::filter(!is.na(score)) %>%
  #   dplyr::inner_join(cellline, by = "depmap") %>%
  #   dplyr::select(-depmap) %>%
  #   dplyr::mutate(accession = gsub("(.*\\(|\\))", "", uniprot),
  #                 isoform = ifelse(grepl("-", accession), gsub(".*-", "", accession), "0")) %>%
  #   dplyr::mutate(isoform = as.numeric(isoform),
  #                 accession = gsub("-.*", "", accession)) %>%
  #   dplyr::inner_join(uniprotaccession, by = "accession") %>%
  #   dplyr::select(-uniprot)

  protein_long1 <- protein.quant.current.normalized %>%
    dplyr::select(accession = Uniprot_Acc, uniprotid = Uniprot, matches("TenPx..$")) %>% 
    tidyr::pivot_longer(!c(accession, uniprotid), names_to = "cellline_TenPx", values_to = "score") %>%
    dplyr::filter(!is.na(score)) %>%
    dplyr::mutate(celllinename = gsub("_TenPx..$", "", cellline_TenPx))
  
  double_filter1 <- protein_long1 %>%
    group_by(cellline_TenPx, celllinename) %>%
    summarise(n = n(), .groups = "drop")
  
  double_filter2 <- double_filter1 %>%
    dplyr::group_by(celllinename) %>%
    dplyr::summarise(n = n(), groups = "drop") %>%
    dplyr::filter(n > 1)
  
  double_filter3 <- double_filter1 %>%
    dplyr::filter(celllinename %in% double_filter2$celllinename) %>%
    dplyr::group_by(celllinename) %>%
    dplyr::slice_min(n, n = 1)
  
  protein_long <- protein_long1 %>%
    #dplyr::filter(!cellline_TenPx %in% double_filter3$cellline_TenPx) %>%
    dplyr::mutate(isoform = ifelse(grepl("-", accession), gsub(".*-", "", accession), "0")) %>%
    dplyr::mutate(isoform = as.numeric(isoform),
                  accession = gsub("-.*", "", accession)) %>%
    dplyr::filter(celllinename %in% cellline$celllinename) %>%
    dplyr::select(-cellline_TenPx) %>%
    group_by(celllinename, accession, uniprotid, isoform) %>%
    summarise(score = mean(score, na.rm = TRUE), .groups = "drop")

  #p1 <- protein_long %>% group_by(celllinename) %>% summarise(score = sum(score))
  #p2 <- protein_long2 %>% group_by(celllinename) %>% summarise(score = sum(score))
  #p1 %>% left_join(p2, by= "celllinename") %>% mutate(correct = score.x == score.y) %>% View()
  
  list(
    cellline.processedproteinmassspec = protein_long
  )
}