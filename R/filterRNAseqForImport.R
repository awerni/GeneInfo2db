#' @export
filterForRNAseqImport <- function(db_tables) {

  con <- getPostgresqlConnection()

  ti <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  |>
    dplyr::select(tissuename) |>
    dplyr::collect() |>
    dplyr::pull(tissuename)

  pa <- dplyr::tbl(con, dbplyr::in_schema("tissue", "patient"))  |>
    dplyr::select(patientname) |>
    dplyr::collect() |>
    dplyr::pull(patientname)

  e <-  dplyr::tbl(con, dbplyr::in_schema("public", "gene"))  |>
    dplyr::select(ensg) |>
    dplyr::collect()

  r <- dplyr::tbl(con, dbplyr::in_schema("tissue", "rnaseqrun"))  |>
    dplyr::select(rnaseqrunid) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ---------------

  # (1) check if tissues and patients are not already in the DB and remove overlap

  if (!is.null(db_tables$tissue.tissue)) {
    db_tables$tissue.tissue <- db_tables$tissue.tissue |>
      dplyr::filter(!tissuename %in% ti)

    ti2 <- db_tables$tissue.tissue |> pull(tissuename)
    ti <- c(ti, ti2)
    if (nrow(db_tables$tissue.tissue) == 0) db_tables$tissue.tissue <- NULL
  }

  if (!is.null(db_tables$tissue.patient)) {
    db_tables$tissue.patient <- db_tables$tissue.patient |>
      dplyr::filter(!patientname %in% pa)

    pa2 <- db_tables$tissue.patient |> pull(patientname)
    pa <- c(pa, pa2)
    if (nrow(db_tables$tissue.patient) == 0) db_tables$tissue.patient <- NULL
  }

  # (2) check if all tissues and patients are either in the list or in the DB

  missing_ti <- setdiff(db_tables$tissue.tissue$tissuename, ti) |> length()
  missing_pa <- setdiff(db_tables$tissue.patient$patientname, pa) |> length()

  if (missing_ti > 0) logger::log_error(paste(missing_ti, "tissues are missing"))
  if (missing_pa > 0) logger::log_error(paste(missing_pa, "patients are missing"))

  # (3) remove all ensg, which are not in the db

  e2 <- unique(db_tables$tissue.processedrnaseq$ensg)
  n_e <- setdiff(e2, e$ensg) |> length()

  if (n_e > 0) {
    logger::log_info(paste(n_e, "ENSGs are missing in the DB"))
    db_tables$tissue.processedrnaseq <- db_tables$tissue.processedrnaseq |>
      dplyr::filter(ensg %in% e$ensg)
  }

  # (4) remove all rnaseqrun, which are already in the db
  r2 <- db_tables$tissue.rnaseqrun$rnaseqrunid
  n_r <- intersect(r$rnaseqrunid, r2) |> length()

  if (n_r > 0) {
    logger::log_info(paste(n_r, "RNAseq runs are already in the DB"))

    if (length(db_tables$tissue.rnaseqrun$rnaseqrunid) == n_r) {
      db_tables$tissue.rnaseqrun <- NULL
    } else {
      db_tables$tissue.rnaseqrun <- db_tables$tissue.rnaseqrun |>
        dplyr::filter(!rnaseqrunid %in% r$rnaseqrunid)
    }
  }

  # (5) remove all expression values, which are already in the db
  con <- getPostgresqlConnection()
  g <- dplyr::tbl(con, dbplyr::in_schema("tissue", "processedrnaseq"))  |>
    dplyr::group_by(rnaseqrunid) |>
    dplyr::summarize(n = n()) |>
    dplyr::filter(rnaseqrunid %in% r2) |>
    dplyr::collect()
  RPostgres::dbDisconnect(con)

  if (any(g$n > 0)) {
    g <- g |> dplyr::filter(n > 0)
    logger::log_info(paste(g$n |> sum(), "expression values from", nrow(g), "rnaseqruns are already in the DB"))

    db_tables$tissue.processedrnaseq <- db_tables$tissue.processedrnaseq |>
      dplyr::filter(!rnaseqrunid %in% g$rnaseqrunid)

    if (nrow(db_tables$tissue.processedrnaseq) == 0) db_tables$tissue.processedrnaseq <- NULL
  }

  # return correct table list
  db_tables

}