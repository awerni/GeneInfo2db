getCelllineMutation <- function() {
  con <- getPostgresqlConnection()

  transcript <- dplyr::tbl(con, "transcript") %>%
    dplyr::inner_join(dplyr::tbl(con, "gene"), by = "ensg") %>% 
    dplyr::filter(species == "human")  %>% 
    dplyr::select(enst) %>%
    dplyr::collect()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human")  %>% 
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  DepMap.mutations <- getFileData("OmicsSomaticMutations")

  DepMap.mutations2 <- DepMap.mutations %>%
    mutate(Transcript = gsub("\\..*$", "", Transcript)) |>
    dplyr::rename(depmap = ModelID, enst = Transcript) %>%
    dplyr::filter(VariantInfo != "SILENT") %>%
    dplyr::mutate(dnazyg = AltCount/(AltCount+RefCount),
                  rnazyg = NA) %>%
    dplyr::group_by(depmap, enst) %>%
    dplyr::summarize(dnamutation = paste(DNAChange, collapse = ";"),
                     aamutation = paste(ProteinChange, collapse = ";"),
                     dnazygosity = ifelse(!all(is.na(dnazyg)), max(dnazyg, na.rm = TRUE), NA),
                     rnazygosity = ifelse(!all(is.na(rnazyg)), max(rnazyg, na.rm = TRUE), NA)) %>%
    dplyr::ungroup() %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::filter(enst %in% transcript$enst) %>%
    dplyr::select(celllinename, enst, dnamutation, aamutation, dnazygosity, rnazygosity)

  list(cellline.processedsequence = DepMap.mutations2)
}