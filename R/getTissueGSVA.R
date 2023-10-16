#' Get Tissue Gene Set Variation Analysis (GSVA) Data
#' @return
#' A list containing the data frame with GSVA scores for hallmark gene sets
#' across different tissues.
#'
#' @export
#' 
getTissueGSVA <- function() {
  # ----------------------------
  con <- getPostgresqlConnection()

  sql <- paste0("SELECT gene_set, array_to_string(ensg_array, ',') AS ensg FROM public.msigdb ",
                "WHERE species = 'human' AND collection_name = 'hallmark'")
  msig <-  DBI::dbGetQuery(con, sql)
  gs <- stringr::str_split(msig$ensg, ",")
  names(gs) <- msig$gene_set

  my_ensg <- unlist(gs) %>% unique()

  hallmark_expr_matrix <- dplyr::tbl(con, dbplyr::in_schema("tissue", "processedrnaseqview")) %>%
    dplyr::filter(ensg %in% my_ensg) %>%
    dplyr::select(tissuename, ensg, counts) %>%
    dplyr::collect() %>%
    tidyr::pivot_wider(names_from = "tissuename", values_from = "counts") %>%
    tibble::column_to_rownames("ensg") %>%
    as.matrix()

  RPostgres::dbDisconnect(con)
  # ---------------------------

  gsva_result <- GSVA::gsva(hallmark_expr_matrix, gs) %>%
    as.data.frame() %>%
    tibble::rownames_to_column("gene_set") %>%
    tidyr::pivot_longer(!gene_set, names_to = "tissuename", values_to = "gsva")

  ssgsea_result <- GSVA::gsva(hallmark_expr_matrix, gs, method = "ssgsea") %>%
    as.data.frame() %>%
    tibble::rownames_to_column("gene_set") %>%
    tidyr::pivot_longer(!gene_set, names_to = "tissuename", values_to = "ssgsea")

  hallmarkscore <- gsva_result %>%
    dplyr::inner_join(ssgsea_result, by = c("gene_set", "tissuename"))

  list(tissue.hallmarkscore = hallmarkscore)
}