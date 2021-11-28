getDrugComb <- function() {
  
  con <- getPostgresqlConnection()
  drug <- dplyr::tbl(con, dbplyr::in_schema("public", "drug"))  %>%
    dplyr::collect()
  RPostgres::dbDisconnect(con)
  
  dc_studies <- jsonlite::fromJSON("https://api.drugcomb.org/studies") %>%
    filter(sname == "ASTRAZENECA")
  
  dc_cl <- jsonlite::fromJSON("https://api.drugcomb.org/cell_lines")
  dc_drugs <- jsonlite::fromJSON("https://api.drugcomb.org/drugs")
  
  data <- getFileData("summary_v_1_5_update_with_drugIDs.csv") %>%
    filter(study_name == "ASTRAZENECA")
  
  dc_drug <- c(data$drug_col, data$drug_row) %>% unique()
  
  dc_drugs <- jsonlite::fromJSON("https://api.drugcomb.org/drugs") %>%
    filter(dname %in% dc_drug)  %>%
    arrange(dname, drugbank_id, kegg_id, synonyms, target_name, target_type) %>%
    group_by(dname) %>%
    slice(1) %>%
    ungroup()
  
  dc_cl <- jsonlite::fromJSON("https://api.drugcomb.org/cell_lines") %>%
    filter(name %in% unique(data$cell_line_name))
 
  dc_drugs2 <- dc_drugs %>%
    left_join(drug %>% select(drugid, scientificname), by = c("stitch_name" = "scientificname")) %>%
    left_join(drug %>% mutate(drugid2 = drugid) %>% select(drugid, drugid2), by = c("dname" = "drugid")) %>%
    mutate(drugid = ifelse(is.na(drugid), drugid2, drugid)) %>%
    select(-drugid2)
   
  dc_drug_mapper <- dc_drugs2 %>% select(dname, synonyms) %>% separate_rows(synonyms, sep = "; ") %>%
    unique() %>%
    left_join(drug %>% select(drugid, scientificname), by = c("synonyms" = "scientificname")) %>%
    mutate(synonyms = tolower(synonyms)) %>%
    left_join(drug %>% mutate(drugid3 = drugid, drugid2 = tolower(drugid)) %>% select(drugid3, drugid2), by = c("synonyms" = "drugid2")) %>%
    mutate(drugid = ifelse(is.na(drugid), drugid3, drugid)) %>%
    select(dname, drugid) %>%
    unique() %>%
    filter(!is.na(drugid))
  
  dc_drugs3 <- dc_drugs2 %>%
    left_join(dc_drug_mapper %>% rename(drugid2 = drugid), by = "dname") %>%
    mutate(drugid = ifelse(is.na(drugid), drugid2, drugid)) %>%
    select(-drugid2) %>%
    filter(!is.na(drugid))
    
  #(!is.na(dc_drugs3$drugid)) %>% table()
  
  
  data2 <- data %>%
    filter(drug_row %in% dc_drugs3$dname & drug_col %in% dc_drugs3$dname) %>%
    
 
}
  