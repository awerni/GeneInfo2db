checkGeneSignature <- function(check_signature) {
  con <- getPostgresqlConnection()
  
  db_signature <- dplyr::tbl(con, "genesignature") |>
    dplyr::collect() |>
    dplyr::filter(signature == check_signature$signature)
  
  RPostgres::dbDisconnect(con)
  
  # -------------------------
  if (nrow(db_signature) == 0) return(list(public.genesignature = check_signature))
  
  if (all.equal(tibble::as_tibble(check_signature), tibble::as_tibble(db_signature))) {
    list()
  } else {
    logger::log_error("{check_signature$signature} signature description is different to database")
  }
}