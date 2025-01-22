#' @export
getGeneSet_network_of_cancer_genes <- function() {
  con <- getPostgresqlConnection()

  gene_map <- tbl(con, "normchromentrezgene2ensemblgene") |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)
  # ---------------------------

  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "network_of_cancer_genes", "human"
  )

  res <- httr::POST(
    url = "http://www.network-cancer-genes.org/download.php", 
    body = list(downloadcancergenes = "Download"), 
    encode = "form",
    httr::timeout(30)
  )
  if (res$status_code != 200){
    stop("Could not download file from network-cancer-genes.org")
  }
  raw_df <- httr::content(
    x = res, 
    type = "text/tab-separated-values" # uses readr::read_tsv function to parse the content
  )
  
  geneassignment <-
    raw_df |>
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
