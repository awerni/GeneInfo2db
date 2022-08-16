getTCGAProteomicsRPPA <- function() {
  
  con <- getPostgresqlConnection()
  
  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  %>%
    select(tissuename) %>%
    dplyr::collect()
  
  antibody <-
    dplyr::tbl(con, dbplyr::in_schema("public", "antibody"))  %>%
    dplyr::collect() %>%
    mutate(antibody_coarse = toupper(gsub("[-()_ ]", "", antibody))) %>%
    mutate(antibody_coarse = ifelse(
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
    mutate(antibody_coarse = toupper(gsub("[-()_ ]", "", `Ab Name Reported on Dataset`))) %>%
    mutate(antibody_coarse = ifelse(
      grepl("^[0-9]", antibody_coarse),
      paste0("X", antibody_coarse),
      antibody_coarse
    ))
  
  antibody_mapping <- additional_TCGA_antibodies %>%
    bind_rows(antibody) %>%
    select(antibody, antibody_coarse)
  
  url <- "https://tcpaportal.org/tcpa/download/TCGA-PANCAN32-L4.zip"
  temp <- tempfile()
  download.file(url, temp)
  data <- read_csv(unz(temp, "tmp/TCGA-PANCAN32-L4.csv"))
  unlink(temp)
  
  ab_data_long <- data %>% 
    select(-Cancer_Type, -Sample_Type) %>%
    pivot_longer(!Sample_ID, names_to = "antibody_coarse", values_to = "score") %>%
    filter(!is.na(score)) %>%
    mutate(tissuename = substring(Sample_ID, 1, 15)) %>%
    select(-Sample_ID) %>%
    filter(tissuename %in% tissue$tissuename) %>%
    mutate(antibody_coarse = toupper(gsub("[-()_ ]", "", antibody_coarse))) %>%
    left_join(antibody_mapping, by = "antibody_coarse") %>%
    filter(!is.na(antibody)) %>%
    select(-antibody_coarse)
  
  list(
    public.antibody = additional_TCGA_antibodies %>% select(-antibody_coarse),
    tissue.processedproteinexpression = ab_data_long
  )
}