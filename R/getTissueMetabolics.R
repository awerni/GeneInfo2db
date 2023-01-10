getTissueMetabolics <- function(directory) {

  # (taken from shiny app described in https://doi.org/10.1186/s12943-018-0895-9)

  con <- getPostgresqlConnection()

  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue"))  %>%
    dplyr::filter(tumortype != "normal") %>%
    dplyr::select(patientname, tissuename) %>%
    dplyr::collect() %>%
    dplyr::filter()

  RPostgres::dbDisconnect(con)

  # ---------------

  files <- dir(path = directory, pattern = "*_metabolicsignatures.csv")

  all_data <- lapply(files, function(f) {
    readr::read_csv(paste0(directory, f)) %>%
    dplyr::rename(patientname = 1)
  }) %>% dplyr::bind_rows()

  all_data_long <- all_data %>%
    tidyr::pivot_longer(!patientname, names_to = "metabolic_pathway", values_to = "score") %>%
    dplyr::mutate(metabolic_pathway = gsub("REACTOME_", "", metabolic_pathway)) %>%
    dplyr::mutate(metabolic_pathway = gsub("_", " ", tolower(metabolic_pathway))) %>%
    dplyr::mutate(metabolic_pathway = gsub("rna", "RNA", metabolic_pathway)) %>%
    dplyr::inner_join(tissue, by = "patientname")

  # SANITY CHECK:
  # 60 patients have a 1-to-n mapping between patientname and tissuename
  all_data_long %>%
    dplyr::count(patientname) %>%
    dplyr::rename(mapping = n) %>%
    dplyr::count(mapping)

  list(
    tissue.metabolics = all_data_long %>% select(-patientname)
  )
}