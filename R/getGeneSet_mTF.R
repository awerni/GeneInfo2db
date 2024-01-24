#' @export
getGeneSet_mTF <- function() {
  
  con <- getPostgresqlConnection()
  
  gene_name_id <- tbl(con, "entrezgene") |>
    dplyr::collect()
  gene_id_ensg <- tbl(con, "entrezgene2ensemblgene") |>
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # ---------------------------
  
  url <- "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8612691/bin/sciadv.abf6123_tables_s1_to_s14.zip"
  temp <- tempfile()
  download.file(url, temp)
  mTF <- readxl::read_xlsx(unzip(temp, exdir = "tmp/Reddy_al_2022_sup_material.xlsx"), sheet=6, skip = 2)
  
  unlink(temp)
  
  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "master transcription factors", "human"
  )
  
  geneassignment <- mTF |>
    dplyr::select(`Candidate MTF`) |>
    dplyr::distinct() |>
    dplyr::left_join(gene_name_id, by = c("Candidate MTF"="symbol")) |>
    dplyr::left_join(gene_id_ensg, by = "geneid") |>
    dplyr::select(ensg) |>
    dplyr::distinct() |>
    dplyr::mutate(genesetname = "master transcription factors")
  
  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment
  )
}
