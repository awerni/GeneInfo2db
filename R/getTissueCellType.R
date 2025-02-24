#' Get Tissue Cell Type Data
#' @export
#' 
getTissueCellType <- function() {

  con <- getPostgresqlConnection()

  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  |>
    dplyr::select(tissuename) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ---------------

  url <- "https://xcell.ucsf.edu/xCell_TCGA_RSEM.txt"
  file_xcell2017 <- "xCell_TCGA_RSEM.txt"
  if (!file.exists(file_xcell2017)) {
    download.file(url, destfile = file_xcell2017, method = "curl", quiet = TRUE)
  }

  ### process
  xcell2017 <- readr::read_tsv(file_xcell2017) |>
    dplyr::rename(celltype = 1)

  xcell2017_long <- xcell2017 |>
    tidyr::pivot_longer(!celltype, names_to = "tissuename", values_to = "score") |>
    dplyr::mutate(tissuename = gsub("\\.", "-", tissuename)) |>
    dplyr::filter(tissuename %in% tissue$tissuename)

  list(
    tissue.immunecelldeconvolution = xcell2017_long
  )
  
}