# https://gdc.cancer.gov/about-data/publications/PanCan-DDR-2018

getSigHRD <- function(){

  # ------- download DDR data
  url <- "https://api.gdc.cancer.gov/data/5dd5a767-8f9f-4579-abee-b1306a4d0ad2"
  file_Knijnenburg2018 <- "TCGA_DDR_Data_Resources.xlsx"
  if (!file.exists(file_Knijnenburg2018)) {
    download.file(url, destfile = file_Knijnenburg2018, method = "wget", quiet = FALSE)
  }
  Knijnenburg2018 <- readxl::read_xlsx(file_Knijnenburg2018, sheet = "DDR footprints", skip = 3, na = "NaN")
  
  # ----------- extract precomputed HRD data
  res_HRD <- Knijnenburg2018 %>%
    dplyr::select(tissuename = "TCGA sample barcode",
                  score = "HRD_Score") |>
    dplyr::mutate(signature = "HRD")
  
  signature_db <- data.frame(
    signature = "HRD",
    description = "HRD scores derived from Knijnenburg et al. 2018",
    unit = "arbitrary units",
    hyperlink = "https://gdc.cancer.gov/about-data/publications/PanCan-DDR-2018"
  )
  
  sig <- c(checkGeneSignature(signature_db),
           list(dbtable = res_HRD))
  names(sig)[names(sig) == "dbtable"] <- "tissue.tissue2genesignature"
  sig
  
}

createTissueSigHRD <- function(){
  getSigHRD()
}
  


