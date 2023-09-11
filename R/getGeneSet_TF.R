getGeneSet_TF <- function() {
  
  con <- getPostgresqlConnection()
  
  gene_id <- tbl(con, "entrezgene2ensemblgene") %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # ---------------------------
  
  TF <- getFileDownload("TFLink_Homo_sapiens.tsv.gz")
  
  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "TF", "human"
  )
  
  geneassignment <-
    dplyr::as_tibble(TF) |>
    dplyr::select(NCBI.GeneID.TF) |>
    base::unique() |>
    dplyr::mutate(NCBI.GeneID.TF = as.integer(NCBI.GeneID.TF)) |>
    dplyr::left_join(gene_id, by = c("NCBI.GeneID.TF"="geneid")) |>
    dplyr::select(ensg) |>
    stats::na.omit() |>
    dplyr::mutate(genesetname = "TF")
  
  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment
  )
}
