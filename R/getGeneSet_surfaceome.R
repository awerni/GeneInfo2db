getGeneSet_surfaceome <- function() {

  con <- getPostgresqlConnection()

  gene <- tbl(con, "gene") %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(ensg) %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ---------------------------

  TCSA_data <- getFileData("TCSA_ensg.xlsx")

  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "surfaceome", "human"
  )

  geneassignment <-
    TCSA_data[, 1] %>%
    dplyr::select(ensg = 1) %>%
    dplyr::filter(ensg %in% gene$ensg) %>%
    dplyr::mutate(genesetname = "surfaceome")

  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment
  )
}