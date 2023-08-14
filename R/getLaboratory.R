getLaboratory <- function(lab) {
  con <- getPostgresqlConnection()

  laboratory <- dplyr::tbl(con, "laboratory") |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # -------------------------
  if (lab %in% laboratory$laboratory) {
    list()
  } else {
    list(public.laboratory = data.frame(laboratory = lab))
  }
}
