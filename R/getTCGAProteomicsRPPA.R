getTCGAProteomicsRPPA <- function() {
  
  con <- getPostgresqlConnection()
  
  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  %>%
    dplyr::select(tissuename) %>%
    dplyr::collect()
  
  antibody <-
    dplyr::tbl(con, dbplyr::in_schema("public", "antibody"))  %>%
    dplyr::collect() %>%
    dplyr::mutate(antibody_coarse = toupper(gsub("[-()_ ]", "", antibody))) %>%
    dplyr::mutate(antibody_coarse = ifelse(
      grepl("^[0-9]", antibody_coarse),
      paste0("X", antibody_coarse),
      antibody_coarse
    ))
  
  RPostgres::dbDisconnect(con)
  
  #------------------------
  mda_file <- paste0("https://www.mdanderson.org/content/dam/mdanderson/",
                     "documents/core-facilities/Functional%20Proteomics%20RPPA",
                     "%20Core%20Facility/RPPA_Expanded_Ab_List_Updated.xlsx")

  file_rppa <- "RPPA_Expanded_Ab_List_Updated.xlsx"
  if (!file.exists(file_rppa)) {
    download.file(mda_file, destfile = file_rppa, method = "curl", quiet = TRUE)
  }
  
  ### process
  rppa_ab <- readxl::read_excel(file_rppa, sheet = 17, skip = 6) %>%
    dplyr::mutate(antibody_coarse = toupper(gsub("[-()_ ]", "", `Ab Name Reported on Dataset`))) %>%
    dplyr::mutate(antibody_coarse = ifelse(
      grepl("^[0-9]", antibody_coarse),
      paste0("X", antibody_coarse),
      antibody_coarse
    ))
  
  additional_TCGA_antibodies <- rppa_ab %>%
    dplyr::filter(!antibody_coarse %in% antibody$antibody_coarse) %>%
    dplyr::select(antibody = 3, validation_status = `Validation Status*`,
           vendor = Company, catalog_number = `Catalog #`,
           antibody_coarse) %>%
    dplyr::filter(!is.na(antibody))
  
  antibody_mapping <- additional_TCGA_antibodies %>%
    bind_rows(antibody) %>%
    dplyr::select(antibody, antibody_coarse)
  
  url <- "https://tcpaportal.org/tcpa/download/TCGA-PANCAN32-L4.zip"
  temp <- tempfile()
  download.file(url, temp)
  data <- read_csv(unz(temp, "tmp/TCGA-PANCAN32-L4.csv"))
  
  unlink(temp)
  
  ab_data_long <- data %>% 
    dplyr::select(-Cancer_Type, -Sample_Type) %>%
    tidyr::pivot_longer(!Sample_ID, names_to = "antibody_coarse", values_to = "score") %>%
    dplyr::filter(!is.na(score)) %>%
    dplyr::mutate(tissuename = substring(Sample_ID, 1, 15)) %>%
    dplyr::select(-Sample_ID) %>%
    dplyr::filter(tissuename %in% tissue$tissuename) %>%
    dplyr::mutate(antibody_coarse = toupper(gsub("[-()_ ]", "", antibody_coarse))) %>%
    dplyr::left_join(antibody_mapping, by = "antibody_coarse") %>%
    dplyr::filter(!is.na(antibody)) %>%
    dplyr::select(-antibody_coarse)
  
  list(
    public.antibody = additional_TCGA_antibodies %>% select(-antibody_coarse),
    tissue.processedproteinexpression = ab_data_long
  )
}
