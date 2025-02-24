#' @export
getCelllineProteomicsMassSpec <- function() {

  con <- getPostgresqlConnection()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
    dplyr::filter(species == "human") |>
    dplyr::select(celllinename, depmap) |>
    dplyr::collect()

  uniprotaccession <- dplyr::tbl(con, "uniprotaccession") |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # -------------------------
  dfile <- "protein_quant_current_normalized.csv.gz"
  protein.quant.current.normalized <- getFileData(dfile)

  protein_long <- protein.quant.current.normalized |>
    dplyr::select(accession = Uniprot_Acc, uniprotid = Uniprot, matches("TenPx..$")) |>
    tidyr::pivot_longer(!c(accession, uniprotid), names_to = "cellline_TenPx", values_to = "score") |>
    dplyr::filter(!is.na(score)) |>
    dplyr::mutate(celllinename = gsub("_TenPx..$", "", cellline_TenPx)) |>
    dplyr::mutate(isoform = ifelse(grepl("-", accession), gsub(".*-", "", accession), "0")) |>
    dplyr::mutate(isoform = as.numeric(isoform),
                  accession = gsub("-.*", "", accession)) |>
    dplyr::filter(celllinename %in% cellline$celllinename) |>
    dplyr::select(-cellline_TenPx) |>
    dplyr::group_by(celllinename, accession, uniprotid, isoform) |>
    dplyr::summarise(score = mean(score, na.rm = TRUE), .groups = "drop")

  list(
    cellline.processedproteinmassspec = protein_long
  )
}
