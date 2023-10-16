#' Get Tissue Signaling Pathway Data
#'
#' This function retrieves signaling pathway data for specific tissues.
#'
#' @return a list
#'
#' @export
#' 
getTissueSignalingPathway <- function() {

  con <- getPostgresqlConnection()

  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  %>%
    dplyr::select(tissuename) %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ------------------------------------------

  url <- "https://www.cell.com/cms/10.1016/j.cell.2018.03.035/attachment/4c206a11-2a3e-461a-8707-d60a47ca5750/mmc4.xlsx"
  file_sanches_vega2018 <- "sanches_vega2018_supplemental_table4.xlsx"
  if (!file.exists(file_sanches_vega2018)) {
    download.file(url, destfile = file_sanches_vega2018, method = "wget", quiet = TRUE)
  }

  sanches_vega2018 <- readxl::read_xlsx(file_sanches_vega2018, sheet = 3, na = "NA") %>%
    dplyr::rename(tissuename = SAMPLE_BARCODE) %>%
    dplyr::rename(cell_cycle = `Cell Cycle`, rtk_ras = `RTK RAS`, tgf_beta = `TGF-Beta`) %>%
    dplyr::rename_all(tolower) %>%
    dplyr::mutate_if(is.numeric, as.logical) %>%
    dplyr::filter(tissuename %in% tissue$tissuename)

  list(
    tissue.signaling_pathway = sanches_vega2018
  )

}