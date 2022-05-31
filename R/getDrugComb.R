getDrugComb <- function() {
  
  con <- getPostgresqlConnection()
  drug <- dplyr::tbl(con, dbplyr::in_schema("public", "drug"))  %>%
    dplyr::collect()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human")  %>% 
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
    filter(name %in% unique(data$cell_line_name)) #%>%
    #mutate_all(na_if(., "NA"))
 
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
  
  dc_cellline_mapper <- dc_cl %>%
    left_join(cellline %>% select(celllinename, cellosaurus), by = c("cellosaurus_accession" = "cellosaurus")) %>%
    rename(celllinename1 = celllinename) %>%
    left_join(cellline %>% select(celllinename, depmap), by = c("depmap_id" = "depmap")) %>%
    mutate(celllinename = ifelse(is.na(celllinename), celllinename1, celllinename )) %>%
    select(-celllinename1) %>%
    rename(celllinename1 = celllinename) %>%
    left_join(cellline %>% select(celllinename, cell_model_passport), by = c("cell_model_passport_id" = "cell_model_passport")) %>%
    mutate(celllinename = ifelse(is.na(celllinename), celllinename1, celllinename )) %>%
    select(name, celllinename) %>%
    filter(!is.na(celllinename))
  
  data2 <- data %>%
    filter(drug_row %in% dc_drugs3$dname & drug_col %in% dc_drugs3$dname) %>%
    inner_join(dc_cellline_mapper, by = c("cell_line_name" = "name"))
  
  geomean <- function(x) 2^(mean(log2(x)))
  
  data_single_row <- data2 %>%
    select(dname = drug_row, celllinename, ri_row, ic50_single = ic50_row) %>%
    mutate(actarea_single = ri_row/100) %>%
    inner_join(dc_drug_mapper, by = "dname") %>%
    select(-ri_row, -dname) 
    
  data_single_col <- data2 %>%
    select(dname = drug_col, celllinename, ri_col, ic50_single = ic50_col) %>%
    mutate(actarea_single = ri_col/100) %>%
    inner_join(dc_drug_mapper, by = "dname") %>%
    select(-ri_col, -dname) 
  
  lab <- "Astra Zeneca"
  camp <- "ASTRAZENECA_combi"
  
  data_single <- data_single_row %>%
    bind_rows(data_single_col) %>%
    group_by(celllinename, drugid) %>%
    summarise(ic50 = geomean(ic50_single), actarea = mean(actarea_single), .groups = "drop") %>%
    mutate(campaign = camp, proliferationtest = "SytoxGreen", laboratory = lab)
  
  data_combi <- data2 %>%
    inner_join(dc_drug_mapper, by = c("drug_col" = "dname")) %>%
    rename(drugid1 = drugid) %>%
    inner_join(dc_drug_mapper, by = c("drug_row" = "dname")) %>%
    rename(drugid2 = drugid) %>%
    mutate(d = if_else(drugid2 < drugid1, drugid2, drugid1)) %>%
    mutate(drugid2 = if_else(drugid2 == d, drugid1, drugid2)) %>%
    mutate(drugid1 = d) %>%
    select(celllinename, drugid1, drugid2, synergy_bliss) %>%
    group_by(celllinename, drugid1, drugid2) %>%
    summarise(combo6 = mean(synergy_bliss), .groups = "drop") %>%
    mutate(campaign = camp, proliferationtest = "SytoxGreen", laboratory = lab)
  
  list(
    cellline.campaign = tibble(campaign = "ASTRAZENECA_combi", campaigndesc = "Astra Zeneca drug combination screen"),
    public.laboratory = tibble(laboratory = lab),
    cellline.processedproliftest = data_single,
    cellline.processedcombiproliftest = data_combi
  )
}
  
