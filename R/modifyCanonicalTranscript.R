modifyCanonicalTranscript <- function() {
  con <- getPostgresqlConnection()
  
  sql <- paste0("SELECT ensg, enst, iscanonical FROM transcript ",
                "WHERE enst IN (SELECT distinct enst FROM cellline.processedsequence)")
  
  mut_enst <- DBI::dbGetQuery(con, sql)
  
  mut_enst2 <- mut_enst %>% group_by(ensg, iscanonical) %>%
    summarise(n = n(), .groups = "drop") %>%
    pivot_wider(ensg, names_from = "iscanonical", values_from = "n", values_fill = 0) %>%
    rename(canonical = 2, non_canonical = 3) %>%
    filter(canonical == 0 & non_canonical == 1)
  
  mut_enst3 <- mut_enst %>%
    filter(ensg %in% mut_enst2$ensg) %>%
    mutate(sql1 = paste0("UPDATE transcript SET iscanonical = FALSE WHERE ensg = '", ensg, "'"),
           sql2 = paste0("UPDATE transcript SET iscanonical = TRUE WHERE enst = '", enst, "'"))
  
  sapply(mut_enst3$sql1, function(s) DBI::dbExecute(con, s))
  sapply(mut_enst3$sql2, function(s) DBI::dbExecute(con, s))
  
  RPostgres::dbDisconnect(con)
  
  return(TRUE)
}
