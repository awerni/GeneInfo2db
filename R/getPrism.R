getPrism <- function() {
  
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # -----------------------------------
  
  prism_data <- getTaiga("secondary-dose-response-curve-parameters")
  
  prism_drugs <- prism_data %>% 
    dplyr::select(name, moa, target, indication, smiles) %>% 
    unique() %>%
    dplyr::mutate(scientificname = name, commonname = NA) %>%
    dplyr::rename(drugid = name) %>%
    dplyr::filter(!is.na(drugid))
  
  prism_data2 <- prism_data %>%
    dplyr::select(-moa, -target, -disease.area, -indication, -phase, -smiles, -row_name, -ccle_name) %>%
    dplyr::filter(passed_str_profiling, !is.na(name)) %>%
    dplyr::arrange(desc(r2)) %>%
    dplyr::group_by(depmap_id, name) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::inner_join(cellline, by = c("depmap_id" = "depmap")) %>%
    dplyr::mutate(campaign = 'Prism', proliferationtest = "PRISM") %>%
    dplyr::rename(actarea = auc, drugid = name, top = upper_limit, bottom = lower_limit) %>%
    dplyr::mutate(actarea = 1 - actarea) %>%
    dplyr::select(-broad_id, -depmap_id, -screen_id, -passed_str_profiling, -r2) %>%
    dplyr::mutate(ec50 = ifelse(ec50 > 1e5 | ec50 < 1e-5, NA, ec50), ic50 = ifelse(ic50 > 1e5 | ic50 < 1e-5, NA, ic50))
  
  list(public.drug = prism_drugs,
       cellline.doseresponsecurve = prism_data2)
}