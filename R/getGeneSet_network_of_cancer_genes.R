#' @export
getGeneSet_network_of_cancer_genes <- function() {
  con <- getPostgresqlConnection()

  gene_map <- tbl(con, "normchromentrezgene2ensemblgene") %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)
  # ---------------------------

  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "network_of_cancer_genes", "human"
  )

  geneassignment <-
    readr::read_tsv(paste0(getLocalFileRepo(), "/NCG_cancerdrivers_annotation_supporting_evidence.tsv")) |>
    dplyr::select(geneid = entrez) |>
    dplyr::distinct() |>
    dplyr::inner_join(gene_map, by = "geneid") |>
    dplyr::select(-geneid) |>
    dplyr::mutate(genesetname = "network_of_cancer_genes")

  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment
  )
}