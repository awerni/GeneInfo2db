# https://gdc.cancer.gov/about-data/publications/PanCan-DDR-2018

getSigHRD <- function(sample_type){

  if (sample_type == 'cellline') {

    con <- getPostgresqlConnection()

    cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
      dplyr::filter(species == "human") |>
      dplyr::select(celllinename, depmap) |>
      dplyr::collect()

    RPostgres::dbDisconnect(con)

    # ------- download processed data
    url <- "https://raw.githubusercontent.com/shirotak/CellLine_HRD_DrugRes/main/processed_data/CCLE_broad.txt"
    file_Takamatsu2023 <- "CCLE_BroadInstitute.txt"
    if (!file.exists(file_Takamatsu2023)) {
      download.file(url, destfile = file_Takamatsu2023, method = "wget", quiet = FALSE)
    }
    Takamatsu2023 <- read.csv(file_Takamatsu2023, sep = "\t", na = "NaN", dec = ".")
    
    # ----------- extract precomputed HRD data
    res_HRD <- Takamatsu2023 |>
      dplyr::select(depmap = "DepMap_ID",
                    score = "HRD_score") |>
      dplyr::inner_join(cellline, by = "depmap") |>
      dplyr::filter(!is.na(score)) |>
      dplyr::select(celllinename, score) |>
      dplyr::mutate(signature = "HRD_cellline")
    
    signature_db <- data.frame(
      signature = "HRD_cellline",
      description = "HRD scores processed by Takamatsu et al. 2023 from depMap data",
      unit = "arbitrary units",
      hyperlink = "https://www.biorxiv.org/content/biorxiv/early/2023/07/07/2023.07.06.547853.full.pdf"
    )
    
    sig <- c(checkGeneSignature(signature_db),
             list(cellline.cellline2genesignature = res_HRD))
    sig
  } else if (sample_type == 'tissue') {

    # ------- download DDR data
    url <- "https://api.gdc.cancer.gov/data/5dd5a767-8f9f-4579-abee-b1306a4d0ad2"
    file_Knijnenburg2018 <- "TCGA_DDR_Data_Resources.xlsx"
    if (!file.exists(file_Knijnenburg2018)) {
      download.file(url, destfile = file_Knijnenburg2018, method = "wget", quiet = FALSE)
    }
    Knijnenburg2018 <- readxl::read_xlsx(file_Knijnenburg2018, sheet = "DDR footprints", skip = 3, na = "NaN")
    
    # ----------- extract precomputed HRD data
    res_HRD <- Knijnenburg2018 |>
      dplyr::select(tissuename = "TCGA sample barcode",
                    score = "HRD_Score") |>
      dplyr::filter(!is.na(score)) |>                  
      dplyr::mutate(signature = "HRD_tissue")
    
    signature_db <- data.frame(
      signature = "HRD_tissue",
      description = "HRD scores derived from Knijnenburg et al. 2018",
      unit = "arbitrary units",
      hyperlink = "https://gdc.cancer.gov/about-data/publications/PanCan-DDR-2018"
    )
    
    sig <- c(checkGeneSignature(signature_db),
             list(tissue.tissue2genesignature = res_HRD))
    sig
  } else {
    logger::log_error("invalid sample type")
  }
  return(sig)
}

#' @export
createCelllineSigHRD <- function(){
  getSigHRD("cellline")
}

#' @export
createTissueSigHRD <- function(){
  getSigHRD("tissue")
}