modifyCanonicalTranscript <- function() {
  con <- getPostgresqlConnection()
  
  sql <- paste0("SELECT t ensg, enst, iscanonical FROM transcript ",
                "WHERE enst IN (SELECT distinct enst FROM cellline.processedsequence)")
  
  mut_enst <- DBI::dbGetQuery(con, sql)
  
  mut_enst2 <- mut_enst %>% group_by(ensg, iscanonical) %>%
    summarise(n = n()) %>%
    pivot_wider(ensg, names_from = "iscanonical", values_from = "n", values_fill = 0) %>%
    rename(canonical = 2, non_canonical = 3) %>%
    filter(canonical == 0 & non_canonical == 1) %>%
    mutate(sql = paste0("UPDATE transcript SET iscanonical = TRUE WHERE enst = '", enst, "'"))
  
  sapply(mut_enst2$sql, function(s) DBI::dbGetQuery(con, s))
  
  RPostgres::dbDisconnect(con)
  
  return(TRUE)
}