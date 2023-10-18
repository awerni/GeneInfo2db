#' @export
getGeneSet_TF <- function() {
  
  con <- getPostgresqlConnection()
  
  gene_id <- tbl(con, "entrezgene2ensemblgene") %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # ---------------------------
  
  TF <- getFileDownload("TFLink_Homo_sapiens.tsv.gz")
  
  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "transcription factors", "human"
  )
  
  geneassignment <-
    dplyr::as_tibble(TF) |>
    dplyr::select(NCBI.GeneID.TF) |>
    dplyr::distinct() |>
    dplyr::mutate(NCBI.GeneID.TF = str_split(NCBI.GeneID.TF, ";")) |>
    tidyr::unnest(NCBI.GeneID.TF) |>
    dplyr::filter(NCBI.GeneID.TF != "-") |>
    dplyr::mutate(NCBI.GeneID.TF = as.integer(NCBI.GeneID.TF)) |>
    dplyr::left_join(gene_id, by = c("NCBI.GeneID.TF" = "geneid")) |>
    dplyr::select(ensg) |>
    dplyr::distinct() |>
    dplyr::mutate(genesetname = "transcription factors")
  
  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment
  )
}
