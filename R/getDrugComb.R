getDrugComb <- function() {
  
  con <- getPostgresqlConnection()
  drug <- dplyr::tbl(con, dbplyr::in_schema("public", "drug"))  %>%
    dplyr::collect()
  RPostgres::dbDisconnect(con)
  
  dc_studies <- jsonlite::fromJSON("https://api.drugcomb.org/studies") %>%
    filter(sname == "ASTRAZENECA")
  
  dc_cl <- jsonlite::fromJSON("https://api.drugcomb.org/cell_lines")
  dc_drugs <- jsonlite::fromJSON("https://api.drugcomb.org/drugs")
  
  data <- getFileData("summary_v_1_5_update_with_drugIDs.csv")
  
}
  