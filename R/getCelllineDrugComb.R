#' @export
getCelllineDrugComb <- function() {

  con <- getPostgresqlConnection()
  drug <- dplyr::tbl(con, dbplyr::in_schema("public", "drug"))  %>%
    dplyr::collect()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human")  %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # -----------------------------------

  dc_studies <- jsonlite::fromJSON("https://api.drugcomb.org/studies") %>%
    dplyr::filter(sname == "ASTRAZENECA")

  dc_cl <- jsonlite::fromJSON("https://api.drugcomb.org/cell_lines")
  dc_drugs <- jsonlite::fromJSON("https://api.drugcomb.org/drugs")

  data <- getFileData("summary_v_1_5_update_with_drugIDs.csv") %>%
    dplyr::filter(study_name == "ASTRAZENECA")

  dc_drug <- c(data$drug_col, data$drug_row) %>% unique()

  dc_drugs <- jsonlite::fromJSON("https://api.drugcomb.org/drugs") %>%
    dplyr::filter(dname %in% dc_drug)  %>%
    dplyr::arrange(dname, drugbank_id, kegg_id, synonyms, target_name, target_type) %>%
    dplyr::group_by(dname) %>%
    slice(1) %>%
    ungroup()

  dc_cl <- jsonlite::fromJSON("https://api.drugcomb.org/cell_lines") %>%
    dplyr::filter(name %in% unique(data$cell_line_name)) #%>%
    #mutate_all(na_if(., "NA"))

  dc_drugs2 <- dc_drugs %>%
    dplyr::left_join(drug %>% select(drugid, scientificname), by = c("stitch_name" = "scientificname")) %>%
    dplyr::left_join(drug %>% mutate(drugid2 = drugid) %>% select(drugid, drugid2), by = c("dname" = "drugid")) %>%
    dplyr::mutate(drugid = ifelse(is.na(drugid), drugid2, drugid)) %>%
    dplyr::select(-drugid2)

  dc_drug_mapper <- dc_drugs2 %>% select(dname, synonyms) %>% separate_rows(synonyms, sep = "; ") %>%
    unique() %>%
    dplyr::left_join(drug %>% select(drugid, scientificname), by = c("synonyms" = "scientificname")) %>%
    dplyr::mutate(synonyms = tolower(synonyms)) %>%
    dplyr::left_join(drug %>% mutate(drugid3 = drugid, drugid2 = tolower(drugid)) %>%
    dplyr::select(drugid3, drugid2), by = c("synonyms" = "drugid2")) %>%
    dplyr::mutate(drugid = ifelse(is.na(drugid), drugid3, drugid)) %>%
    dplyr::select(dname, drugid) %>%
    unique() %>%
    dplyr::filter(!is.na(drugid))

  dc_drugs3 <- dc_drugs2 %>%
    dplyr::left_join(dc_drug_mapper %>% rename(drugid2 = drugid), by = "dname") %>%
    dplyr::mutate(drugid = ifelse(is.na(drugid), drugid2, drugid)) %>%
    dplyr::select(-drugid2) %>%
    dplyr::filter(!is.na(drugid))

  #(!is.na(dc_drugs3$drugid)) %>% table()

  dc_cellline_mapper <- dc_cl %>%
    dplyr::left_join(cellline %>% select(celllinename, cellosaurus), by = c("cellosaurus_accession" = "cellosaurus")) %>%
    dplyr::rename(celllinename1 = celllinename) %>%
    dplyr::left_join(cellline %>% select(celllinename, depmap), by = c("depmap_id" = "depmap")) %>%
    dplyr::mutate(celllinename = ifelse(is.na(celllinename), celllinename1, celllinename )) %>%
    dplyr::select(-celllinename1) %>%
    dplyr::rename(celllinename1 = celllinename) %>%
    dplyr::left_join(cellline %>% select(celllinename, cell_model_passport), by = c("cell_model_passport_id" = "cell_model_passport")) %>%
    dplyr::mutate(celllinename = ifelse(is.na(celllinename), celllinename1, celllinename )) %>%
    dplyr::select(name, celllinename) %>%
    dplyr::filter(!is.na(celllinename))

  data2 <- data %>%
    dplyr::filter(drug_row %in% dc_drugs3$dname & drug_col %in% dc_drugs3$dname) %>%
    dplyr::inner_join(dc_cellline_mapper, by = c("cell_line_name" = "name"))

  geomean <- function(x) 2^(mean(log2(x)))

  data_single_row <- data2 %>%
    dplyr::select(dname = drug_row, celllinename, ri_row, ic50_single = ic50_row) %>%
    dplyr::mutate(actarea_single = ri_row/100) %>%
    dplyr::inner_join(dc_drug_mapper, by = "dname") %>%
    dplyr::select(-ri_row, -dname)

  data_single_col <- data2 %>%
    dplyr::select(dname = drug_col, celllinename, ri_col, ic50_single = ic50_col) %>%
    dplyr::mutate(actarea_single = ri_col/100) %>%
    dplyr::inner_join(dc_drug_mapper, by = "dname") %>%
    dplyr::select(-ri_col, -dname)

  lab <- "Astra Zeneca"
  camp <- "ASTRAZENECA_combi"

  data_single <- data_single_row %>%
    dplyr::bind_rows(data_single_col) %>%
    dplyr::group_by(celllinename, drugid) %>%
    dplyr::summarise(ic50 = geomean(ic50_single), actarea = mean(actarea_single), .groups = "drop") %>%
    dplyr::mutate(campaign = camp, proliferationtest = "SytoxGreen", laboratory = lab)

  data_combi <- data2 %>%
    dplyr::inner_join(dc_drug_mapper, by = c("drug_col" = "dname")) %>%
    dplyr::rename(drugid1 = drugid) %>%
    dplyr::inner_join(dc_drug_mapper, by = c("drug_row" = "dname")) %>%
    dplyr::rename(drugid2 = drugid) %>%
    dplyr::mutate(d = if_else(drugid2 < drugid1, drugid2, drugid1)) %>%
    dplyr::mutate(drugid2 = if_else(drugid2 == d, drugid1, drugid2)) %>%
    dplyr::mutate(drugid1 = d) %>%
    dplyr::select(celllinename, drugid1, drugid2, synergy_bliss) %>%
    dplyr::group_by(celllinename, drugid1, drugid2) %>%
    dplyr::summarise(combo6 = mean(synergy_bliss), .groups = "drop") %>%
    dplyr::mutate(campaign = camp, proliferationtest = "SytoxGreen", laboratory = lab)

  list(
    cellline.campaign = tibble(campaign = "ASTRAZENECA_combi", campaigndesc = "Astra Zeneca drug combination screen"),
    public.laboratory = tibble(laboratory = lab),
    cellline.processedproliftest = data_single,
    cellline.processedcombiproliftest = data_combi
  )
}
