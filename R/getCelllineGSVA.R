getCelllineGSVA <- function() {
  # ----------------------------
  con <- getPostgresqlConnection()

  sql <- paste0("SELECT gene_set, array_to_string(ensg_array, ',') AS ensg FROM public.msigdb ",
                "WHERE species = 'human' AND collection_name = 'hallmark'")
  msig <-  DBI::dbGetQuery(con, sql)
  gs <- stringr::str_split(msig$ensg, ",")
  names(gs) <- msig$gene_set

  my_ensg <- unlist(gs) %>% unique()

  hallmark_expr_matrix <- dplyr::tbl(con, dbplyr::in_schema("cellline", "processedrnaseqview")) %>%
    dplyr::filter(ensg %in% my_ensg) %>%
    dplyr::select(celllinename, ensg, counts) %>%
    dplyr::collect() %>%
    tidyr::pivot_wider(names_from = "celllinename", values_from = "counts") %>%
    tibble::column_to_rownames("ensg") %>%
    as.matrix()

  RPostgres::dbDisconnect(con)
  # ---------------------------

  gsva_result <- GSVA::gsva(hallmark_expr_matrix, gs) %>%
    as.data.frame() %>%
    tibble::rownames_to_column("gene_set") %>%
    tidyr::pivot_longer(!gene_set, names_to = "celllinename", values_to = "gsva")

  ssgsea_result <- GSVA::gsva(hallmark_expr_matrix, gs, method = "ssgsea") %>%
    as.data.frame() %>%
    tibble::rownames_to_column("gene_set") %>%
    tidyr::pivot_longer(!gene_set, names_to = "celllinename", values_to = "ssgsea")

  hallmarkscore <- gsva_result %>%
    dplyr::inner_join(ssgsea_result, by = c("gene_set", "celllinename"))

  list(cellline.hallmarkscore = hallmarkscore)
}
